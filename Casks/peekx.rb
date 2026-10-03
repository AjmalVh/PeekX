cask "peekx" do
  arch arm: "arm64", intel: "x86_64"

  version "1.2"
  sha256 :no_check

  url "https://github.com/AjmalVh/PeekX/releases/download/v#{version}/PeekX-#{version}-#{arch}.dmg"
  name "PeekX"
  desc "Native macOS Quick Look extension for folder and markdown previews"
  homepage "https://github.com/AjmalVh/PeekX"

  depends_on macos: ">= :sonoma"

  app "PeekX.app"

  postflight do
    system_command "/usr/bin/pluginkit", args: ["-e", "use", "-i", "altic.PeekX.PeekXExt"]
    system_command "/usr/bin/qlmanage", args: ["-r", "cache"]
    system_command "/usr/bin/killall", args: ["Finder"], sudo: false
  end

  zap trash: [
    "~/Library/Application Scripts/altic.PeekX",
    "~/Library/Application Scripts/altic.PeekX.PeekXExt",
    "~/Library/Containers/altic.PeekX",
    "~/Library/Containers/altic.PeekX.PeekXExt",
    "~/Library/Preferences/altic.PeekX.plist",
  ]
end
