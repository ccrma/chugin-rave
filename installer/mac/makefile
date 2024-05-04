# Rave.chug installer
#   pre-conditions: (make mac) build-arm64 and build-x86_64
#                   from top-level makefile
#   post-condition: a universal binary .PKG macOS installer
#					file for Rave.chug, including all runtime
#					dependencies

all: clean codesign package notarize

codesign:
	cp -rv ../../build-arm64/Release Rave-arm64
	sh 1-codesign.sh Rave-arm64
	cp -rv ../../build-x86_64/Release Rave-x86_64
	sh 1-codesign.sh Rave-x86_64

package:
	sh 2-package.sh

notarize:
	sh 3-notarize.sh

clean: 
	rm -rf Rave-arm64 Rave-x86_64 Rave Rave.tmp *.pkg

