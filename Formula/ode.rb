class Ode < Formula
  desc "Simulating articulated rigid body dynamics"
  homepage "https://www.ode.org/"
  url "https://bitbucket.org/odedevs/ode/downloads/ode-0.15.2.tar.gz"
  sha256 "2eaebb9f8b7642815e46227956ca223806f666acd11e31708bd030028cf72bac"
  revision OS.mac? ? 1 : 4
  head "https://bitbucket.org/odedevs/ode/", :using => :hg

  bottle do
    cellar :any_skip_relocation
    rebuild 2
    sha256 "bd5d10cb589e3c503282ea5a2b23a6becca27e1f80c8b62a1c67e237b204cd82" => :mojave
    sha256 "e03793b4cc735b3da02ee8301b006761f057bf67daa4fcfdc21bd3f0004dbbb9" => :high_sierra
    sha256 "db9f21ec8ac905541de59c2559736ef41674a3d238248c537e92cfd6f9f77ad2" => :sierra
    sha256 "7d61aecf24013824b30af9e81115bdd1cb93c0fe75887847e68d9cbcce8877bc" => :x86_64_linux
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libccd"

  def install
    inreplace "bootstrap", "libtoolize", "glibtoolize"
    system "./bootstrap"

    system "./configure", "--prefix=#{prefix}", "--enable-libccd"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <ode/ode.h>
      int main() {
        dInitODE();
        dCloseODE();
        return 0;
      }
    EOS
    std = OS.mac? ? "-lc++" : "-lstdc++"
    system ENV.cc, "test.cpp", "-I#{include}/ode", "-L#{lib}", "-lode",
                   "-L#{Formula["libccd"].opt_lib}", "-lccd",
                   *("-lm" unless OS.mac?),
                   std, *("-lpthread" unless OS.mac?), "-o", "test"
    system "./test"
  end
end
