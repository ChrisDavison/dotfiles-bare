(require 'dash)  ;; Stuff like map, each, filter
(require 'f)  ;; Filepath functions
(require 's)  ;; String functions
(require 'rx) ;; Literate regular expressions

(defvar cd/code-dir
  (expand-file-name "~/src/github.com/ChrisDavison")
  "Where my code is stored.")
(defvar cd/work-code-dir
  (expand-file-name "~/src/github.com/cidcom")
  "Where my WORK code is stored.")

(setq-default org-directory (f-join cd/code-dir "knowledge"))

(setq user-full-name "Chris Davison"
      user-mail-address "c.jr.davison@gmail.com")

(setq auto-save-default t
      auto-save-timeout 5
      avy-all-windows t
      recentf-auto-cleanup 60
      global-auto-revert-mode t
      projectile-project-search-path `(,cd/code-dir ,cd/work-code-dir)
      display-line-numbers-type t
      search-invisible t  ;; don't skip matches in query-replace when hidden (e.g. org-mode link urls)
      nov-text-width 80)

(setq pdf-info-epdfinfo-program "/usr/bin/epdfinfo")
(setq calendar-week-start-day 1)

(add-to-list 'auth-sources "~/.authinfo")
(add-hook! dired-mode
           'dired-hide-details-mode
           'dired-hide-dotfiles-mode)

(after! projectile
  (add-to-list 'projectile-project-root-files ".projectile-root"))

;; -----------------------------------------------------------------------------
;;; GLOBAL MODES
;; -----------------------------------------------------------------------------
(global-visual-line-mode 1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(delete-selection-mode 1)
(global-undo-tree-mode 1)
(global-anzu-mode 1) ;; Live preview of search and replace (C-M-@)

;; -----------------------------------------------------------------------------
;;; Hooks
;; -----------------------------------------------------------------------------
(setq fill-column 78)
(setq-default fill-column 78)
(add-hook 'prog-mode-hook #'undo-tree-mode)


(setq vterm-shell "/usr/bin/fish")
(setq shell-file-name "/usr/bin/fish")

;; Nov.el - read epubs in emacs
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
(add-to-list 'auto-mode-alist '("Dockerfile" . dockerfile-mode))
;; (add-to-list 'auto-mode-alist '("docker[a-z\-]" . dockerfile-mode))
(add-to-list 'auto-mode-alist '("\\.scratch\\'" . org-mode))
(add-to-list 'auto-mode-alist '("\\.org_archive\\'" . org-mode))

(setq ibuffer-formats
      `((mark vc-status-mini " "
              (name 50 50 :left :elide) " "
              (size 9 -1 :right)
              " "
              (mode 10 -1 :left) " "
              )
        (mark vc-status-mini " "
              (name 30 30 :left :elide) " "
              (size 9 -1 :right)
              " "
              (mode 10 -1 :left) " "
              vc-relative-file)))

(add-hook! rust-mode '(company-mode flycheck-rust-setup cargo-minor-mode racer-mode eldoc-mode))
(add-to-list 'auto-mode-alist '("\\.rs" . rust-mode))

;; Use goimports instead of go-fmt for formatting with intelligent package addition/removal
(setq gofmt-command "goimports")
(add-hook 'go-mode-hook
          '(lambda ()
             (set (make-local-variable 'company-backends) '(company-go))
             (local-set-key (kbd "M-.") 'godef-jump)
             (go-eldoc-setup)
             (add-hook 'before-save-hook 'gofmt-before-save)))

(setq python-environment-directory "~/.envs/py"
      python-shell-interpreter "python"
      python-shell-interpreter-args ""
      elpy-rpc-python-command "~/.envs/py/bin/python")

;; ipython-based variants
;; (setq python-shell-interpreter "jupyter"
;;       python-shell-interpreter-args "console --simple-prompt")

(add-hook! 'pyvenv-post-activate-hooks
           '((lambda () (setq python-shell-interpreter (f-join pyvenv-virtual-env "bin/jupyter")
                     python-shell-interpreter-args "console --simple-prompt"))))
(add-hook! 'pyvenv-post-deactivate-hooks
           '((lambda ()
               (setq python-shell-interpreter "python"
                     python-shell-interpreter-args ""))))

(map! :map python-mode-map "C-c r" 'elpy-send-contiguous-block)

(defun elpy-send-contiguous-block ()
  "Eval the current python paragraph."
  (interactive)
  (mark-paragraph)
  (elpy-shell-send-region-or-buffer)
  (evil-forward-paragraph))

(defun python-eval-paragraph ()
  "Eval the current python paragraph."
  (interactive)
  (elpy-send-contiguous-block))

(add-hook 'lsp-mode-hook #'lsp-headerline-breadcrumb-mode)
(setq lsp-lens-enable t)
(setq +format-with-lsp nil)

(setq lsp-imenu-index-symbol-kinds
      '(Class Method Property Field Constructor Enum Interface Function Struct Namespace))

(map! :leader :prefix-map ("a" . "applications"))

(defun repoutil (command)
  (cd/shell-command-to-special-buf
   (format "repoutil %s | sort" command)
   "*repoutil*"))
(set-popup-rule! "^\\*repoutil\\*" :side 'bottom :size 0.30 :select t :ttl 1)

(defun cd/shell-command-to-special-buf (command bufname)
  (get-buffer-create bufname)
  (message (format "Running: %s" command))
  (shell-command command bufname)
  (switch-to-buffer-other-window bufname)
  (special-mode)
  (evil-insert 1))

(defun repoutil-branchstat ()
  (interactive)
  (repoutil "branchstat"))

(defun repoutil-list ()
  (interactive)
  (repoutil "list"))

(defun repoutil-fetch ()
  (interactive)
  (repoutil "fetch") (quit-window))

(defun repoutil-unclean ()
  (interactive)
  (repoutil "unclean"))

(map! :leader :prefix ("a r" . "repoutil")  ;; 'a' is my application submenu
      :desc "Status of all branches" "b" #'repoutil-branchstat
      :desc "Fetch all branches" "f" #'repoutil-fetch
      :desc "List all managed repos" "l" #'repoutil-list
      :desc "List all unclean repos" "u" #'repoutil-unclean)

(defun tagsearch-list (&optional tags)
  "List tags under the current directory.

When optional TAGS is a string, show only files matching those tags"
  (interactive)
  (let ((cmd (concat "tagsearch " (or tags "")))
        (temp-buf-name "*tagsearch*"))
    (get-buffer-create temp-buf-name)
    (shell-command cmd temp-buf-name)
    (switch-to-buffer-other-window temp-buf-name)
    (special-mode)
    (evil-insert 1)))

(set-popup-rule! "^\\*tagsearch" :side 'bottom :size 0.30 :select t :ttl 1)

(defun files-matching-tagsearch (&optional tags directory)
  (interactive)
  (let* ((directory (if directory directory (read-directory-name "DIR: ")))
         (cmd (format "tagsearch %s | grep -v archive" (if tags tags (read-string "Tags: "))))
         (fullcmd (format "cd %s && %s" directory cmd))
         (output (s-split "\n" (s-trim (shell-command-to-string fullcmd)))))

    (get-buffer-create "*tagsearch*")
    (shell-command fullcmd "*tagsearch*")
    (switch-to-buffer-other-window "*tagsearch*")
    (special-mode)
    (evil-insert 1)))

(defun find-file-tagsearch (&optional tags directory)
  (interactive)
  (let* (
         (tags (or tags (read-string "Tags: ")))
         (default-directory (expand-file-name (or directory (read-directory-name "Dir: "))))
         (command (s-concat "tagsearch " tags))
         (files (s-split "\n" (s-trim (shell-command-to-string command))))
         (chosen (ivy-read (format "@%s: " tags) files))
         )
    (find-file (f-join default-directory chosen))
    ))

(defun cd/find-thought-file ()
  (interactive)
  (find-file-tagsearch "thought" org-directory))

(defun cd/find-index-file ()
  (interactive)
  (find-file-tagsearch "index" org-directory))

(defun cd/find-book-list-file ()
  (interactive)
  (find-file-tagsearch "booklist" org-directory))

(map! :leader :prefix ("a t" . "tagsearch")  ;; 'a' is my application submenu
     :desc "List tags in this dir" "l" 'tagsearch-list
     :desc "Files with specific tags" "f"
     '(lambda () (interactive)
        (files-matching-tagsearch (read-string "Tags: ") default-directory))
     :desc "ORG Files with specific tags" "o"
     '(lambda () (interactive)
        (files-matching-tagsearch (read-string "Tags: ") org-directory)))

(defun cd/nas/quick-add-download ()
  "Add contents of clipboard to nas' to-download file."
  (interactive)
  (let* ((path "/media/nas/to-download.txt")
         (clip (s-trim (current-kill 0)))
         (re-org-url "\\[\\[\\(.*\\)\\]\\[.*\\]\\]")
         (matches (s-match re-org-url clip))
         (url (if matches (cadr matches) clip))
         (url-tidy (if (s-matches? "youtube\\|youtu\.be" url)
                       (car (s-split "&" url))
                     url))
         (contents (s-split "\n" (read-file-to-string path))))
    (pushnew! contents url-tidy)
    (delete-dups contents)
    (write-region (s-join "\n" contents) nil path)
    (message (concat "Added to downloads: " url-tidy))))
(defun nas/dl/add ()
  (interactive)
  (cd/nas/quick-add-download))

(defun cd/nas/list-downloads ()
  "List contents of NAS 'to-download' list."
  (interactive)
  (let* ((path "/media/nas/to-download.txt")
         (temp-buf-name "*nas-downloads*"))
    (get-buffer-create temp-buf-name)
    (switch-to-buffer-other-window temp-buf-name)
    (insert "NAS DOWNLOADS\n=============\n")
    (insert-file-contents path)
    (special-mode)
    (evil-insert 1)))
(defun nas/dl/list ()
  (interactive)
  (cd/nas/list-downloads))
(set-popup-rule! "^\\*nas-downloads*" :side 'bottom :size 0.30 :select t :ttl 1)

(map! :leader :prefix ("a n" . "nas downloads")  ;; 'a' is my application submenu
      :desc "quick add" "a" 'cd/nas/quick-add-download
      :desc "list" "l" 'cd/nas/list-downloads)

(setq-default deadgrep--search-type 'regexp)
(setq cd/prefer-rg-to-deadgrep t)

(defun cd/unchecked-todos ()
  "Find checkboxes that aren't ticked"
  (interactive)
  (let ((default-directory org-directory)
        (search "\\[ \\]"))
    (if cd/prefer-rg-to-deadgrep
        (rg search "*.org" org-directory)
      (deadgrep search))))

(defun cd/rg-specific-file (search filename)
  "Search for SEARCH inside ORG-DIRECTORY/FILENAME."
  (let* ((default-directory org-directory)
         (deadgrep--file-type '(glob . filename)))
    (if cd/prefer-rg-to-deadgrep
        (rg search filename org-directory)
      (deadgrep search))))

(defun rg-journal (search)
  "Search ORG-DIRECTORY/journal.org"
  (interactive "Msearch string: ")
  (cd/rg-specific-file search "journal.org"))

(defun rg-logbook (search)
  "Search ORG-DIRECTORY/logbook.org"
  (interactive "Msearch string: ")
  (cd/rg-specific-file search "logbook.org"))

(defun rg-work (search)
  "Search ORG-DIRECTORY/work.org"
  (interactive "Msearch string: ")
  (cd/rg-specific-file search "work.org"))

(defun rg-org (search)
  "Search org-directory"
  (interactive "Msearch string: ")
  (if cd/prefer-rg-to-deadgrep
      (rg search "*.org" org-directory)
    (let ((default-directory org-directory))
      (deadgrep search))))

(defun rg-marked-region ()
  "Search for whatever is highlighted, in my org-directory"
  (interactive)
  (kill-ring-save (region-beginning) (region-end))
  (if cd/prefer-rg-to-deadgrep
      (rg (current-kill 0) "*.org" org-directory)
    (let ((default-directory org-directory))
      (deadgrep (current-kill 0)))))

(defun cd/backlinks ()
  "Find files which reference current file."
  (interactive)
  (let ((default-directory org-directory)
        (deadgrep--file-type '(glob . "*.org")))
    (if cd/prefer-rg-to-deadgrep
      (rg (buffer-name) "*.org" org-directory)
    (let ((default-directory org-directory))
      (deadgrep (buffer-name))))))

(map! :leader :prefix ("a g" . "grep")  ;; 'a' is my application submenu
      :desc "org notes" "o" 'rg-org
      :desc "logbook" "l" 'rg-logbook)

(defun regexp-replace-all-matches (regexp replacement)
  "Replace all matches of REGEXP in a buffer with REPLACEMENT."
  (interactive "Mregexp: \nMreplacement: ")
  (replace-regexp regexp replacement nil (point-min) (point-max)))

(defun regexp-erase-all-matches (regexp)
  "Erase all matches of REGEXP in a buffer."
  (interactive "Mregexp: ")
  (regexp-replace-all-matches regexp ""))

;;; Tags (like tagsearch or roam)
(defun tagify (str)
  (interactive "M")
  (s-join " " (--map (format "@%s" it) (s-split " " str))))

(defun roam-tagify (str)
  (interactive "Mtags: ")
  (evil-open-below 1)
  (insert (format "#+ROAM_TAGS: %s\n\n" str))
  (insert (tagify str))
  (evil-force-normal-state)
  (save-buffer))

(defun roam-tagify-toplevel (str)
  (interactive "Mtags: ")
  (evil-goto-first-line)
  (evil-insert-line 1)
  (insert (s-concat "#+ROAM_TAGS: " (tagify str) "\n\n"))
  (evil-force-normal-state)
  (save-buffer))

(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

(defun cd/quotify ()
  (interactive)
  (kill-region (point) (point-at-eol))
  (insert (format "/\"%s\"/" (current-kill 0))))

(defun next-circular-index (i n &optional reverse)
  (let ((next (if reverse (- i 1) (+ i 1))))
    (mod next n)))

(defun new-in-git (&optional n)
  "List files that have been updated or created in last N days."
  (interactive)
  (let* ((bufname "*new-in-repo*")
         (n (if n n 7))
         (cmd (format "new_in_git %s" n)))
    (get-buffer-create bufname)
    (shell-command cmd bufname)
    (switch-to-buffer-other-window bufname)
    (special-mode)))
(set-popup-rule! "^\\*new-in-repo\\*" :side 'bottom :size 0.30 :select t :ttl 1)

(defun cd/projectile-magit-status ()
  "Jump to magit-status in a known projectile project."
  (interactive)
  (let ((project (completing-read "Project: "
                                  projectile-known-projects-on-file)))
    (magit-status project)))

(defun cd/string-to-special-buffer (contents bufname)
  (interactive)
  (when (get-buffer bufname)
    (kill-buffer bufname))
  (get-buffer-create bufname)
  (switch-to-buffer-other-window bufname)
  (normal-mode)
  (goto-char (point-min))
  (kill-region (point-min) (point-max))
  (insert contents)
  (special-mode)
  (evil-insert 1))

(defun read-file-to-string (filePath)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))

(defun plaintext-in-region ()
  (let* ((foo    (progn (kill-ring-save 0 0 t) (current-kill 0)))
         (start  0)
         (end    (length foo)))
    (set-text-properties start end nil foo)
    foo))

(defun get-term-region-or-prompt (&optional term prompt)
  "Get input from user.

If function given a term, use term. Otherwise, if region highlighted, use region.
Finally, prompt the user for a string."
  (interactive)
  (cond (term term)
        ((region-active-p) (plaintext-in-region))
        (t (read-string prompt))))

(defun generic-web-search (search-url &optional term)
  "Search a website."
  (let* ((term (get-term-region-or-prompt term "Search: "))
         (tidy-term (s-replace " " "%20" (s-trim term)))
         (url (format search-url tidy-term)))
    (browse-url url)))

(defun goodreads (&optional term)
  "Find book on goodreads."
  (interactive)
  (generic-web-search "https://www.goodreads.com/search?q=%s" term))

(defun duckduckgo (&optional term)
  "Search duckduckgo."
  (interactive)
  (generic-web-search "https://www.duckduckgo.com/?q=%s" term))

(defun youtube (&optional term)
  "Search youtub."
  (interactive)
  (generic-web-search "https://www.youtube.com/results?search_query=%s" term))

(defun devdocs (&optional term)
  "Search duckduckgo."
  (interactive)
  (generic-web-search "https://devdocs.io/#q=%s" term))

(defun fish-term ()
  "Launch fish"
  (interactive)
  (term "/usr/bin/zsh"))

(defun zsh-term ()
  "Launch zsh"
  (interactive)
  (term "/usr/bin/zsh"))

(defun place-here-anchor ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (replace-regexp "<<here>>" ""))
  (insert "<<here>>"))

(defun jump-to-here-anchor ()
  (interactive)
  (goto-char (point-min))
  (search-forward "<<here>>")
  (evil-scroll-line-to-center nil))

(defun find-here-anchors ()
  (interactive)
  (let* ((default-directory org-directory)
         (deadgrep--file-type '(glob . "*.org"))
         (search "<<here>>"))
    (if cd/prefer-rg-to-deadgrep
        (rg search "*.org" org-directory)
      (deadgrep search))))

(map! :leader
      :desc "<<here>>" "j h" 'jump-to-here-anchor
      :desc "Place <<here>>" "j H" 'place-here-anchor
      :desc "Headline in [work]" "j w"
      '(lambda () (interactive) (jump-to-headline-in-file "work.org"))
      :desc "Headline in [logbook]" "j l"
      '(lambda () (interactive) (jump-to-headline-in-file "logbook.org"))
      :desc "Headline in [productivity]" "j p"
      '(lambda () (interactive) (jump-to-headline-in-file "productivity.org"))
      :desc "Headline in [STEM]" "j s"
      '(lambda () (interactive) (jump-to-headline-in-file "science-tech-engineering-math.org"))
      :desc "Headline in [inbox]" "j i"
      '(lambda () (interactive) (jump-to-headline-in-file "inbox.org"))
      :desc "Headline in [reading]" "j r"
      '(lambda () (interactive) (jump-to-headline-in-file "reading.org"))
)

(map! "C-<" 'avy-goto-word-1) ;; C-S-,

(defun jump-to-headline-in-file (&optional filename)
  (interactive)
  (let ((default-directory org-directory))
    (if filename
        (find-file filename)
      (ido-find-file))
    (counsel-outline)
    (evil-scroll-line-to-top (line-number-at-pos (point)))))

(map! "<f7>" 'next-narrow
      "<f8>" '(lambda () (interactive) (next-narrow 'back)))

(defun find-next-file (&optional backward)
  "Find the next file (by name) in the current directory.

With prefix arg, find the previous file."
  (interactive "P")
  (when buffer-file-name
    (let* ((file (expand-file-name buffer-file-name))
           (files (cl-remove-if (lambda (file) (cl-first (file-attributes file)))
                                (sort (directory-files (file-name-directory file) t nil t) 'string<)))
           (direction (if backward -1 1))
           (pos (mod (+ (cl-position file files :test 'equal) direction)
                     (length files))))
      (find-file (nth pos files)))))

(defun find-previous-file ()
  "Find the next file (by name) in the current directory."
  (interactive)
  (find-next-file t))

(defun files-in-curdir-with-ext (ext)
  (let* ((curdir (expand-file-name default-directory))
         (files (directory-files curdir)))
    (seq-filter
     (lambda (filename)
       (s-equals? ext (file-name-extension filename)))
     (-map (lambda (file) (s-concat curdir file)) files))))

(map! "<f5>" 'find-previous-file
      "<f6>" 'find-next-file
      "C-<left>" 'find-previous-file
      "C-<right>" 'find-next-file)

(setq tramp-default-method "sshx")
(setq cd/remote-servers
      '(("skye" :username "cdavison" :ip "130.159.94.19")
        ("uist" :username "cdavison" :ip "130.159.95.176" :hop "skye")
        ("cava" :username "cdavison" :ip "130.159.94.251" :hop "skye")
        ("bute" :username "cdavison" :ip "130.159.94.204" :hop "skye")
        ("jura" :username "cdavison" :ip "130.159.94.214" :hop "skye")
        ("iona" :username "cdavison" :ip "130.159.94.187" :hop "skye")))


(defun cd/extract-ssh-connection (&optional name)
  (if (boundp 'cd/remote-servers)
      ;; cd/remote-servers should be a plist of (SERVER :username USER :ip IP)
      (let* ((selected (if name name (completing-read "Server: " (mapcar 'car cd/remote-servers) nil t)))
             (data (cdr (assoc selected cd/remote-servers)))
             (username (plist-get data :username))
             (ip (plist-get data :ip))
             (hop (plist-get data :hop)))
        `(,username ,ip ,hop))
    ;; otherwise, read a username and an ip
    (let ((username (read-string "Username: "))
          (ip (read-string "ip: "))
          (hop nil))
      `(,username ,ip ,hop))))

(defun connect-remote ()
  (interactive)
  (let* ((data (cd/extract-ssh-connection))
         (username (car data))
         (folder (if (string= username "root") "/" (format "/home/%s/" username)))
         (ip (car (cdr data)))
         (hop (car (cdr (cdr data))))
         (hopdata (if hop (cd/extract-ssh-connection hop) nil))
         (hopstr (if hopdata (format "sshx:%s@%s|"
                                     (car hopdata)
                                     (car (cdr hopdata)))
                   ""))
         (connstr (format "sshx:%s@%s" username ip))
         (conn (format "/%s%s:%s" hopstr connstr folder)))
    (dired conn)))

(load-library "find-lisp")

(defun cd/org-datetree-find-dayonly-create ()
  (goto-char (point-min))
  (let* ((date (org-read-date nil t))
         (yyyy (format-time-string "%Y" date))
         (mm (format-time-string "%m" date))
         (dd (format-time-string "%d" date))
         (ddnum (string-to-number dd))
         (re (format "^\\* %s-%s-\\([0123][0-9]\\) \\w+$" yyyy mm))
         (datestr (format-time-string "%Y-%m-%d %a" date)))

    ;; Search for the same year-month, while we're still finding dates
    ;; within this month that are earlier than our target date.
    (while (and (setq match (re-search-forward re nil t))
                (goto-char (match-beginning 1))
                (< (string-to-number (match-string 1)) ddnum)))

    (cond
     (;;
      (not match)
      (+org/insert-item-below 1)
      (insert datestr "\n")
      (previous-line)
      (evil-normal-state))
     (;; We've found a headline with the same date
      (= (string-to-number (match-string 1)) (string-to-number dd))
      (goto-char (point-at-bol))
      )
     (t
      (beginning-of-line)
      (+org/insert-item-above 1)
      (insert datestr "\n")
      (previous-line)
      (evil-normal-state)
      )
     )
    ))

(defun remove-org-mode-properties ()
  (interactive)
  (goto-char (point-min))
  (query-replace-regexp
   (rx bol (* " ") ":" (+ (any alnum "_")) ":" (* (seq " " (+ nonl))) "\n")
   ""))

(defun insert-newline-if-not-at-start ()
  (unless (= (point) (line-beginning-position))
    (newline)))

(defun cd/point-of-first-header ()
  "Return the point of first org-mode-header, or nil if it doesn't exist."
  (save-excursion
    (goto-char (point-min))
    (re-search-forward "^\*" nil t)))

(defun cd/goto-end-of-toplevel-list ()
  "Find the first top-level list, or insert one if it doesn't exist."
  (interactive)
  (let ((pos-first-header (cd/point-of-first-header)))
    (goto-char (point-min))
    (if (re-search-forward "^-" (or pos-first-header (point-max)) t)
        (org-forward-paragraph)
      (if pos-first-header
          (progn
            (goto-char pos-first-header)
            (+evil/insert-newline-above 2)
            (evil-next-visual-line -2))
        (progn
          (org-forward-paragraph)
          (+evil/insert-newline-below 1)
          (evil-next-visual-line 1)
          nil)
        ))))

(defun cd/insert-in-toplevel-list (thing)
  (interactive)
  (save-excursion
    (if (cd/goto-end-of-toplevel-list)
        (+org/insert-item-below 1)
      (insert "-"))
    (evil-normal-state)
    (insert " " thing)))

(defun filename-to-pretty-title (filename)
  (s-capitalized-words
   (s-replace "-" " "
              (file-name-sans-extension (file-name-base filename)))))

(defun create-or-add-to-see-also-header (text)
  (save-excursion
    (unless (re-search-forward "^\* See Also" nil t)
      (goto-char (point-max))
      (evil-insert-newline-below)
      (insert "* See Also\n\n"))

    (org-narrow-to-subtree)
    (goto-char (point-max))
    (insert "- " text)
    (widen)))



(defun org-file-from-subtree (&optional arg)
  "Take the current subtree and create a new file from
  it. Add a link at the top of the file in the first pre-header list.

In the new file, promote all direct children of the original
  subtree to be level 1-headings, and transform the original
  heading into the '#+TITLE' parameter.

If called with the universal argument, prompt for new filename,
otherwise use the subtree title.

With ARG, also visit the file.
"
  (interactive "P")
  (let* ((curdir (file-name-directory (buffer-file-name)))
         (filename (read-file-name "File: " curdir))
         (link (file-relative-name filename curdir))
         (title (filename-to-pretty-title filename))
         (link-text (format "[[file:%s][%s]]" link title))
         (curfile-relative-to-new (file-relative-name (buffer-file-name) (file-name-directory filename)))
         (curfile-title (filename-to-pretty-title buffer-file-name))
         (curfile-link (format "[[file:%s][%s]]" curfile-relative-to-new curfile-title)))
    ;; Copy current subtree into clipboard
    (org-cut-subtree)

    (save-excursion
      (create-or-add-to-see-also-header link-text)
      ;; (cd/insert-in-toplevel-list link-text)
      )
    (save-buffer)

    (with-temp-file filename
      (org-mode)
      (insert "#+TITLE: " title "\n\n")
      (org-paste-subtree)
      (create-or-add-to-see-also-header curfile-link))

    (when arg
      (find-file filename))))

(defun org-file-from-selection (&optional clipboard-only)
  "Create a new file from current selection, inserting a link.

  Prompt for a filename, and create. Prompt for an org-mode
  TITLE, and insert. Insert the cut region. Then, insert the link
  into the source document, using TITLE as description"
  (interactive)
  (when (region-active-p)
    (let* ((filename (read-file-name "New filename: " org-directory))
           (file-relative (file-relative-name
                           filename
                           (file-name-directory (expand-file-name filename))))
           (title (read-from-minibuffer "Title: "))
           (link-text (format "[[file:%s][%s]]" link title)))
      (call-interactively' kill-region)
      (if clipboard-only
          (kill-new link-text)
        (save-excursion (cd/insert-in-toplevel-list link-text)))
      ;; (newline)
      (with-temp-file filename
        (org-mode)
        (insert (concat "#+TITLE: " title "\n\n"))
        (evil-paste-after 1)))))


(defun org-open-link-same-window ()
  (interactive)
  (let ((org-link-frame-setup '((file . find-file))))
    (org-open-at-point)))

(defun org-open-link-other-window ()
  (interactive)
  (let ((org-link-frame-setup '((file . find-file-other-window))))
    (org-open-at-point)))


(defun org-refile-to-file (&optional target level)
  (interactive)
  (let* ((filename (or target (ivy-read "Refile to: " (f-entries default-directory nil t))))
         (org-refile-targets `((,filename . (:maxlevel . ,(or level 5))))))
    (org-refile)))


(defun org-refile-to-this-file ()
  (interactive)
  (org-refile-to-file (buffer-name)))


(defun org-refile-to-this-file-level1 ()
  (interactive)
  (org-refile-to-file (buffer-name) 1))


(defun org-change-state-and-archive ()
  (interactive)
  (org-todo)
  (org-archive-subtree-default))


(defun org-paste-checkbox-list ()
  (interactive)
  (insert-newline-if-not-at-start)
  (insert (replace-regexp-in-string "^" "- [ ] " (current-kill 0))))


(defun org-paste-todo-header-list (&optional level)
  (interactive)
  (let* ((level (or level 1))
         (stars (s-repeat level "*"))
         (todo (s-concat stars " TODO ")))
    (insert-newline-if-not-at-start)
    (insert (replace-regexp-in-string "^" todo (current-kill 0)))))


(defun org-paste-todo-header-list-l2 ()
  (interactive)
  (org-paste-todo-header-list 2))


(defun org-paste-todo-header-list-l3 ()
  (interactive)
  (org-paste-todo-header-list 3))


(defun org-archive-level1-done ()
  (interactive)
  (save-excursion
    (goto-char 1)
    (+org/close-all-folds)
    (org-map-entries 'org-archive-subtree "/DONE" 'file)))


(defun org-copy-link-url (&optional arg)
  "Extract URL from org-mode link and add it to kill ring."
  (interactive "P")
  (let* ((link (org-element-lineage (org-element-context) '(link) t))
         (type (org-element-property :type link))
         (url (org-element-property :path link))
         (url (concat type ":" url)))
    (kill-new url)
    (message (concat "Copied URL: " url))))


(defun org-fix-blank-lines (prefix)
  "Ensure that blank lines exist between headings and between headings and their contents.
With prefix, operate on whole buffer. Ensures that blank lines
exist after each headings's drawers."
  (interactive "P")
  (org-map-entries (lambda ()
                     (org-with-wide-buffer
                      ;; `org-map-entries' narrows the buffer, which prevents us from seeing
                      ;; newlines before the current heading, so we do this part widened.
                      (while (not (looking-back "\n\n" nil))
                        ;; Insert blank lines before heading.
                        (insert "\n")))
                     (let ((end (org-entry-end-position)))
                       ;; Insert blank lines before entry content
                       (forward-line)
                       (while (and (org-at-planning-p)
                                   (< (point) (point-max)))
                         ;; Skip planning lines
                         (forward-line))
                       (while (re-search-forward org-drawer-regexp end t)
                         ;; Skip drawers. You might think that `org-at-drawer-p' would suffice, but
                         ;; for some reason it doesn't work correctly when operating on hidden text.
                         ;; This works, taken from `org-agenda-get-some-entry-text'.
                         (re-search-forward "^[ \t]*:END:.*\n?" end t)
                         (goto-char (match-end 0)))
                       (unless (or (= (point) (point-max))
                                   (org-at-heading-p)
                                   (looking-at-p "\n"))
                         (insert "\n"))))
                   t (if prefix
                         nil
                       'tree)))


(defun org-archive-file ()
  "Move current file into my org archive dir."
  (interactive)
  (let* ((archive-dir (f-join org-directory "archive"))
         (fname (file-name-nondirectory (buffer-file-name)))
         (new-fname (f-join archive-dir fname)))
    (rename-file (buffer-file-name) new-fname)))


(defun cd/refile (file headline &optional arg)
  (let ((pos (save-excursion
               (find-file file)
               (org-find-exact-headline-in-buffer headline))))
    (org-refile arg nil (list headline file nil pos)))
  (switch-to-buffer (current-buffer)))

(defun org-unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (org-fill-paragraph nil region)))

(defun find-todays-headline-or-create ()
  (interactive)
  (let* ((today-str (format-time-string "%Y-%m-%d %A"))
         (marker (org-find-exact-headline-in-buffer today-str)))
    (if marker (org-goto-marker-or-bmk marker)
      (progn (goto-char (point-max))
             (org-insert-heading)
             (insert " " today-str)))))


(defun org-update-all-checkbox-counts ()
  (interactive)
  (org-update-checkbox-count t))

(defun org-copy-link (&optional arg)
  "Copy org-mode links from anywhere within."
  (interactive "P")
  (let* ((link (org-element-lineage (org-element-context) '(link) t))
         (raw-link (org-element-property :search-option link))
         (tidy (string-trim-left raw-link "\*")))
    (kill-new tidy)
    (message (concat "Copied Link: " tidy))))

(defun cd/org-copy-next-link ()
  "Find the next link, copy it to the kill ring, and leave the curser at the end."
  (interactive)
  (let* ((start (- (re-search-forward "\\[\\[") 2))
         (end (re-search-forward "\\]\\]")))
    (kill-ring-save start end)
    (goto-char end)))

(defun cd/org-files-under-dir (dir)
  (if (f-dir? dir)
      (find-lisp-find-files dir "\.org$")
    (find-lisp-find-files (f-join org-directory dir) "\.org$")))

(defun cd/do-and-archive ()
  (interactive)
  (org-todo 'done)
  (org-archive-subtree))

(defun cd/kill-and-archive ()
  (interactive)
  (org-todo 'kill)
  (org-archive-subtree))

;; Visit every org file when emacs starts
(setq cd/preload-org-files nil)
(when cd/preload-org-files
  (dolist (it (org-agenda-files))
    (find-file-noselect it)))

(defun cd/get-keyword-key-value (kwd)
  (let ((data (cadr kwd)))
    (list (plist-get data :key)
          (plist-get data :value))))

(defun cd/org-current-buffer-get-title ()
  (cd/org-current-buffer-get-keyword-value "TITLE"))

(defun cd/org-current-buffer-get-keyword-value (keyword)
  (nth 1
       (assoc keyword
              (org-element-map (org-element-parse-buffer 'greater-element)
                  '(keyword)
                #'cd/get-keyword-key-value))))

(defun cd/org-file-get-keyword-value (file keyword)
  (with-current-buffer (find-file-noselect file)
    (cd/org-current-buffer-get-keyword-value keyword)))


(defun cd/org-file-get-title (file)
  (cd/org-file-get-keyword-value file "TITLE"))

(defun cd/org-table-sum-column (col)
  (interactive)
  (org-table-goto-line 2)
  (let ((total 0))
    (while (org-table-p)
      (setq total (+ total (let ((val (org-table-get nil col)))
                             (if val (string-to-number val) 0))))
      (next-line))
    total))

(defun cd/org-table-cycling-tss-sum ()
  (interactive)
  (message "Total TSS: %d" (cd/org-table-sum-column 4)))

(defun collect-duplicate-headings ()
  (let (dups contents hls)
    (save-excursion
      (goto-char (point-max))
      (while (re-search-backward org-complex-heading-regexp nil t)
        (let* ((el (org-element-at-point))
               (hl (org-element-property :title el))
               (pos (org-element-property :begin el)))
          (push (cons hl pos) hls)))
      (setq contents
            (cl-loop for hl in hls
                     for pos = (goto-char (cdr hl))
                     for beg = (progn pos (line-beginning-position))
                     for end = (progn pos (org-end-of-subtree nil t))
                     for content = (buffer-substring-no-properties beg end)
                     collect (list (car hl) (cdr hl) content)))
      (dolist (elt contents)
        (when (> (cl-count (last elt) (mapcar #'last contents)
                           :test 'equal)
                 1)
          (push (cons (car elt)
                      (nth 1 elt))
                dups)))
      (nreverse dups))))

(defun show-duplicate-headings ()
  (interactive)
  (helm :sources (helm-build-sync-source "Duplicate headings"
                                         :candidates (lambda ()
                                                       (with-helm-current-buffer
                                                        (collect-duplicate-headings)))
                                         :follow 1
                                         :action 'goto-char)))

(defun org-lint-dir (directory)
  (let* ((files (directory-files directory t ".*\\.org$")))
    (org-lint-list files)))

(defun org-lint-list (files)
  (cond (files
         (org-lint-file (car files))
         (org-lint-list (cdr files)))))

(defun org-lint-file (file)
  (let ((buf)
        (lint))
    (setq buf (find-file-noselect file))
    (with-current-buffer buf
      (if (setq lint (org-lint))
          (print (list file lint))))))

;;; Lists and checkboxes
(defun make-into-list ()
  "Basically equivalent to org-ctrl-c-minus."
  (interactive)
  (replace-regexp "^" "- " nil (region-beginning) (region-end)))

(defun make-into-checkbox-list ()
  "Convert selection to list (only at root level) of checkboxes."
  (interactive)
  (let ((re (rx bol (zero-or-one "-") (one-or-more space))))
    (replace-regexp re "- [ ] " nil (region-beginning) (region-end))))

(setq cd/simple-css
      "body{
            margin:40px auto;
            max-width: 60em;
            line-height:1.6;
            font-size:18px;
            color:#454545;
            padding:0 10px
        }

        h1,h2,h3{line-height:1.2; text-align: center;}")


(setq org-directory (f-join cd/code-dir "knowledge")
      org-src-window-setup 'current-window
      org-indent-indentation-per-level 1
      org-adapt-indentation nil
      org-tags-column -60
      org-pretty-entities t
      org-id-link-to-org-use-id nil
      org-catch-invisible-edits 'show-and-error
      org-imenu-depth 4
      ;; by default, open org links in SAME window
      org-link-frame-setup '((file . find-file))
      ;; org-link-frame-setup '((file . find-file-other-window))
      org-hide-emphasis-markers t
      org-todo-keywords '((sequence "TODO(t)"
                                    "NEXT(n)" ; PRIORITISED todo
                                    "BLCK(b)" ; CANNOT DO JUST NOW
                                    "WIP(w)"
                                    "|"
                                    "DONE(d)"
                                    "KILL(k)" ; WON'T DO
                                    ))
      org-cycle-separator-lines 0
      org-list-indent-offset 2
      org-modules nil
      org-treat-insert-todo-heading-as-state-change t
      org-log-repeat 'time
      org-log-done 'time
      org-log-done-with-time nil
      org-log-into-drawer t
      org-archive-location (f-join org-directory "archive/archive.org::* From %s")
      org-refile-use-outline-path 't
      org-refile-allow-creating-parent-nodes 'confirm
      org-startup-folded 'fold
      org-id-track-globally t
      org-image-actual-width 600
      org-blank-before-new-entry '((heading . t) (plain-list-item . auto))
      org-html-head (format "<style type=\"text/css\">%s</style>" cd/simple-css)
      )

;; Babel
(setq org-babel-python-command "~/.envs/py/bin/python3")

;; Deft
(setq deft-directory org-directory)
(setq deft-recursive t)

(defun cd/insert-or-make-org-link ()
  "If the clipboard is a url, ask for a title. Otherwise, assume an org-link."
  (let ((clip (current-kill 0)))
    (if (s-starts-with? "http" clip)
        (concat "[[" clip "][" (read-string "Title: ") "]]")
      clip)))

(defun cd/capture-templates ()
  (setq org-capture-templates
        `(("i" "inbox entry" entry
           (file "inbox.org")
           "* %?" :empty-lines-before 1)

          ("n" "note" item
           (file+headline "inbox.org" "Notes")
           "- %?")

          ("t" "note [timestamped]" item
           (file+headline "inbox.org" "Notes")
           "- =%<%b %d, %H:%M>= - %?")

          ("l" "logbook" entry
           (file+function "logbook.org" cd/org-datetree-find-dayonly-create)
           "* %?"))))
(cd/capture-templates)

(map! "<f1>" '(lambda () (interactive) (org-capture nil "i"))
      "<f2>" '(lambda () (interactive) (org-capture nil "l"))
      "<f3>" '(lambda () (interactive) (org-capture nil "n")))

(map! :mode org-mode
      :leader "s i" 'counsel-outline
      :leader "n R" 'rg-org
                )

;;; Org AGENDA
(setq org-agenda-window-setup 'current-window
      org-agenda-restore-windows-after-quit t
      ;; inhibit-startup nil means that if we want files to start 'folded', then agenda
      ;; will respect this
      ;; inhibit-startup t means 'just unfold', and can greatly speed up agenda
      ;; if there are many folded headings
      org-agenda-inhibit-startup t
      org-agenda-dim-blocked-tasks nil
      org-agenda-ignore-drawer-properties '(effort appt)
      org-agenda-show-all-dates t ; nil hides days in agenda if no tasks on that day
      ;; org-agenda-files (--filter (not (s-matches? "archive\\|recipes\\|thought" it))
      ;;                            (find-lisp-find-files org-directory "\.org$"))
      ;; All the files in the root of org directory
      org-agenda-files (append `(,org-directory)
                               ;; ...and any non-dotted directory underneath it
                               (--filter (and (f-directory-p (f-join org-directory it))
                                              (not (s-matches? (rx bol (+ ".")) it))
                                              (not (s-matches? "archive" it))
                                              (not (s-matches? "book-notes" it)))
                                         (directory-files org-directory)))
      ;; (--filter (not (s-matches? "archive\\|recipes\\|thought" it))
      ;;                            (find-lisp-find-files org-directory "\.org$"))
      org-agenda-file-regexp "\\`[^.].*\\.org\\'"
      org-refile-targets `((org-agenda-files . (:maxlevel . 2)))
      org-agenda-span 'week
      org-agenda-start-day nil
      org-agenda-skip-scheduled-if-deadline-is-shown t
      org-agenda-skip-scheduled-if-done nil
      org-agenda-skip-deadline-if-done nil
      org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled
      org-agenda-skip-archived-trees nil
      org-agenda-block-separator ""
      org-agenda-compact-blocks nil
      org-agenda-todo-ignore-scheduled 'future
      org-agenda-sort-notime-is-late nil
      org-agenda-remove-tags t
      org-agenda-time-grid '((daily today require-timed remove-match)
                             (800 1000 1200 1400 1600 1800 2000)
                             "......"
                             "")
      org-agenda-use-time-grid t
      org-agenda-prefix-format '((agenda . "%-20c%-12t%6s")
                                 (timeline . "% s")
                                 (todo . "%-20c")
                                 (tags . "%-20c")
                                 (search . "%-20c"))
      org-agenda-deadline-leaders '("!!! " "D%-2d " "D-%-2d ")
      org-agenda-scheduled-leaders '("" "S-%-2d ")
      org-agenda-sorting-strategy '((agenda time-up todo-state-up  category-up  scheduled-down priority-down)
                                    (todo todo-state-down category-up priority-down)
                                    (tags priority-down category-keep)
                                    (search category-keep))
      )

;;; Org AGENDA
(setq org-agenda-window-setup 'current-window
      org-agenda-restore-windows-after-quit t
      ;; inhibit-startup nil means that if we want files to start 'folded', then agenda
      ;; will respect this
      ;; inhibit-startup t means 'just unfold', and can greatly speed up agenda
      ;; if there are many folded headings
      org-agenda-inhibit-startup t
      org-agenda-dim-blocked-tasks nil
      org-agenda-ignore-drawer-properties '(effort appt)
      org-agenda-show-all-dates t ; nil hides days in agenda if no tasks on that day
      ;; org-agenda-files (--filter (not (s-matches? "archive\\|recipes\\|thought" it))
      ;;                            (find-lisp-find-files org-directory "\.org$"))
      ;; All the files in the root of org directory
      org-agenda-files (append `(,org-directory)
                               ;; ...and any non-dotted directory underneath it
                               (--filter (and (f-directory-p (f-join org-directory it))
                                              (not (s-matches? (rx bol (+ ".")) it))
                                              (not (s-matches? "archive" it))
                                              (not (s-matches? "book-notes" it)))
                                         (directory-files org-directory)))
      ;; (--filter (not (s-matches? "archive\\|recipes\\|thought" it))
      ;;                            (find-lisp-find-files org-directory "\.org$"))
      org-agenda-file-regexp "\\`[^.].*\\.org\\'"
      org-refile-targets `((org-agenda-files . (:maxlevel . 2)))
      org-agenda-span 'week
      org-agenda-start-day nil
      org-agenda-skip-scheduled-if-deadline-is-shown t
      org-agenda-skip-scheduled-if-done nil
      org-agenda-skip-deadline-if-done nil
      org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled
      org-agenda-skip-archived-trees nil
      org-agenda-block-separator ""
      org-agenda-compact-blocks nil
      org-agenda-todo-ignore-scheduled 'future
      org-agenda-sort-notime-is-late nil
      org-agenda-remove-tags t
      org-agenda-time-grid '((daily today require-timed remove-match)
                             (800 1000 1200 1400 1600 1800 2000)
                             "......"
                             "")
      org-agenda-use-time-grid t
      org-agenda-prefix-format '((agenda . "%-20c%-12t%6s")
                                 (timeline . "% s")
                                 (todo . "%-20c")
                                 (tags . "%-20c")
                                 (search . "%-20c"))
      org-agenda-deadline-leaders '("!!! " "D%-2d " "D-%-2d ")
      org-agenda-scheduled-leaders '("" "S-%-2d ")
      org-agenda-sorting-strategy '((agenda time-up todo-state-up  category-up  scheduled-down priority-down)
                                    (todo todo-state-down category-up priority-down)
                                    (tags priority-down category-keep)
                                    (search category-keep))
      )
(defun f-org (filename)
  "Filename relative to my org directory."
  (f-join org-directory filename))

(defun cd/work-files ()
  (-map 'f-org '("work.org" "logbook.org" "literature.org")))

(defun cd/reading-files ()
  (append (cd/org-files-under-dir "book-notes")
          `(,(f-org "reading.org"))))

(defun cd/non-work-files ()
  (let* ((non-work (cl-set-difference (org-agenda-files) (cd/work-files) :test 'equal)))
    non-work))

(defun cd/literature-files ()
  `(,(f-org "literature.org")))

(defun cd/non-reading-files ()
  (--filter (not (s-matches? "reading\\|literature" it))
            (org-agenda-files)))

(defun cd/refile-to-top-level ()
  (interactive)
  (let ((org-refile-use-outline-path 'file)
        (org-refile-targets `((org-agenda-files . (:level . 0)))))
    (org-refile)))

(setq org-pandoc-options-for-ms-pdf
      '((template . "~/.local/share/pandoc/templates/eisvogel.latex")
        (pdf-engine . "pdflatex")))

;;; Org AGENDA
(setq org-agenda-window-setup 'current-window
      org-agenda-restore-windows-after-quit t
      ;; inhibit-startup nil means that if we want files to start 'folded', then agenda
      ;; will respect this
      ;; inhibit-startup t means 'just unfold', and can greatly speed up agenda
      ;; if there are many folded headings
      org-agenda-inhibit-startup t
      org-agenda-dim-blocked-tasks nil
      org-agenda-ignore-drawer-properties '(effort appt)
      org-agenda-show-all-dates t ; nil hides days in agenda if no tasks on that day
      ;; org-agenda-files (--filter (not (s-matches? "archive\\|recipes\\|thought" it))
      ;;                            (find-lisp-find-files org-directory "\.org$"))
      ;; All the files in the root of org directory
      org-agenda-files (append `(,org-directory)
                               ;; ...and any non-dotted directory underneath it
                               (--filter (and (f-directory-p (f-join org-directory it))
                                              (not (s-matches? (rx bol (+ ".")) it))
                                              (not (s-matches? "archive" it))
                                              (not (s-matches? "book-notes" it)))
                                         (directory-files org-directory)))
      ;; (--filter (not (s-matches? "archive\\|recipes\\|thought" it))
      ;;                            (find-lisp-find-files org-directory "\.org$"))
      org-agenda-file-regexp "\\`[^.].*\\.org\\'"
      org-refile-targets `((org-agenda-files . (:maxlevel . 2)))
      org-agenda-span 'week
      org-agenda-start-day nil
      org-agenda-skip-scheduled-if-deadline-is-shown t
      org-agenda-skip-scheduled-if-done nil
      org-agenda-skip-deadline-if-done nil
      org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled
      org-agenda-skip-archived-trees nil
      org-agenda-block-separator ""
      org-agenda-compact-blocks nil
      org-agenda-todo-ignore-scheduled 'future
      org-agenda-sort-notime-is-late nil
      org-agenda-remove-tags t
      org-agenda-time-grid '((daily today require-timed remove-match)
                             (800 1000 1200 1400 1600 1800 2000)
                             "......"
                             "")
      org-agenda-use-time-grid t
      org-agenda-prefix-format '((agenda . "%-20c%-12t%6s")
                                 (timeline . "% s")
                                 (todo . "%-20c")
                                 (tags . "%-20c")
                                 (search . "%-20c"))
      org-agenda-deadline-leaders '("!!! " "D%-2d " "D-%-2d ")
      org-agenda-scheduled-leaders '("" "S-%-2d ")
      org-agenda-sorting-strategy '((agenda time-up todo-state-up  category-up  scheduled-down priority-down)
                                    (todo todo-state-down category-up priority-down)
                                    (tags priority-down category-keep)
                                    (search category-keep))
      )
(defun agenda-header (msg)
  (let* ((char       (nth 2 '("???" "-" " " "=")))
         (borderchar (nth 3 '("???" "-" " " "=")))
         (n-tokens (/ (- 80 2 1 (length msg)) 2))
         (token-str (s-repeat n-tokens char))
         (extra (s-repeat (mod n-tokens 2) char))
         (spaced-str (format "%s%s  %s  %s" token-str extra msg token-str))
         (border (s-repeat (length spaced-str) borderchar)))
    (s-join "\n" `(,border ,spaced-str ,border))))

(setq org-agenda-custom-commands
      `(("c" . "Custom agenda views")

        ("co" "Overview Agenda"
         ((agenda "" ((org-agenda-overriding-header (agenda-header "TODAY"))
                      (org-agenda-span 1)
                      (org-agenda-skip-function-global '(org-agenda-skip-entry-if 'todo 'done))
                      (org-agenda-start-day "-0d")))

          ;; show a todo list of IN-PROGRESS
          (todo "WIP|NEXT" ((org-agenda-overriding-header (agenda-header "In Progress -- Work"))
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-files (cl-set-difference (cd/work-files)
                                                                 (cd/literature-files)
                                                                 :test 'equal))))
          (todo "WIP|NEXT" ((org-agenda-overriding-header (agenda-header "In Progress -- Personal"))
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-files (cd/non-work-files))))

          (todo "BLCK" ((org-agenda-overriding-header (agenda-header "BLOCKED"))))
          ))

        ("cw" "Work tasks"
         ((todo "BLCK" ((org-agenda-overriding-header (agenda-header "BLOCKED"))
                        (org-agenda-files (cl-set-difference (cd/work-files)
                                                             (cd/literature-files)
                                                             :test 'equal))))

          ;; show a todo list of IN-PROGRESS
          (todo "WIP|NEXT" ((org-agenda-overriding-header (agenda-header "In Progress"))
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-files (cl-set-difference (cd/work-files)
                                                                 (cd/literature-files)
                                                                 :test 'equal))))
          (todo "TODO" ((org-agenda-overriding-header (agenda-header "Todo"))
                        (org-agenda-todo-ignore-scheduled t)
                        (org-agenda-files (cl-set-difference (cd/work-files)
                                                             (cd/literature-files)
                                                             :test 'equal))))))

        ("cr" "Review the last week"
         ((agenda "" ((org-agenda-start-day "-7d")
                      (org-agenda-entry-types '(:timestamp))
                      (org-agenda-archives-mode t)
                      (org-agenda-later 1)
                      (org-agenda-log-mode 16)
                      (org-agenda-log-mode-items '(closed clock state))
                      (org-agenda-show-log t)))))

        ("cR" "Reading -- in progress, and possible future books"
         ((todo ""
                ((org-agenda-files (cd/reading-files))
                 (org-agenda-overriding-header (cd/text-header "Books in Progress" nil t))))
          (todo ""
                ((org-agenda-files (cd/literature-files))
                 (org-agenda-overriding-header (cd/text-header "Literature in Progress" nil t))))))
        ))

;;; Org HOOKS
(add-hook! org-mode
           'visual-line-mode
           'visual-fill-column-mode
           'org-indent-mode ; indent subtrees more and more
           ;; 'mixed-pitch-mode
           ;; 'auto-fill-mode
           'abbrev-mode
           'undo-tree-mode
           '(lambda () (set-face-italic 'italic t)) ; ensure we have italic typeface where possible
           )
(add-hook! 'auto-save-hook
           '(lambda () (interactive)
              (save-some-buffers t (lambda () (derived-mode-p 'org-mode)))))

(setq split-width-threshold 150)

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(setq theme-preferences-light '(
                                doom-one-light
                                doom-opera-light
                                ))

(setq theme-preferences-dark '(
                               doom-dracula
                               doom-monokai-ristretto
                               ))

(setq doom-theme (nth 0
                      theme-preferences-dark
                      ;; theme-preferences-light
                      ))

(defun theme-toggle-light-dark ()
  (interactive)
  (if (cl-position doom-theme theme-preferences-light)
      (set-theme-dark)
    (set-theme-light)))

(defun set-theme-dark ()
  (interactive)
  (setq doom-theme (nth 0 theme-preferences-dark))
  (doom/reload-theme)
  (message (format "Theme: %s" (nth 0 theme-preferences-dark))))

(defun set-theme-light ()
  (interactive)
  (setq doom-theme (nth 0 theme-preferences-light))
  (doom/reload-theme)
  (message (format "Theme: %s" (nth 0 theme-preferences-light))))

(defun choose-pretty-theme (&optional subset)
  "Set a theme from one of the available fonts that I like"
  (interactive)
  (let* ((themes (pcase subset
                   ('light theme-preferences-light)
                   ('dark theme-preferences-dark)
                   (_ (append theme-preferences-light theme-preferences-dark))))
         (choice (ivy-read "Pick theme:" themes)))
    (setq doom-theme (intern choice))
    (doom/reload-theme)))

(defun choose-pretty-light-theme ()
  (interactive)
  (choose-pretty-theme 'light))

(defun choose-pretty-dark-theme ()
  (interactive)
  (choose-pretty-theme 'dark))


(defun next-theme (&optional backward alternate-theme-list)
  (interactive)
  (let* ((themes (if alternate-theme-list alternate-theme-list (custom-available-themes)))
         (idx-current (cl-position doom-theme themes))
         (idx-next (next-circular-index (if idx-current idx-current 0) (length themes) (if backward t nil)))
         (next (nth idx-next themes)))
    (setq doom-theme next)
    (doom/reload-theme)
    (message "%s" next)
    ))

(defun next-theme-dark ()
  (interactive)
  (next-theme nil theme-preferences-dark))

(defun next-theme-light ()
  (interactive)
  (next-theme nil theme-preferences-light))

(map! :leader :desc "Toggle light/dark theme" "t t" 'theme-toggle-light-dark)

(setq cd-fonts (--filter (member it (font-family-list))
                         '(
                           "Hack"
                           "Monego"
                           "InconsolataGo"
                           "CamingoCode"
                           "Anonymous Pro"
                           "Inconsolata"
                           "Source Code Pro"
                           )))

(setq cd-mixed-pitch-fonts (--filter (member it (font-family-list))
                                     '(
                                       "Karla"
                                       "Lato"
                                       "Ubuntu"
                                       "Helvetica"
                                       "Monaco"
                                       "Montserrat"
                                       )))

(setq cd/font-size "-14")
(when cd-fonts
  (setq doom-font (concat (nth 0 cd-fonts) cd/font-size)))

(when cd-mixed-pitch-fonts
  (setq doom-variable-pitch-font (concat (nth 0 cd-mixed-pitch-fonts) cd/font-size)))

(defun set-pretty-font ()
  "Set a font from one of the available fonts that I like"
  (interactive)
  (setq doom-font (ivy-read "Pick font:" cd-fonts))
  (doom/reload-font))

(defun next-font ()
  (interactive)
  (let* ((pos (cl-position (car (s-split "-" doom-font)) cd-fonts :test 's-equals?))
         (next-pos (% (+ 1 pos) (length cd-fonts)))
         (next-font-name (nth next-pos cd-fonts)))
    (set-frame-font next-font-name 1)
    (setq doom-font (concat next-font-name cd/font-size))
    (message next-font-name)))

(defun next-variable-font ()
  (interactive)
  (let* ((current-font (car (s-split "-" doom-variable-pitch-font)))
         (pos (cl-position current-font cd-mixed-pitch-fonts :test 's-equals?))
         (next-pos (% (+ 1 pos) (length cd-mixed-pitch-fonts)))
         (next-font-name (nth next-pos cd-mixed-pitch-fonts)))
    (set-frame-font next-font-name 1)
    (setq doom-variable-pitch-font (concat next-font-name "-14"))
    (message next-font-name)))

(map! :n "C-;" 'iedit-mode
      :n "C-:" 'iedit-mode-toggle-on-function)

(map! "M-%" 'anzu-query-replace
      "C-M-%" 'anzu-query-replace-regexp)

(map! "<f9>" 'er/expand-region)

(map! :leader "s I" 'imenu-list)

;; Emacs capture and org-mode
(map! :map org-mode-map :leader :n
      "m r a" 'org-change-state-and-archive
      "m r A" 'org-archive-to-archive-sibling
      "m r D" 'cd/do-and-archive
      "m r K" 'cd/kill-and-archive
      "m r t" 'org-refile-to-this-file
      "m r T" 'org-refile-to-this-file-level1
      "m r F" 'cd/refile-to-top-level
      "m d i" 'org-time-stamp-inactive
      "m h" 'headercount
      "o s" 'org-open-link-same-window
      "o O" 'org-open-link-other-window
      "o o" 'org-open-at-point
      "o S" 'org-sidebar-toggle
      "Q" 'org-unfill-paragraph
      "N" 'org-toggle-narrow-to-subtree
      "m l u" 'org-copy-link-url
      "m l C" 'cd/org-copy-next-link)

(map! :map org-mode-map :n
      "C-x C-n" 'org-file-from-subtree
      :v "C-x C-n" 'org-file-from-selection)

(map! :map dired-mode-map :n "/" 'dired-narrow)

(map! :nv "j" 'evil-next-visual-line
      :nv "k" 'evil-previous-visual-line)

(map! :leader
      :prefix "w"
      :desc "evil-window-split (follow)" "s"
      (lambda () (interactive) (evil-window-split) (evil-window-down 1))
      :desc "evil-window-vsplit (follow)" "v"
      (lambda () (interactive) (evil-window-vsplit) (evil-window-right 1)))



(map! :leader
      :desc "Find Org-dir file (no archive)" "<SPC>"
      '(lambda () (interactive) (doom/find-file-in-other-project org-directory))
      :desc "Jump to headline in a specific file" "S-<SPC>"
      'jump-to-headline-in-file)

(map! :map haskell-mode-map
      "C-x C-e" 'haskell-process-load-file)

(defun wsl_interop ()
  "Set up interop with Windows Subsystem for Linux (WSL).

Workaround to get the right WSL interop variable for clipboard usage.
Relies upon a shell command that exports $WSL_INTEROP to a file before
emacs is launched."
  (interactive)
  (shell-command "wsl_interop_setup")
  (setq is-wsl? nil)
  (when (string-match ".*microsoft.*" (shell-command-to-string "uname -a"))
    (setenv "WSL_INTEROP" (string-trim (shell-command-to-string "cat ~/.wsl_interop")))
    (setq is-wsl? t
          browse-url-generic-program "/mnt/c/Windows/System32/cmd.exe"
          browse-url-generic-args '("/c" "start")
          browse-url-browser-function #'browse-url-generic
          x-selection-timeout 10))
  (when is-wsl?
    (cd cd/code-dir)))

(wsl_interop)

(rg-enable-menu)
(add-hook! 'after-init-hook 'cd/capture-templates)

(defun reading-time ()
  (interactive)
  (let* ((reading-speed 283) ;; words per minute
         (words (if (region-active-p)
                   (count-words (region-beginning) (region-end))
                  (count-words (point-min) (point-max))))
         (time_low (* 0.8 (/ (float words) reading-speed)))
         (time_high (* 1.2 (/ (float words) reading-speed))))
    (message (format "%d words => %.0f to %.0f min" words time_low time_high))))

(defun cd/find-file-windows ()
  (interactive)
  (let ((default-directory "/mnt/c/Users/Davison/"))
    (call-interactively 'find-file)))
