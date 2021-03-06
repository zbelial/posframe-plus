;; posframe-plus.el --- You can set up active map for posframe easily.  -*- lexical-binding: t; -*-

;; Filename: posframe-plus.el
;; Description: You can set up active map for posframe easily
;; Author:  zbelial <zjyzhaojiyang@gmail.com>
;; Maintainer:  zbelial <zjyzhaojiyang@gmail.com>
;; Copyright (C) 2020, zbelial, all rights reserved.
;; Created: 2020-09-04 14:08:12
;; Version: 0.1
;; URL: https://github.com/zbelial/posframe-plus
;; Keywords:
;; Compatibility: GNU Emacs 27.0.50
;;
;; Features that might be required by this library:
;;
;; Please check README
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

(require 'cl-lib)
(require 'posframe)


(defvar posframe-plus-active-map
  (let ((keymap (make-sparse-keymap)))
    keymap)
  "Keymap that is enabled when showing a posframe.")

(defvar posframe-plus--last-point 0
  "Hold last point when show tooltip, use for hide tooltip after move point.")
(defvar posframe-plus--last-scroll-offset 0
  "Hold last scroll offset when show tooltip, use for hide tooltip after window scroll.")

(defvar-local posframe-plus--buffer-or-name nil)

(defvar-local posframe-plus--keymap nil)

(defvar-local posframe-plus--timeout-timer nil
  "Record the timer to deal with timeout argument of `posframe-plus-show'.")

(defvar posframe-plus-emulation-alist '((t . nil)))

(defun posframe-plus-enable-overriding-keymap (keymap)
  (posframe-plus-uninstall-map)
  (setq posframe-plus--keymap keymap))

(defun posframe-plus-ensure-emulation-alist ()
  (unless (eq 'posframe-plus-emulation-alist (car emulation-mode-map-alists))
    (setq emulation-mode-map-alists
          (cons 'posframe-plus-emulation-alist
                (delq 'posframe-plus-emulation-alist emulation-mode-map-alists)))))

(defun posframe-plus-install-map ()
  (unless (or (cdar posframe-plus-emulation-alist)
              (null posframe-plus--keymap))
    (setf (cdar posframe-plus-emulation-alist) posframe-plus--keymap)))

(defun posframe-plus-uninstall-map ()
  (setf (cdar posframe-plus-emulation-alist) nil))

(defun posframe-plus-activate-map (keymap)
  (posframe-plus-ensure-emulation-alist)
  (posframe-plus-enable-overriding-keymap keymap)
  (posframe-plus-install-map)
  )

(defun posframe-plus-deactivate-map()
  (posframe-plus-uninstall-map))


(defun posframe-plus-hide-frame ()
  (interactive)
  (when posframe-plus--buffer-or-name
    (posframe-hide posframe-plus--buffer-or-name)
    (posframe-plus-deactivate-map)
    (remove-hook 'post-command-hook 'posframe-plus-hide-after-move)
    )
  )

(defun posframe-plus-hide-after-move ()
  (ignore-errors
    (when (get-buffer posframe-plus--buffer-or-name)
      (unless (and
               (equal (point) posframe-plus--last-point)
               (equal (window-start) posframe-plus--last-scroll-offset))
        (posframe-plus-hide-frame)))))

(defun posframe-plus--run-timeout-timer (posframe secs)
  "Hide POSFRAME after a delay of SECS seconds."
  (when (and (numberp secs) (> secs 0))
    (when (timerp posframe-plus--timeout-timer)
      (cancel-timer posframe-plus--timeout-timer))
    (setq-local posframe-plus--timeout-timer
                (run-with-timer
                 secs nil #'posframe-plus-deactivate-map))))

(cl-defun posframe-plus-show (buffer-or-name enable-ctrl-g hide-after-move
                                             &key
                                             string
                                             position
                                             poshandler
                                             width
                                             height
                                             min-width
                                             min-height
                                             x-pixel-offset
                                             y-pixel-offset
                                             left-fringe
                                             right-fringe
                                             internal-border-width
                                             internal-border-color
                                             font
                                             foreground-color
                                             background-color
                                             respect-header-line
                                             respect-mode-line
                                             respect-tab-line
                                             initialize
                                             no-properties
                                             keep-ratio
                                             lines-truncate
                                             override-parameters
                                             timeout
                                             refresh
                                             accept-focus
                                             hidehandler
                                             &allow-other-keys)
  "Pop up a posframe and show STRING at POSITION.
If enable-ctrl-g is t, pressing `Ctrl-g' will hide the posframe.
If hide-after-move is t, after moving point, the posframe will hide.
"
  (let (to posframe)

    (posframe-plus-hide-frame)

    (setq posframe-plus--buffer-or-name buffer-or-name)

    (if enable-ctrl-g
        (define-key posframe-plus-active-map (kbd "C-g") 'posframe-plus-hide-frame)
      (define-key posframe-plus-active-map (kbd "C-g") nil))
    (posframe-plus-activate-map posframe-plus-active-map)

    (setq posframe-plus--last-point (point))
    (setq posframe-plus--last-scroll-offset (window-start))

    (setq posframe (posframe-show buffer-or-name
                                  :string string
                                  :position position
                                  :poshandler poshandler
                                  :width width
                                  :height height
                                  :min-width min-width
                                  :min-height min-height
                                  :x-pixel-offset x-pixel-offset
                                  :y-pixel-offset y-pixel-offset
                                  :left-fringe left-fringe
                                  :right-fringe right-fringe
                                  :internal-border-width internal-border-width
                                  :internal-border-color internal-border-color
                                  :font font
                                  :foreground-color foreground-color
                                  :background-color background-color
                                  :respect-header-line respect-header-line
                                  :respect-mode-line respect-mode-line
                                  :respect-tab-line respect-tab-line
                                  :initialize initialize
                                  :no-properties no-properties
                                  :keep-ratio keep-ratio
                                  :lines-truncate lines-truncate
                                  :override-parameters override-parameters
                                  :timeout timeout
                                  :refresh refresh
                                  :accept-focus accept-focus
                                  :hidehandler hidehandler
                                  ))

    (setq to (funcall posframe-arghandler buffer-or-name :timeout timeout))
    (posframe-plus--run-timeout-timer posframe to)
    
    (if hide-after-move
        (add-hook 'post-command-hook 'posframe-plus-hide-after-move)
      (remove-hook 'post-command-hook 'posframe-plus-hide-after-move))
    )
  )

(provide 'posframe-plus)
