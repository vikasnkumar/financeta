### COPYRIGHT: Vikas N Kumar <vikas@cpan.org>
### DATE: 21st Aug 2014
### SOFTWARE: App::financeta
CURDIR=$(shell pwd)
HTMLIZE?=$(CURDIR)/htmlize
HTMLFILES:=$(patsubst %.md,%.html,$(wildcard *.md))

.PHONY: all default rebuild
default: all

all: $(HTMLFILES)

rebuild:
	$(MAKE) -B

$(HTMLFILES): %.html: %.md
	/bin/sh $(HTMLIZE) $<
