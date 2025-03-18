# chugin name
CHUGIN_NAME=rave

# ---------------------------------------------------------------------------- #
# you won't generally need to change anything below this line for a new chugin #
# ---------------------------------------------------------------------------- #

# default target: print usage message and quit
current: 
	@echo "[Rave.chug build]: please use one of the following configurations:"
	@echo "   make mac, make linux, or make win"

# build both architectures
.PHONY: mac osx build-arm64 build-x86_64 download-models
mac osx: build-arm64 build-x86_64

# build a macOS arm64 Rave.chug
build-arm64:
	cmake -B build-arm64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64
	cmake --build build-arm64 --target install

# build a macOS x86_64 Rave.chug
build-x86_64:
	cmake -B build-x86_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64
	cmake --build build-x86_64 --target install

build-arm64-debug:
	cmake -B build-arm64-debug -DCMAKE_BUILD_TYPE=Debug -DCMAKE_OSX_ARCHITECTURES=arm64
	cmake --build build-arm64-debug --target install

# download the models from ccrma servers so we don't have to add them to the repo
download-models:
	mkdir -p models
	curl -z models/chafe_cello.ts -o models/rave_chafe_data_rt.ts https://ccrma.stanford.edu/~nshaheed/rave_models/rave_chafe_data_rt.ts
	curl -z models/downtempo_house.ts -o models/downtempo_house.ts https://ccrma.stanford.edu/~nshaheed/rave_models/downtempo_house.ts

clean: 
	rm -rf build-arm64 build-x86_64

