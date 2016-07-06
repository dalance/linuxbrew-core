class Xmake < Formula
  desc "The Automatic Cross-platform Build Tool"
  homepage "https://github.com/waruqi/xmake"
  url "https://github.com/waruqi/xmake/archive/v2.0.2.tar.gz"
  sha256 "e7a832d407a52a3eb290b5465eb01d1c1d5567eecb6fc627393093b9d6f84bae"
  head "https://github.com/waruqi/xmake.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "a8d847023ef06ffc2c4543ca68c0afbd2a3266f206a6a1a8fcdbf91ae23e745a" => :el_capitan
    sha256 "7b5b1098f73c23bce7051a3ace6d3ed30f810776059a239853e573eeaf273fdb" => :yosemite
    sha256 "b79ffba5448323ef24825a1eaa089902a309107e01ca709e78eca3865d0f75fa" => :mavericks
  end

  def install
    system "./install", "output"
    pkgshare.install Dir["xmake/*"]
    bin.install "output/share/xmake/xmake"
    bin.env_script_all_files(libexec, :XMAKE_PROGRAM_DIR => pkgshare)
  end

  test do
    system bin/"xmake", "create", "-P", testpath
    assert_match "build ok!", pipe_output(bin/"xmake")
  end
end
