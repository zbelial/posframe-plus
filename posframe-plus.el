;; posframe-plus.el --- TODO.  -*- lexical-binding: t; -*-

;; Filename: posframe-plus.el
;; Description: TODO
;; Author:  zbelial <zjyzhaojiyang@gmail.com>
;; Maintainer:  zbelial <zjyzhaojiyang@gmail.com>
;; Copyright (C) 2020, zbelial, all rights reserved.
;; Created: 2020-09-04 14:08:12
;; Version: 0.1
;; URL: https://github.com/zbelial/posframe-plus.el
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

(require 'posframe)

(defcustom posframe-plus-hide-after-move t
  "When non-nil, hide posframe when moving cursor."
  :group 'posframe-plus
  :type 'boolean)

(defvar posframe-plus-last-point 0
  "Hold last point when show tooltip, use for hide tooltip after move point.")
(defvar posframe-plus-last-scroll-offset 0
  "Hold last scroll offset when show tooltip, use for hide tooltip after window scroll.")


(defvar-local posframe-plus-keymap nil)

(defvar posframe-plus-emulation-alist '((t . nil)))

(defun posframe-plus-enable-overriding-keymap (keymap)
  (posframe-plus-uninstall-map)
  (setq posframe-plus-keymap keymap))

(defun posframe-plus-ensure-emulation-alist ()
  (unless (eq 'posframe-plus-emulation-alist (car emulation-mode-map-alists))
    (setq emulation-mode-map-alists
          (cons 'posframe-plus-emulation-alist
                (delq 'posframe-plus-emulation-alist emulation-mode-map-alists)))))

(defun posframe-plus-install-map ()
  (unless (or (cdar posframe-plus-emulation-alist)
              (null posframe-plus-keymap))
    (setf (cdar posframe-plus-emulation-alist) posframe-plus-keymap)))

(defun posframe-plus-uninstall-map ()
  (setf (cdar posframe-plus-emulation-alist) nil))

(defun posframe-plus-activate-map (keymap)
  (posframe-plus-ensure-emulation-alist)
  (posframe-plus-enable-overriding-keymap keymap)
  (posframe-plus-install-map)
  )

(defun posframe-plus-deactivate-map()
  (posframe-plus-uninstall-map))


(provide 'posframe-plus)
