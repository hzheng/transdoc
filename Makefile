TITLE_PAGE = title_page.md
COPYRIGHT = copyright.md
COVER = cover.jpg
CONFIG_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CSS = $(CONFIG_DIR)/epub.css
LUA_FILTER = $(CONFIG_DIR)/epub.lua

TOC_CONTENT = '\# Contents\n\n$$toc$$\n'
CLEAN_LIST = toc-template.md *.toc *.epub *.mobi *.docx

.PRECIOUS: %.toc

.PHONY: clean

toc-template.md:
	@printf $(TOC_CONTENT) > $@


%.toc: toc-template.md
	@echo "creating TOC " $@
	@pandoc --template=$< --toc --toc-depth=3 $(basename $@).md -t markdown -o $@


%.epub: $(TITLE_PAGE) $(COPYRIGHT) %.toc %.md
	@echo "converting " $@
	@pandoc --wrap=none --epub-title-page=false --epub-cover-image=$(COVER) --lua-filter=$(LUA_FILTER) -c $(CSS) $+ -o $@


%.html: $(TITLE_PAGE) $(COPYRIGHT) %.toc %.md
	@echo "converting " $@
	@pandoc --wrap=none --lua-filter=$(LUA_FILTER) -c $(CSS) $+ -o $@

clean:
	@rm -f $(CLEAN_LIST)
