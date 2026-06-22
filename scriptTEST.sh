#!/bin/bash
set -x -v -e
cd "$(dirname "$0")"
export BUILDER_ROOT="$(pwd)"
export FFBUILD_PREFIX="/clang64/ffbuild"
export CMAKE_POLICY_VERSION_MINIMUM="3.5"

arch="x86_64"
TARGET="win64-clang"
VARIANT="gpl"

# # Copy libc++ & libunwind to our prefix folder
# mkdir -p /clang64/ffbuild/lib
# cp /clang64/lib/libc++.a /clang64/ffbuild/lib/libc++.a
# cp /clang64/lib/libunwind.a /clang64/ffbuild/lib/libunwind.a
# 
# cd "$BUILDER_ROOT"/PKGBUILD
# for pkg in *; do
#     if [ -d "$pkg" ]; then
#         echo "Installing $pkg"
#         cd "$pkg"
# 
#         (MINGW_ARCH=clang64 makepkg-mingw -sLfi --noconfirm --skippgpcheck) || exit $?
# 
#         cd ..
#       fi
# done
# 
# cd "$BUILDER_ROOT"
# cd ..
# if [[ -f "debian/patches/series" ]]; then
#     ln -s debian/patches patches
#     quilt push -a
# fi
# 
# # On Windows, included headers are usually case-insensitive:
# # ffmpeg's VERSION and libc++'s "#include <version>"
# if [[ -f "VERSION" && -f "ffbuild/version.sh" ]]; then
#     mv VERSION{,.bak}
#     sed -i "s/cat VERSION/&.bak/g" ffbuild/version.sh
# fi
#
# PKG_CONFIG_PATH=/clang64/ffbuild/lib/pkgconfig ./configure \
#     --cc=clang \
#     --cxx=clang++ \
#     --pkg-config-flags=--static \
#     --extra-cflags=-I/clang64/ffbuild/include \
#     --extra-ldflags=-L/clang64/ffbuild/lib \
#     --prefix=/clang64/ffbuild/jellyfin-ffmpeg \
#     --extra-version=Jellyfin --enable-shared \
#     --disable-unstable \
#     --disable-ffplay \
#     --disable-debug \
#     --disable-doc \
#     --disable-sdl2 \
#     --enable-lto=thin \
#     --enable-gpl \
#     --enable-version3 \
#     --enable-schannel \
#     --enable-iconv \
#     --enable-libxml2 \
#     --enable-zlib \
#     --enable-lzma \
#     --enable-gmp \
#     --enable-chromaprint \
#     --enable-libfreetype \
#     --enable-libfribidi \
#     --enable-libfontconfig \
#     --enable-libharfbuzz \
#     --enable-libass \
#     --enable-libbluray \
#     --enable-libmp3lame \
#     --enable-libopus \
#     --enable-libtheora \
#     --enable-libvorbis \
#     --enable-libopenmpt \
#     --enable-libwebp \
#     --enable-libvpx \
#     --enable-libzimg \
#     --enable-libx264 \
#     --enable-libx265 \
#     --enable-libsvtav1 \
#     --enable-libdav1d \
#     --enable-libfdk-aac \
#     --enable-libshaderc \
#     --enable-libplacebo \
#     --enable-vulkan \
#     --enable-opencl \
#     --enable-dxva2 \
#     --enable-d3d11va \
#     --enable-d3d12va \
#     --enable-amf \
#     --enable-libvpl \
#     --enable-ffnvcodec \
#     --enable-cuda \
#     --enable-cuda-llvm \
#     --enable-cuvid \
#     --enable-nvdec \
#     --enable-nvenc

# make -j$(nproc) V=1
# 
# # We have to manually match lines to get version as there will be no dpkg-parsechangelog on msys2
# PKG_VER=0.0.0
# while IFS= read -r line; do
#     if [[ $line == jellyfin-ffmpeg* ]]; then
#         if [[ $line =~ \(([^\)]+)\) ]]; then
#             PKG_VER="${BASH_REMATCH[1]}"
#             break
#         fi
#     fi
# done < "$BUILDER_ROOT"/../debian/changelog

echo "EXPORT_FILE_NAME: ${EXPORT_FILE_NAME}"
echo "GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"
export GITHUB_WORKSPACE="$(cygpath ${GITHUB_WORKSPACE})"
echo "GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"

# make install

# converts the word of the variable to lowercase
export      PREFIX="/$(echo "${MSYSTEM}" |sed 's/[A-Z]/\L&/g')/ffbuild/jellyfin-ffmpeg"
if [ ! -d "${PREFIX}" ];     then mkdir -p "${PREFIX}"; fi
if [ ! -d "${PREFIX}/doc" ]; then mkdir -p "${PREFIX}/doc"; fi

# BEGIN TEST
mkdir -p ${PREFIX}/SUBDIR
touch    ${PREFIX}/prefix1.txt
touch    ${PREFIX}/SUBDIR/subdir1.txt
# END TEST
if [ -d "${PREFIX}" ]
then
  ls -alrt -R ${PREFIX}
  mkdir -p                                                   ${GITHUB_WORKSPACE}/Export/${EXPORT_FILE_NAME}
  #                     copy the contents
  cp       -R ${PREFIX}/.                                    ${GITHUB_WORKSPACE}/Export/${EXPORT_FILE_NAME}
  pushd                                                      ${GITHUB_WORKSPACE}/Export
    zip -9 -r ${GITHUB_WORKSPACE}/${EXPORT_FILE_NAME}        .
  popd                                                # from ${GITHUB_WORKSPACE}/Export
else
  echo A directory called \""${PREFIX}"\" was not found.  So, exiting ... || exit 1
fi
