.PHONY: all clean test

all: stop.js

clean:
	rm -f parser.js

test: stop.js
	node stop.js examples/example.stop | node

stop.js: parser.js stop.stop
	node stop.js stop.stop > out.js
	rm stop.js
	mv out.js stop.js

parser.js: parser.jison
	# Add -t to show transitions
	node_modules/.bin/jison -m commonjs -o parser.js parser.jison
