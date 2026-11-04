{
    config,pkgs, ...
}:
{
imports = [
    ../../modules/profiles/common.nix
    ../../modules/profiles/development.nix
];
}