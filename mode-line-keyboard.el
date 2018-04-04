;;; mode-line-keyboard.el --- Use the mode line as keyboard (for touch screens)

;; Copyright (C) 2017-2018  Anders Lindgren

;; Author: Anders Lindgren
;; Keywords: convenience
;; Version: 0.0.0
;; Created: 2017-12-01
;; Package-Requires: ((emacs "26.0"))
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

;; This package turns the header and mode lines into a keyboard.  This
;; is mainly intended to be used in environments without a normal
;; keyboard, such as touch devices.  Concretely, the Android
;; application "Termux" provides a Linux terminal environment that
;; includes a terminal version of Emacs.
;;
;; NOTE: This is an "early release" intended to be tested by a small
;; audience.  Please, DO NOT add it to package archives like Melpa --
;; I will do that once this package has gotten some mileage.

;; Activate:
;;
;; Enable the mode in a single buffer using:
;;
;;     M-x mode-line-keyboard-mode RET
;;
;; For all buffers use:
;;
;;     M-x mode-line-keyboard-global-mode RET
;;
;; Alternatively, add the following line to your init file:
;;
;;     (mode-line-keyboard-global-mode 1)

;; Usage:
;;
;; When enabled, the mode line contains the string `KB>'.  If you
;; click on it, the header will look like:
;;
;;     1/4 SHFT CTRL META SPC TAB RET <X X> 1 2 3 4 5 6 7 8 9 0
;;
;; And the mode line will look like:
;;
;;     1/2 a b c d e f g h ...
;;
;; To type on the keyboard, simply click on the characters, modifiers,
;; and special keys.
;;
;; The `1/4' indicates that this is one of four lines -- clicking on
;; it display the next line.  In the mode line, clicking on the last
;; line hides the Mode Line Keyboard -- you can click on the `KB>' to
;; display it again.
;;
;; Clicking in the echo area inserts a space (unless the minibuffer is
;; active).
;;
;; To avoid accidental point movement when the Mode Line Keyboard is
;; visible, you have to double click to move the point, triple click
;; to mark a word etc.

;; Dependencies:
;;
;; This package require Emacs 26.  In earlier Emacs versions, plain
;; typing works OK.  However, when typing something more complex like
;; `C-x C-f', the function `read-key-sequence-vector' raises the error
;; `args-out-of-range'.

;; Tips:
;;
;; When Emacs is used in a terminal, the `header-line' face by default
;; has the `:underline' property set.  As many terminal environments
;; today provide many colors, this doesn't look good, and it makes it
;; hard to distinguish between characters like `.' and `,'.
;;
;; You can override this by using something like:
;;
;;     (deftheme my-theme "Theme to make the header line more readable.")
;;     (custom-theme-set-faces
;;       'my-theme
;;       '(header-line ((((class color)) :inherit mode-line))))

;; Customization:
;;
;; The variables `mode-line-keyboard-header-line-content' and
;; `mode-line-keyboard-mode-line-content' control what should be
;; displayed in the header and mode lines, respectively.
;;
;; They are lists, and each entry in the list corresponds to one
;; concrete line.
;;
;; Each entry can be one of the following:
;;
;;   * `integer' -- A character
;;   * `(:range integer integer)' -- A range of characters
;;   * `(integer label)' -- A character, but display "label".
;;   * `(:shift integer integer)' -- A character and its shifted counterpart.
;;   * `(:toggle var func label)' -- A modifier (like `control').
;;   * `(func label)' -- Call `func' when "label" is clicked.
;;   * `:keyword' -- Looked up in `mode-line-keyboard-template-list'.
;;
;; The variable `mode-line-keyboard-template-list' is a list.  Each
;; element is a list starting with a keyword followed by one or more
;; items that this keyword is substituted for.

;; Notes:
;;
;; When this package in used, `mouse-movement' events are suppressed.
;; Normally, this is not a problem.  Without this, clicking on `ESC'
;; on the Mode Line Keyboard and subsequently moving the mouse would
;; trigger an error that `ESC <mouse-movement>' is undefined.  (Note,
;; this happens when moving the mouse after pressing `ESC' on the
;; keyboard as well, however, in practice this is seldom an issue in
;; that context.)

;; Known problems:
;;
;; * In Termux, sometimes (especially at startup), clicking in the
;;   echo area to insert a space doesn't work (instead the message
;;   "Minibuffer window is not active").  It appears as though Termux
;;   sends the `ESC ... M' sequence (down mouse) but not `ESC ... m'
;;   (up mouse) -- or that Emacs doesn't pick it up.  (To test this,
;;   click in the echo area and then `C-h l'.)
;;
;; * When clicking on a label such as `CTRL' or `KB>', this package
;;   calls `read-key' recursively.  This mean that if you repeatedly,
;;   say, show and hide the keyboard, many times you could run out of
;;   call stack.  (All calls return once you have typed a key.)  In
;;   practice, This should not be a problem, unless you are the
;;   nervous type.
;;
;; * Inserting a space by clicking in the echo are result in a undo
;;   event by itself.  This is probably due to that there are two
;;   events seen by Emacs, one `down' event and one `up'.  (It would
;;   probably be possible to fix this by "swallowing" the down event,
;;   as done by other keys.)
;;
;; * When typing fast it's easy to accidentally move the point.  (When
;;   the Mode Line Keyboard is visible, the user must double-click to
;;   move the point.  However, when typing fast the clicks are
;;   double-clicks, and if the click is outside the mode or header
;;   line, the double click will move the point.)

;; Future ideas:
;;
;; * Caps lock support, at least for shift, but maybe for all
;;   modifiers.
;;
;; * Today, it's possible to step through a number of keyboard lines.
;;   Howevever, there are no reasons to limit the layout to lines.
;;   One could imagine a tree structure, where some labels on the mode
;;   or header line would open new sublayouts.  This could be used,
;;   for example, to open a dedicated meny for parentheses or to
;;   support accented characters.
;;
;; * Allow layouts to be major-mode specific.  For example, when
;;   writing C, curly braces maybe should be accessible than when
;;   writing Lisp.
;;
;; * Provide a convenient mechanism for theme packages.  (I can't wait
;;   to see the kind of layouts users might come up with.)
;;
;; * Better support for automatic detection and adaptation to native
;;   languages (e.g. swedish -- which is my native langugage -- we has
;;   three extra letter å, ä, and ö).

;; Implementation:
;;
;; This package adds key binding for things `mode-line mouse-1' to
;; `input-decode-map'.  These bindings convert the events to plain
;; keys, or perform some other kind of action.  The header- and
;; mode-line strings used by Mode Line Keyboard has the property
;; `mode-line-keyboard-action'.  When the property is a vector
;; (typically containing a key) it is returned.  When it's a function,
;; it is called, this is for example used by the entries that add
;; modifiers.
;;
;; Some of the Mode Line Keyboard functions call `read-key'.  This
;; will in turn tunnel whatever they read through `input-decode-map',
;; which could cause Mode Line Keyboard functions to be called.  This
;; could, of course, mean that the same function is called in a
;; bizarre kind of recursive way.
;;
;; In some cases, this package tries to silence events.  This is done
;; by calling `read-key' and returning the next event.

;; Personal note:
;;
;; When I first started writing this package I though it would be
;; "easy pick", and I planned to spend an evening or two one it.  Boy,
;; was I wrong.  The Emacs event system turned out to be very complex,
;; and it took a lot of time and energy to try to understand how it
;; works.  In addition, I ran into numerous bugs in Emacs along the
;; way.
;;
;; In order to understand what happens when a key is pressed or when
;; something is clicked, I wrote the package `keymap-logger' that
;; instruments a number of system keymaps and log the result.

;; Tips:
;;
;; When Emacs is used in a terminal, the `header-line' face by default
;; has the `:underline' property set.  As many terminal environments
;; today provide many colors, this doesn't look good, and it makes it
;; hard to distinguish between characters like `.' and `,'.
;;
;; You can override this by using something like:
;;
;;     (deftheme my-theme "Theme to make the header line more readable.")
;;     (custom-theme-set-faces
;;       'my-theme
;;       '(header-line ((((class color)) :inherit mode-line))))

;;; Code:

;; TODO:
;;
;; Ponder if there is a more natural way to layout the keys.
;;
;; Make alternative, non utf-8, arrows. (Is it possible to check if a
;; display support utf-8. Is is possible to render different things in
;; different frames?)
;;
;; Make it optional what should happen when clicking in the echo area
;; (currently, a space is inserted).
;;
;; Make it optional how normal clicks should behave: No
;; change. Require an extra click (which is currently hardwired), or
;; disable point movement all together.
;;
;; Make the modifier implementation less repetitious.
;;
;; Make the -template-list and -content variables customizable.


;; ------------------------------------------------------------

(defgroup mode-line-keyboard nil
  "Turn the header and mode lines into a keyboard, useful for touch devices."
  :group 'convenience)


(defface mode-line-keyboard-selected-modifier
  '((t :inverse-video t))
  "Face highlight modifiers in the header or mode line."
  :group 'mode-line-keyboard)


(defvar mode-line-keyboard--saved-mode-line-format nil)
(make-variable-buffer-local 'mode-line-keyboard--saved-mode-line-format)
(defvar mode-line-keyboard--saved-header-line-format nil)
(make-variable-buffer-local 'mode-line-keyboard--saved-header-line-format)

(defvar mode-line-keyboard--inhibit-tranform nil
  "When non-nil, don't transform events.

This is used internally to inhibit transform when events are read
using `read-key' from within remapping functions.")


;; Forward reference, to keep the compiler happy.
(defvar mode-line-keyboard-visible-mode)


;; ------------------------------------------------------------
;; Log support.
;;

;; When the package `keymap-logger' is loaded, this adds extra
;; information to its log.

(defun mode-line-keyboard-log (format-string &rest args)
  "Log FORMAT-STRING, substituting ARGS, like `format'.

When Keymap Logger mode isn't enabled, this function no nothing."
  (when (fboundp 'keymap-logger-log)
    (apply #'keymap-logger-log format-string args)))


(defun mode-line-keyboard-read-key (&rest args)
  "Like `read-key', but with log support.

All arguments, ARGS, are passed to `read-key'.

When the package Keymap Logger is present, log the call and the
return value."
  (if (fboundp 'keymap-logger-apply)
      (keymap-logger-apply #'read-key args)
    (apply #'read-key args)))


(defun mode-line-keyboard-funcall (func &rest args)
  "Call FUNC with ARGS like `funcall', with optional logging.

When Keymap Logger mode is enabled, log the call to FUNC and the
return value."
  (if (fboundp 'keymap-logger-apply)
      (keymap-logger-apply func args)
    (apply func args)))


(defun mode-line-keyboard-read-key-ignore-mouse-movement (&optional prompt)
  "Like `mode-line-keyboard-read-key' but ignore `mouse-movement' events.

PROMPT is passed to to `read-key'."
  (force-mode-line-update)
  (let (key)
    (while (progn
             (setq key (mode-line-keyboard-read-key prompt))
             (eq (event-basic-type key) 'mouse-movement)))
    key))


;; ------------------------------------------------------------
;; Event handling
;;

(defun mode-line-keyboard-eventp (event &optional down)
  "Non-nil if EVENT is from the Mode Line Keyboard.

When DOWN is nil, check if EVENT is the \"up\" event.  When
non-nil, check if it's the \"down\" event.

The actual return value is the value of the property
`mode-line-keyboard-action'."
  (and (eq (event-basic-type event) 'mouse-1)
       (memq (car event)
             (if down
                 '(down-mouse-1 double-down-mouse-1 triple-down-mouse-1)
               '(mouse-1 double-mouse-1 triple-mouse-1)))
       (let ((position (nth 1 event)))
         (and (memq (posn-area position) '(mode-line header-line))
              (let ((pair (posn-string position)))
                (and pair
                     (get-text-property
                      0 'mode-line-keyboard-action (car pair))))))))


(defun mode-line-keyboard-perform-action (prompt &optional event)
  "Perform a mode line keyboard event.

PROMPT is the argument originally passed to `read-key'.

If EVENT is nil, `last-input-event' is used.

If the action is a function, call it and return its return
value (which is never nil).  Otherwise, return the action itself
which can be a vector, string, or nil.

This is designed to be bound to `mode-line' or `header-line' and
a mouse event."
  (unless event
    (setq event last-input-event))
  (let ((action (mode-line-keyboard-eventp event)))
    (if (functionp action)
        (prog1
            (mode-line-keyboard-funcall action prompt)
          (force-mode-line-update))
      ;; Vector, string, or nil.
      action)))


(defun mode-line-keyboard-ignore-mouse-movement (prompt)
  "Read an event, but ignore mouse movement events.

PROMPT is passed to `read-key'."
  (and (not mode-line-keyboard--inhibit-tranform)
       (let ((mode-line-keyboard--inhibit-tranform t))
         (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))))


(defun mode-line-keyboard-suppress-down-event (prompt)
  "Suppress the down mouse events, for mode line keyboard entries.

PROMPT is passed to `read-key'."
  (and (mode-line-keyboard-eventp last-input-event 'down)
       (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt))))


;; ------------------------------------------------------------
;; XTerm support.
;;

;; When a remapping is performed in the `input-decode-map', it is not
;; rescanned. Unfortunately, `xterm-mouse-mode' is implemented using
;; `input-decode-map'. So the mouse event it produces would normally
;; not be remapped.
;;
;; We get around this limitation by substituing the `xterm-mouse-mode'
;; bindings in `input-decode-map' to our own function, which calls the
;; original function and, if the event is one of ours, remaps it.

(declare-function xterm-mouse-translate-extended "xt-mouse.el")

(defun mode-line-keyboard-wrapper-for-xterm-mouse-translate-extended (prompt)
  "Wrapper around `xterm-mouse-translate-extended' for the Mode Line Keyboard.

PROMPT is the argument passed to this function when the event
occurred."
  (mode-line-keyboard-log "Buffer: %S" (current-buffer))
  (let ((orig (xterm-mouse-translate-extended prompt)))
    (mode-line-keyboard-log "(xterm-mouse-translate-extended %S) => %S"
                            prompt orig)
    (mode-line-keyboard-log "mode-line-keyboard--inhibit-tranform: %S"
                            mode-line-keyboard--inhibit-tranform)
    (mode-line-keyboard-log "mode-line-keyboard-visible-mode: %S"
                            mode-line-keyboard-visible-mode)
    (if (and (not mode-line-keyboard--inhibit-tranform)
	     (vectorp orig)
	     (eq (length orig) 1))
        (let ((event (aref orig 0)))
	  (when (mode-line-keyboard-eventp event 'down)
	    ;; Ignore this event by reading the "up" event.
	    ;;
	    ;; By setting `mode-line-keyboard--inhibit-tranform' to t
	    ;; the event isn't transformed to a key event by ourselves.
	    (let ((mode-line-keyboard--inhibit-tranform t))
              (let ((maybe-up-event
                     (mode-line-keyboard-read-key-ignore-mouse-movement)))
                (if (mode-line-keyboard-eventp maybe-up-event)
                    (setq event maybe-up-event)
                  (push maybe-up-event unread-command-events)))))
          (or (mode-line-keyboard-inactive-minibuffer-space prompt event)
              (mode-line-keyboard-perform-action prompt event)
              orig))
      orig)))


;; ------------------------------------------------------------
;; Qualifier keys.
;;

;; When the user clicks on a modifier label (such as CTRL) on the
;; header or mode line, the modifier is added to the next key read.
;; If the user clicks on the same modifier labal again, the effect is
;; canceled.
;;
;; The functions are implemented to that the next key is read using
;; `read-key'.  If the user clicks the label again, the same action
;; function is called recursively.  Also, if the user clicks on
;; another modifier label, its action function is called.
;;
;; The toggling effect is implemented by keeing track of which call is
;; the outermost, and whether odd or even clicks for that modifier has
;; been seen.  If an odd number of clicks has been seen, the modifier
;; is added.
;;
;; One could imagine other implementations.  One approach could be to
;; add or remove the modifier, but removing modifiers would require
;; another set of tools.

;; Note: Emacs provides similar functions named `event-apply-xxx'.
;; However, they use `read-event' so thet doesn't work with
;; `xterm-mouse-mode'.


;; Testing:
;;
;; Click CTRL and "e". Should move point to the end of line.
;;
;; Click CTRL, CTRL, and "e". Should insert the "e".
;;
;; Click CTRL, CTRL, CTRL, and "a". Should move point to the beginning
;; of the line.
;;
;; Click CTRL. META, and x. Swap the order of the modifier keys.


;; TODO: Report the following bugs in Emacs:
;;
;; 1) `event-apply-xxx-modifier' use `read-event' to read the next
;;    key.  This doesn't work in xterm mode.
;;
;; 2) `event-apply-modifier' incorrectly adds CTRL when another
;;    modifier already has been added.
;;
;;    Concretely, the following two expressions should yeild the same result:
;;
;;    (mode-line-keyboard-apply-modifier
;;      (mode-line-keyboard-apply-modifier ?x 'control)
;;      'meta)
;;
;;    (mode-line-keyboard-apply-modifier
;;      (mode-line-keyboard-apply-modifier ?x 'meta)
;;      'control)
;;
;; 3) `event-apply-modifier' can't handle SHIFT for non-ASCII letters,
;;    like å and Å.
;;
;;    (event-apply-modifier ?å 'shift 25 "S-") should return 196 but
;;    instead it returns 33554661.


(defun mode-line-keyboard-event-apply-modifier (event symbol lshiftby prefix)
  "Apply a modifier flag to event EVENT.
SYMBOL is the name of this modifier, as a symbol.
LSHIFTBY is the numeric value of this modifier, in keyboard events.
PREFIX is the string that represents this modifier in an event type symbol."
  (if (numberp event)
      (let ((base-event (logand event
                                (- (lsh 1 22) 1)))
            (base-modifiers (logand event
                                    (lognot (- (lsh 1 22) 1)))))
        (cond ((eq symbol 'control)
	       (cond ((and (<= (downcase base-event) ?z)
		           (>= (downcase base-event) ?a))
		      (logior (- (downcase event) ?a -1)
                              base-modifiers))
	             ((and (<= (downcase base-event) ?Z)
			   (>= (downcase base-event) ?A))
                      (logior (- (downcase event) ?A -1)
                              base-modifiers))
                     (t
		      (logior (lsh 1 lshiftby) event))))
	      ((eq symbol 'shift)
               (if (eq (upcase base-event)
                       (downcase base-event))
                   (logior (lsh 1 lshiftby) event)
                 (logior base-modifiers (upcase event))))
	      (t
	       (logior (lsh 1 lshiftby) event))))
    (if (memq symbol (event-modifiers event))
	event
      (let ((event-type (if (symbolp event) event (car event))))
	(setq event-type (intern (concat prefix (symbol-name event-type))))
	(if (symbolp event)
	    event-type
	  (cons event-type (cdr event)))))))


(defun mode-line-keyboard-apply-modifier (key modifier)
  "To KEY, Apply MODIFIER.

Modifier is one of the symbols `alt', `super', `hyper', `shift',
`control', or `meta'."
  (cond ((eq modifier 'alt)
         (mode-line-keyboard-event-apply-modifier key modifier 22 "A-"))
        ((eq modifier 'super)
         (mode-line-keyboard-event-apply-modifier key modifier 23 "s-"))
        ((eq modifier 'hyper)
         (mode-line-keyboard-event-apply-modifier key modifier 24 "H-"))
        ((eq modifier 'shift)
         (mode-line-keyboard-event-apply-modifier key modifier 25 "S-"))
        ((eq modifier 'control)
         (mode-line-keyboard-event-apply-modifier key modifier 26 "C-"))
        ((eq modifier 'meta)
         (mode-line-keyboard-event-apply-modifier key modifier 27 "M-"))
        (t
         (error "Unexepcted modifier `%S'" modifier))))


;; ----------------------------------------
;; Alt

(defvar mode-line-keyboard-top-level-alt t
  "Non-nil outside calls to `mode-line-keyboard-apply-alt-modifier'.

This is bound to nil inside the the first call to the function,
to change thebehaviour of recursive invocations.")


(defvar mode-line-keyboard-add-alt nil
  "When Non-nil `mode-line-keyboard-apply-alt-modifier' add modifier.

This is used to make the function behave like a toggle.")


(defun mode-line-keyboard-apply-alt-modifier (prompt)
  "Add the alt modifier to the following event.

Act as a toggle, i.e. the effect is undone if applied a second time.

PROMPT is passed to `read-key'."
  (if mode-line-keyboard-top-level-alt
      (let ((mode-line-keyboard-top-level-alt nil)
            (mode-line-keyboard-add-alt t))
        (let ((key (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))
          (vector (if mode-line-keyboard-add-alt
                      (mode-line-keyboard-apply-modifier key 'alt)
                    key))))
    (setq mode-line-keyboard-add-alt (not mode-line-keyboard-add-alt))
    (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt))))


;; ----------------------------------------
;; Control

(defvar mode-line-keyboard-top-level-control t
  "Non-nil outside calls to `mode-line-keyboard-apply-control-modifier'.

This is bound to nil inside the the first call to the function,
to change the behaviour of recursive invocations.")


(defvar mode-line-keyboard-add-control nil
  "When Non-nil `mode-line-keyboard-apply-control-modifier' add modifier.

This is used to make the function behave like a toggle.")


(defun mode-line-keyboard-apply-control-modifier (prompt)
  "Add the control modifier to the following event.

Act as a toggle, i.e. the effect is undone if applied a second time.

PROMPT is passed to `read-key'."
  (if mode-line-keyboard-top-level-control
      (let ((mode-line-keyboard-top-level-control nil)
            (mode-line-keyboard-add-control t))
        (let ((key (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))
          (vector (if mode-line-keyboard-add-control
                      (mode-line-keyboard-apply-modifier key 'control)
                    key))))
    (setq mode-line-keyboard-add-control (not mode-line-keyboard-add-control))
    (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt))))


;; ----------------------------------------
;; Super

(defvar mode-line-keyboard-top-level-super t
  "Non-nil outside calls to `mode-line-keyboard-apply-super-modifier'.

This is bound to nil inside the the first call to the function,
to change the behaviour of recursive invocations.")


(defvar mode-line-keyboard-add-super nil
  "When Non-nil `mode-line-keyboard-apply-super-modifier' add modifier.

This is used to make the function behave like a toggle.")


(defun mode-line-keyboard-apply-super-modifier (prompt)
  "Add the super modifier to the following event.

Act as a toggle, i.e. the effect is undone if applied a second time.

PROMPT is passed to `read-key'."
  (if mode-line-keyboard-top-level-super
      (let ((mode-line-keyboard-top-level-super nil)
            (mode-line-keyboard-add-super t))
        (let ((key (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))
          (vector (if mode-line-keyboard-add-super
                      (mode-line-keyboard-apply-modifier key 'super)
                    key))))
    (setq mode-line-keyboard-add-super (not mode-line-keyboard-add-super))
    (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt))))


;; ----------------------------------------
;; Hyper

(defvar mode-line-keyboard-top-level-hyper t
  "Non-nil outside calls to `mode-line-keyboard-apply-hyper-modifier'.

This is bound to nil inside the the first call to the function,
to change the behaviour of recursive invocations.")


(defvar mode-line-keyboard-add-hyper nil
  "When Non-nil `mode-line-keyboard-apply-hyper-modifier' add modifier.

This is used to make the function behave like a toggle.")


(defun mode-line-keyboard-apply-hyper-modifier (prompt)
  "Add the hyper modifier to the following event.

Act as a toggle, i.e. the effect is undone if applied a second time.

PROMPT is passed to `read-key'."
  (if mode-line-keyboard-top-level-hyper
      (let ((mode-line-keyboard-top-level-hyper nil)
            (mode-line-keyboard-add-hyper t))
        (let ((key (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))
          (vector (if mode-line-keyboard-add-hyper
                      (mode-line-keyboard-apply-modifier key 'hyper)
                    key))))
    (setq mode-line-keyboard-add-hyper (not mode-line-keyboard-add-hyper))
    (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt))))


;; ----------------------------------------
;; Shift

(defvar mode-line-keyboard-top-level-shift t
  "Non-nil outside calls to `mode-line-keyboard-apply-shift-modifier'.

This is bound to nil inside the the first call to the function,
to change the behaviour of recursive invocations.")


(defvar mode-line-keyboard-add-shift nil
  "When Non-nil `mode-line-keyboard-apply-shift-modifier' add modifier.

This is used to make the function behave like a toggle.")


(defun mode-line-keyboard-apply-shift-modifier (prompt)
  "Add the shift modifier to the following event.

Act as a toggle, i.e. the effect is undone if applied a second time.

PROMPT is passed to `read-key'."
  (if mode-line-keyboard-top-level-shift
      (let ((mode-line-keyboard-top-level-shift nil)
            (mode-line-keyboard-add-shift t))
        (let ((key (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))
          (vector (if mode-line-keyboard-add-shift
                      (mode-line-keyboard-apply-modifier key 'shift)
                    key))))
    (setq mode-line-keyboard-add-shift (not mode-line-keyboard-add-shift))
    (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt))))


;; ----------------------------------------
;; Meta

(defvar mode-line-keyboard-top-level-meta t
  "Non-nil outside calls to `mode-line-keyboard-apply-meta-modifier'.

This is bound to nil inside the the first call to the function,
to change the behaviour of recursive invocations.")


(defvar mode-line-keyboard-add-meta nil
  "When Non-nil `mode-line-keyboard-apply-meta-modifier' add modifier.

This is used to make the function behave like a toggle.")


(defun mode-line-keyboard-apply-meta-modifier (prompt)
  "Add the meta modifier to the following event.

Act as a toggle, i.e. the effect is undone if applied a second time.

PROMPT is passed to `read-key'."
  (if mode-line-keyboard-top-level-meta
      (let ((mode-line-keyboard-top-level-meta nil)
            (mode-line-keyboard-add-meta t))
        (let ((key (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))
          (vector (if mode-line-keyboard-add-meta
                      (mode-line-keyboard-apply-modifier key 'meta)
                    key))))
    (setq mode-line-keyboard-add-meta (not mode-line-keyboard-add-meta))
    (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt))))


;; ------------------------------------------------------------
;; Use an inactive minibuffer as an extra SPACE key.
;;

(defun mode-line-keyboard-minibuffer-inactive-event-p (event)
  "Non-nil if EVENT is a mouse event in an inactive minibuffer."
  (and (consp event)
       (let* ((position (nth 1 event))
              (win (posn-window position))
              (frame (window-frame win)))
         (and (memq (car event) '(mouse-1 double-mouse-1 triple-mouse-1))
	      (eq (minibuffer-window frame) win)
              (not (active-minibuffer-window))))))


;; This is sufficient for a SPC in the middle of a key sequence.
(defun mode-line-keyboard-inactive-minibuffer-space (_prompt &optional event)
  "Remap clicks in an inactive minibuffer to spaces.

EVENT is an event.  If EVENT is nil, `last-input-event' is used."
  (unless event
    (setq event last-input-event))
  (mode-line-keyboard-log "Buffers: %S" (buffer-list))
  (mode-line-keyboard-log "Event: %S" event)
  (if (and
       (mode-line-keyboard-minibuffer-inactive-event-p event)
       (with-current-buffer
           ;; Hack to get the buffer before the inactive minibuffer
           ;; was made current.
           (if (eq major-mode 'minibuffer-inactive-mode)
               (car (buffer-list))
             (current-buffer))
         mode-line-keyboard-visible-mode))
      [32]
    nil))


;; Typically, this is bound to SPC in `minibuffer-inactive-mode-map'.
;; This is used when no prefix keys has been typed, and it ensures
;; that clicks in an inactive minibuffer are inserted as spaces,
;; thanks to the remapping performed by
;; `mode-line-keyboard-inactive-minibuffer-space'.
(defun mode-line-keyboard-self-insert-command (_arg)
  "Like `self-insert-command' but isn't affected by a remap entry."
  (interactive "P")
  (call-interactively #'self-insert-command))


;; ------------------------------------------------------------
;; Constructing the mode and header lines.
;;

(defvar mode-line-keyboard-template-list
  '((:escape   (27 "ESC"))
    (:space    (32 "SPC"))
    (:tab      (9  "TAB"))
    (:ret      (13 "RET"))
    (:delback  ([backspace]  "<X"))
    (:delforw  ([deletechar] "X>"))
    (:home     ([home]  "HOME"))
    (:end      ([end]   "END"))
    (:pgup     ([prior] "PGUP"))
    (:pgdn     ([next]  "PGDN"))
    (:alt      (:toggle mode-line-keyboard-add-alt
                        mode-line-keyboard-apply-alt-modifier      "ALT"))
    (:super    (:toggle mode-line-keyboard-add-super
                        mode-line-keyboard-apply-super-modifier    "SUPR"))
    (:hyper    (:toggle mode-line-keyboard-add-hyper
                        mode-line-keyboard-apply-hyper-modifier    "HYPR"))
    (:shift    (:toggle mode-line-keyboard-add-shift
                        mode-line-keyboard-apply-shift-modifier    "SHFT"))
    (:control  (:toggle mode-line-keyboard-add-control
                        mode-line-keyboard-apply-control-modifier  "CTRL"))
    (:meta     (:toggle mode-line-keyboard-add-meta
                        mode-line-keyboard-apply-meta-modifier     "META"))
    (:letters  (:range ?a ?z))
    (:digits   (:shift ?1 ?!) (:shift ?2 ?@) (:shift ?3 ?#) (:shift ?4 ?$)
               (:shift ?5 ?%) (:shift ?6 ?^) (:shift ?7 ?&) (:shift ?8 ?*)
               (:shift ?9 ?\() (:shift ?0 ?\) ))
    (:parens   ?< ?\[ ?{ ?\( ?\) ?} ?\] ?>)
    (:quotes   ?' ?` ?\")
    (:punct    ?. ?, ?: ?\; ?? ?! ?# ?$ ?_)
    (:ariths   ?- ?+ ?* ?= ?& ?| ?^ ?/ ?\\ ?% ?@)
    (:hl       (mode-line-keyboard-step-header-line
                mode-line-keyboard-header-line-label))
    (:ml       (mode-line-keyboard-step-mode-line
                mode-line-keyboard-mode-line-label))
    (:hide     (mode-line-keyboard-hide-keyboard-and-read-key "<KB"))
    (:soh-ml   (mode-line-keyboard-step-or-hide-mode-line
                mode-line-keyboard-mode-line-label))
    (:arrows   ([left] "\u2190") ([up] "\u2191")
               ([down] "\u2193") ([right] "\u2192"))
    (:hl-cmn   :hl :shift :control :meta
               :space :tab :ret :delback :delforw))
  "List of templates for the Mode Line Keyboard content variables.

Each entry in the list is on the form:

    (ID REPLACEMENT ...)

Where ID is a keyword like `:tab'.  When it occurs in
`mode-line-keyboard-header-line-content' or
`mode-line-keyboard-mode-line-content' it is replaced by the REPLACEMENT:s.")


(defvar mode-line-keyboard-header-line-content
  '((:hl-cmn :digits)
    (:hl-cmn :parens :quotes)
    (:hl-cmn :ariths)
    (:hl-cmn :punct))
  "A list of entries, each representing a keyboard line in the header line.")


(defvar mode-line-keyboard-mode-line-content
  '((:ml     :letters)
    (:soh-ml :arrows :escape :home :end :pgup :pgdn))
  "A list of entries, each representing a keyboard line in the mode line.")


(defun mode-line-keyboard-flatten-template (template)
  "Replace entries in TEMPLATE according to `mode-line-keyboard-template-list'.

Return a flat list containing only primitive forms."
  (let ((res '())
        (worklist template))
    (while worklist
      (let ((item (pop worklist)))
        (let ((entry (assq item mode-line-keyboard-template-list)))
          (if entry
              (setq worklist (append (cdr entry) worklist))
            (push item res)))))
    (nreverse res)))


(defun mode-line-keyboard-format-one-entry (action label &optional props)
  "Create a clickable area, suitable for inclusion in the mode or header line.

ACTION is the action that should be performed (a number or
vector).  LABEL is the text.  PROPS is a list of additional properties.

The return value is a list on the form `(:propertize STRING
mode-line-keyboard-action ACTION PROPS...)', Where STRING is
constructed from LABEL by adding a space on each side.  See
`mode-line-format' for more information.

If LABEL is a function, it is called to retrieve the label."
  (when (numberp action)
    (setq action (vector action)))
  (when (functionp label)
    (setq label (funcall label)))
  (setq label (replace-regexp-in-string "%" "%%" label))
  `(:propertize
    ;; TODO: Put this responsibility on the caller.
    ,(concat " " label " ")
    mode-line-keyboard-action
    ,action
    ,@props))


(defun mode-line-keyboard-format-entry (action label &optional props)
  "Create an clickable area, suitable for inclusion in the mode or header line.

ACTION is the action that should be performed (a number or
vector).  LABEL is the text.  PROPS is a list of additional properties.

LABEL is typically in lower case.  If it can be converted to
upper case, the result is on the form
`(mode-line-keyboard-add-shift UPCASE-ENTRY LOWCASE-ENTRY)'."
  (let ((up-label (and (stringp label)
                       (upcase label))))
    (if (or (not up-label)
            (string-equal label up-label))
        (mode-line-keyboard-format-one-entry action label props)
      `(mode-line-keyboard-add-shift
        ,(mode-line-keyboard-format-one-entry action up-label props)
        ,(mode-line-keyboard-format-one-entry action label props)))))


;; TODO: rename template to content-line, or something similar.
(defun mode-line-keyboard-format (template)
  "Format a header or mode line from TEMPLATE."
  (let ((res '()))
    (dolist (item (mode-line-keyboard-flatten-template template))
      (cond ((eq item :original-mode-line)
             (push 'mode-line-keyboard--saved-mode-line-format
                   res))
            ((eq item :original-header-line)
             (push 'mode-line-keyboard--saved-header-line-format
                   res))
            ((numberp item)
             (push (mode-line-keyboard-format-entry
                    item
                    (concat (list item)))
                   res))
            ((and (listp item)
                  (or (numberp (nth 0 item))
                      (vectorp (nth 0 item))))
             (push (mode-line-keyboard-format-entry
                    (car item)
                    (nth 1 item))
                   res))
            ((and (listp item)
                  (eq (nth 0 item) :shift))
             (push
              `(mode-line-keyboard-add-shift
                ,(mode-line-keyboard-format-one-entry
                  (nth 2 item)
                  (concat (list (nth 2 item))))
                ,(mode-line-keyboard-format-one-entry
                  (nth 1 item)
                  (concat (list (nth 1 item)))))
              res))
            ((and (listp item)
                  (eq (nth 0 item) :range))
             (let ((from (nth 1 item))
                   (to   (nth 2 item)))
               (while (<= from to)
                 (push (mode-line-keyboard-format-entry
                        from
                        (concat (list from)))
                       res)
                 (setq from (+ from 1)))))
            ((and (listp item)
                  (eq (nth 0 item) :toggle))
             (let ((var  (nth 1 item))
                   (func (nth 2 item))
                   (name (nth 3 item)))
               (push
                (list var
                      (mode-line-keyboard-format-entry
                       func
                       name
                       '(face mode-line-keyboard-selected-modifier))
                      (mode-line-keyboard-format-entry
                       func
                       name))
                res)))
            ((and (listp item)
                  (functionp (nth 0 item)))
             (push (mode-line-keyboard-format-entry
                    (nth 0 item)
                    (nth 1 item))
                   res))))
    (nreverse res)))


(defvar mode-line-keyboard-mode-line-step 0
  "The current Mode Line Keyboard mode line variant.")
(defvar mode-line-keyboard-header-line-step 0
  "The current Mode Line Keyboard header line variant.")


(defun mode-line-keyboard-update-mode-line ()
  "Update mode line according to the Mode Line Keyboard settings."
  (setq mode-line-format
        (mode-line-keyboard-format
         (nth mode-line-keyboard-mode-line-step
              mode-line-keyboard-mode-line-content)))
  (force-mode-line-update))


(defun mode-line-keyboard-update-header-line ()
  "Update header line according to the Mode Line Keyboard settings."
  (setq header-line-format
        (mode-line-keyboard-format
         (nth mode-line-keyboard-header-line-step
              mode-line-keyboard-header-line-content)))
  (force-mode-line-update))


;; --------------------
;; Step line

(defun mode-line-keyboard-step-mode-line (prompt)
  "Step to the next Mode Line Keyboard mode line variant.

PROMPT is the prompt of the original key event, it is passed to
the next call to `read-key'."
  (setq mode-line-keyboard-mode-line-step
        (mod (+ mode-line-keyboard-mode-line-step 1)
             (length mode-line-keyboard-mode-line-content)))
  (mode-line-keyboard-update-mode-line)
  (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))


(defun mode-line-keyboard-step-header-line (prompt)
  "Step to the next Mode Line Keyboard header line variant.

PROMPT is the prompt of the original key event, it is passed to
the next call to `read-key'."
  (setq mode-line-keyboard-header-line-step
        (mod (+ mode-line-keyboard-header-line-step 1)
             (length mode-line-keyboard-header-line-content)))
  (mode-line-keyboard-update-header-line)
  (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))


;; --------------------
;; Step or hide line

(defun mode-line-keyboard-step-or-hide-mode-line (prompt)
  "Step to the next line or hide the Mode Line Keyboard.

PROMPT is the prompt of the original key event, it is passed to
the next call to `read-key'."
  (if (eq (+ mode-line-keyboard-mode-line-step 1)
          (length mode-line-keyboard-mode-line-content))
      (mode-line-keyboard-hide-keyboard-and-read-key prompt)
    (mode-line-keyboard-step-mode-line prompt)))


(defun mode-line-keyboard-step-or-hide-header-line (prompt)
  "Step to the next line or hide the Mode Line Keyboard.

PROMPT is the prompt of the original key event, it is passed to
the next call to `read-key'."
  (if (eq (+ mode-line-keyboard-header-line-step 1)
          (length mode-line-keyboard-header-line-content))
      (mode-line-keyboard-hide-keyboard-and-read-key prompt)
    (mode-line-keyboard-step-header-line prompt)))


;; --------------------
;; Step labelse

(defun mode-line-keyboard-mode-line-label ()
  "Return string like 1/3 indicating current and number of keyboard lines."
  (format "%d/%d"
          (+ mode-line-keyboard-mode-line-step 1)
          (length mode-line-keyboard-mode-line-content)))


(defun mode-line-keyboard-header-line-label ()
  "Return string like 1/3 indicating current and number of keyboard lines."
  (format "%d/%d"
          (+ mode-line-keyboard-header-line-step 1)
          (length mode-line-keyboard-header-line-content)))

;; ------------------------------------------------------------
;; Avoid accidental point movement.
;;

(defun mode-line-keyboard-inhibit-mouse-set-point ()
  "Replacement binding for mouse click, to avoid accidental mouse movements."
  (interactive)
  (message "Double-click to move cursor when mode line keyboard is visible"))


(defun mode-line-keyboard-mouse-set-point (event &optional promote-to-region)
  "Like `mouse-set-point', but require an additional click.

EVENT and is an event.  See `mouse-set-point' for information
about PROMOTE-TO-REGION."
  (interactive "e\np")
  (let ((count (event-click-count event)))
    ;; `mouse-set-point' sets the point on one click, selects a word
    ;; and two, and a line on three etc.  When mode-line-keyboard-mode
    ;; is active, one click is inhibited, double click sets the
    ;; point, triple click selects a word, et.c.
    (when (> count 1)
      (setq count (- count 1)))
    (mouse-set-point (list (nth 0 event)
                           (nth 1 event)
                           count)
                     promote-to-region)))


;; ------------------------------------------------------------
;; The "visible" mode.
;;
;; This is enabled when the mode like keyboard is made visible.

;; This function used to reduce movement inside windows when the
;; header line is displayed or hidden.
(defun mode-line-keyboard-format-adjust-window-starts (adjustment)
  "Adjust the start of all windows associated with the current buffer.

No adjustment is made when the adjustment would place the window
point outside the visible area of the window.

The adjustment is performed ADJUSTMENT lines."
  (dolist (frame (frame-list))
    (dolist (window (window-list frame :ignore-minibuffer))
      (when (eq (current-buffer) (window-buffer window))
        (let ((new-window-start
               (save-excursion
                 (goto-char (window-start window))
                 ;; TODO: To handle wrapped lines correctly, this
                 ;; should really be something like "forward visible
                 ;; line forward".
                 (forward-line adjustment)
                 (point))))
          (when (<= new-window-start (window-point window))
            (set-window-start window new-window-start)))))))


(defvar mode-line-keyboard-visible-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<mouse-1>")
      #'mode-line-keyboard-inhibit-mouse-set-point)
    (define-key map (kbd "<down-mouse-1>")
      #'mode-line-keyboard-inhibit-mouse-set-point)
    (define-key map (kbd "<double-mouse-1>")
      #'mode-line-keyboard-mouse-set-point)
    map)
  "Keymao for Mode Line Keyboard Visible Mode.")


(define-minor-mode mode-line-keyboard-visible-mode
  "Minor mode that turns the mode line into a keyboard."
  nil
  nil
  nil
  :group mode-line-keyboard-mode
  :keymap mode-line-keyboard-visible-map
  (if mode-line-keyboard-visible-mode
      ;; Turn the mode on (or keep it on).
      (progn
	(unless (display-graphic-p)
	  (xterm-mouse-mode 1))
        ;; Note: `mode-line-format' is "always" non-nil, whereas
        ;; `header-line-format' often is.  We use the saved value of
        ;; `mode-line-format' to indicate if this mode already was on
        ;; or not.
        (unless mode-line-keyboard--saved-mode-line-format
          (setq mode-line-keyboard--saved-mode-line-format mode-line-format)
          (setq mode-line-keyboard--saved-header-line-format
                header-line-format))

        ;; --------------------
        ;; Mode line
        ;;
        (set (make-local-variable 'mode-line-keyboard-mode-line-step) 0)
        (mode-line-keyboard-update-mode-line)

        ;; --------------------
        ;; Header line
        ;;
        (let ((old header-line-format))
          (set (make-local-variable 'mode-line-keyboard-header-line-step) 0)
          (mode-line-keyboard-update-header-line)

          (when (and (not old)
                     header-line-format)
            (mode-line-keyboard-format-adjust-window-starts 1))))
    (when mode-line-keyboard--saved-mode-line-format
      (when (and header-line-format
                 (not mode-line-keyboard--saved-header-line-format))
        (mode-line-keyboard-format-adjust-window-starts -1))
      (setq mode-line-format mode-line-keyboard--saved-mode-line-format)
      (setq header-line-format mode-line-keyboard--saved-header-line-format)
      (setq mode-line-keyboard--saved-mode-line-format nil)
      (setq mode-line-keyboard--saved-header-line-format nil)
      (define-key minibuffer-inactive-mode-map [mouse-1]
        #'view-echo-area-messages))))


;; ------------------------------------------------------------
;; The actual mode.
;;

(defun mode-line-keyboard-display-keyboard-and-read-key (prompt)
  "Display the Mode Line Keyboard and read the next key.

PROMPT is the prompt of the original key event, it is passed to
the next call to `read-key'."
  (mode-line-keyboard-visible-mode 1)
  (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))


(defun mode-line-keyboard-hide-keyboard-and-read-key (prompt)
  "Hide the Mode Line Keyboard and read the next key.

PROMPT is the prompt of the original key event, it is passed to
the next call to `read-key'."
  (mode-line-keyboard-visible-mode -1)
  (vector (mode-line-keyboard-read-key-ignore-mouse-movement prompt)))

(defvar mode-line-keyboard-mode-show-keyboard
  `(,(mode-line-keyboard-format-entry
      #'mode-line-keyboard-display-keyboard-and-read-key "KB>"))
  "Mode line format string for the label to display the mode line keyboard.")
(put 'mode-line-keyboard-mode-show-keyboard 'risky-local-variable t)


;;;###autoload
(define-minor-mode mode-line-keyboard-mode
  "Minor mode that turns the mode line into a keyboard."
  nil
  nil
  nil
  (if mode-line-keyboard-mode
      ;; Enable, or keep the mode on.
      (progn
        (mode-line-keyboard-visible-mode -1)
        ;; Note: `add-to-list' is not recommended to be used from
        ;; lisp, and I don't want to use `cl-pushnew' and I don't want
        ;; to bring in a Common Lisp compatibility package for this.
        (unless (memq 'mode-line-keyboard-mode-show-keyboard
                      mode-line-format)
          (push 'mode-line-keyboard-mode-show-keyboard
                mode-line-format)
          ;; Seems to be needed, why I don't know.
          (push "" mode-line-format))

        (unless (display-graphic-p)
          (xterm-mouse-mode 1))

        ;; --------------------
        ;; Key bindings
        ;;
        (define-key input-decode-map [mode-line down-mouse-1]
          #'mode-line-keyboard-suppress-down-event)
        (define-key input-decode-map [header-line down-mouse-1]
          #'mode-line-keyboard-suppress-down-event)

        (define-key input-decode-map [mode-line mouse-1]
          #'mode-line-keyboard-perform-action)
        (define-key input-decode-map [mode-line double-mouse-1]
          #'mode-line-keyboard-perform-action)
        (define-key input-decode-map [mode-line triple-mouse-1]
          #'mode-line-keyboard-perform-action)

        (define-key input-decode-map [header-line mouse-1]
          #'mode-line-keyboard-perform-action)
        (define-key input-decode-map [header-line double-mouse-1]
          #'mode-line-keyboard-perform-action)
        (define-key input-decode-map [header-line triple-mouse-1]
          #'mode-line-keyboard-perform-action)

        (define-key input-decode-map [mouse-1]
          #'mode-line-keyboard-inactive-minibuffer-space)

        (define-key minibuffer-inactive-mode-map [32]
          #'mode-line-keyboard-self-insert-command)

        (define-key input-decode-map [mouse-movement]
          #'mode-line-keyboard-ignore-mouse-movement)

        (substitute-key-definition
         #'xterm-mouse-translate-extended
         #'mode-line-keyboard-wrapper-for-xterm-mouse-translate-extended
         input-decode-map)

        ;; Ensure that the instrumentation of Keymap Logger mode is up to
        ;; date.  (Note: When the global mode is enabled, this mode is
        ;; enabled for new buffers.)
        (when (fboundp 'keymap-logger-instrument-keymap-list)
          (keymap-logger-instrument-keymap-list)))
    (mode-line-keyboard-visible-mode -1)
    (setq mode-line-format
          (delq 'mode-line-keyboard-mode-show-keyboard
                mode-line-format))))


;;;###autoload
(define-global-minor-mode mode-line-keyboard-global-mode
  mode-line-keyboard-mode
  (lambda ()
    (mode-line-keyboard-mode 1))
  :group mode-line-keyboard-mode
  :require 'mode-line-keyboard)


;; ------------------------------------------------------------
;; The end.
;;

(provide 'mode-line-keyboard)

;;; mode-line-keyboard.el ends here
