### COPYRIGHT: Vikas N Kumar <vikas@cpan.org>
### DATE: 21st Aug 2014
### SOFTWARE: App::financeta
CURDIR=$(shell pwd)
HTMLIZE?=$(CURDIR)/htmlize
HTMLFILES:=$(patsubst %.md,%.html,$(wildcard *.md))

default: all

all: $(HTMLFILES)

$(HTMLFILES): %.html: %.md
	$(HTMLIZE) $<

.PHONY: all default
