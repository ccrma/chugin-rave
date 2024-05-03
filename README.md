# Build & Installation Instructions
## Windows (requires CMake)
How to make visual studio project:

- Go into the terminal (preferably powershell or cygwin).
- Navigate to the `chugin-rave/` directory.
- `git submodule update --init`
- Make a `build` directory
- `cd build`
- `cmake . -S ..\  -DCMAKE_BUILD_TYPE:STRING=Release -G "Visual Studio 17 2022" -A "x64"`

How to build:
- Navigate to `build` directory from above
- `cmake --build . --config Release` to just build
- `sudo cmake --build . --config Release --target install` to build & install

## Linux (requires CMake)
How to create the project:

- Navigate to the `chugin-rave/` directory.
- `git submodule update --init`
-  Make a `build` directory
-  `cd build`
-  `cmake . -S ../"`
-  If you get an error about unix makefiles not support x64 or something similar try building with Ninja: `cmake . -S ../ -G Ninja"`

How to build:
- Navigate to `build` directory from above
- `cmake --build . ` to just build
- `cmake --build . --target install` to build & install

## MacOS (requires CMake)
How to create the project:

- Go to terminal.
- Navigate to the `chugin-rave/` directory.
- `git submodule update --init`
- Make a `build` directory
- `cd build`

To configure for Apple Silicon (arm64):
- `cmake . -S ../ -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64`

To configure for Intel (x86_64):
- `cmake . -S ../ -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64`

To build:
- Navigate to `build` directory from above
- `cmake --build . ` to just build
- `sudo cmake --build . --target install` to build & install
