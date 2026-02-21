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
    packages = with pkgs; [
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtAb8GNqbdy/FaA7kI5Qeay1Z9Yfo7u/EMZFwMy7DZBOv4KjYgP/bC2KdcF4fr1+mNzEARw1e4Lriygi54bmjMQDbQBT/Oh9Dj6f3mIvfw3LDd9EOMLfB4jzBiisA0IjRysuwDmion5ny01KWYg4mQqmKsCnDN3Xpyqits8iW06jlvJlXwtsNpgfzg21uuhfRUCZOPqiIg0JSNLCVqN83PUvZXG42lJ0XKvvDOyb2egWjCWFtqB2EPWnGVYhD1SkRqDhvf77X4hl6stuHaKcOTPavyTmGwRRtK3LYqoFEzUrCu9leVVo+aYe9/eZZM5Rnuep79UDvpBkjgiunWNBiPw== muhackel@machackel-pro.ad.fh-albsig.de"
    ];
  };
}