## Example Makefile for Sahel font
## Copy SFD source files to SRCDIR
## Copy TTF Latin fonts to LATDIR
## https://github.com/rastikerdar/sahel-font/tree/master/source
## https://github.com/google/fonts/tree/master/apache/opensans

NAME    = Sahel
LATIN   = OpenSans

## Font weights are 400, 700, 900
FONTS        = Sahel Sahel-Bold Sahel-Black
## Font weights are 400, 700, 800
LATINWEIGHTS = Regular Bold ExtraBold

## Directories
SRCDIR  = source/farsi
LATDIR  = source/latin
TOOLDIR = tools
RESDIR  = res
DISTDIR = out/fonts
DOCDIR  = out/doc
WEBDIR  = out/webfonts

SFD = sfd
PY ?= python

BUILD   = $(TOOLDIR)/build.py
MAKETAB = $(TOOLDIR)/maketextable.py
MAKEWEB = $(TOOLDIR)/makeweb.py


LATDEP = $(LATDIR)/$(LATIN)-$(word 1,$(LATINWEIGHTS)).ttf
FDFEA  = $(RESDIR)/digits.fea

OTF   = $(FONTS:%=$(DISTDIR)/%.otf)
WLOTF = $(FONTS:%=$(DISTDIR)/%-WOL.otf)
FDOTF = $(FONTS:%=$(DISTDIR)/%-FD.otf)

WTTF  = $(FONTS:%=$(WEBDIR)/%.ttf)
WOFF  = $(FONTS:%=$(WEBDIR)/%.woff)
WOF2  = $(FONTS:%=$(WEBDIR)/%.woff2)
WEOT  = $(FONTS:%=$(WEBDIR)/%.eot)

DOCS  = $(DOCDIR)/sample.pdf $(DOCDIR)/table.pdf

all: otf doc
.PHONY: all

otf: $(WLOTF) $(OTF) $(FDOTF)
web: $(WTTF) $(WOFF) $(WOF2) $(WEOT)
doc: $(DOCS)

SHELL=/usr/bin/env bash

## Plain build of the font without mixing in the Latin digits
$(DISTDIR)/%-WOL.otf $(DISTDIR)/%-WOL.ttf: $(SRCDIR)/%.$(SFD) $(BUILD)
	@echo  GEN   $@
	@$(PY) $(BUILD) --arabic-file=$< --out-file=$@

## Merge Latin chars into the font
$(DISTDIR)/%.otf $(DISTDIR)/%.ttf: $(SRCDIR)/%.$(SFD) $(BUILD) $(LATDEP)
	@echo  GEN   $@
	@export LATW=`$(PY) -c "a='$(FONTS)'; \
	b='$(LATINWEIGHTS)'; \
	print ''.join([y for x, y in zip(a.split(), b.split()) \
	if x == '$(notdir $(basename $@)' ]))"`; \
	$(PY) $(BUILD) --arabic-file=$< --out-file=$@ \
	--latin-file=$(LATDIR)/$(LATIN)-$$LATW.ttf --merge-type plain

## Merge Latin chars into the font and convert Latin digits to Farsi
$(DISTDIR)/%-FD.otf $(DISTDIR)/%-FD.ttf: $(SRCDIR)/%.$(SFD) $(BUILD) $(FDFEA) $(LATDEP)
	@echo  GEN   $@
	@export LATW=`$(PY) -c "a='$(FONTS)'; \
	b='$(LATINWEIGHTS)'; \
	print ''.join([y for x, y in zip(a.split(), b.split()) \
	if x == '$(subst -FD,,$(notdir $(basename $@)' ])))"`; \
	$(PY) $(BUILD) --arabic-file=$< --out-file=$@ \
	--latin-file=$(LATDIR)/$(LATIN)-$$LATW.ttf --merge-type plain \
	--digits-feature-file=$(FDFEA)

## Sample text typeset via this font
## WARNING: Font name and weights are encoded in the TeX file in RESDIR
$(DOCDIR)/sample.pdf: $(RESDIR)/sample.tex otf
	@echo  GEN   $@
	@-mkdir -p $(DOCDIR)
	@xetex -output-directory=$(DOCDIR) --interaction=batchmode $< &> /dev/null
	@-rm -f $(basename $@).log

## A table of all characters defined in the font
$(DOCDIR)/table.pdf: otf $(MAKETAB)
	@echo GEN    $@
	@$(PY) $(MAKETAB) --font $(DISTDIR)/$(NAME).otf > $(DOCDIR)/table.tex
	@xelatex -output-directory=$(DOCDIR) --interaction=batchmode $(DOCDIR)/table.tex &> /dev/null
	@-rm -f $(basename $@).log $(basename $@).aux $(basename $@).tex

## Three flavors (ttf, woff, woff2) are created at once
$(WEBDIR)/%.ttf $(WEBDIR)/%.woff $(WEBDIR)/%.woff2: $(DISTDIR)/%.ttf $(MAKEWEB)
	@echo "   WEB   $*"
	@mkdir -p $(WEBDIR)
	@$(PY) $(MAKEWEB) $< $(WEBDIR)

## Generate the EOT webfont via ttf2eot
$(WEBDIR)/%.eot: $(DISTDIR)/%.ttf $(MAKEWEB)
	@echo "   WEBE  $*"
	@mkdir -p $(WEBDIR)
	@ttf2eot $< > $@

clean:
	@-rm -fr $(DISTDIR) $(DOCDIR) $(WEBDIR)