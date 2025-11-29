setopt interactive_comments
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh; fi
for f in ~/dotfiles/zsh/functions/*.zsh(N); do source "$f"; done
export PATH=$HOME/.nix-profile/bin:$PATH
