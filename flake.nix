{
  description = "Multi-machine Home Manager and System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, treefmt-nix, home-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Import the treefmt-nix module into flake-parts
      imports = [
        treefmt-nix.flakeModule
      ];

      perSystem = { config, pkgs, system, ... }: {
        # 1. Formatting Configuration
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            # Standard opinionated formatter (or use programs.nixpkgs-fmt.enable / alejandra.enable)
            nixfmt.enable = true;
            deadnix.enable = true; # Removes unused code
            statix.enable = true;  # Lints anti-patterns

            # Format shell scripts, markdown, and yaml alongside your nix files
            shfmt.enable = true;
            prettier.enable = true;
          };
        };

        # 2. Developer Shell with Nix LSP and Linters
        devShells.default = pkgs.mkShell {
          name = "homemanager-dotfiles";

          packages = with pkgs; [
            # Language Server Protocol
            nil # Fast, comprehensive Nix LSP (alternative: nixd)

            # Linters and syntax checks
            statix
            deadnix

            # Formatting wrapper (points directly to the treefmt config above)
            config.treefmt.build.wrapper

            # Convenience CLI tools for flakes / deployment
            nh       # Modern Nix CLI helper
            nix-diff # Analyze build differences
          ];

          shellHook = ''
            echo "Dotfiles dev environment loaded."
            echo "Run 'treefmt' to format the codebase."
          '';
        };
      };

      flake = {
        # 3. Machine Configurations (Stubs to expand)
        homeConfigurations = {
          "user@laptop" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages."x86_64-linux";
            extraSpecialArgs = { inherit inputs; };
            modules = [ ./hosts/laptop/home.nix ];
          };

          "user@workstation" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages."x86_64-linux";
            extraSpecialArgs = { inherit inputs; };
            modules = [ ./hosts/workstation/home.nix ];
          };

          "user@homelab" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages."x86_64-linux";
            extraSpecialArgs = { inherit inputs; };
            modules = [ ./hosts/homelab/home.nix ];
          };
        };
      };
    };
}