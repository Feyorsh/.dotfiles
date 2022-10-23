; bootstrap straight.el
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

; install use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq straight-vc-git-default-clone-depth '(1 single-branch))
(setq use-package-verbose nil)

(use-package pdf-tools
			 :config 
			 (pdf-tools-install)
			 (setq pdf-view-use-scaling t)
			 (setq-default pdf-view-display-size 'fit-page)
			 )
(use-package magit)
; lol doesn't work because emacs 28 introduced a breaking change or something idk
;(use-package slime)

; this is... weird
; don't bother spinning up daemon; instead, emacs just doesn't close the last frame
; consider using (server-start) so we can bind an Automator task to do some shizzle
(use-package mac-pseudo-daemon
			 :config
			 (mac-pseudo-daemon-mode 1)
			 )

(use-package vterm
			 :config
			 (setq vterm-shell "fish")
			 )

(use-package ledger-mode)

(setq-default frame-title-format
    '((:eval (if (buffer-file-name)
                  (file-name-nondirectory (buffer-file-name))
                    "%b"))
      (:eval (if (buffer-modified-p) 
                 " •"))
      " [%m] - Emacs")
  )

; This doesn't work for emacs-mac, see https://bitbucket.org/mituharu/emacs-mac/src/892fa7b2501a403b4f0aea8152df9d60d63f391a/doc/emacs/macport.texi?at=master#macport.texi-529
; (menu-bar-mode -1)
(define-key global-map [menu-bar] nil)
(add-hook 'after-change-major-mode-hook (lambda () (local-set-key [menu-bar] nil)))
(add-hook 'minibuffer-setup-hook (lambda () (local-set-key [menu-bar] nil)))
(scroll-bar-mode -1)
(tool-bar-mode -1)

(set-face-attribute 'default nil
					:family "Jetbrains Mono"
					:height 130
					)

(setenv "PATH" (concat (getenv "PATH") ":/opt/homebrew/bin"))
(setq exec-path (append exec-path '("/opt/homebrew/bin")))

; gnus
(setq gnus-home-directory (concat user-emacs-directory "gnus/"))
(setq gnus-directory gnus-home-directory)
(setq gnus-init-file (concat gnus-home-directory ".gnus.el"))
(setq gnus-startup-file (concat gnus-home-directory ".newsrc"))

; EasyPG
(require 'epa-file)
(defvar epa-pinentry-mode)
(setq epa-pinentry-mode 'loopback)

(setq auth-sources (mapcar (lambda (x) (concat user-emacs-directory x)) '(".authinfo.gpg" ".authinfo" ".netrc")))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ledger-reports
   '(("report1" "ledger ")
     ("bal" "%(binary) -f %(ledger-file) bal")
     ("reg" "%(binary) -f %(ledger-file) reg")
     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
     ("account" "%(binary) -f %(ledger-file) reg %(account)")))
 '(package-selected-packages '(auctex use-package slime pdf-tools magit))
 '(warning-suppress-types '((comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
