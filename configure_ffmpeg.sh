#!/bin/bash
pushd `dirname $0`
. settings.sh

if [[ $DEBUG == 1 ]]; then
  echo "DEBUG = 1"
  DEBUG_FLAG="--disable-stripping"
fi

# I haven't found a reliable way to install/uninstall a patch from a Makefile,
# so just always try to apply it, and ignore it if it fails. Works fine unless
# the files being patched have changed, in which cause a partial application
# could happen unnoticed.
patch -N -p1 --reject-file=- < redact-plugins.patch
patch -N -p1 --reject-file=- < arm-asm-fix.patch
patch -d ffmpeg -N -p1 --reject-file=- < \
    ARM_generate_position_independent_code_to_access_data_symbols.patch
patch -d ffmpeg -N -p1 --reject-file=- < \
    ARM_intmath_use_native-size_return_types_for_clipping_functions.patch
patch -d ffmpeg -N -p1 --reject-file=- < \
    enable-fake-pkg-config.patch

pushd ffmpeg

./configure \
$DEBUG_FLAG \
--arch=arm \
--cpu=cortex-a8 \
--target-os=linux \
--enable-runtime-cpudetect \
--prefix=$prefix \
--enable-pic \
--disable-shared \
--enable-static \
--cross-prefix=$NDK_TOOLCHAIN_BASE/bin/$NDK_ABI-linux-androideabi- \
--sysroot="$NDK_SYSROOT" \
--extra-cflags="-I../x264 -mfloat-abi=softfp -mfpu=neon -fPIE -pie" \
--extra-ldflags="-L../x264 -fPIE -pie" \
\
--enable-version3 \
--enable-gpl \
\
--disable-doc \
--enable-yasm \
  --enable-nonfree --enable-version3 \
  --enable-libmp3lame --enable-libx264 \
  --enable-gpl --enable-pthreads --enable-gray --enable-runtime-cpudetect \
  \
  --disable-ffplay --disable-doc \
  \
  --disable-devices \
  --disable-bsfs      --enable-bsf=h264_mp4toannexb \
  --disable-filters   --enable-filter=scale,aresample \
  --disable-parsers   --enable-parser=h264,aac,aac_latm \
  --disable-protocols --enable-protocol=file,pipe,concat \
  --disable-encoders  --enable-encoder=libmp3lame,libx264,wav,pcm_s16le,pcm_s32le \
  --disable-decoders  --enable-decoder=aac,flv,h264,mp3,mpeg4,wav,vc1,vorbis,vp8,pcm_s16le,pcm_s32le \
  --disable-demuxers  --enable-demuxer=flv,matroska,mov,mp3,mp4,wav,sox,h264,mpegts,pcm_s16le \
  --disable-muxers    --enable-muxer=flv,matroska,mov,mp3,mp4,ismv,tgp,tg2,wav,webm,sox,h264,mpegts,null,pcm_s16le \
\
\
--disable-indevs \
--enable-indev=lavfi \
--disable-outdevs \
\
--enable-hwaccels \
\
--enable-ffmpeg \
--disable-ffserver \
--disable-network \
\
--enable-libx264 \
--enable-zlib \
--enable-muxer=md5

popd; popd


