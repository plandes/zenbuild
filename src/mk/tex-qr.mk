# make module for generating a .bib file from a master source .bib file
#
# to use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex-qr


# this must be set to the URL the device will go to when scanned
TEX_QR_URL ?=
# the QR code image file to generate
TEX_QR_FILE =		$(TEX_IMG_DIR)/qr-code.eps
TEX_PRE_COMP_DEPS +=	tex-qr-generate
TEX_IMG_EPS +=		$(TEX_QR_FILE)
ADD_CLEAN_ALL +=	$(TEX_QR_FILE)


# make sure the user has set the URL
ifeq ($(TEX_QR_URL),)
$(error "Can not create QR code: unset TEX_QR_URL variable")
endif

# the phony target is necessary as it seems to subsume the %.eps generic target
.PHONY:			tex-qr-generate
tex-qr-generate:	$(TEX_QR_FILE)

# create the QR code image only if the file doesn't already exist
$(TEX_QR_FILE):
			@if [ ! -f "$(TEX_QR_FILE)" ] ; then \
				echo "generating QR code in $(TEX_QR_FILE)" ; \
				mkdir -p $$(dirname $(TEX_QR_FILE)) ; \
				qrencode -t eps -o $(TEX_QR_FILE) '$(TEX_QR_URL)' ; \
				cp $(TEX_QR_FILE) $(TEX_LAT_PATH) ; \
			fi
