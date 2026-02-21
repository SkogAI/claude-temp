# Setup Log — Annotated Command History

Reconstructed from `~/.bash_history` (89 lines, pre-zsh-switch).
Timestamps not available in bash history — order is sequential.

---

## Phase 1: Network Verification

```bash
ping www.av.com
```

First thing after boot — verify network connectivity works.

---

## Phase 2: Package Manager & Browser

```bash
sudo pacman -Syu          # full system upgrade
sudo pacman -S firefox     # browser (chrome attempt failed — not in official repos)
```

**Note:** Attempted `sudo pacman -S google-chrome-stable` first — this package is AUR-only. Also tried `yay` which wasn't installed yet. Fell back to firefox from official repos.

**TODO:** Install an AUR helper (yay/paru) for AUR packages.

---

## Phase 3: GitHub CLI & SSH Keys

```bash
# Install and authenticate
sudo pacman -S github-cli
gh auth login
gh auth setup-git

# Clone private SSH keys repo
gh repo clone SkogAI/secrets      # multiple attempts with different org names
                                   # (skogai, skogix, Skogix — correct is SkogAI)

# Set up SSH directory
mv secrets/ .ssh
cd .ssh/secrets/ && mv * .. && mv .* ..
rmdir secrets/
./fix-ssh-permissions.sh           # script from the secrets repo
ssh-add .ssh/id_rsa
```

**Key insight:** The `SkogAI/secrets` repo contains SSH keys and a `fix-ssh-permissions.sh` script. After cloning, contents are moved to `~/.ssh/` and the nested dir is removed.

**Auth flow:** gh CLI first (HTTPS-based), then SSH keys loaded for git-over-SSH.

---

## Phase 4: Workspace & Claude Code

```bash
# Clone workspace
gh repo clone SkogAI/claude-temp
mv claude-temp/ claude
cd claude/

# Install Claude Code CLI
curl -fsSL https://claude.ai/install.sh > install.sh
chmod +x install.sh
./install.sh
```

**Note:** Repo is `SkogAI/claude-temp`, renamed locally to `~/claude`. Claude Code installed from official installer.

---

## Phase 5: Dotfiles via Chezmoi

```bash
sudo pacman -S chezmoi

# Clone dotfiles into chezmoi source dir
cd ~/.local/share/
gh repo clone SkogAI/dotfiles chezmoi

# Apply dotfiles
chezmoi init
chezmoi apply
```

**Note:** Dotfiles repo is `SkogAI/dotfiles`, cloned directly as chezmoi's source directory. Includes i3 config and other dotfiles.

---

## Phase 6: Shell Switch (bash → zsh)

```bash
sudo pacman -S zsh
chsh                      # ran twice — selecting /bin/zsh
sudo reboot now           # reboot to apply shell change
```

**Note:** `chsh` ran twice, likely first attempt had a typo or needed to verify. Reboot applies the login shell change.

---

## Phase 7+: Post-Reboot (current session)

Zsh is now the active shell. This is where we are now — zsh history will start accumulating.

---

## Raw History Reference

<details>
<summary>Full ~/.bash_history (89 lines)</summary>

```
ping www.av.com
ls
sudo pacman -S google-chrome-stable
yay
sudo pacman -Syu
sudo pacman -S firefox
sudo pacman -S github-cli
gh auth login
gh repo clone skogai/.ssh
gh repo clone skogai/secrets .ssh
ls .ssh
gh repo clone skogix/secrets .ssh
gh repo clone skogai/secrets
gh repo clone Skogix/secrets
gh repo clone Skogix/secrets
git clone  Skogix/secrets
git clone git@github.com:SkogAI/secrets.git
gh repo clone SkogAI/secrets
gh auth setup-git
gh repo clone SkogAI/secrets
gh auth status
gh repo clone SkogAI/secrets --help
gh repo clone git@github.com:SkogAI/secrets.git
gh repo clone https://github.com/SkogAI/secrets
ls
mv secrets/ .ssh
ls
ssh-add .ssh/id_rsa
ls
ls .ssh/
cd .ssh/
cd secrets/
setxkbmap se
mv * ..
ls -la
mv *
mv .* ..
cd
cd .ssh/
rmdir secrets/
ls
cd
ssh-add .ssh/id_rsa
ls
gh repo clone SkogAI/claude-temp
cd .ssh/
./fix-ssh-permissions.sh
cd
gh repo clone SkogAI/claude-temp
gh repo clone SkogAI/skogansible .ansible
ls
mv claude-temp/ claude
cd claude/
ls
curl -fsSL https://claude.ai/install.sh
curl -fsSL https://claude.ai/install.sh > install.sh
chmod +x install.sh
./install.sh
sudo pacman -S chezmoi
cd
cd .local/share/
gh repo clone SkogAI/dotfiles chezmoi
chezmoi cd
chezmoi apply
chezmoi init
chezmoi init
chezmoi apply
ls
cd
cd .config/i3/
ls
ls -la
ls
chezmoi
chezmoi cd
ls
chezmoi
chezmoi git
chezmoi git status
ls
cd
cd claude/
claude
chsh
chsh
sudo pacman -S zsh
chsh
chsh
sudo reboot now
```

</details>
