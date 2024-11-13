# fdでカレントディレクトリ以下のディレクトリを探してcdする
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git | fzf +m)
  cd "$dir"
}

# ghqのリポジトリリストからfzfしてcdする (find github)
fgh() {
  declare -r REPO_NAME="$(ghq list >/dev/null | fzf-tmux --reverse +m)"
  [[ -n "${REPO_NAME}" ]] && cd "$(ghq root)/${REPO_NAME}"
}

# GitHubのリモートの内容を現在のローカルで書き換え、initial commit 一つだけにする (git reset force)
grf() {
  # .gitディレクトリが存在するか確認
  if [ ! -d ".git" ]; then
    echo "Error: This command must be run from the project root (where .git directory is located)."
    return 1
  fi

  # 確認プロンプト
  echo "Warning: This command will delete all remote and local commits, replacing them with a single commit of the current local state."
  echo -n "Are you sure you want to proceed? (y/n): "
  read confirmation

  # y の場合のみ実行
  if [ "$confirmation" = "y" ]; then
    # 初期化の処理
    git checkout --orphan tmp
    git add .
    git commit -m "initial commit"
    git checkout -B main
    git push -f origin main
    git branch -d tmp
  else
    # y 以外が入力された場合
    echo "Operation aborted."
    return 1
  fi
}

# ローカルのmainブランチをリモートの最新状態に強制的に同期する (git pull force)
gpf() {
  # 確認プロンプト
  echo "Warning: This command will delete all local changes and reset the 'main' branch to match 'origin/main'."
  echo -n "Are you sure you want to proceed? (y/n): "
  read confirmation

  # y の場合のみ実行
  if [ "$confirmation" != "y" ]; then
    echo "Operation aborted."
    return 1
  fi

  # 現在のブランチがmainでない場合のみチェックアウト
  if [ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then
    git checkout main
  fi

  # もしコンフリクトしていたら、mergeの処理を中止
  if git merge HEAD &>/dev/null; then
    echo "No ongoing merge process."
  else
    echo "Aborting merge process..."
    git merge --abort
  fi

  # リモートの最新状態を取得
  git fetch origin main

  # リセットしてリモートの状態に同期
  git reset --hard origin/main

  echo "Local main branch has been reset to match origin/main."
}
