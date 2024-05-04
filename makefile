# chugin name
CHUGIN_NAME=rave

# ---------------------------------------------------------------------------- #
# you won't generally need to change anything below this line for a new chugin #
# ---------------------------------------------------------------------------- #

# default target: print usage message and quit
current: 
	@echo "[Rave.chug build]: please use one of the following configurations:"
	@echo "   make mac, make linux, or make win"

# build a macOS arm64 Rave.chug
build-arm64:
	cmake -B build-arm64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64
	cmake --build build-arm64 --target install

# build a macOS x86_64 Rave.chug
build-x86_64:
	cmake -B build-x86_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64
	cmake --build build-x86_64 --target install

.PHONY: mac osx
mac osx: build-arm64 build-x86_64

mac-codesign:
	

clean: 
	rm -rf build-arm64 build-x86_64

