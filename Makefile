.PHONY: all clean test

all: _parser.js

clean:
	rm -f _parser.js

test: _parser.js
	node_modules/.bin/coffee index.coffee example.stop

_parser.js: parser.jison
	node_modules/.bin/jison -m commonjs -o _parser.js parser.jison
