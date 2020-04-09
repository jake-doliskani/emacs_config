;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  


(package-initialize)


;; Set up repos

(setq package-enable-at-startup nil)
(setq package-archives
      '(("elpa" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))


;; Bootstrap use-package

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(require 'use-package-ensure)
(setq use-package-always-ensure t)


;; Increase garbage collection threshold

(setq gc-cons-threshold (* 100 1024 1024))


;; Increase the size of data Emacs reads from processes, mainly for lsp-mode

(setq read-process-output-max (* 1024 1024))


;; Restore gc threshold after startup

(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold (* 1024 1024))))


;; Set custom settings to load in own file

(setq custom-file (make-temp-file "emacs-custom"))



;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;; Preferences
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Don't display startscreen on startup

(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)


;;  maximize the frame

(add-to-list 'default-frame-alist '(fullscreen . maximized))


;; moving between windows

(windmove-default-keybindings)
(setq windmove-wrap-around t) ; allow wrap-around


;; Buffers don't ask for confirmation when killed

(setq confirm-kill-processes nil)


;; Disable menu-bar, tool-bar and scroll-bar

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)


;; Show line numbers

(global-display-line-numbers-mode)


;; Replace yes-or-no with y-or-n

(defalias 'yes-or-no-p 'y-or-n-p)


;; Tab width

(setq tab-width 4)


;; Backups, different directory

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t)
(setq version-control t)


;; Use utf-8

(prefer-coding-system 'utf-8)


;; C-k kill the whole line

(setq kill-whole-line t)


;; Matching pairs of parentheses and other characters

(show-paren-mode 1)
(setq show-paren-delay 0)
(setq show-paren-style 'parenthesis)


;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;; Packages
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Install the doom themes

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t)
  (setq doom-themes-enable-italic t)
  (load-theme 'doom-vibrant t))


;; which-key displays available keybindings in popup

(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))


;; modular text completion framework

(use-package company
  :hook (after-init . global-company-mode)
  :config
  (setq company-require-match 'never)
  (setq company-minimum-prefix-length 2)
  (setq company-tooltip-align-annotations t)
  (setq company-idle-delay 0)
  (setq company-tooltip-limit 20)
  (setq global-company-mode t)
  :bind ("C-<tab>" . company-complete))


;; Language Server Protocol (LSP)

(use-package lsp-mode
  :config
  (setq lsp-diagnostic-package :flycheck)
  (setq lsp-enable-snippet t)
  (setq lsp-auto-execute-action t)
  (setq lsp-eldoc-render-all t)
  (setq lsp-enable-completion-at-point t)
  (setq lsp-enable-xref t)
  (setq lsp-enable-indentation t))

(use-package company-lsp
  :after '(company lsp-mode)
  :config
  (setq company-lsp-cache-candidates t)
  (setq company-lsp-async t)
  (setq company-lsp-enable-snippet t)
  (push 'company-lsp company-backends))


;; syntax checking with flycheck

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package flycheck-pos-tip
  :after flycheck
  :config (flycheck-pos-tip-mode))


;; Python

(use-package python
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python" . python-mode)
  :hook
  (python-mode . lsp))


;; Rust

(use-package rust-mode
  :hook
  ((rust-mode . lsp)
   (rust-mode . (lambda () (setq indent-tabs-mode nil))))
  :bind
  ("C-c C-b" . rust-compile)
  ("C-c C-r" . rust-run)
  ("C-c C-t" . rust-test))

(use-package cargo
  :hook (rust-mode . cargo-minor-mode))

(use-package flycheck-rust
  :config
  (with-eval-after-load 'rust-mode
    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)))


;; Latex

(require 'lsp-clients)
(add-hook 'latex-mode-hook 'lsp)
(add-hook 'latex-mode-hook (lambda () (flyspell-mode 1)))

;; Run Makefile using "C-c C-m"
(add-hook 'latex-mode-hook (lambda ()
			     (define-key latex-mode-map (kbd "C-c C-m") 'recompile)))

(defun my-pdflatex-compile ()
  "Run pdflatex on the current buffer."
  (interactive)
  (shell-command (concat "pdflatex " (buffer-file-name))))

(add-hook 'latex-mode-hook (lambda ()
			     (define-key latex-mode-map (kbd "C-c C-c") 'my-pdflatex-compile)))

;; Line wrap at 100 characters
(add-hook 'latex-mode-hook 'auto-fill-mode)
(add-hook 'latex-mode-hook (lambda ()
			     (setq fill-column 100)))
;; (use-package tex
;;   :ensure auctex
;;   :mode ("\\.tex\\'" . latex-mode)
;;   :config
;;   (setq TeX-auto-save t)
;;   (setq TeX-parse-self t)
;;   (setq-default TeX-master nil)
;;   ;; Update PDF buffers after successful LaTeX runs
;;   (add-hook 'TeX-after-compilation-finished-functions
;; 	    #'TeX-revert-document-buffer)
;;   (add-hook 'LaTeX-mode-hook 'flyspell-mode))

;; (use-package company-auctex
;;   :ensure t
;;   :init (company-auctex-init))



;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;; Keybindings
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;; init ends here
