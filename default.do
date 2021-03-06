# -*- mode:sh -*-
exec >&2; set -x
set -- $1 ${1%.*} $3

[ -n "$CC" ] || export CC=gcc
case $(getconf LONG_BIT) in
  32) CPPFLAGS="$CPPFLAGS -D_M_IX86 -DASM_X86_V2" ;;
  64) CPPFLAGS="$CPPFLAGS -D_M_X64 -DC" ;;
esac
get_deps() {
  DEPS=""
  case $(getconf LONG_BIT) in
    32) DEPS="$DEPS aes_x86_v2.o" ;;
    64) DEPS="$DEPS" ;;
  esac
  echo "$DEPS aescrypt.o aeskey.o aestab.o aes_modes.o"
}

case $1 in
  all)
    redo-ifchange bgaes2.so bgaes2.a bgaes_bo.so bgaes_bo.a \
      bgaes_ccm.so bgaes_ccm.a \
      bgaes_cmac.so bgaes_cmac.a \
      bgaes_cwc.so bgaes_cwc.a \
      bgaes_eax.so bgaes_eax.a \
      bgaes_gcm.so bgaes_gcm.a \
      bgaes_omac.so bgaes_omac.a \
      bgaes_xts.so bgaes_xts.a \
      bgaes_eme2.so bgaes_eme2.a \
    ;;
  clean)
    rm -f *.o *.d *.a *.so
    ;;
  distclean)
    redo clean
    rm -rf .redo .do_built* *.did
    ;;
  bgaes2.so)
    redo-ifchange $(get_deps)
    $CC $LDFLAGS $(get_deps) -shared -o $3
    ;;
  bgaes2.a)
    redo-ifchange $(get_deps)
    ar cr $3 $(get_deps)
    ;;
  bgaes_bo.so)
    O=byte_aes.o
    redo-ifchange $O
    $CC $LDFLAGS $O -shared -o $3
    ;;
  bgaes_bo.a)
    O=byte_aes.o
    redo-ifchange $O
    ar cr $3 $O
    ;;
  bgaes_ccm.so)
    O="ccm.o"
    redo-ifchange $O
    $CC $LDFLAGS $O -shared -o $3
    ;;
  bgaes_ccm.a)
    O="ccm.o"
    redo-ifchange $O
    ar cr $3 $O
    ;;
  bgaes_cmac.so)
    O="cmac.o"
    redo-ifchange $O
    $CC $LDFLAGS $O -shared -o $3
    ;;
  bgaes_cmac.a)
    O="cmac.o"
    redo-ifchange $O
    ar cr $3 $O
    ;;
  bgaes_cwc.so)
    O="cwc.o"
    redo-ifchange $O
    $CC $LDFLAGS $O -shared -o $3
    ;;
  bgaes_cwc.a)
    O="cwc.o"
    redo-ifchange $O
    ar cr $3 $O
    ;;
  bgaes_eax.so)
    O="eax.o"
    redo-ifchange $O
    $CC $LDFLAGS $O -shared -o $3
    ;;
  bgaes_eax.a)
    O="eax.o"
    redo-ifchange $O
    ar cr $3 $O
    ;;
  bgaes_gcm.so)
    O="gcm.o gf128mul.o gf_convert.o"
    redo-ifchange $O
    $CC $LDFLAGS $O -shared -o $3
    ;;
  bgaes_gcm.a)
    O="gcm.o gf128mul.o gf_convert.o"
    redo-ifchange $O
    ar cr $3 $O
    ;;
  bgaes_omac.so)
    O="omac.o"
    redo-ifchange $O
    $CC $LDFLAGS $O -shared -o $3
    ;;
  bgaes_omac.a)
    O="omac.o"
    redo-ifchange $O
    ar cr $3 $O
    ;;
  bgaes_xts.so)
    O="xts.o"
    redo-ifchange $O
    $CC $LDFLAGS $O -shared -o $3
    ;;
  bgaes_xts.a)
    O="xts.o"
    redo-ifchange $O
    ar cr $3 $O
    ;;
  bgaes_eme2.so)
    O="eme2.o"
    redo-ifchange $O
    $CC $LDFLAGS $O -shared -o $3
    ;;
  bgaes_eme2.a)
    O="eme2.o"
    redo-ifchange $O
    ar cr $3 $O
    ;;
  *.o)
    if test -f $2.asm; then
      redo-ifchange $2.asm
      case $(getconf LONG_BIT) in
        32) yasm $CPPFLAGS -f elf32 -a x86 -m x86 -o $3 $2.asm ;;
        64) yasm $CPPFLAGS -f elf64 -a x86 -m amd64 -o $3 $2.asm ;;
      esac
    else
      redo-ifchange $2.c
      $CC -MD -MF $2.d -fPIC $CPPFLAGS $CFLAGS -c -o $3 $2.c
      read DEPS < $2.d
      redo-ifchange ${DEPS#*:}
    fi
    ;;
esac
