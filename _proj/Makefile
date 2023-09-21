
OUTPUT   ?= bin
CSS      := $(OUTPUT)/style.css
JS       := $(OUTPUT)/main.js
HACK     := --macro "exclude('haxe.iterators.ArrayIterator')"

#start#
all: js css
	@echo done!

clean:
	@echo $@...
	@rm -rf dump $(CSS) $(JS)

js: $(JS)

css: $(CSS)

.PHONY: all clean css js


$(CSS): hss/style.hss hss/markdown.hss hss/_vars.hss
	hss -output $(OUTPUT) $<

$(JS): $(wildcard src/*.hx)
	haxe -dce full -cp src -D analyzer-optimize -D js-es=3 -lib no-vdom $(HACK) --main Main --js $@
