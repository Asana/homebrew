require 'formula'

class Fb303 < Formula
  homepage 'http://thrift.apache.org'

  # We use a custom verion of fb303, although we may try to submit these changes back.
  url 'git://github.com/Asana/thrift.git', :branch => "trunk"
  version "7678ccd570"

  depends_on 'thrift'
  depends_on 'automake'
  depends_on 'autoconf'

  def install
    # fb303 is in a thrift subdirectory.
    Dir.chdir "contrib/fb303"

    # These were in admin/configure.py. I don't know what they do.
    ENV["CPPFLAGS"] = "-DHAVE_NETDB_H=1 -DHAVE_NETINET_IN_H=1 -DHAVE_INTTYPES_H=1 -fpermissive -fPIC"
    ENV["PY_PREFIX"] = "#{HOMEBREW_PREFIX}"
    system "./bootstrap.sh"

    # Language bindings try to install outside of Homebrew's prefix, so
    # omit them here. For ruby you can install the gem, and for Python
    # you can use pip or easy_install.
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--libdir=#{lib}",
                          "--with-thriftpath=#{HOMEBREW_PREFIX}"

    ENV.j1
    system "make"
    system "make install"
  end
end

