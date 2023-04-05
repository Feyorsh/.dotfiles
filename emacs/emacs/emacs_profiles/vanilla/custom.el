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
 '(org-modern-done ((t (:inherit org-modern-label :background "bisque1" :foreground "gray10")))))
