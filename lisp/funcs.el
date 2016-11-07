;;; funcs.el --- Some functions and macros I use.    -*- lexical-binding: t; -*-

;; Copyright ⓒ 2013-2016 Mattias Bengtsson

;; Author           : Mattias Bengtsson <mattias.jc.bengtsson@gmail.com>
;; Version          : 20141020
;; Keywords         : extensions, tools
;; Package-Requires : ((emacs "25.1"))
;; URL              : TBA
;; Doc URL          : TBA
;; Compatibility    : GNU Emacs: 24.x

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with This program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Note:

;;; Code:

;;;###autoload
(defun my/maximize ()
  "Maximize Emacs."
  (interactive)
  (when (display-graphic-p)
    (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                           '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
    (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                           '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))))

;;;###autoload
(defun my/shorten-minor-modes (modes)
  "Shorten the displayed name for MODES in the modeline."
  (dolist (mode-and-line modes)
    (let ((line (cdr mode-and-line))
          (mode (car mode-and-line)))
      (my/shorten-minor-mode mode line))))

;;;###autoload
(defun my/shorten-minor-mode (mode line)
  "Replace the displayed name for MODE by LINE."
  (let ((hook (intern (concat (symbol-name mode) "-hook"))))
    (add-hook hook (lambda () (diminish mode line)))))

;;;###autoload
(defun my/shorten-major-modes (modes)
  "Shorten the displayed name for MODES in the mode line."
  (dolist (mode-and-line modes)
    (let ((line (cdr mode-and-line))
          (mode (car mode-and-line)))
      (my/shorten-major-mode mode line))))

;;;###autoload
(defun my/shorten-major-mode (mode line)
  "Replace the displayed name for MODE by LINE."
  (let ((hook (intern (concat (symbol-name mode) "-hook"))))
    (add-hook hook (lambda () (setq-local mode-name line)))))

;;;###autoload
(defun my/byte-compile ()
  "Byte compile my configs."
  (interactive)
  (byte-recompile-directory "~/.emacs.d" 0))

;;;###autoload
(defun my/auto-modes (modes)
  "Add many MODES to `auto-mode-alist'."
  (setq auto-mode-alist (append modes auto-mode-alist)))

;;;###autoload
(defun my/global-define-keys (keybindings)
  "Set a bunch of global KEYBINDINGS at the same time."
  (my/define-keys (current-global-map)
                  keybindings))

;;;###autoload
(defun my/global-remap-keys (mappings)
  "Remap a bunch of global keybindings defined in MAPPINGS."
  (my/remap-keys (current-global-map) mappings))

;;;###autoload
(defun my/define-keys (mode-map keybindings)
  "Set a bunch of MODE-MAP specific KEYBINDINGS at the same time."
  (dolist (binding keybindings)
    (let* ((key  (kbd (car binding)))
           (func (cdr binding)))
      (define-key mode-map key func))))

;;;###autoload
(defun my/remap-keys (mode-map mappings)
  "Remap a bunch of MODE-MAP keybindings defined in MAPPINGS."
  (dolist (mapping mappings)
    (let* ((key        (car mapping))
           (value      (cdr mapping))
           (func-remap (and (functionp key) (functionp value)))
           (key-remap  (and (stringp key) (stringp value))))
      (cond (key-remap (define-key mode-map
                         (kbd key)
                         (key-binding (kbd value))))
            (func-remap (substitute-key-definition (car mapping)
                                                   (cdr mapping)
                                                   mode-map))))))

;;;###autoload
(defun my/mapcar-head (fn-head fn-rest list)
  "Like MAPCAR, but apply FN-HEAD to CAR and FN-REST to CDR of LIST."
  (cons (funcall fn-head (car list))
        (mapcar fn-rest (cdr list))))

(defun my/mapconcat-head (fn-head fn-rest list sep)
  "Like `mapconcat', but apply FN-HEAD to CAR and FN-REST to CDR of LIST.
Just like `mapconcat' the last argument (SEP) is used as separator."
  (mapconcat #'identity
             (my/mapcar-head fn-head fn-rest list)
             sep))

;;;###autoload
(defun my/split-name (s)
  "Split S by name."
  (split-string
   (let ((case-fold-search nil))
     (downcase
      (replace-regexp-in-string "\\([a-z]\\)\\([A-Z]\\)" "\\1 \\2" s)))
   "[^A-Za-z0-9]+"))

;;;###autoload
(defun my/lower-camel-case (s)
  "Camel case S."
  (my/mapconcat-head 'downcase
                     'capitalize
                     (my/split-name s)
                     ""))

;;;###autoload
(defun my/camel-case (s)
  "Camel case S."
  (mapconcat #'capitalize (my/split-name s) ""))

;;;###autoload
(defun my/snake-case (s)
  "Snake case S."
  (mapconcat #'downcase (my/split-name s) "_"))

;;;###autoload
(defun my/dash-case (s)
  "Dash case S."
  (mapconcat #'downcase (my/split-name s) "-"))

;;;###autoload
(defun my/is-dash-case (s)
  "Return T if S is in dash-case."
  (let ((case-fold-search nil))
    (string-match-p "[a-z]+\\(?:-[a-z]+\\)+" s)))

;;;###autoload
(defun my/is-camel-case (s)
  "Return T if S is in camel-case."
  (let ((case-fold-search nil))
    (string-match-p "^\\(?:[A-Z][a-z]+\\)+"  s)))

;;;###autoload
(defun my/is-lower-camel-case (s)
  "Return T if S is in lower-camel-case."
  (let ((case-fold-search nil))
    (string-match-p "^[a-z]+\\(?:[A-Z][a-z]+\\)+"  s)))

;;;###autoload
(defun my/is-snake-case (s)
  "Return T if S is in snake-case."
  (let ((case-fold-search nil))
    (string-match-p "^[a-z]+\\(?:_[a-z]+\\)+" s)))

;;;###autoload
(defun my/toggle-programming-case (s) ;; UP
  "Toggle programming style casing of S."
  (cond ((my/is-snake-case       s) (my/dash-case        s))
        ((my/is-dash-case        s) (my/camel-case       s))
        ((my/is-camel-case       s) (my/lower-camel-case s))
        ((my/is-lower-camel-case s) (my/snake-case       s))))

;;;###autoload
(defun my/toggle-programming-case-reverse (s)
  "Toggle programming style casing of S in reverse."
  (cond ((my/is-dash-case        s) (my/snake-case       s))
        ((my/is-snake-case       s) (my/lower-camel-case s))
        ((my/is-lower-camel-case s) (my/camel-case       s))
        ((my/is-camel-case       s) (my/dash-case        s))))

(defun my/toggle-programming-case-word-at-point ()
  "Toggle programming style casing of word a point."
  (interactive)
  (my/operate-on-thing-or-region 'symbol #'my/toggle-programming-case))

(defun my/toggle-programming-case-word-at-point-reverse ()
  "Toggle programming style casing of word a point.
In reverse."
  (interactive)
  (my/operate-on-thing-or-region 'symbol #'my/toggle-programming-case-reverse))

;;;###autoload
(defun my/operate-on-thing-or-region (thing fn)
  "Replace THING or region with the value of the function FN."
  (let (pos1 pos2 meat excerpt)
    (if (and transient-mark-mode mark-active)
        (setq pos1 (region-beginning)
              pos2 (region-end))
      (setq pos1 (car (bounds-of-thing-at-point thing))
            pos2 (cdr (bounds-of-thing-at-point thing))))
    (setq excerpt (buffer-substring-no-properties pos1 pos2))
    (setq meat (funcall fn excerpt))
    (delete-region pos1 pos2)
    (insert  meat)))

(defun my/calc-thing-at-point ()
  "Replace math expression at point or in region with it's value."
  (interactive)
  (my/operate-on-thing-or-region 'symbol #'calc-eval))

;;;###autoload
(defun my/preceding-char-match-p (pattern)
  "Match preceding char with PATTERN."
  (let ((str (string (preceding-char))))
    (string-match-p pattern str)))

;;;###autoload
(defun my/following-char-match-p (pattern)
  "Match following char with PATTERN."
  (let ((str (string (following-char))))
    (string-match-p pattern str)))

(defvar my/time-formats '("%Y%m%d" "%Y-%m-%d" "%A, %d. %B %Y"))

(defun my/get-date (format)
  "Get the current date in FORMAT."
  (let ((system-time-locale "en_US"))
    (format-time-string format)))

(defun my/get-year ()
  "Get the curret year."
  (my/get-date "%Y"))

(defun my/autoinsert-yas-expand()
  "Replace text in yasnippet template."
  (yas-expand-snippet (buffer-string)
                      (point-min)
                      (point-max)))

(defun my/yas-choose-license ()
  "Choose a license to expand."
  (yas-choose-value
   (directory-files "~/.emacs.d/licenses/"
                    nil
                    "^[A-Za-z0-9-+_][A-Za-z0-9-+_.]*$")))

(defun my/get-user-mail-address ()
  "Get variable `user-mail-address' with fallback."
  (if (boundp 'user-mail-address)
      user-mail-address
    "user@example.com"))

(defun my/get-user-full-name ()
  "Get variable `user-full-name' with fallback."
  (if (boundp 'user-full-name)
      user-full-name
    "Full Name"))

;;;###autoload
(defun my/dot-and-complete ()
  "Quicker auto-complete on objects and structs."
  (interactive)
  (my/char-and-complete ?.))

;;;###autoload
(defun my/double-colon-and-complete ()
  "Quicker auto-complete on namespaces and modules."
  (interactive)
  (my/char-and-complete ?: ?:))

;;;###autoload
(defun my/arrow-and-complete ()
  "Quicker auto-complete on namespaces and modules."
  (interactive)
  (my/char-and-complete ?> ?-))

;;;###autoload
(defun my/slash-and-complete ()
  "Quicker auto-complete in lisp-code."
  (interactive)
  (my/char-and-complete ?/))

;;;###autoload
(defun my/dash-and-complete ()
  "Quicker auto-complete in lisp-code."
  (interactive)
  (my/char-and-complete ?-))

;;;###autoload
(defun my/char-and-complete (char &optional prev)
  "Insert CHAR and complete if `preceding-char' is equal to PREV."
  (interactive)
  (let ((do-complete (if prev (char-equal prev (preceding-char)) t)))
    (progn
      (insert char)
      (when do-complete
        (company-complete-common)))))

;;;###autoload
(defun my/isearch-forward-symbol-with-prefix (p)
  "Like function `isearch-forward', unless prefix argument is provided.
With a prefix argument P, isearch for the symbol at point."
  (interactive "P")
  (let ((current-prefix-arg nil))
    (call-interactively
     (if p #'isearch-forward-symbol-at-point
       #'isearch-forward))))

;;;###autoload
(defun my/isearch-backward-symbol (&optional _not-symbol no-recursive-edit)
  "Do incremental search forward for a symbol.
The prefix argument is currently unused.
Like ordinary incremental search except that your input is treated
as a symbol surrounded by symbol boundary constructs \\_< and \\_>.
See the command `isearch-forward' for more information."
  (interactive "P\np")
  (isearch-mode nil nil nil (not no-recursive-edit) 'isearch-symbol-regexp))

;;;###autoload
(defun my/isearch-backward-symbol-at-point ()
  "Do incremental search backward for a symbol found near point.
Like ordinary incremental search except that the symbol found at point
is added to the search string initially as a regexp surrounded
by symbol boundary constructs \\_< and \\_>.
See the command `isearch-backward-symbol' for more information."
  (interactive)
  (my/isearch-backward-symbol nil 1)
  (let ((bounds (find-tag-default-bounds)))
    (cond
     (bounds
      (when (< (car bounds) (point))
        (goto-char (car bounds)))
      (isearch-yank-string
       (buffer-substring-no-properties (car bounds) (cdr bounds))))
     (t
      (setq isearch-error "No symbol at point")
      (isearch-update)))))

;;;###autoload
(defun my/isearch-backward-symbol-with-prefix (p)
  "Like function `isearch-backward', unless prefix argument is provided.
With a prefix argument P, isearch for the symbol at point."
  (interactive "P")
  (let ((current-prefix-arg nil))
    (call-interactively
     (if p #'my/isearch-backward-symbol-at-point
       #'isearch-backward))))

;;;###autoload
(defmacro my/bol-with-prefix (function)
  "Define a new function which call FUNCTION.
Except it moves to beginning of line before calling FUNCTION when
called with a prefix argument.  The FUNCTION still receives the prefix argument."
  (let ((name (intern (format "my/%s-BOL" function))))
    `(progn
       (defun ,name (p)
         ,(format
           "Call `%s', but move to BOL when called with a prefix argument."
           function)
         (interactive "P")
         (when p
           (forward-line 0))
         (call-interactively ',function))
       ',name)))

(defvar ido-matches)
(defvar ido-max-prospects)
(defun my/ido-visible-prospects ()
  "The number of visible prospects."
  ;; TODO: fix smex's `…' (The out-commented stuff is for that)
  (let* ((available-lines (1- (ffloor (* max-mini-window-height (frame-height)))))
         ;; (prospects-len (length ido-matches))
         ;; (dot-dot (< available-lines (max ido-max-prospects prospects-len)))
         )
    (1- available-lines)))

;;;###autoload
(defun my/ido-scroll-down ()
  "A bit more eager `ido-next-match'."
  (interactive)
  (dotimes (_ (my/ido-visible-prospects) nil) (ido-next-match)))

;;;###autoload
(defun my/ido-scroll-up ()
  "A bit more eager `ido-prev-match'."
  (interactive)
  (dotimes (_ (my/ido-visible-prospects) nil) (ido-prev-match)))

(defvar company-tooltip-limit)
(defun my/company-scroll-down ()
  "A bit more eager `company-select-next'."
  (interactive)
  (dotimes (_ (- company-tooltip-limit 1) nil) (company-select-next)))

;;;###autoload
(defun my/company-scroll-up ()
  "A bit more eager `company-select-previous'."
  (interactive)
  (dotimes (_ (- company-tooltip-limit 1) nil) (company-select-previous)))

;;;###autoload
(defvar yas-fallback-behavior)
(defun my/yas-expand ()
  "Perform a `yas-expand' but return nil on failure."
  (when (yas-minor-mode)
    (let ((yas-fallback-behavior 'return-nil))
      (yas-expand))))

;;;###autoload
(defun my/indent-snippet-or-complete ()
  "Tab indent, insert snippet or complete (using `company-mode')
depending on context."
  (interactive)
  (if (minibufferp)
      (minibuffer-complete)
    (let ((old-indent (current-indentation)))
      (indent-for-tab-command)
      (if (and (= old-indent (current-indentation))
               (my/preceding-char-match-p "[a-zA-Z\-\.\>\_\/\:]")
               (null (my/yas-expand)))
          (company-complete-common)))))

;;;###autoload
(defun my/indent-or-complete ()
  "Auto indent or complete (using `company-mode') depending on context."
  (interactive)
  (if (minibufferp)
      (minibuffer-complete)
    (let ((old-indent (current-indentation)))
      (indent-for-tab-command)
      (if (and (= old-indent (current-indentation))
               (my/preceding-char-match-p "[a-zA-Z\-\.\>\_\/\:]"))
          (company-complete-common)))))

;;;###autoload
(defun my/snippet-or-complete ()
  "Insert snippet or complete (using `company-mode') depending on context."
  (interactive)
  (if (minibufferp)
      (minibuffer-complete)
    (when (null (my/yas-expand))
      (company-complete-common))))

;;;###autoload
(defun my/fci-turn-off (&rest _)
  "Turn off `fci-mode'."
  (when (boundp 'fci-mode)
    (turn-off-fci-mode)))

;;;###autoload
(defun my/fci-turn-on (&rest _)
  "Turn on `fci-mode'."
  (when (boundp 'fci-mode)
    (turn-on-fci-mode)))

;;;###autoload
(defun my/reopen-file-as-root ()
  "Re-open file the current buffer is visiting as root."
  (interactive)
  (when buffer-file-name
    (unless (file-writable-p buffer-file-name)
      (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name)))))

;;;###autoload
(defun my/create-non-existent-directory ()
  "Offer to create parent directory for current buffer if it doesn't exist."
  (let ((parent-directory (file-name-directory buffer-file-name)))
    (when (and (not (file-exists-p parent-directory))
               (y-or-n-p (format "Directory `%s' does not exist! Create it?"
                                 parent-directory)))
      (make-directory parent-directory t))))

;;;###autoload
(defun my/restclient ()
  "Create a `restclient-mode' buffer."
  (interactive)
  (switch-to-buffer (get-buffer-create "*REST*"))
  (restclient-mode)
  (insert "# -*- restclient -*-\n\n"))

;;;###autoload
(defun my/magit-mode-quit ()
  "Quit and kill magit-status window and frame."
  (interactive)
  (magit-mode-quit-window 4))

;;;###autoload
(defun my/aim-new-block (mode control-stmts &optional char-tokens)
  "Does this line suggest a new block in MODE.
CONTROL-STMTS is a list of new block introducing control statements.
The optional parameter CHAR-TOKENS is a list of block introducing char tokens."
  (let* ((control-stmt-regex (concat "\\b\\("
                                     (mapconcat #'identity control-stmts "\\|")
                                     "\\)\\b"))
         (char-tokens (or char-tokens "[;{}]"))
         (complete-regex (concat "\\("
                                 "[" char-tokens "]"
                                 "\\|"
                                 control-stmt-regex
                                 "\\)")))
    (and (derived-mode-p mode)
         (null (string-match complete-regex (thing-at-point 'line))))))

;;;###autoload
(defun yas-popup-isearch-prompt (prompt choices &optional display-fn)
  "Use popup.el for yasnippet.  (PROMPT, CHOICES, DISPLAY-FN)."
  (require 'popup)
  (popup-menu*
   (mapcar
    (lambda (choice)
      (popup-make-item
       (or (and display-fn (funcall display-fn choice))
           choice)
       :value choice))
    choices)
   :prompt prompt
   ;; start isearch mode immediately
   :isearch t))

;;;###autoload
(defun my/uniquify-region-lines (beg end)
  "Remove duplicate adjacent lines in region BEG to END."
  (interactive "*r")
  (save-excursion
    (goto-char beg)
    (while (re-search-forward "^\\(.*\n\\)\\1+" end t)
      (replace-match "\\1"))))

;;;###autoload
(defun my/uniquify-buffer-lines ()
  "Remove duplicate adjacent lines in the current buffer."
  (interactive)
  (uniquify-region-lines (point-min) (point-max)))

;;;###autoload
(defun my/occur-dwim ()
  "Call `occur' with a sane default."
  (interactive)
  (push (if (region-active-p)
            (buffer-substring-no-properties
             (region-beginning)
             (region-end))
          (thing-at-point 'symbol))
        regexp-history)
  (call-interactively #'occur))

;;;###autoload
(defun my/wrap-in-comment (string)
  "Wrap STRING inside comment."
  (format "%s%s%s" comment-start string comment-end))

;;;###autoload
(defun my/toggle-comment ()
  "Comments or uncomments current region or line."
  (interactive)
  (let (beg end)
    (if (region-active-p)
        (setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))

(defvar control-mode)
;;;###autoload
(defun my/control-mode-set-cursor ()
  "Update cursor based for `control-mode'."
  (if (display-graphic-p)
      (setq cursor-type (if control-mode
                            'box
                          '(bar . 5)))
    (send-string-to-terminal (if control-mode
                                 "\e[1 q"
                               "\e[5 q"))))

;;;###autoload
(defun my/control-mode-off ()
  "Turn off `control-mode'."
  (interactive)
  (global-control-mode 0))

;;;###autoload
(defun my/control-mode-on ()
  "Turn on `control-mode'."
  (interactive)
  (global-control-mode 1))

;;;###autoload
(defun my/focus-buffer-dwim (buffer)
  "Switch to BUFFER in other window unless it's currently in view."
  (unless (string-equal buffer (buffer-name (current-buffer)))
    (switch-to-buffer-other-window buffer)))

(defun my/advice-describe-func (describe-function)
  "Advice DESCRIBE-FUNCTION to switch to the *Help* buffer after popping it up."
  (advice-add describe-function
              :after (lambda (&rest _) (my/focus-buffer-dwim "*Help*"))))

(defun my/other-window (&rest args)
  "Like `(other-window 1)' but skip ARGS."
  (other-window 1))

(defun my/advice-other-window-after (func)
  "Advice FUNC to switch window after been run."
  (advice-add func :after #'my/other-window))

;;;###autoload
(defun my/rename-current-buffer-and-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

;;;###autoload
(defun my/list-installed-packages ()
  "Like `package-list-packages', but show only installed optional packages."
  (interactive)
  (package-initialize)
  (package-show-package-list
   (cl-remove-if-not (lambda (x) (and (not (package-built-in-p x))
                                      (package-installed-p x)))
                     (mapcar #'car package-archive-contents))))

;;;###autoload
(defun my/set-proxy ()
  "Automatically set HTTP proxy in Emacs based on system environment."
  (interactive)
  (if (and (getenv "HTTP_PROXY") (getenv "HTTPS_PROXY"))
      (setq-default url-proxy-services '(("http"  . (getenv "HTTP_PROXY"))
                                         ("https" . (getenv "HTTPS_PROXY"))
                                         ))))
;;;###autoload
(defun my/term-paste (&optional string)
  "Paste STRING into a term-buffer."
  (interactive)
  (process-send-string
   (get-buffer-process (current-buffer))
   (if string string (current-kill 0))))

;; Taken from here:
;; http://endlessparentheses.com/ispell-and-abbrev-the-perfect-auto-correct.html
;;;###autoload
(defun my/ispell-word-then-abbrev (p)
  "Call `ispell-word', then create an abbrev for it.
With prefix P, create local abbrev.  Otherwise it will
be global.
If there's nothing wrong with the word at point, keep
looking for a typo until the beginning of buffer.  You can
skip typos you don't want to fix with `SPC', and you can
abort completely with `C-g'."
  (interactive "P")
  (let (bef aft)
    (save-excursion
      (while (if (setq bef (thing-at-point 'word))
                 ;; Word was corrected or used quit.
                 (if (ispell-word nil 'quiet)
                     nil ; End the loop.
                   ;; Also end if we reach `bob'.
                   (not (bobp)))
               ;; If there's no word at point, keep looking
               ;; until `bob'.
               (not (bobp)))
        (backward-word))
      (setq aft (thing-at-point 'word)))
    (if (and aft bef (not (equal aft bef)))
        (let ((aft (downcase aft))
              (bef (downcase bef)))
          (define-abbrev
            (if p local-abbrev-table global-abbrev-table)
            bef aft)

          (message "\"%s\" now expands to \"%s\" %sally"
                   bef aft (if p "loc" "glob")))
      (user-error "No typo at or before point"))))

;;;###autoload
(defun my/shell-command-dwim (command &optional
                                      output-buffer
                                      replace
                                      error-buffer
                                      display-error-buffer)
  "Like `shell-command-on-region' but infer START and END from context.
COMMAND, OUTPUT-BUFFER, REPLACE, ERROR-BUFFER and DISPLAY-ERROR-BUFFER are just
passed on unchanged."
  (interactive "sShell command: ")
  (shell-command-on-region (if (region-active-p) (region-beginning) (point-min))
                           (if (region-active-p) (region-end)       (point-max))
                           command
                           output-buffer
                           replace
                           error-buffer
                           display-error-buffer))

;; TODO: Save URL in kill-ring
;;;###autoload
(defun my/fpaste-dwim ()
  "Push the current region or buffer to paste.fedoraproject.org."
  (interactive)
  (my/shell-command-dwim (format "fpaste -n %s" (user-login-name))))

;; TODO: Make this work
;;;###autoload
(defun my/fpaste-insert (url)
  "Fetch an fpaste from URL."
  (interactive "sFPaste URL: ")
  (let* ((url (format "%s/raw" url))
         (cmd (format "curl \"%s\" 2>/dev/null" url))
         (err-buf "*Shell Command Error*"))
    (shell-command cmd t err-buf)))

;;;###autoload
(defun my/set-imenu-create-index-function (&optional function separator)
  "Set up a flat `imenu'.
Generate index with FUNCTION (default: `imenu-create-index-function').
Separate with SEPARATOR if set (default: '/')"
  (let ((func (or function imenu-create-index-function))
        (sepa (or separator "/")))
    (setq-local imenu-create-index-function
                (lambda ()
                  (my/flatten-imenu-index (funcall func) sepa)))))

;;;###autoload
(defun my/flatten-imenu-index (index separator)
  "Flatten `imenu' INDEX w/ SEPARATOR."
  (let ((cdr-is-index (listp (cdr index))))
    (cond ((not (stringp (car index)))
           (cl-mapcan (lambda (idx) (my/flatten-imenu-index idx separator))
                      index))
          (cdr-is-index (my/imenu-prefix-flattened index separator))
          (t (list index)))))

;;;###autoload
(defun my/imenu-prefix-flattened (index separator)
  "Flatten `imenu' INDEX w/ SEPARATOR."
  (let ((flattened (my/flatten-imenu-index (cdr index) separator)))
    (cl-loop for sub-item in flattened
             collect
             `(,(concat (car index)
                        separator
                        (car sub-item))
               .
               ,(cdr sub-item)))))

;;;###autoload
(defun my/open-with (arg)
  ;; Taken from Prelude
  "Open visited file in default external program.
With a prefix ARG always prompt for command to use."
  (interactive "P")
  (when buffer-file-name
    (let ((is-osx    (eq system-type 'darwin))
          (is-linux (member system-type '(gnu gnu/linux gnu/kfreebsd))))
      (shell-command (concat
                      (cond
                       ((and (not arg) is-osx)   "open")
                       ((and (not arg) is-linux) "xdg-open")
                       (t (read-shell-command "Open current file with: ")))
                      " "
                      (shell-quote-argument buffer-file-name))))))

;;;###autoload
(defun my/guess-cc-mode ()
  "Guess whether to activate `c-mode' or `c++-mode' for a .h-file."
  (interactive)
  (let ((c-file (concat (substring (buffer-file-name) 0 -1) "c")))
    (if (file-exists-p c-file)
        (c-mode)
      (c++-mode))))

;;;###autoload
;; From: http://endlessparentheses.com/fill-and-unfill-paragraphs-with-a-single-key.html
(defun my/fill-or-unfill ()
  "Like `fill-paragraph', but unfill if used twice."
  (interactive)
  (let ((fill-column
         (if (eq last-command 'endless/fill-or-unfill)
             (progn (setq this-command nil)
                    (point-max))
           fill-column)))
    (call-interactively #'fill-paragraph)))

;;;###autoload
(defun my/package-init ()
  "Initialize the package system."
  (package-initialize)
  (unless (seq-every-p #'package-installed-p
                       package-selected-packages)
    (package-refresh-contents)
    (my/install-packages-in-dir "~/.emacs.d/packages/")
    (package-install-selected-packages)))

;;;###autoload
(defun my/install-packages-in-dir (directory)
  "Install all packages in DIRECTORY."
  (mapc #'package-install-file
        (directory-files directory t "^\\([^.]\\|\\.[^.]\\|\\.\\..\\)")))

;;;###autoload
(defun my/set-terminal-cursors ()
  "Set up the terminal cursors."
  (send-string-to-terminal (concat "\033]12;" (face-background 'cursor) "\007"))
  (add-hook 'kill-emacs-hook
            (lambda ()
              (send-string-to-terminal "\033]12;white\007\e[1 q"))))

;;;###autoload
(defun my/projectile-regen-rtags ()
  "Update rtags for current project."
  (interactive)
  (let* ((project (projectile-project-name))
         (type (projectile-project-type)))
    (when (eq type 'jhbuild)
      (my/projectile-regen-rtags-jhbuild project))))

(defun my/projectile-regen-rtags-jhbuild (module)
  "Create a `compile_commands.json' file for `JHBuild' MODULE and feed it to rc."
  (let* ((jhbuild-prefix (format "jhbuild run --in-builddir=%s -- " module))
         (compile-cmd (mapconcat
                       (lambda (s) (concat jhbuild-prefix s))
                       '("make clean" "bear make" "rc -J compile_commands.json")
                       " && ")))
    (compile compile-cmd)))

(defun my/find-git-projects (dir &optional depth)
  "Find all git projects under DIR.
Optionally only search as deep as DEPTH."
  (let* ((depth-flag (if depth (format "-maxdepth %d" depth) ""))
         (cmd (format "find %s %s -name '.git' -type d" dir depth-flag))
         (result (split-string (shell-command-to-string cmd))))
    (mapcar (lambda (s) (substring s 0 -4)) result)))

;;;###autoload
(defun my/projectile-index-projects ()
  "Index my project directories."
  (interactive)

  (mapc #'projectile-add-known-project
        (my/find-git-projects "~/" 5))

  (projectile-cleanup-known-projects))

;;;###autoload
(defun my/projectile-gitg ()
  "Run gitg at root of project."
  (interactive)
  (projectile-with-default-dir (projectile-project-root)
    (call-process "/usr/bin/gitg" nil 0)))

;;;###autoload
(defun my/quit-iedit-mode ()
  "Turn off `iedit-mode'."
  (interactive)
  (iedit-mode -1))

(defvar flyspell-old-buffer-error)
(defvar flyspell-old-pos-error)
;;;###autoload
(defun my/flyspell-goto-previous-error ()
  "Go to ARG previous spelling error."
  (interactive)
  (let ((arg 1))
    (while (not (= 0 arg))
      (let ((pos (point))
            (min (point-min)))
        (if (and (eq (current-buffer) flyspell-old-buffer-error)
                 (eq pos flyspell-old-pos-error))
            (progn
              (if (= flyspell-old-pos-error min)
                  ;; goto beginning of buffer
                  (progn
                    (message "Restarting from end of buffer")
                    (goto-char (point-max)))
                (backward-word 1))
              (setq pos (point))))
        ;; seek the next error
        (while (and (> pos min)
                    (let ((ovs (overlays-at pos))
                          (r '()))
                      (while (and (not r) (consp ovs))
                        (if (flyspell-overlay-p (car ovs))
                            (setq r t)
                          (setq ovs (cdr ovs))))
                      (not r)))
          (backward-word 1)
          (setq pos (point)))
        ;; save the current location for next invocation
        (setq arg (1- arg))
        (setq flyspell-old-pos-error pos)
        (setq flyspell-old-buffer-error (current-buffer))
        (goto-char pos)
        (if (= pos min)
            (progn
              (message "No more miss-spelled word!")
              (setq arg 0)))))))

(defvar my/realgud-debugger
  (lambda ()
    (interactive)
    (error "No debugger for this mode")))

(defun my/realgud-debug ()
  "Run a `realgud' debugger."
  (interactive)
  (require 'realgud)
  (call-interactively my/realgud-debugger))

(provide 'funcs)
;;; funcs.el ends here
