COMP_DEPS +=	$(TEX).ilg

$(TEX).ilg:	$(TEX).tex
		$(LAT) $(TEX).tex
		makeindex $(TEX).idx
		$(LAT) $(TEX).tex
		makeindex $(TEX).idx
