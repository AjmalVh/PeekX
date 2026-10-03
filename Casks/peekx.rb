cask "peekx" do
  version "1.1"
  sha256 :no_check

  url "https://github.com/AjmalVh/PeekX/releases/download/v#{version}/PeekX-#{version}.dmg"
  name "PeekX"
  desc "Native macOS Quick Look extension for folder and markdown previews"
  homepage "https://github.com/AjmalVh/PeekX"

  depends_on macos: ">= :sonoma"

  app "PeekX.app"

  postflight do
    system_command "/usr/bin/qlmanage", args: ["-r", "cache"]
    system_command "/usr/bin/killall", args: ["Finder"], sudo: false
  end

  zap trash: [
    "~/Library/Group Containers/group.altic.PeekX",
    "~/Library/Preferences/group.altic.PeekX.plist",
    "~/Library/Application Scripts/group.altic.PeekX",
  ]
end
