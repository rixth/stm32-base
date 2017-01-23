#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: build.sh [clean|release|debug]"
fi

STM32_DEVICE="${STM32_DEVICE:-"STM32F103CB"}"
TARGET_FILE="${TARGET_FILE:-"stm32-base"}"

GDB_HOST="${GDB_HOST:-"127.0.0.1"}"
GDB_PORT="${GDB_PORT:-"2331"}"

PATH_TO_STM32CUBE="${PATH_TO_STM32CUBE:-"/opt/STM32Cube_FW_F1_V1.3.0"}"
PATH_TO_STM32_CMAKE="${PATH_TO_STM32_CMAKE:-"./stm32-cmake"}"

for arg in $@; do
  if [ "clean" = "$arg" ]; then
      set -x
      rm -rf debug release CMakeFiles random.pch
      rm -rf $TARGET_FILE.hex $TARGET_FILE.axf ${TARGET_FILE}_flash.ld $TARGET_FILE
      rm -rf Makefile cmake_install.cmake CMakeCache.txt
  elif [ "release" = "$arg" ]; then
      echo "#define RANDOM $RANDOM" > random.pch
      cmake \
        -DTOOLCHAIN_PREFIX=/usr/local \
        -DSTM32_CHIP=$STM32_DEVICE \
        -DSTM32Cube_DIR=$PATH_TO_STM32CUBE \
        -DCMAKE_TOOLCHAIN_FILE=$PATH_TO_STM32_CMAKE/cmake/gcc_stm32.cmake \
        -DCMAKE_MODULE_PATH=$PATH_TO_STM32_CMAKE/cmake/ \
        -DCMAKE_BUILD_TYPE=Release \
        .
      make -j4 $TARGET_FILE.hex
      cp $TARGET_FILE $TARGET_FILE.axf
  elif [ "build" = "$arg" ]; then
      echo "#define RANDOM $RANDOM" > random.pch
      cmake \
        -DTOOLCHAIN_PREFIX=/usr/local \
        -DSTM32_CHIP=$STM32_DEVICE \
        -DSTM32Cube_DIR=$PATH_TO_STM32CUBE \
        -DCMAKE_TOOLCHAIN_FILE=$PATH_TO_STM32_CMAKE/cmake/gcc_stm32.cmake \
        -DCMAKE_MODULE_PATH=$PATH_TO_STM32_CMAKE/cmake/ \
        -DCMAKE_BUILD_TYPE=Debug \
        .
      make -j4 $TARGET_FILE.hex
      cp $TARGET_FILE $TARGET_FILE.axf
  elif [ "flash" = "$arg" ]; then
      exec 5>&1
      JLINK_OUTPUT=$(JLinkExe -commandfile ./tools/flash.jlink|tee >(cat - >&5))

      if (echo $JLINK_OUTPUT | egrep -i "failed|warning" > /dev/null)
      then
        echo "**********************"
        echo "Flash failed or warned"
        echo "**********************"
        exit 1
      else
        echo "Flash ok!"
      fi
  elif [ "debug" = "$arg" ]; then
      arm-none-eabi-gdb \
        -ex "target remote $GDB_HOST:$GDB_PORT" \
        -ex "monitor flash device = $STM32_DEVICE" \
        -ex "monitor halt" \
        -ex "load" \
        -ex "monitor reset" \
        $TARGET_FILE
  fi
done
