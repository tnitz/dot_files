(require 'package)
(setq package-archives '(("gnu"          . "https://elpa.gnu.org/packages/")
                         ("marmalade"    . "https://marmalade-repo.org/packages/")
                         ("melpa"        . "https://melpa.org/packages/")
                         ("melpa-stable" . "http://stable.melpa.org/packages/")))
(package-initialize)

;; Custom file handling.
(setq custom-file "~/.emacs.d/etc/custom.el")
(when (not (file-exists-p custom-file))
  (with-temp-buffer (write-file custom-file)))
(load custom-file)

;; Machine specific configuration parameters
(defvar local-file)
(setq local-file "~/.emacs.d/etc/local.el")
(when (not (file-exists-p local-file))
  (with-temp-buffer (write-file local-file)))
(load local-file)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))
(use-package diminish
             :ensure t)
(use-package bind-key
             :ensure t)

(use-package win-switch
  :ensure t
  :bind
  ("C-x o" . win-switch-dispatch)
  :config
  (setq win-switch-window-threshold 0
        win-switch-idle-time 1.8
        win-switch-other-window-first nil)
  (win-switch-set-wrap-around nil))
(windmove-default-keybindings 'meta)

(defun clang-format-before-save ()
  (interactive)
  (when (or (eq major-mode 'c++-mode) (eq major-mode 'c-mode)) (clang-format-buffer)))

;; clang format
(use-package clang-format
  :ensure t
  :bind ([C-M-tab] . clang-format-region)
  :config
  ;; Hook function
  (add-hook 'before-save-hook 'clang-format-before-save))

;; editorconfig
(use-package editorconfig
  :ensure t
  :diminish editorconfig-mode
  :config
  (editorconfig-mode 1))

;; magit
(use-package magit
  ;; :load-path "site-lisp/magit/"
  :bind ("C-x g" . magit-status)
  :functions magit-define-popup-switch
  :config
  (magit-define-popup-switch 'magit-log-popup ?f "First parent" "--first-parent"))
  ;; (with-eval-after-load 'info
  ;;   (info-initialize)
  ;;   (add-to-list 'Info-directory-list
  ;;                "~/.emacs.d/site-lisp/magit/Documentation/")))

(use-package magithub
  :disabled t
  :after magit
  :load-path "site-lisp/magithub/"
  :functions magithub-feature-autoinject
  :config
  (magithub-feature-autoinject t))

(use-package magit-lfs
  :ensure t
  :after magit
  :pin melpa)

(use-package git-timemachine
  :ensure t
  :bind (("C-x t" . git-timemachine-toggle)))

;; helm
(use-package helm
  :ensure t
  :diminish helm-mode
  :bind (("M-x"     . helm-M-x)
         ("C-x r b" . helm-filtered-bookmarks)
         ("C-x C-f" . helm-find-files)
         ("C-x C-b" . helm-buffers-list)
         ("C-x b"   . helm-buffers-list)
         ("M-y"     . helm-show-kill-ring)
         :map helm-map
         ([tab] . helm-execute-persistent-action))
  :config
  (helm-mode 1)
  (setq helm-split-window-inside-p t))

;; projectile
(use-package projectile
  :ensure t
  :config
  (projectile-mode)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package helm-projectile
  :ensure t
  :after projectile
  :after helm
  :config
  (setq projectile-completion-system 'helm
        projectile-switch-project-action 'helm-projectile
        projectile-enable-caching t)
  (helm-projectile-on))

;; irony
(use-package irony
  :diminish irony-mode
  :ensure t
  :defer t
  :disabled t
  :config
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)
  (defun my-irony-mode-hook ()
    (define-key irony-mode-map [remap completion-at-point]
      'irony-completion-at-point-async)
    (define-key irony-mode-map [remap complete-symbol]
      'irony-completion-at-point-async))
  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

(use-package company-irony
  :after company
  :after irony
  :ensure t
  :disabled t
  :commands company-indent-or-complete-common
  :config
  (add-to-list 'company-backends 'company-irony))

(use-package flycheck-irony
  :after flycheck
  :after irony
  :ensure t
  :disabled t
  :config
  (add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

;; company and flycheck
(use-package company
  :diminish company-mode
  :defer t
  :ensure t
  :config
  (global-company-mode)
  (setq company-backends (delete 'company-semantic company-backends))
  (add-to-list 'company-backends 'company-c-headers)
  (setq company-async-timeout 10))

(use-package company-quickhelp
  :after company
  :ensure t
  :config
  (company-quickhelp-mode 1))

(use-package flycheck
  :diminish flycheck-mode
  :ensure t
  :config
  (add-hook 'c++-mode-hook 'flycheck-mode)
  (add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11")))
  (add-hook 'c-mode-hook 'flycheck-mode))

(use-package flycheck-color-mode-line
  :after flycheck
  :ensure t
  :config
  (add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

;; ycmd
;; (use-package ycmd
;;   :diminish ycmd
;;   :functions gloabal-ycmd-mode
;;   :config
;;   (global-ycmd-mode)
;;   (set-variable 'ycmd-server-command `("python" ,(file-truename "~/ycmd/ycmd/")))
;;   (set-variable 'ycmd-extra-conf-whitelist '("~/cruise/*")))

;; (use-package company-ycmd
;;   :after company
;;   :after ycmd
;;   :config
;;   (company-ycmd-setup))

;; (use-package flycheck-ycmd
;;   :after flycheck
;;   :after ycmd
;;   :config
;;   (flycheck-ycmd-setup))

;; rtags
;; (use-package rtags
;;   :ensure t
;;   :config
;;   (setq rtags-path "~/rtags/bin"
;;         rtags-autostart-diagnostics t
;;         rtags-completions-enabled t)
;;   (add-hook 'c-mode-common-hook 'rtags-start-process-unless-running)
;;   (rtags-enable-standard-keybindings)
;;   (rtags-diagnostics))

;; (use-package helm-rtags
;;   :ensure t
;;   :after rtags
;;   :after helm
;;   :config
;;   (setq rtags-display-result-backend 'helm))

;; (use-package company-rtags
;;   :ensure t
;;   :after rtags
;;   :after company
;;   :config
;;   (add-to-list 'company-backends 'company-rtags))

;; (use-package flycheck-rtags
;;   :ensure t
;;   :after rtags
;;   :after flycheck
;;   :config
;;   (defun setup-flycheck-rtags ()
;;     (flycheck-select-checker 'rtags)
;;     ;(setq-local flycheck-highlighting-mode nil)
;;     ;(setq-local flycheck-check-syntax-automatically nil)
;;     )
;;   (add-hook 'flycheck-mode-hook 'setup-flycheck-rtags))

;; enable column-number-mode for c-like languages
(add-hook 'c++-mode-hook 'column-number-mode)
(add-hook 'c-mode-hook 'column-number-mode)
(add-hook 'objc-mode-hook 'column-number-mode)

;; cmake-mode
(use-package cmake-mode
  :ensure t
  :mode ("^CMake" . cmake-mode))

;; markdown-mode
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

;; whitespace
(use-package whitespace
  :diminish global-whitespace-mode
  :config
  (setq whitespace-style '(tabs tab-mark)) ;turns on white space mode only for tabs
  (global-whitespace-mode 1)
  (add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace t))))
;;  (setq-default show-trailing-whitespace t))
(setq-default indent-tabs-mode nil)

(use-package abbrev
  :diminish abbrev-mode)

(use-package yaml-mode
  :ensure t
  :mode "\\.e?ya?ml$")

(use-package rainbow-delimiters
  :ensure t
  :init
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package powerline
  :ensure t
  :config
  (powerline-default-theme))

(use-package ample-theme
  :ensure t)

(use-package org
  :mode ("\\.org'" . org-mode)
  :ensure t
  :bind (("C-c c" . org-capture)
         ("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c b" . org-iswitchb))
  :config (setq org-directory "~/org"
                org-default-notes-file (concat org-directory "/notes.org")))

;; (use-package srefactor
;;   :ensure t
;;   :bind (:map c-mode-map
;;   ("M-RET" . srefactor-refactor-at-point)
;;   :map c++-mode-map
;;   ("M-RET" . srefactor-refactor-at-point))
;;   :config
;;   (semantic-mode 1))

;; ;; keymaps for c/c++
(defun my-c-mode-hook ()
  (define-key c-mode-base-map [(tab)] 'company-indent-or-complete-common)
  (define-key c-mode-base-map (kbd "RET") 'newline-and-indent))
(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)
(add-hook 'c-mode-common-hook 'hs-minor-mode)

;; Show collapsed blocks when jumping into them using goto-line
(defadvice goto-line (after expand-after-goto-line activate compile)
  "hideshow-expand affected block when using goto-line in a collapsed buffer"
  (save-excursion (hs-show-block)))

;; global keymaps
(global-set-key (kbd "C-x /") 'comment-or-uncomment-region)
(global-unset-key (kbd "C-z"))

;; Save all tempfiles in $TMPDIR/emacs$UID/
(defconst emacs-tmp-dir (expand-file-name (format "emacs%d" (user-uid)) temporary-file-directory))
(setq backup-directory-alist `((".*" . ,emacs-tmp-dir))
      auto-save-file-name-transforms `((".*" ,emacs-tmp-dir t))
      auto-save-list-file-prefix emacs-tmp-dir)

;; Avoid making a mess with ~ files.
(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

;; don't have a toolbar
(tool-bar-mode -1)

;; don't quit with the normal key binding.
(global-unset-key "\C-x\C-c")

;; set theme
(load-theme 'ample)

