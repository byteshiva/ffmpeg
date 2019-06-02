#!/usr/bin/env sh

FFMPEG_VERSION=4.1.3

rm -rf ffmpeg-${FFMPEG_VERSION}*
wget https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
tar xjf ffmpeg-${FFMPEG_VERSION}.tar.bz2
cd ffmpeg-${FFMPEG_VERSION}

echo "Configure"

# Configure and compile LLVM bitcode
emconfigure ./configure \
  --ar=emar \
  --cc=emcc \
  --cxx=em++ \
  --disable-asm \
  --disable-autodetect \
  --disable-doc \
  --disable-sdl2 \
  --disable-stripping \
  --enable-cross-compile || exit $?

echo "Build"
emmake make -j8 || exit $?

# Generate `.wasm` file
echo "Link"
TOTAL_MEMORY=67108864  # increase heap size from 16mb to 64mb

mv ffmpeg ffmpeg.o
emcc ffmpeg.o -o ../ffmpeg.wasm -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s TOTAL_MEMORY=${TOTAL_MEMORY}

# mv ffplay ffplay.o
# emcc ffplay.o -o ../ffplay.wasm -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s TOTAL_MEMORY=${TOTAL_MEMORY}

mv ffprobe ffprobe.o
emcc ffprobe.o -o ../ffprobe.wasm -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s TOTAL_MEMORY=${TOTAL_MEMORY}

echo "Clean"
cd ..
rm -rf ffmpeg-${FFMPEG_VERSION}*

echo "Done"
