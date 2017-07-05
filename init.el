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

;; clang format
(use-package clang-format
  :ensure t
  :bind ([C-M-tab] . clang-format-region))

;; editorconfig
(use-package editorconfig
  :ensure t
  :diminish editorconfig-mode
  :config
  (editorconfig-mode 1))

;; magit
(use-package magit
  :ensure t
  :pin melpa-stable
  :bind ("C-x g" . magit-status)
  :functions magit-define-popup-switch
  :config
  (magit-define-popup-switch 'magit-log-popup ?f "first parent" "--first-parent")
  (with-eval-after-load 'info
    (info-initialize)
    (add-to-list 'Info-directory-list
                 "~/.emacs.d/site-lisp/magit/Documentation/")))

(use-package magithub
;;  :disabled t
;;  :ensure t
  :after magit
  :load-path "site-lisp/magithub/"
  :functions magithub-feature-autoinject
  :config
  (magithub-feature-autoinject t))

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
  (setq helm-split-window-in-side-p t))

;; projectile
(use-package projectile
  :ensure t
  :config
  (projectile-mode))

(use-package helm-projectile
  :ensure t
  :after projectile
  :after helm
  :config
  (setq projectile-completion-system 'helm)
  (helm-projectile-on))

(use-package irony
  :diminish irony-mode
  :ensure t
  :defer t
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

(use-package company-irony
  :after company
  :after irony
  :ensure t
  :commands company-indent-or-complete-common
  :config
  (add-to-list 'company-backends 'company-irony))

(use-package flycheck
  :diminish flycheck-mode
  :ensure t
  :config
  (add-hook 'c++-mode-hook 'flycheck-mode)
  (add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11")))
  (add-hook 'c-mode-hook 'flycheck-mode))

(use-package flycheck-irony
  :after flycheck
  :after irony
  :ensure t
  :config
  (add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

(use-package flycheck-color-mode-line
  :after flycheck
  :ensure t
  :config
  (add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

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

(use-package abbrev
  :diminish abbrev-mode)

(use-package guide-key
  :defer t
  :diminish guide-key-mode
  :config
  (progn
    (setq guide-key/guide-key-sequence '("C-x r" "C-x 4" "C-c"))
    (guide-key-mode 1)))

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

;; (use-package ansi-color
;;   :config
;;   (setq ansi-color-names-vector ["#2e3436" "#a40000" "#4e9a06" "#c4a000" "#204a87" "#5c3566" "#ce5c00" "#eeeeec"]))

;; cc-mode defaults
;; (setq-default indent-tabs-mode nil)
;; (setq-default c-basic-offset 4)
;; (setq-default c-indent-tabs-mode nil
;;               c-indent-level 4
;;               c-argdecl-indent 0
;;               c-tab-always-indent t
;; )
;; (c-add-style "cruise" '((c-offsets-alist
;;                          (arglist-intro . 6)
;;                          (substatement-open . 0)
;;                          (innamespace . -)
;;                          (inline-open . 0)
;;                          (block-open . +)
;;                          (brace-list-open . +)   ; all "opens" should be indented by the c-indent-level
;;                          (case-label . 0)
;;                          )
;;                         (c-continued-statement-offset 6)))

;; ;; keymaps for c/c++
;; (defun my-c-mode-hook ()
;;   (c-set-style "cruise")
;;   (define-key c-mode-base-map [(tab)] 'company-indent-or-complete-common)
;;   (define-key c-mode-base-map (kbd "RET") 'newline-and-indent))
;; (add-hook 'c-mode-hook 'my-c-mode-hook)
;; (add-hook 'c++-mode-hook 'my-c-mode-hook)
(add-hook 'c-mode-common-hook 'hs-minor-mode)

;; global keymaps
(global-set-key (kbd "C-x /") 'comment-or-uncomment-region)
(global-unset-key (kbd "C-z"))

;; Save all tempfiles in $TMPDIR/emacs$UID/
(defconst emacs-tmp-dir (expand-file-name (format "emacs%d" (user-uid)) temporary-file-directory))
(setq backup-directory-alist
      `((".*" . ,emacs-tmp-dir)))
(setq auto-save-file-name-transforms
      `((".*" ,emacs-tmp-dir t)))
(setq auto-save-list-file-prefix
      emacs-tmp-dir)

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

;; set theme
;; (load-theme 'Oblivion)
;; (load-theme 'monokai)
;; (load-theme ')
(load-theme 'ample)
