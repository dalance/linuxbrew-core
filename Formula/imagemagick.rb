class Imagemagick < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://www.imagemagick.org/"
  # Please always keep the Homebrew mirror as the primary URL as the
  # ImageMagick site removes tarballs regularly which means we get issues
  # unnecessarily and older versions of the formula are broken.
  url "https://dl.bintray.com/homebrew/mirror/ImageMagick-7.0.8-43.tar.xz"
  mirror "https://www.imagemagick.org/download/ImageMagick-7.0.8-43.tar.xz"
  sha256 "07adf246a9c81f6b898554fa318f196eb1ed0e814631d82385fbb13efb161513"
  head "https://github.com/ImageMagick/ImageMagick.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    sha256 "1341e9985105bd4e7c5112c9f7600ff7857c83a3c255e859b204f2e88ea80bbb" => :mojave
    sha256 "41fc6a27cdf5f3fe34242f6d88430cbbe1e6f47883f6257819ff136ae104ee53" => :high_sierra
    sha256 "e2b61ee8448d516b687c17a337133a4e8e7bba916fe107d92bd7d49dce9650e8" => :sierra
    sha256 "f8cb60e12e22e39c6eb794e4ec3dea544ee10e5fd25e660c41325d38e2ffdcbd" => :x86_64_linux
  end

  depends_on "pkg-config" => :build

  depends_on "freetype"
  depends_on "jpeg"
  depends_on "libheif"
  depends_on "libomp"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libtool"
  depends_on "little-cms2"
  depends_on "openexr"
  depends_on "openjpeg"
  depends_on "webp"
  depends_on "xz"

  depends_on "bzip2" unless OS.mac?
  depends_on "linuxbrew/xorg/xorg" unless OS.mac?
  depends_on "libxml2" unless OS.mac?

  skip_clean :la

  def install
    args = %W[
      --disable-osx-universal-binary
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-opencl
      --enable-shared
      --enable-static
      --with-freetype=yes
      --with-modules
      --with-openjp2
      --with-openexr
      --with-webp=yes
      --with-heic=yes
      --without-gslib
      --with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts
      --without-fftw
      --without-pango
      --without-x
      --without-wmf
      --enable-openmp
      ac_cv_prog_c_openmp=-Xpreprocessor\ -fopenmp
      ac_cv_prog_cxx_openmp=-Xpreprocessor\ -fopenmp
      LDFLAGS=-lomp
    ]

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[Modules freetype jpeg png tiff].each do |feature|
      assert_match feature, features
    end
  end
end
