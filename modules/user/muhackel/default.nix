{ config, lib, pkgs, ... }:

let
  baseGroups = [
    "wheel"
    "networkmanager"
    "dialout"
    "uucp" # legacy group for serial devices
  ];
in

{
  users.users.muhackel = {
    isNormalUser = true;
    extraGroups = lib.unique (baseGroups ++ config.local.userExtraGroups);
    shell = pkgs.zsh;
    linger = true;
    initialPassword = "1qaz!QAZ";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtAb8GNqbdy/FaA7kI5Qeay1Z9Yfo7u/EMZFwMy7DZBOv4KjYgP/bC2KdcF4fr1+mNzEARw1e4Lriygi54bmjMQDbQBT/Oh9Dj6f3mIvfw3LDd9EOMLfB4jzBiisA0IjRysuwDmion5ny01KWYg4mQqmKsCnDN3Xpyqits8iW06jlvJlXwtsNpgfzg21uuhfRUCZOPqiIg0JSNLCVqN83PUvZXG42lJ0XKvvDOyb2egWjCWFtqB2EPWnGVYhD1SkRqDhvf77X4hl6stuHaKcOTPavyTmGwRRtK3LYqoFEzUrCu9leVVo+aYe9/eZZM5Rnuep79UDvpBkjgiunWNBiPw== muhackel@machackel-pro.ad.fh-albsig.de"
    ];
  };

  # Claude Code erwartet ~/.claude.json, die eigentliche Datei liegt in ~/.claude/
  system.activationScripts.claudeJsonSymlink = lib.mkIf config.local.features.ai ''
    if [ $(cat /proc/uptime | cut -d. -f1) -ge 30 ]; then
      src="/home/muhackel/.claude/claude.json"
      dst="/home/muhackel/.claude.json"
      if [ -f "$src" ]; then
        echo "Claude: Symlink $dst -> $src"
        ln -sf "$src" "$dst"
      else
        echo "Claude: $src nicht gefunden, überspringe Symlink"
      fi
    else
      echo "Claude: Symlink-Aktivierung übersprungen (uptime < 30s)"
    fi
  '';
}