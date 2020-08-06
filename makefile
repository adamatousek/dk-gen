all: singles

SINGLES = $(wildcard _generated/[1-9]*.tex)
singles: $(SINGLES:tex=pdf)

$(SINGLES:tex=pdf): %.pdf : %.tex zjisteni.tex
	./generate.pl
	TEXINPUTS="_generated:tex:$$TEXINPUTS" latexmk -pdf -auxdir=_aux -outdir=_aux $< < /dev/null
	mv -t _generated _aux/*.pdf
