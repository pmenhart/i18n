#!/bin/sh

# /bin/sh on Solaris is not a POSIX compatible shell, but /usr/bin/ksh is.
if [ `uname -s` = 'SunOS' -a "${POSIX_SHELL}" != "true" ]; then
    POSIX_SHELL="true"
    export POSIX_SHELL
    exec /usr/bin/ksh $0 $@
fi
unset POSIX_SHELL # clear it so if we invoke other scripts, they run as ksh as well

ICU_VSN=""


set -e

if [ `basename $PWD` != "c_src" ]; then
    # originally "pushd c_src" of bash
    # but no need to use directory stack push here
    cd c_src
fi

BASEDIR="$PWD"

# detecting gmake and if exists use it
# if not use make
# (code from github.com/tuncer/re2/c_src/build_deps.sh
which gmake 1>/dev/null 2>/dev/null && MAKE=gmake
MAKE=${MAKE:-make}

# Changed "make" to $MAKE

case "$1" in
    rm-deps)
        rm -rf icu4c
        ;;

    clean)
        if [ -d icu4c ]; then
            (cd icu4c && $MAKE clean)
        fi
        #rm -f ../priv/leveldb_repair ../priv/sst_scan ../priv/sst_rewrite ../priv/perf_dump
        ;;

    get-deps)
        if [ ! -d icu4c ]; then
            git clone https://github.com/icu-project/icu4c
        fi
        ;;

    *)


        if [ ! -d icu4c ]; then
            git clone https://github.com/icu-project/icu4c

        fi

        # hack issue where high level make is running -j 4
        #  and causes build errors in leveldb
        export MAKEFLAGS=
        export CFLAGS="-DU_DISABLE_RENAMING=1 -DU_CHARSET_IS_UTF8=1 -DU_GNUC_UTF16_STRING=1 -DU_STATIC_IMPLEMENTATION"
        export CXXFLAGS="-DU_DISABLE_RENAMING=1 -DU_USING_ICU_NAMESPACE=0 -std=gnu++0x -DU_CHARSET_IS_UTF8=1 -DU_GNUC_UTF16_STRING=1 -DU_HAVE_CHAR16_T=1 -DUCHAR_TYPE=char16_t -Wall --std=c++0x -DU_STATIC_IMPLEMENTATION"
        export CPPFLAGS="-DU_DISABLE_RENAMING=1 -DU_USING_ICU_NAMESPACE=0 -DU_CHARSET_IS_UTF8=1 -DU_STATIC_IMPLEMENTATION"
	export
        (cd icu4c/icu4c/source && ./runConfigureICU Linux --prefix=`pwd`istalli18n --enable-static --disable-shared --disable-renaming && $MAKE -j 3 && $MAKE install)
        ;;
esac
