# dotfiles
okash1nのdotfiles（令和最新版）

# 準備
## macOS

- `xcode-select --install`

## Linux
`zsh` をログインシェルにしておく

## GitHub
GitHubにSSH Keyを登録しておく


- [Generating a new SSH key and adding it to the ssh\-agent \- GitHub Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [Adding a new SSH key to your GitHub account \- GitHub Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

```bash
$ ssh-keygen -t ed25519 -C "mail@example.com"
$ pbcopy < ~/.ssh/id_ed25519.pub
```
https://github.com/settings/keys から登録

# 実行

```
cd dotfiles
make init
```


# 設定の更新
Homebrew や Aqua でツールを手動でインストールした後は、次のコマンドで設定ファイルを最新化できます。

```bash
./update.sh
```
