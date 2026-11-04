{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/profiles/common.nix
    ../../modules/profiles/development.nix
    ../../modules/profiles/desktop-gui.nix
    ../../modules/profiles/kde.nix
  ];

  home.packages = with pkgs; [
    steam
    discord
  ];

}
