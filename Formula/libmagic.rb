class Libmagic < Formula
  desc "Implementation of the file(1) command"
  homepage "https://www.darwinsys.com/file/"
  url "https://astron.com/pub/file/file-5.40.tar.gz"
  sha256 "167321f43c148a553f68a0ea7f579821ef3b11c27b8cbe158e4df897e4a5dd57"
  # libmagic has a BSD-2-Clause-like license
  license :cannot_represent

  livecheck do
    url "https://astron.com/pub/file/"
    regex(/href=.*?file[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_big_sur: "e588a1adec77deda36340e9cce3375fde9ffcdabcd79ba86a429dbd14ea542fe"
    sha256 big_sur:       "2a09f46305a9457a2bfae1069cbf8f6a473d77f69a6370e67f67c0decc96ca0a"
    sha256 catalina:      "90b17cb74e853804227abdd32c6810ff535fb98e8862f946c49860b697faece0"
    sha256 mojave:        "f32eb14fbef470d28a041ddefec932e8d96870b4a13dbac3f61d8c6de6e50f29"
    sha256 high_sierra:   "110d2db0b588dc5a379124d024b228e8ee8aae58c95a6a0510e68dc36426a86a"
  end

  uses_from_macos "zlib"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-fsect-man5",
                          "--enable-static"
    system "make", "install"
    (share/"misc/magic").install Dir["magic/Magdir/*"]

    # Don't dupe this system utility
    rm bin/"file"
    rm man1/"file.1"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      #include <stdio.h>

      #include <magic.h>

      int main(int argc, char **argv) {
          magic_t cookie = magic_open(MAGIC_MIME_TYPE);
          assert(cookie != NULL);
          assert(magic_load(cookie, NULL) == 0);
          // Prints the MIME type of the file referenced by the first argument.
          puts(magic_file(cookie, argv[1]));
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lmagic", "-o", "test"
    cp test_fixtures("test.png"), "test.png"
    assert_equal "image/png", shell_output("./test test.png").chomp
  end
end
