all: weirwood weirwood.js

weirwood.js: src/Main.hs
	hastec -Wall -Werror -isrc -hidir temp -odir temp --outdir=temp -o src/weirwood.js src/Main.hs

weirwood:
	ghc -Wall -Werror -isrc -hidir temp -odir temp --make src/Main.hs -o src/weirwood

clean:
	-rm -f src/*~
	-rm -rf temp

distclean: clean
	-rm src/weirwood
	-rm src/weirwood.js
