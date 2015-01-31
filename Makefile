all: weirwood weirwood.js

weirwood.js: src/weirwood.hs
	hastec --outdir=src/temp-js -o src/weirwood.js src/weirwood.hs

weirwood:
	ghc --make src/weirwood.hs

clean:
	-rm -f src/*~
	-rm -rf src/temp-js
	-rm -f src/weirwood.hi
	-rm -f src/weirwood.o

distclean: clean
	-rm src/weirwood
	-rm src/weirwood.js
