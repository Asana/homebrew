require 'formula'

class Scribe < Formula
  # We have a couple of custom fixes to scribe.
  url 'git://github.com/Asana/scribe.git'
  version "8388f3c810"

  depends_on 'libevent'
  depends_on 'boost'
  depends_on 'thrift'
  depends_on 'autoconf'
  depends_on 'automake'
  depends_on 'fb303'

  def install
    # xcxc libevent location
    ENV["CPPFLAGS"] = "-DHAVE_NETDB_H=1 -DHAVE_NETINET_IN_H=1 -DHAVE_INTTYPES_H=1 -fpermissive -I#{HOMEBREW_PREFIX}/include"
    ENV["LDFLAGS"] = "-L#{HOMEBREW_PREFIX}/lib"
    ENV["PY_PREFIX"] = "#{HOMEBREW_PREFIX}"
    system "./bootstrap.sh", "--with-boost=#{HOMEBREW_PREFIX}"
    system "./configure", "--prefix=#{prefix}",
                          "--libdir=#{lib}",
                          "--with-boost=#{HOMEBREW_PREFIX}",
                          "--with-libevent=#{HOMEBREW_PREFIX}",
                          "--with-thriftpath=#{HOMEBREW_PREFIX}",
                          "--with-fb303path=#{HOMEBREW_PREFIX}"
    
    ENV.j1
    system "make"
    system "make install"
  end
end
