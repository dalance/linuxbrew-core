class Openblas < Formula
  desc "Optimized BLAS library"
  homepage "https://www.openblas.net/"
  url "https://github.com/xianyi/OpenBLAS/archive/v0.3.6.tar.gz"
  sha256 "e64c8fe083832ffbc1459ab6c72f71d53afd3b36e8497c922a15a06b72e9002f"
  head "https://github.com/xianyi/OpenBLAS.git", :branch => "develop"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any
    sha256 "c7717658d2801da03bfd1a6d83016bec1beacc62baa02ab3d321f566250b88a3" => :mojave
    sha256 "b9c3a1c6ac196fd5c254049a50f5762a8fd643a289e70514bb76bbbbcec947f2" => :high_sierra
    sha256 "0731e35071ceeed6a59570d1965a52ae0450445db6c461c8db3245ebbff5455a" => :sierra
    sha256 "0af7f4686da64edf749bb3d486c1a3d4ff54b22892f88452675b61ed464d9fb5" => :x86_64_linux
  end

  keg_only :provided_by_macos,
           "macOS provides BLAS and LAPACK in the Accelerate framework"

  depends_on "gcc" # for gfortran
  fails_with :clang

  def install
    ENV["DYNAMIC_ARCH"] = "1"
    ENV["USE_OPENMP"] = "1"
    ENV["NO_AVX512"] = "1"

    # Must call in two steps
    system "make", "CC=#{ENV.cc}", "FC=gfortran", "libs", "netlib", "shared", *("NO_AVX512=1" unless OS.mac?)
    system "make", "PREFIX=#{prefix}", "install"

    so = OS.mac? ? "dylib" : "so"
    lib.install_symlink "libopenblas.#{so}" => "libblas.#{so}"
    lib.install_symlink "libopenblas.#{so}" => "liblapack.#{so}"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <stdlib.h>
      #include <math.h>
      #include "cblas.h"

      int main(void) {
        int i;
        double A[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double B[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double C[9] = {.5, .5, .5, .5, .5, .5, .5, .5, .5};
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans,
                    3, 3, 2, 1, A, 3, B, 3, 2, C, 3);
        for (i = 0; i < 9; i++)
          printf("%lf ", C[i]);
        printf("\\n");
        if (fabs(C[0]-11) > 1.e-5) abort();
        if (fabs(C[4]-21) > 1.e-5) abort();
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lopenblas",
                   "-o", "test"
    system "./test"
  end
end
