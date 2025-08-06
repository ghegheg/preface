;; preface.el --- change faces of symbols -*- lexical-binding: t -*-

;; Copyright (C) Gabriel Mitu <Mitu.Gabriel.Cristian@gmail.com>
;; Created:

;; Keywords: convenience
;; URL: htttps://github.com/ghegheg

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should " have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; The `preface-mode put a face to a symbol or a group of symbols, or 
;; put faces to more groups of symbols, using overlay concept. 
;; Enabling the mode put faces over all declared symbols in the
;; whole buffer. Further, it put face on symbol dynamically, while the
;; user is typing.
;; Depending on the value of `preface-is-words-highlighted' variable,
;; the program may highlight words or symbols in buffer. Remember, the
;; symbol is bounded inferiorly and superiorly by SPC, \n, \t,
;; \r, \f, \v, but word isn't, it may be part from a symbol.  
;; The mode does not modify any in buffer, it only put overlay in
;; the buffer. Closing the mode returns the buffer to its initial
;; state. Its like you have a picture and you put some objects on the
;; picture. The objects modify how the picture looks, but they don't
;; modify the picture itself. Move away the objects and you get the
;; picture how it was in the beginning.
;; How to set the program? 
;; - customize all program custom variable with the command:
;; `M-x customize-group : preface' or individually you can 
;; customize `preface-faces', simply type in minibuffer
;; `M-x customize-variable' and `Customize-variable: preface-faces'.
;; Here, `Value Menu' button displays two option:
;; a) `Use prettify-symbol-mode with face': where you set a
;; face for all symbol from `prettify-symbols-alist' when you use  
;; `prettify-symbol-mode'. Very important to note how
;; `prettify-symbol-mode' highlight its characters in buffer as symbol
;; or as word, so you must set accordingly
;; `preface-is-words-highlighted' or
;; `preface-is-words-highlighted-local' variable. 
;; b) `Use your own symbols': you can set groups of symbols, every
;; group having its own face.  
;; Take care: 
;; - use an unique face for a group of symbols in `preface-faces' variable
;; so if `Tom' `Jerry' has `animal' face, and `dog' `rat' has `animal'
;; face is an incorrect variable declaration. Correct is: `Tom'
;; `Jerry' `dog' `rat' has `animal' face. 
;; - modifying of settings needs shutdown and reopen `preface-mode'
;; again: `M-x preface-mode' `M-x preface-mode' or `M-: (preface-mode 1)'
;; - editing symbols in buffer may let the initial overlay face on
;; parts of symbol. To remove the overlay face from editing remains simply
;; proceed as in previous point (modifying of settings). It would be
;; useful to have a shortcut on next function:
;; (defun your-fun ()
;;    (interactive) 
;;    (preface-mode 1))
;; -if something wrong appears, shutting the `preface-mode' brings
;; the buffer to initial state. If it doesn't happen, closing after
;; saving and reopen the file without preface-mode enabled should do.   
;; - set global variables `preface-faces', `preface-is-words-highlighted',
;; `preface-overlays-priority' only from customization, `M-x
;; customize-variable' and never set them with `setq'. These variable
;; are global and have effects over every buffer. If user wants to
;; have different customization in other buffers, use buffer local
;; variables `preface-faces-local', 
;; `preface-is-words-highlighted-local' and `preface-overlays-priority-local'. 
;; These buffer local variables are set with `setq' with a non-nil
;; value. Setting these with nil makes the program to not consider
;; them in calculation again, but to consider its global customization
;; variable correspondent.  
;; Only custom variables are persistent and only if they are
;; saved after modification (press `State' button and select `Save for
;; future Sessions'). Buffer-local variables that end in `-local' are not
;; persistent, to make them persistent you must run a file after
;; `preface-mode' file is loaded, where you set all these variables. 
;; You can put (require 'file) declaration after (require
;; 'preface-mode) declaration in .emacs to load this file with settings.
;; Don't set variables that end in `-for-code' or `-data-structure',
;; they are used internally only by program.

;; Todo:


;;; Code:

(defgroup preface nil
  "Group of preface package"
  :group 'convenience)


(defcustom preface-faces 'compilation-warning 
  "Set faces for some symbols in buffer.
Option:
- Use `prettify-symbols-mode' with face: it sets all symbols
  defined in `prettify-symbols-alist' with one face. 
- Use your own symbols: user declare groups of symbols and their
 face to be displayed in buffer."
  :type '(choice
          (face :tag "Use `prettify-symbols-mode' with face"
                :value compilation-warning) 
          (repeat :tag "Use your own symbols"
                  (cons
                   :tag "Declare a group of symbols and their face" 
                   (repeat :tag "The group of symbols" string)
                   (face :tag "The group face"
                         :value compilation-warning))))
  :group 'preface)

(defvar preface-faces-local nil
  "Set faces for some symbols locally. 
This variable is a buffer local variable as: 
(((\"sym11\" \"sym21\" \"sym31\" ...) . face1)
 ((\"sym12\" \"sym22\" \"sym32\" ...) . face2)
 ....). User can set locally the symbols and the faces on every buffer
how he wants.")

(make-variable-buffer-local 'preface-faces-local)

(defvar preface-faces-for-code nil
  "Preface faces used by code. Please, do not set it!
It is set by `preface--set-faces' function.")

(make-variable-buffer-local 'preface-faces-for-code)

(defcustom preface-is-words-highlighted nil
  "Highlight in buffer as words or symbols. 
Set how the symbols from `preface-faces' or
`preface-faces-local' are considered in buffer:
`nil' - a symbol that must be bounded at its beginning and its end 
by one from next characters: `SPC', `\\n', `\\t', `\\r', `\\f', `\\v'.
`not-nil' - a word that needn't be bounded at both sides by previous characters"
  :type 'symbol
  :group 'preface)

(defvar preface-is-words-highlighted-local nil
  "Idem `preface-is-words-highlighted' but as buffer local variable.
For being integrated into the code the variable cannot have `nil' or
`t' values. It must set with `yes' and `no' symbols.")

(make-variable-buffer-local 'preface-is-words-highlighted-local)

(defvar preface-is-words-highlighted-for-code nil
  "Variable use by code. Please, do not set it!
It is set by `preface--set-is-words-highlighted' function.")

(make-variable-buffer-local 'preface-is-words-highlighted-for-code)

(defcustom preface-overlays-priority nil
  "The priority of the overlays.
This property's value determine the priority of the overlay. If you
want to specify a priority value, use either nil (or zero), or a
integer, or cons of two values. For more details read:
(URL `https://www.gnu.org/software/emacs/manual/html_node/elisp/Overlay-Properties.html')."
  :type '(choice 
          (natnum :tag "Positive integer")
          (const :tag "Nil" nil)
          (cons :tag "Cons of two values"
                sexp
                sexp))
  :group 'preface)

(defvar preface-overlays-priority-local nil
  "Idem `preface-overlays-priority' but locally in current buffer.
The `nil' value has no effect, used `0' value instead.")

(make-variable-buffer-local 'preface-overlays-priority-local)

(defvar preface-overlays-priority-for-code nil
  "Variable used by code. Please, do not set it!
It is set by `preface--set-overlays-priority'.")

(make-variable-buffer-local 'preface-overlays-priority-for-code)

(defvar preface-overlays nil
  "All created overlays. Please, do not set it!")

(make-variable-buffer-local 'preface-overlays)

(defvar preface-vector-data-structure nil
  "Variable with program internal structure. Please, do not set it!
It is a vector where index represent ASCII code. 
Last character of symbols from `preface-faces' variable if it is an
ASCII character is recorded in vector at an index equal with his 
ASCII number and with value representing the rest of characters 
in reverse order and corresponding face. 
For example `preface-faces' contains:
(((\"tom\" \"gamma\" \"beta\") . button) ((\"iam\" \"come\") . error) ...) 
Here in first list `tom' `gamma' `beta' are symbols that must appear
under `button' face.  
See at `tom' symbol. Its reverse is `mot'. `m' the reverse first
character has ASCII code 109. It records in vector at 109 index the
list: ((109 111 116 button)). Here 111 is ?o and 116 is ?t the rest of
characters from `mot'. Symbols `gamma', `beta' are recorded in the
same manner at ?a index in vector. App arrives at `iam' symbol. Its
reverse is `mai'. We add into the list from 109 index (109 97 105 error) 
where 97 is ?a and 105 is ?i, so list at 109 index is now ((109 111 116
button) (109 97 105 error)), and so on.     
Why it is good to record data into vector? Because the vector item at
specific index may be accessed immediately, if we had chosen a list,
it might have been passed to arrive at specific index. It's about the
time.The `after-change-functions' hook contains a function that must
execute rapid. If the function passes a list with 100 items, it lasts 
long every time we type a character. But what happens if symbol ends
with an character that is not in ASCII code, for example `tom©', © is
not in ASCII code? Then it is recorded in `preface-list-data-structure'. 
Anyway, most letters that user types or that are in the symbols are
from ASCII code.") 

(make-variable-buffer-local 'preface-vector-data-structure)

(defvar preface-list-data-structure nil
  "Variable with program internal structure. Please, do not set it!
List of list that records the symbols that don't ends into ASCII
character. For exampled if `preface-faces' contains: 
((\"tom\" \"gamma©\" \"beta\" button)....) then this variable starts
so: ((169 97 109 109 97 103 button)....). Read 
`preface-vector-data-structure'")

(make-variable-buffer-local 'preface-list-data-structure)

(defun preface--set-faces ()
  "Set `preface-faces-for-code' variable. Please, do no use it!."
  (if preface-faces-local
      (setq preface-faces-for-code preface-faces-local)
    (if (consp preface-faces)
        (setq preface-faces-for-code preface-faces) 
      (let ((result nil))
        (dolist (i prettify-symbols-alist result)
          (setq result (cons (car i) result)))
        (setq preface-faces-for-code (cons (cons result
                                                 preface-faces)
                                           nil))))))

(defun preface--set-is-words-highlighted ()
  "Set `preface-is-words-highlighted-for-code' variable."
  (setq preface-is-words-highlighted-for-code
        (if preface-is-words-highlighted-local 
            (cond ((eq preface-is-words-highlighted-local 'yes)
                   t)
                  ((eq preface-is-words-highlighted-local 'no)
                   nil)
                  (t (error "%s"
                            (concat 
                             "Variable `preface-is-words-highlighted-locally'"
                             " must be set with `yes' or `no'"))))
          preface-is-words-highlighted)))

(defun preface--set-overlays-priority ()
  "Set `preface-overlays-priority-for-code' variable."
  (if preface-overlays-priority-local
      (setq preface-overlays-priority-for-code
            preface-overlays-priority-local)
    (setq preface-overlays-priority-for-code
          preface-overlays-priority)))

(defun preface--set-data-structure ()
  "Set `preface-vector-data-structure' and `preface-list-data-structure'."
  (setq preface-vector-data-structure (make-vector 126 nil))
  (setq preface-list-data-structure nil)
  (dolist (i preface-faces-for-code)
    (dolist (str (car i))
      (let* ((len (length str))
             (last-in-str (aref str (1- len))) ;is number
             (data (cons (cdr i) nil)))
        (dotimes (j len) 
          (setq data (cons (aref str j) 
                           data)))
        (if (<= last-in-str 126)        ;is ASCII?
            (aset preface-vector-data-structure ;is ASCII
                  last-in-str
                  (cons data (aref preface-vector-data-structure
                                   last-in-str)))
          (setq preface-list-data-structure ;is not ASCII
                (cons data  
                      preface-list-data-structure)))))))

(defun preface-get-symbol-near-point ()
  "Get symbol from `preface-faces-for-code' near point, before. 
The symbol may be or not bounded inferiorly by other characters that 
are not `SPC', `\\n', `\\t', `\\r', `\\f', `\\v', but is bounded 
superiorly by point. The function returns the symbol, its beginning 
point in buffer and its face or nil if nothing exists." 
  (backward-char)
  (let* ((char (char-after))
         (data (if (<= char 126)
                   (aref preface-vector-data-structure char)
                 preface-list-data-structure))
         (result "")
         (to-add-in-result t)
         (left-data nil)
         (match nil))
    (catch 'foo
      (if data
          (while t
            (dolist (i data)
              (let ((first (car i))
                    (rest (cdr i)))
                (when (eql char first)
                  (setq match t) 
                  (when to-add-in-result
                    (setq result (concat (char-to-string char)
                                         result))
                    (setq to-add-in-result nil))
                  (if (>= (length rest) 2) 
                      (setq left-data (cons rest 
                                            left-data))
                    (throw 'foo (cons result ;there's a symbol
                                      (cons (point)
                                            (cons (car rest)
                                                  nil)))))))) 
            (if match 
                (progn
                  (backward-char)
                  (setq char (char-after))
                  (setq data left-data)
                  (setq left-data nil)
                  (setq to-add-in-result t)
                  (setq match nil))
              (throw 'foo nil)))
        (throw 'foo nil)))))

(defun preface-is-white (char)
  "Check if CHAR is `SPC', `\\n', `\\t', `\\r', `\\f' or `\\v'."
  (if (or (eql char ? )
          (eql char ?\t)
          (eql char ?\r)
          (eql char ?\f)
          (eql char ?\v)
          (eql char ?\n))
      t
    nil))

(defun preface-put-overlay (beg end face priority)
  "Put overlay from BEG to END with FACE and PRIORITY." 
  (let ((overlay (make-overlay beg 
                               end)))
    (overlay-put overlay 'face face)
    (overlay-put overlay 'priority priority)
    (push overlay preface-overlays)))

(defun preface-put-overlay-to-symbol-near-point ()
  "Put overlays to the symbol near point. See `preface-get-symbol-near-point'."
  ;; for correct code execution of this package, next modes must be closed.
  (let ((result nil)
        (evil-mode nil)
        (evil-local-mode nil))
    (if preface-is-words-highlighted-for-code
        (setq result (preface-get-symbol-near-point))
      (let ((last-typed-char (char-before)))
        (when (preface-is-white last-typed-char)
          (save-excursion
            (save-restriction
              (widen)
              (backward-char)
              (setq result (preface-get-symbol-near-point))
              (when result
                (goto-char (car (cdr result)))
                (let ((char-before-symbol (char-before)))
                  (unless (preface-is-white char-before-symbol) 
                    (setq result nil))))))))) 
    (when result
      (let* ((beg (car (cdr result)))
             (end (+ beg (length (car result))))
             (face (car (cdr (cdr result)))))
        (preface-put-overlay beg
                             end
                             face
                             preface-overlays-priority-for-code)
        nil))))

(defun preface-put-overlays-in-zone (beg end)
  "Put overlay over symbols from `preface-faces' or `preface-faces-local'." 
  ;; for correct code execution of this package, next modes must be closed.
  (let ((evil-mode nil)                 
        (evil-local-mode nil))
    (goto-char beg)
    (dolist (i preface-faces-for-code)
      (let ((symbols-list (car i))
            (face (cdr i)))
        (dolist (j symbols-list)
          (while (search-forward j end 'noerror)
            (if preface-is-words-highlighted-for-code
                (preface-put-overlay (- (point) (length j))
                                     (point)
                                     face
                                     preface-overlays-priority-for-code)
              (let ((char-after-symbol (char-after)))
                (when (or (preface-is-white char-after-symbol)
                          (eq (point) (point-max)))
                  (save-excursion
                    (goto-char (- (point) (length j)))
                    (let ((char-before-symbol (char-before)))
                      (when (or (preface-is-white char-before-symbol) 
                                (eq (point) 1))
                        (preface-put-overlay
                         (point)
                         (+ (point) (length j))
                         face
                         preface-overlays-priority-for-code))))))))
          (goto-char beg))))))

(defun preface-put-overlay-dynamically (beg end len)
  "Put overlays dynamically over symbols from `preface-faces' or `preface-faces-local'. 
BEG - beginning of region just changed 
END - end of region just changed
LEN - length of the text that existed before the change. 
See `after-change-function', the function is contained on this hook."
  (when (zerop len)
    (save-excursion
      (save-match-data
        (save-restriction
          (widen)
          (if (eql (- end beg) 1)
              (preface-put-overlay-to-symbol-near-point)
            (preface-put-overlays-in-zone beg end)))))))

(define-minor-mode preface-mode
  "Toggle `preface-mode' that puts faces on symbols in buffer.
For complete details read comments from beginning of `preface-mode.el' file."
  :init-value nil
  :lighter nil
  (if preface-mode
      (progn
        (dolist (i preface-overlays)
          (delete-overlay i))
        (setq preface-overlays nil) 
        (preface--set-faces)
        (preface--set-is-words-highlighted)
        (preface--set-overlays-priority)
        (preface--set-data-structure)
        (add-hook 'after-change-functions 'preface-put-overlay-dynamically nil 'local)
        (save-excursion
          (save-match-data 
            (save-restriction
              (preface-put-overlays-in-zone (point-min) (point-max))))))
    (remove-hook 'after-change-functions 'preface-put-overlay-dynamically 'local)
    (dolist (i preface-overlays)
      (delete-overlay i))
    (setq preface-overlays nil))) 

(provide 'preface-mode)



