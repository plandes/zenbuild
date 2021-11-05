;;; zb-org-mode.el --- Automate publishing Org Mode files  -*- lexical-binding: t; -*-

;; Copyright (C) 2021 Paul Landes

;; Version: 0.1
;; Author: Paul Landes
;; Maintainer: Paul Landes
;; Keywords: editor org-mode
;; URL: https://github.com/plandes/zb-org-mode
;; Package-Requires: ((emacs "26") (dash "2.17.0"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Functions to automate publishing using the orgmode-publish.mk build
;; configuration.

;;; Code:

(require 'org)
(require 'dash)

(defvar zb-org-better-bibtex-enabled t
  "Whether or not to use BetterBibtex key -> citekey link replacements.")

(defvar zb-org-better-bibtex-cache nil
  "The cache BetterBibtex key -> citekey values.")

(defvar zb-org-better-bibtex-debug nil
  "Debug BetterBibtex functionality using `message`.")

(defun zb-org-read-better-bibtex-ids (betterbibid-program)
  "Return all BetterBibtex key to citekey mappings.
BETTERBIBID-PROGRAM is the program that reads the BetterBibtex database."
  (unless (file-exists-p betterbibid-program)
    (error "Missing BetterBibtex ID mapping script: %s"
	   betterbibid-program))
  (let ((cmd (list "python" betterbibid-program "-f"
		   "(\"{libraryID}_{itemKey}\" . \"{citekey}\")"
		   "-k" "all")))
    (with-temp-buffer
      (unless (eq 0 (apply 'call-process (car cmd) nil (current-buffer)
			   zb-org-better-bibtex-debug
			   (cdr cmd)))
	(error "Could not get better bibtex IDs: %s" (buffer-string)))
      (goto-char (point-min))
      (insert "(")
      (goto-char (point-max))
      (insert ")")
      (goto-char (point-min))
      (condition-case err
	  (read (current-buffer))
	(error (error "Can not read as lisp: %S <%s>"
		      err (buffer-string)))))))

(defun zb-org-get-better-bibtex-ids (&rest args)
  "Return all BetterBibtex key to citekey mappings.
If cached, return that, otherwise use ARGS with
`zb-org-read-better-bibtex-ids'."
  (when zb-org-better-bibtex-enabled
    (unless zb-org-better-bibtex-cache
      (setq zb-org-better-bibtex-cache
	    (apply #'zb-org-read-better-bibtex-ids args)))
    zb-org-better-bibtex-cache))

(defun zb-org-clear-better-bibtex-ids ()
  "Clear any cached BetterBibtex IDs."
  (setq zb-org-better-bibtex-cache nil))

(defun zb-org-filter-link-function (text backend info)
  "Replace links TEXT with Zotero Zotsync links.
This requires environment variable `CNT_SITE_SERV' to be set to the zotsite
\(https://github.com/plandes/zotsite) to be set to the URL of your deployed
Zotero site.

BACKEND the backend, which is usually `twbs'.
INFO is optional information about the export process."
  (set-text-properties 0 (length text) nil text)
  (when zb-org-better-bibtex-debug
    (message "Remapping %s" text))
  (let ((prev-link text)
	(regex "^<a href=\"//select/items/\\(.*?\\)\">\\(.*\\)</a>\\([ ]*\\)$")
	(host-url (getenv "CNT_SITE_SERV"))
	(bb-ids (zb-org-get-better-bibtex-ids)))
    (unless bb-ids
      (message "Warning: no better bibtex IDs found"))
    (when zb-org-better-bibtex-debug
      (message "Recomposing link %s using %d mappings" text (length bb-ids)))
    (if (null (string-match regex text))
	(when zb-org-better-bibtex-debug
	  (message "Link does not match: {{%s}}--skipping" text))
      (let* ((item-key (match-string 1 text))
	     (link-text (match-string 2 text))
	     (some-buggy-whitesapce (match-string 3 text))
	     (lib-key (cdr (assoc item-key bb-ids))))
	(unless lib-key
	  (message "Missing item key %s--skipping" item-key))
	(when lib-key
	  (setq url (format "%s/site/zotero/?id=%s" host-url lib-key)
		text (format "<a href=\"%s\">%s</a>%s" url link-text
			     some-buggy-whitesapce))
	  (message "Replacing link %s -> %s" prev-link text))))
    text))

(add-hook 'org-export-filter-link-functions 'zb-org-filter-link-function)

(defun zb-org-mode-publish (output-directory &optional publish-fn
					     better-bibtex-program
					     includes excludes)
  "Publish an Org Mode project in to a website.

This first sets `org-publish-project-alist', and then calls
`org-publish-current-project' with FORCE set to t.

OUTPUT-DIRECTORY is the directory where the output files are generated and/or
copied.

PUBLISH-FN is the function that is used for the `:publishing-function' and
defaults to `org-html-publish-to-html'.

BETTER-BIBTEX-PROGRAM is the program that creates item key to BetterBibtex
citekeys.

INCLUDES is either a string (which is split on whitespace) or a list of strings
used as additional resource directories that are copied to the OUTPUT-DIRECTORY.

EXCLUDES is used in the `:exclude' property, which is a regular expression of
files, that if matches, is excluded from the list of files to copy."
  (setq excludes (or excludes "^\\(.gitignore\\|.*\\.org\\)$"))
  (setq publish-fn (or publish-fn #'org-html-publish-to-html))
  (when (stringp includes)
    (setq includes (split-string (string-trim includes))))
  ;; set cache of item key to BetterBibtex keys if the script is available
  (let (bb-ids)
    (if better-bibtex-program
	(setq bb-ids (zb-org-get-better-bibtex-ids better-bibtex-program))
      (setq zb-org-better-bibtex-enabled nil))
    (when zb-org-better-bibtex-debug
      (message "BetterBibtex mapping (prog=%s, enable=%S, link count=%d)"
	       better-bibtex-program
	       zb-org-better-bibtex-enabled
	       (length bb-ids))))
  (->> includes
       (-map (lambda (dir)
	       (cons dir (replace-regexp-in-string "[/\\.]" "-" dir))))
       (-map (lambda (dir-name)
	       (let ((dir (car dir-name)))
		 `(,(cdr dir-name)
		   :base-directory ,dir
		   :base-extension ".*"
		   :publishing-function org-publish-attachment
		   :publishing-directory ,(expand-file-name dir output-directory)
		   :exclude ,excludes
		   :recursive t))))
       (funcall (lambda (forms)
		  (append forms
			  `(("website" :components
			     ,(cons "orgfiles" (-map 'cl-first forms)))))))
       (append `(("orgfiles"
		  :base-directory "."
		  :base-extension "org"
		  :publishing-function ,publish-fn
		  :publishing-directory ,output-directory
		  :recursive t)))
       (setq org-publish-project-alist))
  (org-publish-current-project t))

(provide 'zb-org-mode)

;;; zb-org-mode.el ends here
