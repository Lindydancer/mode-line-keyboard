;;; mode-line-keyboard-test.el --- Tests for `mode-line-keyboard'.  -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Anders Lindgren

;; Author: Anders Lindgren
;; URL: https://github.com/Lindydancer/mode-line-keyboard

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Tests for mode-line-keyboard.el

;; Unfortunately, the most features of Mode Line Keyboard must be
;; tested interactively, so it's hard to test then using automatic
;; regression tests.  This file contains some test automatic tests for
;; primitive functions and the section "Interactive Testing" below
;; lists some manual steps that is valuable to test.

;; Interactive Testing:
;;
;; The following steps should be performed in both a GUI Emacs, in one
;; running in a plain terminal, and in Termux running on an android
;; touch device.
;;
;; `M-x mode-line-keyboard-mode RET' should enable it in the current
;; buffer.  Running it again should disable it.
;;
;; `M-x mode-line-keyboard-global-mode RET' should enable it in all
;; modes.  Running it again should disable it in all modes.
;;
;; Enable it and click the `KB>' label.  The mode line should turn
;; into a keyboard with a `1/2' label and letters.  The header line
;; should contain a number of special labels and digits.
;;
;; Clicking on a character should insert it.  Clicking on the echo
;; area should insert a space.  Characters should be inserted even if
;; the mode or header line does not belong to the selected window, or
;; if the user edits the mode line.
;;
;; Click repeatedly and fast on a character (i.e. double and triple
;; clicks) and ensure that each click result in an inserted character.
;;
;; Type, say, C-x on the real keyboard followed by, say "o", on the
;; mode line keyboard should select the other window.
;;
;; Clicking the `1/2' label should step to the next keyboard line.
;; When clicking on the last line, `2/2', the mode line should return
;; to the first.
;;
;; Evaluating `(read-key)' and then clicking on the mode line keyboard
;; should return the corresponding ASCII code. (E.g. `97' for `a'.)
;;
;; Insert a few characters and type `C-x u' (`undo'). Check that all
;; the inserted characters are undone at once.  (Currently, this is
;; not true for spaces.)
;;
;; C-x (on the keyboard) then 4 . on the virtual keyboard.  (This
;; should run `xref-find-definitions-other-window'.)
;;
;; Click on the "KB>" icon and check that the mode line and header
;; line change.  Ensure that the window position doesn't shift, unless
;; the point is on the first window line.  Step through the lines.
;; When the keyboard is hidden the window content should not move,
;; unless the top of the buffer is visible.

;;; Code:

(require 'ert)

;; ------------------------------------------------------------
;; Modifiers
;;

(ert-deftest mode-line-keyboard-test-modifiers ()
  (should (eq (mode-line-keyboard-apply-modifier ?a 'shift) ?A))
  (should (eq (mode-line-keyboard-apply-modifier ?A 'shift) ?A))
  (should (eq (mode-line-keyboard-apply-modifier ?ä 'shift) ?Ä))
  (should (eq (mode-line-keyboard-apply-modifier ?Ä 'shift) ?Ä))
  ;;
  (should (eq (mode-line-keyboard-apply-modifier ?a 'control) ?\C-A))
  (should (eq (mode-line-keyboard-apply-modifier ?A 'control) ?\C-A))
  ;; Note: ?\C-ä and ?\C-Ä evaluates to 132, maybe this function
  ;; should return that? If so, does that apply to non-latin-1
  ;; characters as well?
  (should (eq (mode-line-keyboard-apply-modifier ?ä 'control)
              (logior ?ä (ash 1 26))))
  (should (eq (mode-line-keyboard-apply-modifier ?Ä 'control)
              (logior ?Ä (ash 1 26))))
  ;; Meta (Super, Hyper, and Alt work the same way).
  (should (eq (mode-line-keyboard-apply-modifier ?a 'meta) ?\M-a))
  (should (eq (mode-line-keyboard-apply-modifier ?A 'meta) ?\M-A))
  (should (eq (mode-line-keyboard-apply-modifier ?ä 'meta) ?\M-ä))
  (should (eq (mode-line-keyboard-apply-modifier ?Ä 'meta) ?\M-Ä))
  nil)

(provide 'mode-line-keyboard-test)

;;; mode-line-keyboard-test.el ends here
