# 2021年頃のデプロイ構成メモ(Docker化以前)

このアプリは2021年頃に作られ、当初は EC2 上に直接コードを配置する
「Capistrano 風」の手動デプロイを想定した構成になっていた。2026年に Docker 化した
際に該当設定を置き換えたため、当時の考え方と苦労したポイントをここに残しておく。
旧 `config/puma.rb` などの実物は git 履歴で読める(`git log -p --follow config/puma.rb`)。

## 当時の構成

### Puma(`config/puma.rb`)
- `bind "unix://#{Rails.root}/tmp/sockets/puma.sock"` — TCP ではなく Unix ドメイン
  ソケットで待ち受け、Nginx の `upstream` からソケット経由で接続させる方式。
- 本番のみ `daemonize` でバックグラウンド起動し、`tmp/pids/puma.pid` /
  `tmp/pids/puma.state` を出力。`pumactl`(または Capistrano)で restart する前提。
- `stdout_redirect(log/puma.log, log/puma-error.log, true)` でログをファイルに追記。

### 依存まわり
- 画像アップロードは `refile` + `refile-mini_magick`。本家 `refile/refile` が
  メンテ停止していたため、Rails 5 対応パッチの入った **フォーク `manfe/refile`**
  (commit `46b4178`)を `Gemfile` で直接指していた。`sinatra ~> 2.0.0.beta2` への
  依存があり、bundle の解決に手こずった。ImageMagick はサーバに手で入れる必要があった。
- 本番 DB は RDS(MySQL)。`config/database.yml` の production ブロックを手で書き換え、
  `mysql2` アダプタ + `utf8mb4`(絵文字対応)+ ENV 変数(`DB_HOST` 等)参照にした。
- `dotenv-rails` を group で囲わず読み込ませ、production でも `.env` を効かせていた。
- メール送信は Gmail SMTP(`ENV['SEND_MAIL']` / `ENV['SEND_MAIL_PASSWORD']`)。
- `SECRET_KEY_BASE` は credentials ではなく ENV で渡す運用。

### ハマったところ(記録)
- Nginx ↔ Puma のソケット指定・権限、`tmp/sockets` ディレクトリの作り忘れ。
- `daemonize` 時の pid / state ファイルの残骸で再起動が失敗する問題。
- `refile` のフォーク選定と sinatra beta 依存の解決。
- デプロイ時の `assets:precompile` と `RAILS_SERVE_STATIC_FILES` の扱い。

## Docker 化(2026)で変えた点

| 項目 | 以前 | 現在 |
|------|------|------|
| Puma | Unix ソケット + `daemonize` + ログファイル | 前景起動 + `tcp://0.0.0.0:3000` + STDOUT ログ |
| refile | `github: 'manfe/refile'`(のちに GitHub から消滅) | `vendor/gems/refile` に commit `46b4178` を同梱 |
| assets | デプロイ時に precompile | Docker イメージのビルド時に precompile |
| 実行環境 | EC2 に ruby/bundler/ImageMagick を直接構築 | `Dockerfile`(`ruby:2.6.3-buster` ベース) |

DB(RDS / MySQL / utf8mb4)、`.env` 運用、Gmail SMTP の考え方は当時のまま引き継いでいる。
