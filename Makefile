.PHONY: all clean test

all: parser.js

clean:
	rm -f parser.js

test: parser.js
	./stop.js example.stop

parser.js: parser.jison
	# Add -t to show transitions
	node_modules/.bin/jison -m commonjs -o parser.js parser.jison
