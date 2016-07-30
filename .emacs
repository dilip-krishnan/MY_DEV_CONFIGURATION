
;;; initial Setup 
;;;set load path
;;; Code:
(setenv "PATH" (concat (getenv "PATH") ":/usr/bin/"))
    (setq exec-path (append exec-path '("/usr/bin/")))
(let ((default-directory  "~/.emacs.d/"))
  (normal-top-level-add-subdirs-to-load-path))

;;set package repository
(require 'package)
(add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)
;; set default-load-theme should be after package initialize
(load-theme `tty-dark t)

;;emacs autosaves direcotry
(setq auto-save-file-name-transforms
      `((".*" ,"~/.emacs.d/auto-save/" t)))

(defvar --backup-directory "~/.emacs.d/auto-save/")
(if (not (file-exists-p --backup-directory))
    (make-directory --backup-directory t))
(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t               ; backup of a file the first
					; time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6               ; oldest versions to keep
					; when a new numbered backup is
					; made (default: 2)
      
      kept-new-versions 9               ; newest versions to keep when
					; a new numbered backup is made
					; (default: 2)
      auto-save-default t               ; auto-save every buffer that
					; visits a file
      auto-save-timeout 20              ; number of seconds idle time
					; before auto-save (default: 30)
      auto-save-interval 200            ; number of keystrokes between
					; auto-saves (default: 300)
            )
;;===================================================================================
;;					Functions
;;===================================================================================
(defun reload-init ()
  (interactive)
  (save-buffer)
  (load-file "~/.emacs"))

(defun load-init ()
  (interactive)
  (find-file "~/.emacs"))

(defun other-window-backward ()
  (interactive)
  (other-window -1))

;;=================================================================================
;; 	       			   Custom keybindings
;;=================================================================================

;; unset keys
(global-unset-key "\C-xo")
(global-unset-key "\C-xu")
(global-unset-key "\C-_")

;; key bindings for emacs
;;
(global-set-key (kbd "C-c r") 'reload-init)
(global-set-key (kbd "C-c j" ) 'load-init)
(global-set-key (kbd "<C-up>") 'shrink-window)
(global-set-key (kbd "<C-down>") 'enlarge-window)
(global-set-key (kbd "<C-left>") 'shrink-window-horizontally)
(global-set-key (kbd "<C-right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-c t") 'sr-speedbar-toggle)
(global-set-key [(control shift left)] 'windmove-left)
(global-set-key [(control shift right)] 'windmove-right)
(global-set-key [(control shift up)] 'windmove-up)
(global-set-key [(control shift down)] 'windmove-down)




;;=================================================================================
;;			      Navigation frame
;;=================================================================================

;; Do this to emacs frame on load
(require 'sr-speedbar)
(setq sr-speedbar-width 20)
(sr-speedbar-open)


;;=================================================================================
;;                            Source code Tagging
;;=================================================================================
(require 'ggtags)
(add-hook 'c-mode-common-hook
	  (lambda ()
	    (when (derived-mode-p 'c-mode)
	      (ggtags-mode 1))))

(define-key ggtags-mode-map (kbd "C-c g s") 'ggtags-find-other-symbol)
(define-key ggtags-mode-map (kbd "C-c g h") 'ggtags-view-tag-history)
(define-key ggtags-mode-map (kbd "C-c g r") 'ggtags-find-reference)
(define-key ggtags-mode-map (kbd "C-c g f") 'ggtags-find-file)
(define-key ggtags-mode-map (kbd "C-c g c") 'ggtags-create-tags)
(define-key ggtags-mode-map (kbd "C-c g u") 'ggtags-update-tags)
(define-key ggtags-mode-map (kbd "M-,") 'pop-tag-mark)


;;=================================================================================
;;			   	Autocomplete
;;=================================================================================

(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(require 'company-c-headers)
(add-to-list 'company-backends 'company-c-headers)
(require 'yasnippet)
(yas-global-mode 1)

;; Fix iedit bug
(define-key global-map (kbd "C-c ;") 'iedit-mode)

;;=================================================================================
;;				For C language
;;=================================================================================

(require 'cc-mode)
(setq-default c-basic-offset 8 c-default-style "linux")
(setq-default tab-width 8 indent-tabs-mode t)
(define-key c-mode-base-map (kbd "RET") 'newline-and-indent) ; automatically indent when press RET
(add-hook 'c-mode-common-hook   'hs-minor-mode)
(require 'semantic)
(semantic-mode 1)
(global-semanticdb-minor-mode 1)
(global-semantic-idle-scheduler-mode 1)
(global-semantic-idle-summary-mode 1)
(add-to-list 'semantic-default-submodes 'global-semantic-stickyfunc-mode)
(require 'stickyfunc-enhance)

(setq-local eldoc-documentation-function #'ggtags-eldoc-function)
;; activate whitespace-mode to view all whitespace characters
(global-set-key (kbd "C-c w") 'whitespace-mode)
;; Package: clean-aindent-mode
(require 'clean-aindent-mode)
(add-hook 'prog-mode-hook 'clean-aindent-mode)
;; show unncessary whitespace that can mess up your diff
(add-hook 'prog-mode-hook (lambda () (interactive) (setq show-trailing-whitespace 1)))

;; key for compiling
(global-set-key (kbd "<f5>") (lambda ()
			       (interactive)
			       (setq-local compilation-read-command nil)
			       (call-interactively 'compile)))

;; debugging
(setq
;; use gdb-many-windows by default
 gdb-many-windows t
 ;; Non-nil means display source file containing the main routine at startup
 gdb-show-main t
 )


;;=================================================================================
;;				For Python language
;;=================================================================================

(elpy-enable)
(add-hook 'after-init-hook #'global-flycheck-mode)
;; use flycheck not flymake with elpy
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; enable autopep8 formatting on save
(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)
(set-variable 'flycheck-checker-error-threshold 600)


