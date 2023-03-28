;;; bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; install use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq straight-vc-git-default-clone-depth '(1 single-branch))
(setq use-package-verbose nil)



;;; performance
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ; 1mb
(setenv "LSP_USE_PLISTS" "1")
;;(setenv "DOOMDIR" "~/emacs/emacs_profiles/doom/config")


;;;; packages

(use-package pdf-tools
    :config 
  (pdf-tools-install)
  (setq pdf-view-use-scaling t)
  (setq-default pdf-view-display-size 'fit-page))

(use-package magit)

;; lol doesn't work because emacs 28 introduced a breaking change or something idk
;; (use-package slime)

;; don't bother spinning up daemon; instead, emacs just doesn't close the last frame
;; consider using (server-start) so we can bind an Automator task to do some shizzle
(use-package mac-pseudo-daemon
    :config
  (mac-pseudo-daemon-mode 1))

(use-package vterm
    :config
  (setq vterm-shell "fish"))

(use-package prescient)
(use-package ivy-prescient
    :config
  (ivy-prescient-mode 1))

(use-package counsel
    :config
  (setq ivy-use-virtual-buffers t
        ivy-count-format "%d/%d ")
  (ivy-mode 1))

(use-package all-the-icons-ivy-rich
    :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
    :config
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)
  (ivy-rich-mode 1))


(use-package ledger-mode)

(use-package doom-themes
    :ensure t
    :config
    ;; Global settings (defaults)
    (setq doom-themes-enable-bold t     ; if nil, bold is universally disabled
          doom-themes-enable-italic t)  ; if nil, italics is universally disabled
    (load-theme 'doom-palenight t)

    ;; Enable flashing mode-line on errors
    (doom-themes-visual-bell-config)
    ;; Enable custom neotree theme (all-the-icons must be installed!)
					; (doom-themes-neotree-config)
    ;; or for treemacs users
					; (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
					; (doom-themes-treemacs-config)
    ;; Corrects (and improves) org-mode's native fontification.
    (doom-themes-org-config))

					; modeline
(use-package doom-modeline
    :ensure t
    :hook (after-init . doom-modeline-mode))

;; distinguish between "real" and "virtual" buffers
(use-package solaire-mode
    :ensure t
    :config
    (solaire-global-mode +1))


;;; org mode
(setq org-src-preserve-indentation t
      org-src-fontify-natively t
      org-export-latex-listings t
      org-export-with-smart-quotes t
      org-latex-listings 'listings
      org-latex-prefer-user-labels t
      org-confirm-babel-evaluate nil
      org-latex-pdf-process '("latexmk -bibtex -f -xelatex %f")
      org-babel-python-command "/usr/bin/env python3"
      org-startup-folded t
      org-cycle-include-plain-lists 'integrate
      org-agenda-skip-scheduled-if-done t
      org-startup-indented t)

(add-to-list 'org-latex-packages-alist '("" "listings"))

(setq org-directory "~/emacs/org/")


;;; lsp
(use-package lsp-mode
    :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (
         (cc-mode . lsp-deferred)
	 (python-mode . lsp-deferred)
	 (zig-mode . lsp-deferred)
	 (rustic-mode . lsp-deferred))
  ;; If you want which-key integration
  ;;(lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred))

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; lsp lang
(use-package lsp-pyright
    :ensure t
    :hook (python-mode . (lambda ()
			   (require 'lsp-pyright)
			   (lsp-deferred))))  ; or lsp-deferred
(use-package rustic
    :custom
  (rustic-analyzer-command '("rustup" "run" "stable" "rust-analyzer")))

;; optionally if you want to use debugger
(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
;;(use-package which-key
;;    :config
;;    (which-key-mode))

(use-package company
    :after lsp-mode
    :hook (prog-mode . company-mode)
    :bind (:map company-active-map
		("<tab>" . company-complete-selection))
    (:map lsp-mode-map
          ("<tab>" . company-indent-or-complete-common))
    :custom
    (company-minimum-prefix-length 2)
    (company-idle-delay 0.0))

;; cc-mode
(setq-default c-default-style "k&r"
	      c-basic-offset 4)
(setq-default lisp-indent-function 'common-lisp-indent-function)


;;;; end packages

(setq-default frame-title-format
	      '((:eval (if (buffer-file-name)
			   (file-name-nondirectory (buffer-file-name))
			 "%b"))
		(:eval (if (buffer-modified-p) 
			   " •"))
		" - Emacs"))


;; This doesn't work for emacs-mac, see https://bitbucket.org/mituharu/emacs-mac/src/892fa7b2501a403b4f0aea8152df9d60d63f391a/doc/emacs/macport.texi?at=master#macport.texi-529
;; (menu-bar-mode -1)
(define-key global-map [menu-bar] nil)
(add-hook 'after-change-major-mode-hook (lambda () (local-set-key [menu-bar] nil)))
(add-hook 'minibuffer-setup-hook (lambda () (local-set-key [menu-bar] nil)))
(scroll-bar-mode -1)
(tool-bar-mode -1)


(set-face-attribute 'default nil
		    :family "Jetbrains Mono"
		    :height 130
		    )
(mac-auto-operator-composition-mode 1)


;; consider adding `env LIBRARY_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib"` as a hack because of libgccjit weirdness
;; actually, just launch emacs through terminal
(setenv "PATH" (concat (getenv "PATH") ":/opt/homebrew/bin:/Users/george/.cargo/bin"))
(setenv "LIBRARY_PATH" "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib")
(setq exec-path (append exec-path '("/opt/homebrew/bin")))

;; gnus
(setq gnus-home-directory (concat user-emacs-directory "gnus/"))
(setq gnus-directory gnus-home-directory)
(setq gnus-init-file (concat gnus-home-directory ".gnus.el"))
(setq gnus-startup-file (concat gnus-home-directory ".newsrc"))

;; EasyPG
(require 'epa-file)
(defvar epa-pinentry-mode)
(setq epa-pinentry-mode 'loopback)

(setq auth-sources (mapcar (lambda (x) (concat user-emacs-directory x)) '(".authinfo.gpg" ".authinfo" ".netrc")))

;; auto-save and backups
(setq backup-directory-alist `(("." . "~/emacs/saves/backups")))
(setq auto-save-file-name-transforms `((".*" "~/emacs/saves/auto-saves/" t)))
(setq backup-by-copying-when-linked t
      version-control t
      kept-new-versions 5
      kept-old-versions 0
      delete-old-versions t
      vc-make-backup-files t)

(define-minor-mode sensitive-minor-mode
    "For sensitive files like password lists.
It disables backup creation and auto saving.

With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode."
  ;; The initial value.
  :init-value nil
  ;; The indicator for the mode line.
  :lighter " sensitive"
  ;; The minor mode bindings.
  :keymap nil
  (if (symbol-value sensitive-minor-mode)
      (progn
	;; disable backups
	(set (make-local-variable 'backup-inhibited) t)	
	;; disable auto-save
	(if auto-save-default
	    (auto-save-mode -1)))
    ;; resort to default value of backup-inhibited
    (kill-local-variable 'backup-inhibited)
    ;; resort to default auto save setting
    (if auto-save-default
	(auto-save-mode 1))))

(setq auto-mode-alist
      (append '(("\\.gpg$" . sensitive-minor-mode))
              auto-mode-alist))

;; fancy-splash likely disabled because of yabai resizing, so we ignore initial screen size
(defun use-fancy-splash-screens-p () t)

;; user-init-file is mangled by chemacs
(let ((find-file-visit-truename t))
  (find-file-noselect (expand-file-name "init.el" user-emacs-directory)))
(find-file-noselect (expand-file-name "agenda.org" org-directory))

;; scuffed chemacs switcher by me
(defun switch-profile ()
  (interactive)
  (let* ((profiles_dir "~/emacs/emacs_profiles")
	 (chemacs "~/.config/chemacs/profile")
	 (emacs_app "/opt/homebrew/Cellar/emacs-mac/emacs-28.2-mac-9.1/Emacs.app")
	 (profiles (directory-files profiles_dir nil "^[^.].*"))
	 (choice (completing-read "Choose profile: " profiles))
	 (icon (file-name-concat profiles_dir (file-name-as-directory choice) (concat choice ".icns"))))
    (if (and (file-readable-p chemacs) (file-writable-p chemacs))
	(progn
	  (call-process-shell-command (concat "echo \"" choice "\" > " chemacs) nil t nil)
	  (if (executable-find "fileicon")
	      (progn
		(call-process-shell-command (concat "fileicon set " emacs_app " " icon) nil nil nil)
		(save-some-buffers)
		(kill-emacs))
	    (message (propertize "Error: fileicon not found" 'face '(:foreground "red")))))
      (message (propertize "Error: Can't write to chemacs `profile`" 'face '(:foreground "red"))))))



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ledger-reports
   '(("monthly_expenses" "ledger -f ~/Downloads/expenses.ledger reg Expenses\\:Personal -b 2022/12/09 -e 2023/01/04 --real")
     ("report1" "ledger -f ~/Downloads/expenses.ledger reg Liabilities\\:Credit\\ Card -b 2022/08/11 -e 2022/09/07")
     ("bal" "%(binary) -f %(ledger-file) bal")
     ("reg" "%(binary) -f %(ledger-file) reg")
     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
     ("account" "%(binary) -f %(ledger-file) reg %(account)")))
 '(org-agenda-files '("~/emacs/org/agenda.org"))
 '(warning-suppress-types '((comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )



;;; need to reorganize at some point (refactor to other files? use org-mode?)
