class Kubeprod < Formula
  desc "Installer for the Bitnami Kubernetes Production Runtime (BKPR)"
  homepage "https://kubeprod.io"
  url "https://github.com/bitnami/kube-prod-runtime/archive/v1.3.0.tar.gz"
  sha256 "0a16a18ace187a8f72a4344c5839ffedfa1493060f5c5b6f67d339bf5778b292"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any_skip_relocation
    sha256 "939f4d0c6ffc1ab4fa7d29202e421a6b5dd0a46ffce8790561c6613b950f7d71" => :mojave
    sha256 "18a9b708d1596fb87b58395bc09d5c6ce2feeb5d541c59fb1d867d52aa8616ce" => :high_sierra
    sha256 "8b0be67f595fe846e563ccdfbe7db2a079fc07115901d2678f2e050525046654" => :sierra
    sha256 "c5a2b155dfc1f7352a053941d3e35b97d5ea388ab7d98db762b4d882eccc958d" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["TARGETS"] = OS.mac? ? "darwin/amd64" : "linux/amd64"
    dir = buildpath/"src/github.com/bitnami/kube-prod-runtime"
    dir.install buildpath.children

    cd dir do
      system "make", "-C", "kubeprod", "release", "VERSION=v#{version}"
      bin.install "kubeprod/_dist/" + ENV["TARGETS"].tr("/", "-") + "/bkpr-v#{version}/kubeprod"
    end
  end

  test do
    version_output = shell_output("#{bin}/kubeprod version")
    assert_match "Installer version: v#{version}", version_output

    (testpath/"kube-config").write <<~EOS
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: test
          server: http://127.0.0.1:8080
        name: test
      contexts:
      - context:
          cluster: test
          user: test
        name: test
      current-context: test
      kind: Config
      preferences: {}
      users:
      - name: test
        user:
          token: test
    EOS

    authz_domain = "castle-black.com"
    project = "white-walkers"
    oauth_client_id = "jon-snow"
    oauth_client_secret = "king-of-the-north"
    contact_email = "jon@castle-black.com"

    ENV["KUBECONFIG"] = testpath/"kube-config"
    system "#{bin}/kubeprod", "install", "gke",
                              "--authz-domain", authz_domain,
                              "--project", project,
                              "--oauth-client-id", oauth_client_id,
                              "--oauth-client-secret", oauth_client_secret,
                              "--email", contact_email,
                              "--only-generate"

    json = File.read("kubeprod-autogen.json")
    assert_match "\"authz_domain\": \"#{authz_domain}\"", json
    assert_match "\"client_id\": \"#{oauth_client_id}\"", json
    assert_match "\"client_secret\": \"#{oauth_client_secret}\"", json
    assert_match "\"contactEmail\": \"#{contact_email}\"", json

    jsonnet = File.read("kubeprod-manifest.jsonnet")
    assert_match "https://releases.kubeprod.io/files/v#{version}/manifests/platforms/gke.jsonnet", jsonnet
  end
end
