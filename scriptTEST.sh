#!/bin/bash
set -x -v -e
cd "$(dirname "$0")"
export BUILDER_ROOT="$(pwd)"
export FFBUILD_PREFIX="/clang64/ffbuild"
export CMAKE_POLICY_VERSION_MINIMUM="3.5"

arch="x86_64"
TARGET="win64-clang"
VARIANT="gpl"



# sometimes in testing, this line is commented out
# make install

echo "PKG_VER: ${PKG_VER}"
if [ "${PKG_VER}" == "" ]; then PKG_VER="0.0.0"; fi
export PKG_VER
echo "PKG_VER=${PKG_VER}" >> ${GITHUB_ENV}

echo "PKG_VER: ${PKG_VER}"

echo "EXPORT_FILE_NAME: ${EXPORT_FILE_NAME}"
export EXPORT_FILE_NAME="${EXPORT_FILE_NAME}-${PKG_VER}"
echo "EXPORT_FILE_NAME=${EXPORT_FILE_NAME}" >> ${GITHUB_ENV}

echo "EXPORT_FILE_NAME: ${EXPORT_FILE_NAME}"

echo "GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"
export GITHUB_WORKSPACE="$(cygpath ${GITHUB_WORKSPACE})"
echo "GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"

# converts the word of the variable to lowercase
export      PREFIX="/$(echo "${MSYSTEM}" |sed 's/[A-Z]/\L&/g')/ffbuild/jellyfin-ffmpeg"
if [ ! -d "${PREFIX}" ];     then mkdir -p     "${PREFIX}"; fi
if [ ! -d "${PREFIX}/doc" ]; then mkdir -p     "${PREFIX}/doc"; fi
cp -R ${GITHUB_WORKSPACE}/JLFNFFMPEGSRC/doc/.  "${PREFIX}/doc/"

if [ $(which doxygen) ]
then
  pushd ${GITHUB_WORKSPACE}/PUREFFMPEGSRC
    # https://linux.die.net/man/1/doxygen
    # update an old configuration file
    doxygen -u doc/Doxyfile
    # generate documentation
    set +x +v +e
    doxygen    doc/Doxyfile
    set -x -v -e
    # generate FFmpeg documentation
    ./configure --cc=${cc} --cxx=${cxx}
    which make
    # WTF
    # JLFNFFMPEGSRC/msys2/build.sh: line 50: make: command not found
make install-doc
  popd # from ${GITHUB_WORKSPACE}/PUREFFMPEGSRC
  cp -R       ${GITHUB_WORKSPACE}/PUREFFMPEGSRC/doc/.    "${PREFIX}/doc/"
fi

if [ -d "${PREFIX}" ]
then
  ls -alrt -R ${PREFIX}
  mkdir -p                                                   ${GITHUB_WORKSPACE}/Export/${EXPORT_FILE_NAME}
  #                     copy the contents
  cp       -R ${PREFIX}/.                                    ${GITHUB_WORKSPACE}/Export/${EXPORT_FILE_NAME}
  pushd                                                      ${GITHUB_WORKSPACE}/Export
    zip -9 -r ${GITHUB_WORKSPACE}/${EXPORT_FILE_NAME}.zip    .
    ls -alrt  ${GITHUB_WORKSPACE}/${EXPORT_FILE_NAME}.zip
  popd                                                # from ${GITHUB_WORKSPACE}/Export
else
  echo A directory called \""${PREFIX}"\" was not found.  So, exiting ... || exit 1
fi
