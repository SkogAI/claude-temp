# Post-Archinstall Setup Steps

## 1. Verify network
`ping www.av.com`

## 2. PROBLEM: No AUR helper → no Chrome → fallback to Firefox
Wanted Chrome (`pacman -S google-chrome-stable`) but it's AUR-only.
Tried `yay` — not installed. Ended up with `sudo pacman -S firefox` as fallback.
**Needs:** AUR helper installed early so AUR packages are available from the start.

## 3. System upgrade
`sudo pacman -Syu`

## 4. Install GitHub CLI
`sudo pacman -S github-cli`

## 5. Authenticate with GitHub
`gh auth login`
`gh auth setup-git`

## 6. PROBLEM: SSH key setup is too manual
```bash
gh repo clone SkogAI/secrets
mv secrets/ .ssh
cd .ssh/secrets/ && mv * .. && mv .* ..
rmdir secrets/
./fix-ssh-permissions.sh
ssh-add .ssh/id_rsa
```
Took multiple attempts to get the org name right (`skogai`, `skogix`, `Skogix` → `SkogAI`).
Then clone, move contents into `~/.ssh/`, remove nested dir, fix perms, add key.
**Needs:** A single script that handles all of this.

## 7. Clone workspace
`gh repo clone SkogAI/claude ~/claude`
(Was `claude-temp` renamed to `claude` — real setup will clone directly.)

## 8. Clone ansible
`gh repo clone SkogAI/skogansible .ansible`

## 9. Install Claude Code
```bash
curl -fsSL https://claude.ai/install.sh > install.sh
chmod +x install.sh
./install.sh
```
Will be scripted.

## 10. Install chezmoi
`sudo pacman -S chezmoi`

## 11. PROBLEM: Chezmoi workflow unclear
```bash
cd ~/.local/share/
gh repo clone SkogAI/dotfiles chezmoi
chezmoi init
chezmoi apply
```
First time using chezmoi. Cloned directly into source dir, ran init and apply.
**Needs:** Figure out the proper chezmoi init workflow.

## 12. Install zsh
`sudo pacman -S zsh`

## 13. Switch shell and reboot
`chsh`
`sudo reboot now`
