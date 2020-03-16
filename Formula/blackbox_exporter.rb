# this actually doesn't work very well for pings: blackbox_exporter needs root on macOS to use IMCP :(
VERSION = "0.16.0"
TAG = "v#{VERSION}"

class BlackboxExporter < Formula
  desc "Service monitoring system and time series database"
  homepage "https://prometheus.io/"
  url "https://github.com/prometheus/blackbox_exporter/archive/v0.16.0.tar.gz"
  sha256 "6ebfd9f590286004dacf3c93b3aa3e3c560d6f1e5994f72c180e5af94fdd0099"


  depends_on "go" => :build

  def install
    mkdir_p buildpath/"src/github.com/prometheus"
    ln_sf buildpath, buildpath/"src/github.com/prometheus/blackbox_exporter"

    # make build involves installing their release tool `promu`; could probably save some
    # time by just doing go build directly, but meh
    system "make", "build"
    system "mv", "blackbox_exporter-#{VERSION}", "blackbox_exporter"
    bin.install "blackbox_exporter"
  end

  def post_install
    if not (etc/"blackbox_exporter.yml").exist? then
      (etc/"blackbox_exporter.yml").write <<~EOS
        modules:
          icmp:
            prober: icmp
      EOS
    end
  end

  def caveats
    <<~EOS
    EOS
  end

  plist_options :manual => "blackbox_exporter"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/blackbox_exporter</string>
            <string>--web.listen-addr=localhost:9115</string>
            <string>--config.file #{etc}/blackbox_exporter.yml</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <false/>
          <key>StandardErrorPath</key>
          <string>#{var}/log/blackbox_exporter.err.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/blackbox_exporter.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    system "blackbox_exporter", "--version"
  end
end
