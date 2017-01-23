# stm32-base

This is a skeleton project for a STM32-based firmware. It uses cmake as a build system. The base project also uses FreeRTOS, though this can easily be stripped out.

Make sure that you also check out the submodules: `git submodule update --init --recursive`. You will also need the STM32Cube software from ST's website.

The demo app contained within is for the STM32F103CB. To change the device targeted, make changes in:

* `tools/build.sh`
* `tools/flash.jlink`
* `.clang_autocomplete`

The binary name is `stm32-base` -- to adjust this, edit `tools/build.sh`, and `CMakeLists.txt`.

## Build.sh

The build script has several targets.

* `build.sh build`: build a debug file
* `build.sh debug`: upload the debug build to a board via GDB and start a debugger (you must have started GDB yourself)
* `build.sh flash`: flash the previous build to a board via a jlink adapter
* `build.sh clean`: remove all the temporary build files and cmake junk

## Toolchain

* arm-none-eabi-gcc (GNU Tools for ARM Embedded Processors) 6.2.1 20161205 (release) [ARM/embedded-6-branch revision 243739]
* cmake version 3.7.2
* STM32Cube 1.3.0
* SEGGER J-Link Commander V6.12f (Compiled Jan 13 2017 16:41:09)

## Suggested IDE plugins

I've been using Atom with the `autocomplete-clang`, `build`, and `linter-clang`. This provides autocomplete, cmake-aware building (via `.atom-build.yml`), and inline error checking.
