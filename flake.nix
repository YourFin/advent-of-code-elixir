{
  description = "Advent of code dev env";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils/main";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            elixir-ls
            elixir # 15.7 currently
          ];
          shellHook = ''
            ###################################################
            # Create a diretory for the generated artifacts
            ###################################################
            mkdir -p .nix-shell
            export NIX_SHELL_DIR=$PWD/.nix-shell
            ###################################################
            # Put any Mix-related data in the project directory
            ###################################################
            export MIX_HOME="$NIX_SHELL_DIR/.mix"
            export MIX_ARCHIVES="$MIX_HOME/archives"
            export ERL_AFLAGS="-kernel shell_history enabled"
          '';
        };
      });
}
