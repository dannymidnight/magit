;;; init --- minimal settings for magit
;;; Commentary:
;;; Code:
(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))

;; Disable all temporary file creation
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      auto-save-list-file-prefix nil)

;; Disable package.el to avoid loading it
(setq package-enable-at-startup nil)

;; Minimize GC during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Restore GC settings after startup
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq gc-cons-threshold 16777216
		  gc-cons-percentage 0.1)))

;; Disable file-name-handler-alist during startup
(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq file-name-handler-alist file-name-handler-alist-original)))

;; Minimal UI setup early
(setq inhibit-startup-screen t
      initial-scratch-message ""
      mode-line-format nil)

(menu-bar-mode -1)

(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq-default mode-line-format nil)
	    (force-mode-line-update t)))

(defalias 'yes-or-no-p 'y-or-n-p)

;; Straight.el setup with aggressive optimizations
(defvar bootstrap-version)
(setq straight-disable-native-compile t
      straight-check-for-modifications nil ; Skip file modification checks
      straight-use-package-by-default t    ; Use straight by default
      straight-cache-autoloads t)          ; Cache autoloads
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

;; Load packages with minimal config
(use-package magit
  :defer t) ; Defer loading until actually needed

;; Lazy-load theme after startup for faster init
(use-package catppuccin-theme
  :defer t)
(add-hook 'emacs-startup-hook
	  (lambda () (load-theme 'catppuccin t)))

;; Magit keybinding
(with-eval-after-load 'magit
  (define-key magit-status-mode-map "q" 'save-buffers-kill-emacs))

;; Clean up buffers
(when (get-buffer "*scratch*")
  (kill-buffer "*scratch*"))

;; Disable startup message
(setq inhibit-message t)
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq inhibit-message nil)))

;; Start magit
(let ((sha (getenv "SHA")))
  (if sha
      (magit-log-setup-buffer (list "--all") nil nil nil sha)
    (magit-status))
  (delete-other-windows))


(provide 'init)
;;; init.el ends here
