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

(defun zb-org-mode-publish (output-directory &optional publish-fn
					     includes excludes)
  "Publish an Org Mode project in to a website.

This first sets `org-publish-project-alist', and then calls
`org-publish-current-project' with FORCE set to t.

OUTPUT-DIRECTORY is the directory where the output files are generated and/or
copied.

PUBLISH-FN is the function that is used for the `:publishing-function' and
defaults to `org-html-publish-to-html'.

INCLUDES is either a string (which is split on whitespace) or a list of strings
used as additional resource directories that are copied to the OUTPUT-DIRECTORY.

EXCLUDES is used in the `:exclude' property, which is a regular expression of
files, that if matches, is excluded from the list of files to copy."
  (setq excludes (or excludes "^\\(.gitignore\\|.*org\\)$"))
  (setq publish-fn (or publish-fn #'org-html-publish-to-html))
  (when (stringp includes)
    (setq includes (split-string (string-trim includes))))
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
       ((lambda (forms)
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
