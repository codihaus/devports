cask "devports" do
  version "__VERSION__"
  sha256 "__SHA256__"

  url "https://github.com/codihaus/devports/releases/download/v#{version}/DevPorts.app.zip"
  name "DevPorts"
  desc "Tiny macOS menu bar app for monitoring local dev servers and ports"
  homepage "https://github.com/codihaus/devports"

  depends_on macos: ">= :sonoma"

  app "DevPorts.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/DevPorts.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/LaunchAgents/com.devports.app.plist",
  ]
end
