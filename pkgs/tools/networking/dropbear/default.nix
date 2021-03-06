{ stdenv, lib, fetchurl, glibc, zlib
, enableStatic ? stdenv.hostPlatform.isStatic
, sftpPath ? "/run/current-system/sw/libexec/sftp-server"
}:

stdenv.mkDerivation rec {
  name = "dropbear-2020.81";

  src = fetchurl {
    url = "https://matt.ucc.asn.au/dropbear/releases/${name}.tar.bz2";
    sha256 = "0fy5ma4cfc2pk25mcccc67b2mf1rnb2c06ilb7ddnxbpnc85s8s8";
  };

  dontDisableStatic = enableStatic;

  configureFlags = lib.optional enableStatic "LDFLAGS=-static";

  CFLAGS = "-DSFTPSERVER_PATH=\\\"${sftpPath}\\\"";

  # https://www.gnu.org/software/make/manual/html_node/Libraries_002fSearch.html
  preConfigure = ''
    makeFlags=VPATH=`cat $NIX_CC/nix-support/orig-libc`/lib
  '';

  patches = [
    # Allow sessions to inherit the PATH from the parent dropbear.
    # Otherwise they only get the usual /bin:/usr/bin kind of PATH
    ./pass-path.patch
  ];

  buildInputs = [ zlib ] ++ lib.optionals enableStatic [ glibc.static zlib.static ];

  meta = with stdenv.lib; {
    homepage = "https://matt.ucc.asn.au/dropbear/dropbear.html";
    description = "A small footprint implementation of the SSH 2 protocol";
    license = licenses.mit;
    maintainers = with maintainers; [ abbradar ];
    platforms = platforms.linux;
  };
}
