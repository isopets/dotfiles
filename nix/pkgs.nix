{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    eza bat zoxide fzf lazygit direnv starship mise
    gh glow
    pkgs-unstable.jless pkgs-unstable.serpl
    jq gnused ripgrep fd gnupg
    snyk trivy gum
    uv
    nerd-fonts.hack
    yq
  ];
}
