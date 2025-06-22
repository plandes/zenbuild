#@meta {author: "Paul Landes"}
#@meta {desc: "source control automation", date: "2025-06-22"}
#@meta {requires: "python/build.mk", order: "before"}


# make a tag using the version of the last commit
.PHONY:			pymktag
pymktag:
			@if [ -z "$(COMMENT)" ] ; then \
				echo "use:\nmake COMMENT='comment' pymktag" ; \
				exit 1 ; \
			fi
			@$(call relpo,mktag,"--message=$(COMMENT)")

# remove the last tag
.PHONY:			pyrmtag
pyrmtag:
			@$(call relpo,rmtag,"--message=$(COMMENT)")

# delete the last tag and create a new one on the latest commit
.PHONY:			pybumptag
pybumptag:
			@$(call relpo,bumptag)

# print this repo's info
.PHONY:			pycheck
pycheck:		$(PY_PYPROJECT_FILE)
			@$(PY_PX_BIN) lock
			@$(call relpo,check) || true
