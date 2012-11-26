require 'formula'

class Libmemcached < Formula
  homepage 'http://libmemcached.org'
  # Asana: We use a quite old version of libmemcached. Somewhere between here and 1.0.8, v8cgi starts getting segfaults.
  url 'https://launchpad.net/libmemcached/1.0/0.40/+download/libmemcached-0.40.tar.gz'
  sha1 'cba48c9816e19ecc0b0c71907c122286fd929780'

  depends_on 'memcached'

  def install
    ENV.append_to_cflags "-undefined dynamic_lookup" if MacOS.version == :leopard

    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
