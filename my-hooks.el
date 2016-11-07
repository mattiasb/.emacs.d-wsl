;;; my-hooks.el --- My mode hooks -*- lexical-binding: t; -*-

;; Copyright ⓒ 2016 Mattias Bengtsson

;; Author           : Mattias Bengtsson <mattias.jc.bengtsson@gmail.com>
;; Version          : 20160417
;; Keywords         : init
;; Package-Requires : ((emacs "25.1"))
;; URL              : https://github.com/moonlite/.emacs.d
;; Compatibility    : GNU Emacs: 25.x

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

;; AG
(defvar ag-mode-map)
(defun my/ag-mode-hook ()
  "My `ag' mode hook."
  (my/define-keys ag-mode-map
                  '(( "W" . wgrep-change-to-wgrep-mode))))

(add-hook 'ag-mode-hook #'my/ag-mode-hook)

;; Browse Kill Ring
(defvar browse-kill-ring-mode-map)
(defun my/browse-kill-ring-mode-hook ()
  "My `browse-kill-ring' mode hook."
  (my/define-keys browse-kill-ring-mode-map
                  '(( "<down>"    . browse-kill-ring-forward)
                    ( "<tab>"     . browse-kill-ring-forward)
                    ( "<up>"      . browse-kill-ring-previous)
                    ( "<backtab>" . browse-kill-ring-previous)
                    ( "C-g"       . browse-kill-ring-quit))))

(add-hook 'browse-kill-ring-mode-hook #'my/browse-kill-ring-mode-hook)

;; C common
(defvar c-mode-base-map)
(defun my/c-mode-common-hook ()
  "My `c-mode' mode hook."
  (unless (keymap-parent c-mode-base-map)
    (set-keymap-parent c-mode-base-map prog-mode-map)))

(add-hook 'c-mode-common-hook #'my/c-mode-common-hook)

;; C / C++
(defvar rtags-completions-enabled)
(defvar company-backends)
(defvar projectile-command-map)
(defun my/c-mode-hook ()
  "A mode hook for C and C++."
  (require 'rtags)
  (require 'company-rtags)
  (rtags-start-process-unless-running)
  (setq-local rtags-completions-enabled t)
  (rtags-enable-standard-keybindings c-mode-base-map)
  (setq-local company-backends '((company-rtags
                                  company-keywords
                                  company-files)))

  ;; Work around bug where c-mode-base-map doesn't inherit from
  ;; prog-mode-map
  (my/define-keys c-mode-base-map
                  '(( "C-<return>" . rtags-find-symbol-at-point)
                    ( "M-<left>"   . rtags-location-stack-back)
                    ( "M-<right>"  . rtags-location-stack-forward)
                    ( "C-z f r"    . rtags-rename-symbol)
                    ( "."          . my/dot-and-complete)
                    ( ":"          . my/double-colon-and-complete)
                    ( ">"          . my/arrow-and-complete)))
  (my/define-keys projectile-command-map
                  '(( "j"         . rtags-find-symbol))))

(add-hook 'c-mode-hook   #'my/c-mode-hook)
(add-hook 'c++-mode-hook #'my/c-mode-hook)

;; CMake
(defun my/cmake-mode-hook ()
  "My `cmake' mode hook."
  (setq-local company-backends '((company-cmake
                                  company-keywords
                                  company-files
                                  company-dabbrev-code))))

(add-hook 'cmake-mode-hook #'my/prog-mode)
(add-hook 'cmake-mode-hook #'my/cmake-mode-hook)

;; Control
(defvar control-mode)
(defvar control-mode-keymap)
(defun my/control-mode-hook ()
  "My `control' mode hook."
  (my/control-mode-set-cursor)
  (my/define-keys control-mode-keymap
                  '(( "i"           . my/control-mode-off)
                    ( "<escape>"    . ESC-prefix)
                    ( "x x"         . smex)
                    ( "x s"         . save-buffer)
                    ( "x S"         . save-some-buffers))))

(add-hook 'control-mode-keymap-generation-functions
          'control-mode-ctrlx-hacks)
(add-hook 'control-mode-hook #'my/control-mode-hook)

;; Company
(defvar company-active-map)
(defun my/company-mode-hook ()
  "My `company' mode hook."
  (company-quickhelp-mode)

  ;; Make it possible to undo unwanted completion.
  (define-key company-active-map (kbd "<SPC>")
    '(lambda()
       (interactive)
       (insert " ")
       (undo-boundary)
       (company-complete-selection)))

  (my/define-keys company-active-map
                  '(( "\C-n"    . company-select-next)
                    ( "\C-p"    . company-select-previous)
                    ( "<next>"  . my/company-scroll-down)
                    ( "<prior>" . my/company-scroll-up)
                    ( "\C-v"    . company-show-location)
                    ( "\C-g"    . company-abort))))

(add-hook 'company-mode-hook                 #'my/company-mode-hook)
(add-hook 'company-completion-started-hook   #'my/fci-turn-off)
(add-hook 'company-completion-finished-hook  #'my/fci-turn-on)
(add-hook 'company-completion-cancelled-hook #'my/fci-turn-on)

;; Cython
(defun my/cython-mode-hook ()
  "My `cython' mode hook."
  (require 'flycheck-cython))

(add-hook 'cython-mode-hook #'my/cython-mode-hook)

;; Dired
(defvar dired-mode-map)
(defun my/dired-mode-hook ()
  "My `dired' mode hook."
  (hl-line-mode)
  (dired-hide-details-mode)
  (my/define-keys dired-mode-map
                  '(( "W" . wdired-change-to-wdired-mode)
                    ( "F" . find-name-dired)
                    ( "c" . find-file)))
  (my/remap-keys dired-mode-map
                 '(("s" . "C-s")
                   ("r" . "C-r"))))

(add-hook 'dired-mode-hook #'my/dired-mode-hook)

;; ELisp
(defun my/emacs-lisp-mode-hook ()
  "My `emacs-lisp' mode hook."
  (setq page-delimiter
        (rx bol ";;;" (not (any "#")) (* not-newline) "\n"
            (* (* blank) (opt ";" (* not-newline)) "\n"))))

(add-hook 'emacs-lisp-mode-hook #'lisp-extra-font-lock-mode)
(add-hook 'emacs-lisp-mode-hook #'my/emacs-lisp-mode-hook)

;; Flycheck
(defun my/flycheck-mode-hook ()
  "My `flycheck' mode hook."
  (flycheck-pos-tip-mode)
  (flycheck-status-emoji-mode)
  (flycheck-cask-setup)
  (flycheck-package-setup))

(add-hook 'flycheck-mode-hook #'my/flycheck-mode-hook)

;; Flyspell
(defvar flyspell-mode-map)
(defun my/flyspell-mode-hook ()
  "My `flyspell' mode hook."
  (require 'flyspell-correct-popup)
  (flyspell-buffer)
  (my/define-keys flyspell-mode-map
                  '(("C-," . my/flyspell-goto-previous-error)
                    ("C-." . flyspell-goto-next-error)
                    ("C-;" . flyspell-correct-previous-word-generic)
                    ("C-:" . flyspell-correct-next-word-generic))))

(add-hook 'flyspell-mode-hook #'my/flyspell-mode-hook)

;; Find-file
(add-hook 'find-file-not-found-functions #'my/create-non-existent-directory)

;; Go
(defvar go-mode-map)
(defun my/go-mode-hook ()
  "My `go' mode hook."
  (go-eldoc-setup)

  (setq-local tab-width 4)
  (setq-local company-backends '(company-go
                                 company-keywords
                                 company-files))

  (my/define-keys go-mode-map
                  '(( "C-z i a"    . go-import-add)
                    ( "C-z i r"    . go-remove-unused-imports)
                    ( "C-z i g"    . go-goto-imports)
                    ( "C-z d"      . godoc-at-point)
                    ( "C-<return>" . godef-jump)
                    ( "."          . my/dot-and-complete))))

(add-hook 'go-mode-hook #'my/go-mode-hook)

;; Haskell
(defun my/haskell-mode-hook ()
  "My `haskell' mode hook."
  (setq-local electric-indent-mode nil)
  (turn-on-haskell-indentation))

(add-hook 'haskell-mode-hook #'my/haskell-mode-hook)

;; Help
(defvar help-mode-map)
(defun my/help-mode-hook ()
  "My `help' mode hook."
  (my/define-keys help-mode-map
                  '(( "M-<left>"  . help-go-back)
                    ( "M-<right>" . help-go-forward)))
  (my/remap-keys help-mode-map
                 '(("s" . "C-s")
                   ("r" . "C-r"))))

(add-hook 'help-mode-hook #'my/help-mode-hook)

;; Ido
(defvar ido-common-completion-map)
(defun my/ido-setup-hook ()
  "My `ido' mode hook."
  (my/define-keys ido-common-completion-map
                  '(( "<tab"    . ido-complete)
                    ( "<next>"  . my/ido-scroll-down)
                    ( "<prior>" . my/ido-scroll-up))))

(add-hook 'ido-setup-hook #'my/ido-setup-hook)

;; IBuffer
(defvar ibuffer-sorting-mode)
(defun my/ibuffer-hook ()
  "My `ibuffer' mode hook."
  (ibuffer-projectile-set-filter-groups)
  (unless (eq ibuffer-sorting-mode 'alphabetic)
    (ibuffer-do-sort-by-alphabetic)))

(add-hook 'ibuffer-hook 'my/ibuffer-hook)

;; Iedit
(defvar iedit-mode-keymap)
(defun my/iedit-mode-hook ()
  "My `iedit' mode hook."
  (my/define-keys iedit-mode-keymap
                  '(("<return>" . my/quit-iedit-mode))))

(add-hook 'iedit-mode-hook #'my/iedit-mode-hook)

;; IELM
(defvar ielm-map)
(defun my/ielm-mode-hook ()
  "My `ielm' mode hook."
  (company-mode)
  (my/define-keys ielm-map
                  '(( "<tab>" . my/indent-snippet-or-complete))))

(add-hook 'ielm-mode-hook #'my/ielm-mode-hook)

;; Info
(defun my/Info-mode-hook ()
  "My `Info' mode hook."
  (my/define-keys Info-mode-map
                  '(( "M-<left>"  . Info-history-back)
                    ( "M-<right>" . Info-history-forward)
                    ( "M-<up>"    . Info-up))))

(add-hook 'Info-mode-hook #'my/Info-mode-hook)
(add-hook 'Info-selection-hook #'niceify-info)

;; Java
(defun my/java-mode-hook ()
  "My `java' mode hook."
  (require 'ensime-company)
  (ensime)
  (setq-local company-backends '((ensime-company))))

(add-hook 'java-mode-hook #'my/java-mode-hook)

;; JS2
(defvar js2-mode-map)
(defvar flimenu-imenu-separator)
(autoload 'js2r-rename-var "js2-refactor" "" t nil)

(defun my/js2-mode-hook ()
  "My `js2' mode hook."
  (require 'js2-refactor)
  (js2-imenu-extras-mode)
  (setq flimenu-imenu-separator ".")
  (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t)

  (my/define-keys js2-mode-map
                  '(( "C-z f r"    . js2r-rename-var)))

  (setq-local company-backends '((company-dabbrev-code
                                  company-files
                                  company-keywords))))

(add-hook 'js2-mode-hook #'my/js2-mode-hook)

(defvar tern-mode-keymap)
(defun my/tern-mode-hook ()
  "My `tern' mode hook."
  (my/define-keys tern-mode-keymap
                  '(( "M-<left>"   . tern-pop-find-definition)
                    ( "C-<return>" . tern-find-definition)
                    ( "C-z f r"    . tern-rename-variable))))

(add-hook 'tern-mode-hook #'my/tern-mode-hook)

;; JSON
(defun my/json-mode-hook ()
  "My `json' mode hook."
  (highlight-numbers-mode -1))

(add-hook 'json-mode-hook #'my/json-mode-hook)

;; Lua
(defun my/lua-mode-hook ()
  "My `lua' mode hook."
  (setq-local company-backends '((company-dabbrev-code
                                  company-files
                                  company-keywords))))

(add-hook 'lua-mode-hook #'my/lua-mode-hook)

;; Magit
(defun my/git-commit-mode-hook ()
  "My `git-commit' mode hook."
  (my/control-mode-off)
  (flyspell-mode)
  (auto-fill-mode)
  (fci-mode 1)
  (setq-local fill-column 72))

(autoload 'turn-on-magit-gitflow "magit-gitflow" "" t nil)
(defun my/magit-mode-hook ()
  "My `magit' mode hook."
  (require 'magit-gitflow)
  (turn-on-magit-gitflow)
  (add-hook 'magit-post-refresh-hook
            #'git-gutter:update-all-windows))

(defvar magit-blame-mode-map)
(defun my/magit-blame-mode-hook ()
  "My `magit-blame' mode hook."
  (my/define-keys magit-blame-mode-map
                  '(( "C-z t b"     .  magit-blame-quit))))

(add-hook 'magit-status-mode-hook #'magit-filenotify-mode)
(add-hook 'magit-blame-mode-hook  #'my/magit-blame-mode-hook)
(add-hook 'magit-mode-hook        #'my/magit-mode-hook)
(add-hook 'git-commit-mode-hook   #'my/git-commit-mode-hook)

;; Markdown
(defvar markdown-mode-map)
(defun my/markdown-mode-hook ()
  "My `markdown' mode hook."
  (flyspell-mode)
  (setq-local fill-column 80)
  (fci-mode)
  (auto-fill-mode)
  (setq-local indent-tabs-mode nil)
  (my/define-keys markdown-mode-map
                  '(( "C-<return>" . markdown-jump)
                    ( "C-c C-c p"  . my/open-with)
                    ( "M-<up>"     . nil)
                    ( "M-<down>"   . nil))))

(add-hook 'markdown-mode-hook #'my/markdown-mode-hook)

;; MTG deck mode
(defvar mtg-deck-mode-map)
(defun my/mtg-deck-mode-hook ()
  "My `mtg-deck' mode hook."
  (company-mode)
  (setq-local company-backends '(company-capf))
  (my/define-keys mtg-deck-mode-map
                  '(( "<tab>" . my/snippet-or-complete))))

(add-hook 'mtg-deck-mode-hook #'my/mtg-deck-mode-hook)

;; Multiple Cursors
(defun my/multiple-cursors-mode-enabled-hook ()
  "My `multiple-cursors' mode hook."
  (control-mode-reload-bindings))

(add-hook 'multiple-cursors-mode-enabled-hook
          #'my/multiple-cursors-mode-enabled-hook)

;; nXML
(defvar nxml-mode-map)
(defun my/nxml-mode-hook ()
  "My `nxml' mode hook."
  (setq-local company-backends '(company-nxml
                                 company-keywords
                                 company-files))
  (my/define-keys nxml-mode-map
                  '(( "<tab>" . my/indent-snippet-or-complete))))

(add-hook 'nxml-mode-hook #'my/nxml-mode-hook)
(add-hook 'nxml-mode-hook #'my/prog-mode)

;; Package Menu
(defun my/package-menu-mode-hook ()
  "My `package-menu' mode hook."
  (hl-line-mode)
  (my/remap-keys package-menu-mode-map
                 '(("s" . "C-s")
                   ("R" . "r")
                   ("r" . "C-r"))))

(add-hook 'package-menu-mode-hook #'my/package-menu-mode-hook)

;; Prog
(defvar flyspell-prog-text-faces)
(defun my/prog-mode ()
  "My `prog-mode' hook."

  (setq-local fill-column 80)
  (unless (derived-mode-p 'makefile-mode)
    (setq-local indent-tabs-mode nil))

  (ws-butler-mode)
  (company-mode)
  (flycheck-mode)
  (setq flyspell-prog-text-faces
        '(font-lock-comment-face font-lock-doc-face))
  (flyspell-prog-mode)
  (fci-mode)
  (highlight-numbers-mode)
  (emr-initialize)

  (my/define-keys prog-mode-map
                  '(( "<tab>"       . my/indent-snippet-or-complete)
                    ( "C-z f e"     . iedit-mode)
                    ( "C-z f f"     . emr-show-refactor-menu)
                    ( "C-z d"       . nil)
                    ( "C-z d d"     . my/realgud-debug)
                    ( "C-z d a"     . realgud-short-key-mode)))
  (my/remap-keys  prog-mode-map
                  '(( "RET"         . "M-j"))))

(add-hook 'prog-mode-hook #'my/prog-mode)

;; Projectile
(defvar projectile-known-projects)
(defun my/projectile-mode-hook ()
  "My `projectile' mode hook."

  (unless projectile-known-projects
    (my/projectile-index-projects))

  (setq projectile-mode-line
        '(:eval (format " [%s]" (projectile-project-name))))

  (projectile-register-project-type 'jhbuild
                                    (lambda () nil)
                                    "jhbuild make"
                                    "make check"
                                    "jhbuild make && jhbuild run ${PWD##*/}")

  (my/define-keys projectile-command-map
                  '(( "B"   . projectile-ibuffer)
                    ( "i"   . my/projectile-index-projects)
                    ( "I"   . projectile-invalidate-cache)
                    ( "d"   . projectile-dired)
                    ( "V"   . my/projectile-gitg)
                    ( "D"   . projectile-find-dir)))

  (control-mode-reload-bindings)

  (def-projectile-commander-method ?d
    "Open project root in dired."
    (projectile-dired))

  (def-projectile-commander-method ?q
    "Go back to project selection."
    (projectile-switch-project))

  (def-projectile-commander-method ?t
    "Open a terminal in the project root."
    (ansi-term (getenv "SHELL")
               (format "*ansi-term [%s]*" (projectile-project-name)))))

(add-hook 'projectile-mode-hook #'my/projectile-mode-hook)

;; Python
(defvar anaconda-mode-map)
(defvar python-mode-map)
(defvar my/realgud-debugger)
(defvar yas-indent-line)
(defun my/python-mode-hook ()
  "My `python' mode hook."
  (setq-local fill-column 79)           ; PEP0008 says lines should be 79 chars
  (setq-local my/realgud-debugger #'realgud:ipdb)
  (setq-local company-backends '(company-anaconda))
  (anaconda-mode)
  (anaconda-eldoc-mode)
  (setq-local yas-indent-line 'fixed)
  (my/define-keys python-mode-map
                  '(( "."          . my/dot-and-complete))))

(add-hook 'python-mode-hook #'my/python-mode-hook)

;; Anaconda
;; TODO: Figure out bindings for this
;; M-, 		anaconda-mode-find-assignments
;; M-? 		anaconda-mode-show-doc
(defun my/anaconda-mode-hook ()
  "My `anaconda' mode hook."
  (my/define-keys anaconda-mode-map
                  '(( "M-<left>"   . anaconda-mode-go-back)
                    ( "C-<return>" . anaconda-mode-find-definitions)
                    ( "M-?"        . anaconda-mode-find-references))))

(add-hook 'anaconda-mode-hook #'my/anaconda-mode-hook)

;; Realgud Track
(defvar realgud-track-mode-map)
(defun my/realgud-track-mode-hook ()
  "My `realgud-track' mode hook."
  (my/define-keys realgud-track-mode-map
                  '(( "."          . my/dot-and-complete)
                    ( "<tab>"  . my/snippet-or-complete))))

(add-hook 'realgud-track-mode-hook #'my/realgud-track-mode-hook)

;; REST Client
(defvar restclient-mode-map)
(defun my/restclient-mode-hook ()
  "My `restclient' mode hook."
  (company-mode)
  (setq-local company-backends '((company-restclient)))
  (my/define-keys restclient-mode-map
                  '(( "<tab>" . my/snippet-or-complete))))

(add-hook 'restclient-mode-hook #'my/restclient-mode-hook)

;; Rust
(defvar rust-mode-map)
(defun my/rust-mode-hook ()
  "My `rust' mode hook."
  (racer-mode)
  (my/define-keys rust-mode-map
                  '(( "C-<return>" . racer-find-definition)
                    ( "."          . my/dot-and-complete)
                    ( ":"          . my/double-colon-and-complete))))

(add-hook 'rust-mode-hook #'my/rust-mode-hook)

;; Shell
(defvar term-raw-map)
(defvar yas-dont-activate)
(defun my/term-mode-hook ()
  "My `term' mode hook."
  (setq yas-dont-activate t)
  (my/define-keys term-raw-map
                  '(( "M-x"       . smex)
                    ( "C-y"       . my/term-paste)
                    ( "<escape>"  . ESC-prefix))))

(defun my/term-exec-hook ()
  "My `term' mode hook."
  (set-buffer-process-coding-system 'utf-8-unix
                                    'utf-8-unix))

(add-hook 'term-mode-hook #'my/term-mode-hook)
(add-hook 'term-exec-hook #'my/term-exec-hook)

;; Shell script
(defun my/sh-mode-hook ()
  "My `sh' mode hook."
  (setq-local my/realgud-debugger #'realgud:bashdb)
  (setq-local company-backends '((company-shell
                                  company-keywords
                                  company-files
                                  company-dabbrev-code)))
  (sh-extra-font-lock-activate))

(add-hook 'sh-mode-hook #'my/sh-mode-hook)


;; Sql
(defun my/sql-mode-hook ()
  "My `sql' mode hook."
  (sqlup-mode))

(add-hook 'sql-mode-hook #'my/sql-mode-hook)


;; Vala
(defvar flycheck-checkers)
(defun my/vala-mode-hook ()
  "My `vala' mode hook."
  (require 'flycheck-vala)
  (add-to-list 'flycheck-checkers 'vala-valac))

(add-hook 'vala-mode-hook #'my/prog-mode)
(add-hook 'vala-mode-hook #'my/vala-mode-hook)

;; Woman
(defvar woman-mode-map)
(defun my/woman-mode-hook ()
  "My `woman' mode hook."
  (my/remap-keys woman-mode-map
                 '(("a" . "s")
                   ("s" . "C-s")
                   ("R" . "r")
                   ("r" . "C-r"))))

(add-hook 'woman-mode-hook #'my/woman-mode-hook)

(provide 'my-hooks)
;;; my-hooks.el ends here
