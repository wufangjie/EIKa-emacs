;;; my-python.el -*- lexical-binding: t -*-

;; #####################################################################
;; `python'
;; hide / show code, M-x hs-<TAB>
;; #####################################################################
(setq python-shell-completion-native-enable nil)

(if (string-equal system-type "gnu/linux")
    (setq python-shell-interpreter "python3"))

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))


;; (add-hook 'python-mode-hook 'hs-minor-mode)
(add-hook 'inferior-python-mode-hook
	  (lambda ()
	    ;; (outline-minor-mode t)
	    ;; (setq outline-regexp "\\(>>> \\)+")
	    (setq-local paragraph-start "^>>> ")
	    ;; (paragraph-separate "")
	    ;; (setq comint-use-prompt-regexp t)
	    ;; (setq comint-prompt-regexp "^\\(>>> \\)+"
	    ))


(generate-easy-insert-func
 "python"
 `(("head" . "#!/usr/bin/python3\n# -*- coding: utf-8 -*-\n\n")
   ("main" . "if __name__ == '__main__':\n    ")
   ("path" . ,(concat
	       "import os\n\n\ntry:\n"
	       "    path = os.path.split(os.path.realpath(__file__))[0]\n"
	       "except NameError:\n"
	       "    path = os.getcwd() or os.getenv('PWD')\n\n"))
   ("pdb"  . "import pdb; pdb.set_trace()\n")))



;; #####################################################################
;; `jedi'
;; #####################################################################
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))


;; (add-to-list 'load-path "~/.emacs.d/el-get/el-get")
;; (unless (require 'el-get nil 'noerror)
;;   (with-current-buffer
;;       (url-retrieve-synchronously
;;        "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
;;     (goto-char (point-max))
;;     (eval-print-last-sexp)))
;; (el-get 'sync)

;;; used to add custom path TODO: those pth already in site-packages
;; (setq jedi:server-args
;;       '("--sys-path" "/usr/local/lib/python3.8/dist-packages"
;; 	"--sys-path" "/usr/lib/python3/dist-packages"
;; 	"--sys-path" "/usr/lib/python3.8/dist-packages"
;; 	;"--sys-path" "~/packages"
;; 	))


(setq jedi:setup-keys t)
(setq jedi:complete-on-dot t)
(add-hook 'python-mode-hook 'jedi:setup)
(add-hook 'python-mode-hook 'flycheck-mode)

;; NOTE: Do not add jedi to interpreter, pdb single character complete!
;; (add-hook 'inferior-python-mode-hook 'jedi:setup)


;; #####################################################################
;; smart C-c C-c
;; #####################################################################
(defun python-shell-send-buffer-smart (&optional send-main)
  (interactive (list current-prefix-arg))
  (unless (python-shell-get-process)
    (let* ((current-prefix-arg t)
	   (process (call-interactively 'run-python)))
      (comint-send-string
       process
       (format "exec(%s)\n" (python-shell--encode-string
			     python-shell-eval-setup-code)))
      (comint-send-string
       process
       (format "exec(%s)\n" (python-shell--encode-string
			     "from pprint import pprint;"))) ; seperate
      ))
  (python-shell-send-buffer send-main))
(add-hook 'python-mode-hook
	  (lambda ()
	    (local-unset-key (kbd "C-c C-c"))
	    (local-set-key (kbd "C-c C-c") 'python-shell-send-buffer-smart)
	   ))



;; #####################################################################
;; `pyenv'
;; #####################################################################
(defun pyenv-shell (version)
  (interactive (list (completing-read "Pyenv: " (pyenv-versions))))
  (setenv "PYENV_VERSION" version)
  (setq python-shell-interpreter (pyenv-full-path version))
  )

(defun pyenv-shell-unset ()
  (interactive)
  (setenv "PYENV_VERSION"))

(defun pyenv-versions ()
  (cons "system" (split-string (shell-command-to-string "pyenv versions --bare"))))

(defun pyenv-version ()
  (interactive)
  (message (or (getenv "PYENV_VERSION") "system")))

(defun pyenv-full-path (version)
  (if (string= version "system")
      "python3"
    (concat (string-trim-right (shell-command-to-string "pyenv root"))
	    "/versions/"
	    version
	    "/bin/ipython"))) ;; ipython for mac, windows



(provide 'my-python)
