# some credit to https://github.com/maddox/magick-installer
require 'formula'

def ghostscript_srsly?
  build.include? 'with-ghostscript'
end

def ghostscript_fonts?
  File.directory? "#{HOMEBREW_PREFIX}/share/ghostscript/fonts"
end

class Imagemagick < Formula
  homepage 'http://www.imagemagick.org'

  # upstream's stable tarballs tend to disappear, so we provide our own mirror
  # Tarball and checksum from: http://www.imagemagick.org/download
  url 'http://downloads.sf.net/project/machomebrew/mirror/ImageMagick-6.8.7-0.tar.bz2'
  sha256 '841f34ffd92cf043b2b5ec949887c6e09e4af53812fd0f4b0186f8954cb0910f'

  head 'https://www.imagemagick.org/subversion/ImageMagick/trunk',
    :using => UnsafeSubversionDownloadStrategy

  bottle do
    sha1 'f352bf49c3f5376f4536b62f0f2c90f60df18f66' => :mountain_lion
    sha1 '68b4f53526f8703df0dafbeffd8b793e193cc334' => :lion
    sha1 '40110c9eded6425c6863de96f907edc0ab51cb63' => :snow_leopard
  end

  option 'with-quantum-depth-8', 'Compile with a quantum depth of 8 bit'
  option 'with-quantum-depth-16', 'Compile with a quantum depth of 16 bit'
  option 'with-quantum-depth-32', 'Compile with a quantum depth of 32 bit'
  option 'with-perl', 'enable build/install of PerlMagick'
  option 'without-magick-plus-plus', 'disable build/install of Magick++'

  depends_on :libltdl

  depends_on 'pkg-config' => :build

  depends_on 'jpeg' => :recommended
  depends_on :libpng => :recommended
  depends_on :freetype => :recommended

  depends_on :x11 => :optional
  depends_on :fontconfig => :optional
  depends_on 'libtiff' => :optional
  depends_on 'little-cms' => :optional
  depends_on 'little-cms2' => :optional
  depends_on 'jasper' => :optional
  depends_on 'libwmf' => :optional
  depends_on 'librsvg' => :optional
  depends_on 'liblqr' => :optional
  depends_on 'openexr' => :optional
  depends_on 'ghostscript' => :optional
  depends_on 'webp' => :optional

  opoo '--with-ghostscript is not recommended' if build.with? 'ghostscript'
  if build.with? 'openmp' and (MacOS.version == :leopard or ENV.compiler == :clang)
    opoo '--with-openmp is not supported on Leopard or with Clang'
  end

  bottle do
    version "3"
    sha1 '0d7ca4e54a1d3090e8b5a85663f0efa857ea52b7' => :mountainlion
    sha1 '64fca6d7c75407dd1942a271a4df837ab02bbeb0' => :lion
    sha1 'b8d1a9b2de7b1961da311df77922d326c2b6723f' => :snowleopard
  end

  skip_clean :la

  def patches
    # Fixes xml2-config that can be missing --prefix.  See issue #11789
    # Remove if the final Mt. Lion xml2-config supports --prefix.
    # Not reporting this upstream until the final Mt. Lion is released.
    DATA
  end

  def install
    args = [ "--disable-osx-universal-binary",
             "--prefix=#{prefix}",
             "--disable-dependency-tracking",
             "--enable-shared",
             "--disable-static",
             "--without-pango",
             "--with-included-ltdl",
             "--with-modules"]

    args << "--disable-openmp" unless build.include? 'enable-openmp'
    args << "--disable-opencl" if build.include? 'disable-opencl'
    args << "--without-gslib" unless build.with? 'ghostscript'
    args << "--without-perl" unless build.with? 'perl'
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" unless build.with? 'ghostscript'
    args << "--without-magick-plus-plus" if build.without? 'magick-plus-plus'
    args << "--enable-hdri=yes" if build.include? 'enable-hdri'

    if build.include? 'with-quantum-depth-32'
      quantum_depth = 32
    elsif build.include? 'with-quantum-depth-16'
      quantum_depth = 16
    elsif build.include? 'with-quantum-depth-8'
      quantum_depth = 8
    end

    args << "--with-quantum-depth=#{quantum_depth}" if quantum_depth
    args << "--with-rsvg" if build.include? 'use-rsvg'
    args << "--without-x" unless build.include? 'with-x'
    args << "--with-fontconfig=yes" if build.include? 'with-fontconfig' or MacOS::X11.installed?
    args << "--with-freetype=yes" unless build.include? 'without-freetype' and not MacOS::X11.installed?

    # versioned stuff in main tree is pointless for us
    inreplace 'configure', '${PACKAGE_NAME}-${PACKAGE_VERSION}', '${PACKAGE_NAME}'
    system "./configure", *args
    system "make install"
  end

  def caveats
    s = <<-EOS.undent
      For full Perl support you must install the Image::Magick module from the CPAN.
        https://metacpan.org/module/Image::Magick

      The version of the Perl module and ImageMagick itself need to be kept in sync.
      If you upgrade one, you must upgrade the other.

      For this version of ImageMagick you should install
      version #{version} of the Image::Magick Perl module.
    EOS
    s if build.with? 'perl'
  end

  test do
    system "#{bin}/identify", "/usr/share/doc/cups/images/cups.png"
  end
end

__END__
--- a/configure	2012-02-25 09:03:23.000000000 -0800
+++ b/configure	2012-04-26 03:32:15.000000000 -0700
@@ -31924,7 +31924,7 @@
         # Debian installs libxml headers under /usr/include/libxml2/libxml with
         # the shared library installed under /usr/lib, whereas the package
         # installs itself under $prefix/libxml and $prefix/lib.
-        xml2_prefix=`xml2-config --prefix`
+        xml2_prefix=/usr
         if test -d "${xml2_prefix}/include/libxml2"; then
             CPPFLAGS="$CPPFLAGS -I${xml2_prefix}/include/libxml2"
         fi
