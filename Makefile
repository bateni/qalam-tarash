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
DISTDIR = out/fonts
TOOLDIR = tools

SFD = sfd
PY ?= python

BUILD   = $(TOOLDIR)/build.py

LATDEP = $(LATDIR)/$(LATIN)-$(word 1,$(LATINWEIGHTS)).ttf

WLOTF = $(FONTS:%=$(DISTDIR)/%-WOL.otf)
OTF   = $(FONTS:%=$(DISTDIR)/%.otf)

all: otf
.PHONY: all

otf: $(WLOTF) $(OTF)

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

clean:
	@-rm -fr $(DISTDIR)