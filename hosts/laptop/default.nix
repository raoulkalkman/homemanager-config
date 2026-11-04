{
    config,pkgs, ...
}:
{
imports = [
    ../../modules/profiles/common.nix
    ../../modules/profiles/development.nix
    ../../modules/profiles/desktop-gui.nix
    ../../modules/profiles/gnome.nix
    ./xiaomi-mi-pro-15-laptop.nix
];

home.packages = with pkgs; [
];

}