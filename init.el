;;; -*- lexical-binding: t -*-

;; TODO: dir-locals - not in this file somehow
;; TODO: treesit directory no-littering
;; TODO: dap mode for C++ and Rust
;; TODO: flyspell correct integration via corfu, don't overwrite C-. anywhere conflicts with embark.
;; TODO: activities or burly?
;; TODO: embark-prefix-help-command without needing to go through C-h.
;; TODO: embark-act for LSP and similar
;; TODO: org mode setup

;;
;; Very early setup, enough to ensure we can avoid littering even through
;; bringing up package/use-package/no-littering
;;
(defvar no-littering-etc-directory (expand-file-name ".cache/etc/" user-emacs-directory))
(defvar no-littering-var-directory (expand-file-name ".cache/var/" user-emacs-directory))
(setq package-user-dir (expand-file-name "elpa/" no-littering-var-directory))

;;
;; Top-level configuration for `package`, `use-package`, and `auto-compile`
;;
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archive-priorities '("melpa-stable" . 10) t)
(add-to-list 'package-archive-priorities '("melpa" . 1) t)

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(require 'use-package-ensure)
(setq use-package-always-ensure t)
(setq use-package-always-pin "melpa-stable")
(use-package use-package)

(use-package no-littering
  :demand
  :config
  (require 'recentf)
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory)
  (no-littering-theme-backups))

(use-package auto-compile
  :demand
  :init
  (setq load-prefer-newer t)
  :config
  (auto-compile-on-load-mode))


;;
;; Use use-package for emacs configurations
;;
(use-package emacs
  :custom
  ;; Indispensable top level key bindings for macos
  (mac-command-modifier 'meta)
  (mac-option-modifier 'super)

  ;; Sideline custom.el per no-littering
  (custom-file (no-littering-expand-etc-file-name "custom.el"))

  ;; No need for the startup screen
  (inhibit-startup-screen t)

  ;; Make `TAB` smarter
  (tab-always-indent 'complete)

  ;; Bell-ring is annoying
  (ring-bell-function 'ignore)

  ;; Always add a trailing newline to files
  (require-final-newline t)

  ;; Configure buffer uniqueness
  (uniquify-buffer-name-style 'post-forward)
  (uniquify-separator "|")

  (custom-unlispify-menu-entries nil)
  (custom-unlispify-tag-names nil)

  ;; Go to where things already are
  (display-buffer-base-action '(display-buffer-reuse-window (reusable-frames . visible)))

  ;; Use pop-to-buffer for emacsclient buffers so they don't replace the current window
  (server-window 'pop-to-buffer)

  ;; Works better with nested C++ namespaces
  (imenu-flatten 'prefix)

  ;; Why not
  (imenu-auto-rescan t)

  :config
  ;; Toolbar/scrollbar is a waste of space
  (when (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))
  (when (fboundp 'scroll-bar-mode)
    (scroll-bar-mode -1))

  ;; Blinking cursor is silly
  (blink-cursor-mode -1)

  ;; Include more metadata in the modeline
  (line-number-mode +1)
  (column-number-mode +1)
  (size-indication-mode +1)

  ;; We want this for magit
  (global-unset-key (kbd "s-m"))

  ;; Don't require typing out `yes` or `no`; accept `y` or `n`.
  (fset 'yes-or-no-p 'y-or-n-p)

  ;; Always start the initial frame large
  (add-to-list 'initial-frame-alist '(fullscreen . maximized))

  ;; Delete the selection on any keypress
  (delete-selection-mode +1)

  ;; If files change outside emacs, automatically reload them
  (global-auto-revert-mode +1)

  ;; global line numbers
  (global-display-line-numbers-mode +1)

  ;; Enable repeat mode
  (repeat-mode +1)

  ; ;; Inconsolata-16 as the default
  ; ;; TODO: Can this go into the `solarized` use-pacakge below?
  ; (add-to-list 'default-frame-alist '(font . "Inconsolata-16"))

  ;; On macOS, this key is used to cycle windows of the current
  ;; app. So, arrange to let it do so for our frames as well.
   ; :bind (("M-`" . ns-next-frame)
   ;        ("M-~" . ns-prev-frame)
   ;        ("M-/" . completion-at-point)
   ;        ([remap list-buffers] . 'ibuffer))
   )


;;
;; Get some theme in there, and other UI stuff
;;
; (use-package solarized
;   :ensure solarized-theme
;   :defer t
;   :init
;   (load-theme 'solarized-dark t))

(use-package diff-hl
  :hook ((dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :init
  (global-diff-hl-mode +1))

(use-package hl-line
  :config
  (global-hl-line-mode +1))

(use-package diminish)


;;
;; Remember things with recentf, savehist, and saveplace
;;
(use-package recentf
  :custom
  (recentf-auto-cleanup 'never)
  (recentf-max-saved-items 1000)
  :config
  (recentf-mode +1))

(use-package savehist
  :custom
  (savehist-additional-variables '(search-ring regexp-search-ring))
  (savehist-autosave-interval 60)
  :config
  (savehist-mode +1))

(use-package saveplace
  :config
  (save-place-mode +1))


;;
;; Load MOVEC and which-key, and other means
;; of finding things
;;
(use-package vertico
  :init
  (vertico-mode +1)
  (vertico-multiform-mode +1)
  :config
  (add-to-list 'vertico-multiform-categories '(embark-keybinding grid))
  :custom
  (enable-recursive-minibuffers t))

(use-package vertico-directory
  :after vertico
  :ensure nil
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :bind
  (:map vertico-map
        ("RET" . vertico-directory-enter)
        ("DEL" . vertico-directory-delete-char)
        ("M-DEL" . vertico-directory-delete-word)))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :after (projectile vertico)
  :custom
  (consult-narrow-key "<")
  (consult-project-function (lambda (_) (projectile-project-root)))
  (xref-show-xrefs-function 'consult-xref)
  (xref-show-definitions-function 'consult-xref)
  :bind (("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x p b" . consult-project-buffer)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flycheck)
         ("M-g g" . consult-goto-line)
         ("M-g m" . consult-mark)
         ("M-g M" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history)))

(use-package consult-dir
  :pin melpa  ;; stable is too old
  :after (vertico)
  :bind (("C-x C-d" . consult-dir)
         :map vertico-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file))
  :custom
  (consult-dir-project-list-function 'consult-dir-projectile-dirs)
  :init
  (defun my/consult-dir--tramp-container-hosts ()
      (cl-loop for (id name) in (tramp-container--completion-function tramp-docker-program)
           collect (format "/docker:%s" name)))

  (defvar my/consult-dir--source-tramp-container
    `(:name     "Docker"
      :narrow   ?d
      :category file
      :face     consult-file
      :history  file-name-history
      :items    ,#'my/consult-dir--tramp-container-hosts)
    "Docker candidate source for `consult-dir'.")

  :config
  (add-to-list 'consult-dir-sources 'consult-dir--source-tramp-ssh t)
  (add-to-list 'consult-dir-sources 'my/consult-dir--source-tramp-container t))

(use-package consult-projectile
  :pin melpa
  :after (consult projectile)
  :bind
  (:map projectile-mode-map
        ;; It'd be better to use remap here, but I can't get it to work
        ("s-p f" . consult-projectile)
        ("s-p b" . consult-projectile-switch-to-buffer)))

(use-package marginalia
  :init
  (marginalia-mode +1))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C->" . embark-dwim)
   ("s-]" . embark-collect)
   ("s-}" . embark-export)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  ;; From https://karthinks.com/software/avy-can-do-anything/
  (with-eval-after-load 'avy
    (defun avy-action-embark (pt)
      (unwind-protect
          (save-excursion
            (goto-char pt)
            (embark-act))
        (select-window
         (cdr (ring-ref avy-ring 0))))
      t)
    (setf (alist-get ?. avy-dispatch-alist) 'avy-action-embark))
  :custom
  (embark-indicators '(
    embark-minimal-indicator  ; default is embark-mixed-indicator
    embark-highlight-indicator
    embark-isearch-highlight-indicator))
  (embark-prompter 'embark-completing-read-prompter)
  (embark-cycle-key ".")
  (embark-help-key "?"))

(use-package embark-consult
  :after (embark consult)
  :demand t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package which-key
  :diminish
  :config
  (which-key-mode +1))

(use-package rg
  :ensure-system-package rg)


;;
;; Completion - Let's Try Corfu and Cape
;;
(use-package corfu
  :custom
  (corfu-auto t)
  :init
  (global-corfu-mode)
  :bind
  (:map corfu-map
        ("C-n" . corfu-next)
        ("<escape>" . corfu-reset)
        ("C-g" . corfu-quit)
        ("s-SPC" . corfu-insert-separator)
        ("C-p" . corfu-previous)
        ))

(use-package dabbrev
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode))

(use-package cape
  :demand
  :bind ("C-M-/" . cape-prefix-map)
  :config
  (define-key cape-prefix-map (kbd "y") 'consult-yasnippet)
  (define-key cape-prefix-map (kbd "Y") 'yas-insert-snippet)
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-history)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-hook 'completion-at-point-functions
                        #'cape-keyword nil t))))


;;
;; Load magit, projectile, fly[check,spell], compile, etc. as key programming configs.
;;
; (use-package magit
;   :custom
;   (magit-list-refs-sortby "-creatordate")
;   (magit-diff-refine-hunk 'all)
;   (magit-log-show-refname-after-summary t)
;   :bind (("s-m m" . magit-status)
;          ("s-m j" . magit-dispatch)
;          ("s-m k" . magit-file-dispatch)
;          ("s-m l" . magit-log-buffer)
;          ("s-m b" . magit-blame)))

(use-package projectile
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map))
  :custom
  (projectile-per-project-compilation-buffer t)
  (projectile-switch-project-action 'projectile-vc)
  (compilation-save-buffers-predicate
   (lambda ()
     (and (buffer-file-name)
          (projectile-project-p)
          (projectile-file-exists-p (buffer-file-name))))))

(use-package flycheck
  :diminish
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package consult-flycheck
  :after (consult)
)

(use-package flyspell
  :diminish
  :hook ((prog-mode . flyspell-prog-mode)
         (text-mode . flyspell-mode)))

(use-package flyspell-correct
  :after flyspell
  :defer t)

(use-package consult-flyspell
  :pin melpa
  :after (consult)
  :config
  (setq consult-flyspell-select-function (lambda () (flyspell-correct-at-point) (consult-flyspell))
        consult-flyspell-set-point-after-word t
        consult-flyspell-always-check-buffer nil))

(use-package compile
  :custom
  (compilation-max-output-line-length nil)
  (compilation-skip-threshold 0))

(use-package smartparens
  :diminish smartparens-mode
  :hook (prog-mode text-mode markdown-mode)
  :config
  (require 'smartparens-config)
  :custom
  (sp-base-key-bindings 'sp))

(use-package eldoc
  :diminish eldoc-mode)


;;
;; Navigation in space and time (tramp, windows, undo, etc.)
;;
(use-package undo-tree
  :pin gnu
  :diminish
  :custom
  (undo-tree-auto-save-history t)
  :config
  (global-undo-tree-mode +1))

(use-package ace-window
  :demand
  :init
  ;; From https://karthinks.com/software/emacs-window-management-almanac/#aw-select-the-completing-read-for-emacs-windows
  (defun my/ace-window-prefix ()
    "Use `ace-window' to display the buffer of the next command.
The next buffer is the buffer displayed by the next command
invoked immediately after this command (ignoring reading from the
minibuffer). Creates a new window before displaying the
buffer. When `switch-to-buffer-obey-display-actions' is non-nil,
`switch-to-buffer' commands are also supported."
    (interactive)
    (display-buffer-override-next-command
     (lambda (buffer _)
       (let (window type)
         (setq
          window (aw-select (propertize " ACE" 'face 'mode-line-highlight))
          type 'reuse)
         (cons window type)))
     nil "[ace-window]")
    (message "Use `ace-window' to display next command buffer..."))
  (defun my/ace-window-one-command ()
  (interactive)
  (let ((win (aw-select " ACE")))
    (when (windowp win)
      (with-selected-window win
        (let* ((command (key-binding
                         (read-key-sequence
                          (format "Run in %s..." (buffer-name)))))
               (this-command command))
          (call-interactively command))))))
  :bind
  ([remap other-window] . ace-window)
  ("C-x 4 o" . 'my/ace-window-prefix)
  ("C-x O" . 'my/ace-window-one-command)
  :custom
  (switch-to-buffer-obey-display-actions t)
  (aw-dispatch-always t)
  (ace-window-display-mode t)
  )

(use-package windmove
  :config
  (windmove-default-keybindings))

(use-package tramp
  :custom
  (tramp-default-method "ssh")
  (tramp-show-ad-hoc-proxies t)
  (enable-remote-dir-locals t)
  (tramp-use-scp-direct-remote-copying t)
  (tramp-use-connection-share nil)
  (tramp-copy-size-limit (* 1024 1024))
  :config
  (with-eval-after-load 'compile
    (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options))
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(use-package avy
  :config
  ;; From https://karthinks.com/software/emacs-window-management-almanac/
  (define-advice pop-global-mark (:around (pgm) use-display-buffer)
    "Make `pop-to-buffer' jump buffers via `display-buffer'."
    (cl-letf (((symbol-function 'switch-to-buffer)
               #'pop-to-buffer))
      (funcall pgm)))
  :custom
  (avy-enter-times-out nil)
  (avy-all-windows 'all-frames)
  :bind
  (("M-g c" . avy-goto-char-timer)
   ("M-g l" . avy-goto-line)
   ("M-g w" . avy-goto-word-1)
   :map isearch-mode-map
   ("M-s a" . avy-isearch)))


;;
;; General editing
;;
(use-package guru-mode
  :diminish
  :config
  (guru-global-mode +1))

(use-package volatile-highlights
  :diminish
  :config
  (volatile-highlights-mode +1))

(use-package anzu
  :diminish
  :bind
  (("M-%" . anzu-query-replace)
   ("C-M-%" . anzu-query-replace-regexp))
  :config
  (global-anzu-mode +1))

(use-package whitespace
  :diminish
  :init
  ;; TODO: Why doesn't this seem to work when done with :hook before-save?
  (add-hook 'before-save-hook #'whitespace-cleanup)
  :hook
  ((prog-mode text-mode) . whitespace-mode)
  :custom
  (whitespace-line-column nil)
  (whitespace-style '(face tabs empty trailing)))

(use-package wgrep)

(use-package dired
  :ensure nil
  :bind
  (:map dired-mode-map
        ("C-c C-p" . wdired-change-to-wdired-mode)))

(use-package wdired
  :ensure nil
  :custom
  ;; Allow editing perms bits in wdired
  (wdired-allow-to-change-permissions t)
)

; (use-package atomic-chrome
;   :demand t
;   :custom
;   (atomic-chrome-extension-type-list '(atomic-chrome))
;   (atomic-chrome-buffer-open-style 'frame)
;   :config (atomic-chrome-start-server))

(use-package crux
  :bind (("C-a" . crux-move-beginning-of-line)
         ("C-k" . crux-smart-kill-line)))


;;
;; Programming modes, tree-sitter, LSP
;;
; (use-package treesit-auto
;   :pin melpa
;   :custom
;   (treesit-auto-install 'prompt)
;   :config
;   ;; https://www.reddit.com/r/emacs/comments/1ewrjrm/help_get_proper_syntax_highlight_on_ctsmode/
;   (add-to-list 'treesit-auto-recipe-list
;                (make-treesit-auto-recipe
;                 :lang 'rust
;                 :ts-mode 'rust-ts-mode
;                 :remap 'rust-mode
;                 :url "https://github.com/tree-sitter/tree-sitter-rust"
;                 :revision "v0.23.3"
;                 :ext "\\.rs\\'"))
;   ;; https://github.com/renzmann/treesit-auto/issues/76
;   (setq major-mode-remap-alist
;         (treesit-auto--build-major-mode-remap-alist))
;   (treesit-auto-add-to-auto-mode-alist 'all)
;   (global-treesit-auto-mode))

(use-package cmake-mode
  :ensure t
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode)))

; (use-package rust-mode
;   :demand
;   :pin melpa
;   :custom
;   (rust-mode-treesitter-derive t)
;   :hook
;   (rust-mode . (lambda () (setq indent-tabs-mode nil))))

; (use-package rustic
;   :pin melpa
;   :after (rust-mode))

(use-package go-mode
  :hook (go-ts-mode . (lambda ()
                        (whitespace-toggle-options '(tabs))
                        (setq tab-width 2)))
  :custom
  (go-ts-mode-indent-offset 2))

(use-package markdown-mode
  :ensure t
  :mode
  ("README\\.md\\'" . gfm-mode)
  :custom
  (markdown-command "markdown"))

(use-package protobuf-mode
  :mode "\\.proto\\'")

(use-package lsp-mode
  :pin melpa
  :custom
  (lsp-keymap-prefix "s-l")
  (lsp-completion-provider :none) ;; Corfu!
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.01)
  ;; Having the inlays on all the time is distracting. Instead, toggle them on
  ;; interactively with `M-x lsp-inline-hints-mode` when you want them, then make
  ;; them go away by running it again.
  ;; TODO: Add a toggle for this under the LSP command keymap.
  ;; (lsp-inlay-hint-enable t)
  ;; These are optional configurations. See https://emacs-lsp.github.io/lsp-mode/page/lsp-rust-analyzer/#lsp-rust-analyzer-display-chaining-hints for a full list
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints nil)
  (lsp-rust-analyzer-display-reborrow-hints nil)
  :init
  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless))) ;; Configure orderless
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (lsp-completion-mode . my/lsp-mode-setup-completion)
         (c++-mode . lsp-deferred)
         (c++-ts-mode . lsp-deferred)
         (c-mode . lsp-deferred)
         (c-or-c++-mode . lsp-deferred)
         (c-or-c++-ts-mode . lsp-deferred)
         (c-ts-mode . lsp-deferred)
         (cmake-mode . lsp-deferred)
         (cmake-ts-mode . lsp-deferred)
         (go-mode . lsp-deferred)
         (go-ts-mode . lsp-deferred)
         (python-mode . lsp-deferred)
         (python-ts-mode . lsp-deferred)
         (rust-mode . lsp-deferred)
         (rust-ts-mode . lsp-deferred)
         (typescript-ts-mode . lsp-deferred))
  :commands (lsp lsp-deferred))

(use-package lsp-ui
  :pin melpa
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-show-with-mouse nil)
  (lsp-ui-sideline-enable nil))

(use-package consult-lsp
  :pin melpa
  :after lsp-mode
  :commands consult-lsp-symbols
  :init (define-key lsp-mode-map [remap xref-find-apropos] #'consult-lsp-symbols))

; (use-package auth-source
;   :pin melpa
;   :ensure t)

; (use-package auth-source-1password
;   :pin melpa
;   :ensure t
;   :ensure-system-package op
;   :config
;   (auth-source-1password-enable))

; (use-package gptel
;   :pin melpa
;   :config
;   (setq gptel-model 'claude-sonnet-4-5-20250929)
;   (defun my/get-anthropic-api-key ()
;     "Retrieve Anthropic API key from auth-source (1Password)."
;     (let ((key (auth-source-pick-first-password
;                 :host "anthropic.com"
;                 :user "password")))
;       (if key
;           key
;         (user-error "Anthropic API key not found in auth-source"))))

;   (setq gptel-backend (gptel-make-anthropic "Claude"
;                          :stream t
;                          :key (my/get-anthropic-api-key))))


; ;; Prereq for claude-code-ide
; (use-package eat
;   :vc (:url "https://codeberg.org/akib/emacs-eat" :rev :newest)
;   :demand
;   :bind (:map eat-semi-char-mode-map
;               ;; Unbind M-` so it falls through to global binding (ns-next-frame)
;               ("M-`" . nil)))

; ;; vterm - alternative terminal backend for claude-code-ide
; (use-package vterm
;   :ensure t
;   :pin melpa
;   :bind (:map vterm-mode-map
;               ;; Unbind M-` so it falls through to global binding (ns-next-frame)
;               ("M-`" . nil)))

; (use-package claude-code-ide
;   :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
;   ;; :ensure-system-package claude-code
;   :bind ("s-c" . claude-code-ide-menu)
;   :custom

;   ;; Terminal backend
;   ;; (claude-code-ide-terminal-backend 'eat)  ; Commented out - trying vterm instead
;   (claude-code-ide-terminal-backend 'vterm)

;   ;; Window configuration
;   (claude-code-ide-use-side-window nil)
;   (claude-code-ide-focus-on-open t)

;   ;; Diff integration with ediff
;   (claude-code-ide-use-ide-diff t)
;   (claude-code-ide-focus-claude-after-ediff t)

;   (claude-code-ide-diagnostics-backend 'flycheck)
;   (claude-code-ide-debug-mode nil)
;   (claude-code-ide-chat-auto-scroll t)

;   :config
;   (setenv "ANTHROPIC_API_KEY" (my/get-anthropic-api-key))

;   ;; Enable Emacs MCP tools for deep integration
;   (claude-code-ide-emacs-tools-setup)
; )


; ;; Helper function to load MCP tool guidance from markdown files
; (defun my/load-mcp-guidance (filename)
;   "Load MCP tool guidance from ~/.emacs.d/claude-mcp-guidance/FILENAME."
;   (let ((path (expand-file-name
;                (concat "claude-mcp-guidance/" filename)
;                user-emacs-directory)))
;     (if (file-exists-p path)
;         (with-temp-buffer
;           (insert-file-contents path)
;           (string-trim (buffer-string)))
;       (format "TODO: Create guidance file at %s" path))))

; ;; Claude Code IDE Extras - Additional MCP tools
; (use-package claude-code-ide-extras
;   :vc (:url "https://github.com/acmorrow/claude-code-ide-extras"
;        :rev "0.0.4")
;   :after (projectile lsp-mode claude-code-ide)
;   :demand t
;   :custom
;   ;; Projectile tool customizations
;   (claude-code-ide-extras-projectile-task-start-usage-prompt
;    (my/load-mcp-guidance "projectile/task_start.md"))
;   (claude-code-ide-extras-projectile-task-wait-usage-prompt
;    (my/load-mcp-guidance "projectile/task_wait.md"))
;   (claude-code-ide-extras-projectile-task-query-usage-prompt
;    (my/load-mcp-guidance "projectile/task_query.md"))
;   (claude-code-ide-extras-projectile-task-search-usage-prompt
;    (my/load-mcp-guidance "projectile/task_search.md"))
;   (claude-code-ide-extras-projectile-task-kill-usage-prompt
;    (my/load-mcp-guidance "projectile/task_kill.md"))
;   (claude-code-ide-extras-projectile-read-project-dir-locals-usage-prompt
;    (my/load-mcp-guidance "projectile/read_project_dir_locals.md"))
;   (claude-code-ide-extras-projectile-get-project-files-usage-prompt
;    (my/load-mcp-guidance "projectile/get_project_files.md"))
;   (claude-code-ide-extras-projectile-get-project-buffer-local-keys-usage-prompt
;    (my/load-mcp-guidance "projectile/get_project_buffer_local_keys.md"))
;   (claude-code-ide-extras-projectile-get-project-buffer-local-variables-usage-prompt
;    (my/load-mcp-guidance "projectile/get_project_buffer_local_variables.md"))

;   ;; LSP tool customizations
;   (claude-code-ide-extras-lsp-format-buffer-usage-prompt
;    (my/load-mcp-guidance "lsp/format_buffer.md"))
;   (claude-code-ide-extras-lsp-describe-thing-at-point-usage-prompt
;    (my/load-mcp-guidance "lsp/describe_thing_at_point.md"))

;   ;; Emacs tool customizations
;   (claude-code-ide-extras-emacs-describe-usage-prompt
;    (my/load-mcp-guidance "emacs/describe.md"))
;   (claude-code-ide-extras-emacs-apropos-usage-prompt
;    (my/load-mcp-guidance "emacs/apropos.md"))
;   (claude-code-ide-extras-emacs-apropos-command-usage-prompt
;    (my/load-mcp-guidance "emacs/apropos_command.md"))
;   (claude-code-ide-extras-emacs-apropos-documentation-usage-prompt
;    (my/load-mcp-guidance "emacs/apropos_documentation.md"))
;   (claude-code-ide-extras-emacs-buffer-query-usage-prompt
;    (my/load-mcp-guidance "emacs/buffer_query.md"))
;   (claude-code-ide-extras-emacs-buffer-search-usage-prompt
;    (my/load-mcp-guidance "emacs/buffer_search.md"))
;   (claude-code-ide-extras-emacs-read-dir-locals-usage-prompt
;    (my/load-mcp-guidance "emacs/read_dir_locals.md"))
;   (claude-code-ide-extras-emacs-get-buffer-local-keys-usage-prompt
;    (my/load-mcp-guidance "emacs/get_buffer_local_keys.md"))
;   (claude-code-ide-extras-emacs-get-buffer-local-variables-usage-prompt
;    (my/load-mcp-guidance "emacs/get_buffer_local_variables.md"))
;   (claude-code-ide-extras-emacs-eval-elisp-usage-prompt
;    (my/load-mcp-guidance "emacs/eval_elisp.md"))
;   (claude-code-ide-extras-emacs-eval-region-usage-prompt
;    (my/load-mcp-guidance "emacs/eval_region.md"))
;   (claude-code-ide-extras-emacs-eval-defun-at-point-usage-prompt
;    (my/load-mcp-guidance "emacs/eval_defun_at_point.md"))
;   (claude-code-ide-extras-emacs-find-file-usage-prompt
;    (my/load-mcp-guidance "emacs/find_file.md"))
;   (claude-code-ide-extras-emacs-position-point-usage-prompt
;    (my/load-mcp-guidance "emacs/position_point.md"))
;   (claude-code-ide-extras-emacs-select-region-usage-prompt
;    (my/load-mcp-guidance "emacs/select_region.md"))
;   (claude-code-ide-extras-emacs-xref-find-definitions-at-point-usage-prompt
;    (my/load-mcp-guidance "emacs/xref_find_definitions_at_point.md"))
;   (claude-code-ide-extras-emacs-xref-find-references-at-point-usage-prompt
;    (my/load-mcp-guidance "emacs/xref_find_references_at_point.md"))

;   ;; Meta tool customizations
;   (claude-code-ide-extras-meta-get-mcp-custom-advice-header
;    (my/load-mcp-guidance "meta/header.md"))
;   (claude-code-ide-extras-meta-get-mcp-custom-advice-usage-prompt
;    (my/load-mcp-guidance "meta/get_mcp_custom_advice.md"))

;   :config
;   (claude-code-ide-extras-setup))


;;
;; Snippets
;;
(use-package yasnippet
  :diminish yas-minor-mod
  :hook (prog-mode . yas-minor-mode)
  :config (yas-reload-all))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package consult-yasnippet
  :pin melpa
  :after (consult yasnippet))


;;
;; Other configuration
;;
(use-package ereader
  :pin melpa)


;;
;; Load sidelined custom.el
;;
(when (file-exists-p custom-file)
  (load custom-file))


;;
;; Start the server
;;
(server-start)
