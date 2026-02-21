# Post-Archinstall Setup Steps

## 1. Verify network
```bash
ping www.av.com
```
Nothing works without internet. Confirm connectivity first.

## 2. Try to install Chrome (fails)
```bash
sudo pacman -S google-chrome-stable
```
AUR-only package — fails because no AUR helper is installed.

## 3. Try AUR helper (fails)
```bash
yay
```
Not installed. No way to get AUR packages yet.

## 4. System upgrade
```bash
sudo pacman -Syu
```
Update system before installing anything else.

## 5. Install Firefox
```bash
sudo pacman -S firefox
```
Fallback browser since Chrome needs AUR.

## 6. Install GitHub CLI
```bash
sudo pacman -S github-cli
```
Need authenticated access to private GitHub repos.

## 7. Authenticate with GitHub
```bash
gh auth login
gh auth setup-git
```
Authenticate so cloning private repos works.

## 8. Clone SSH keys
```bash
gh repo clone SkogAI/secrets
mv secrets/ .ssh
cd .ssh/secrets/ && mv * .. && mv .* ..
rmdir secrets/
./fix-ssh-permissions.sh
ssh-add .ssh/id_rsa
```
Private repo with SSH keys. Move contents into `~/.ssh/`, fix permissions, add to agent. Multiple attempts with wrong org name capitalization before finding `SkogAI`.

## 9. Clone workspace
```bash
gh repo clone SkogAI/claude-temp
mv claude-temp/ claude
```
Clone the workspace repo, rename to `~/claude`.

## 10. Clone ansible
```bash
gh repo clone SkogAI/skogansible .ansible
```
Ansible playbooks to `~/.ansible`.

## 11. Install Claude Code
```bash
curl -fsSL https://claude.ai/install.sh > install.sh
chmod +x install.sh
./install.sh
```
Install the Claude Code CLI.

## 12. Install chezmoi
```bash
sudo pacman -S chezmoi
```
Dotfiles manager.

## 13. Clone and apply dotfiles
```bash
cd ~/.local/share/
gh repo clone SkogAI/dotfiles chezmoi
chezmoi init
chezmoi apply
```
Clone dotfiles repo directly as chezmoi source directory, then deploy.

## 14. Install zsh
```bash
sudo pacman -S zsh
```
Preferred shell.

## 15. Switch shell and reboot
```bash
chsh
sudo reboot now
```
Set zsh as default login shell, reboot to apply.
