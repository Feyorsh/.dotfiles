(setq gnus-save-newsrc-file nil)
(setq gnus-read-newsrc-file nil)


(setq
  	user-mail-address "spammonsalmon@gmail.com"
	user-full-name "Spammon Salmon"
	mml-secure-openpgp-signers '("6FAB1EF94529AA55")

	gnus-select-method
	'(nnimap "gmail"
	   (nnimap-address "imap.gmail.com")
	   (nnimap-server-port 993)
	   (nnimap-stream ssl))
	smtpmail-smtp-server "smtp.gmail.com"
	smtpmail-smtp-service 587
	message-send-mail-function 'smtpmail-send-it

	gnus-agent nil
	;; We don't want local, unencrypted copies of emails we write.
	gnus-message-archive-group nil
	;; We want to be able to read the emails we wrote.
	mml-secure-openpgp-encrypt-to-self t

	gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

(add-hook 'message-setup-hook 'mml-secure-message-encrypt)
