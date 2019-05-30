#!/usr/bin/env sh

FFMPEG_VERSION=4.1.3

rm -rf ffmpeg-${FFMPEG_VERSION} ffmpeg-${FFMPEG_VERSION}.tar.bz2*
wget https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
tar xjf ffmpeg-${FFMPEG_VERSION}.tar.bz2
cd ffmpeg-${FFMPEG_VERSION}

echo "Configure"

# Configure and compile LLVM bitcode
emconfigure ./configure \
  --arch=wasm32 \
  --ar=emar \
  --cc=emcc \
  --cxx=em++ \
  --disable-stripping \
  --disable-x86asm \
  --enable-cross-compile || exit $?
  # --disable-autodetect

echo "Build"
emmake make || exit $?

# Generate `.wasm` file
echo "Link"
mv ffmpeg ffmpeg.o
emcc ffmpeg.o -o ../ffmpeg.wasm -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s TOTAL_MEMORY=52428800

mv ffplay ffplay.o
emcc ffplay.o -o ../ffplay.wasm -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s TOTAL_MEMORY=52428800

mv ffprobe ffprobe.o
emcc ffprobe.o -o ../ffprobe.wasm -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s TOTAL_MEMORY=52428800

echo "Clean"
cd ..
rm -rf ffmpeg-${FFMPEG_VERSION} ffmpeg-${FFMPEG_VERSION}.tar.gz

echo "Done"
