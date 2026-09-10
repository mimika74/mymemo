# Mymemo

日々の出費を写真付きで記録して、買って得たものを後からカレンダーで視覚的に振り返る家計メモアプリ。

🔗 **本番環境: https://mymemorry.com**

## サイト概要
日々の出費を写真付きで記録して、買って得たものを後から視覚的にカレンダーで確認することができます。いつ何にお金を使ったか日記や手帳のように記録できるサイトです。

### サイトテーマ
使ったお金で何を得ているかをメモするサイト

### テーマを選んだ理由
身近にある家計簿や家計簿アプリは、支出・収支を項目別に細かく記載して、立てた予算に対して調整していくという手間があります。
ただそのような管理が面倒だったり苦手だったりする方も多いと思います。
一方で現金の出金・入金のみ入力していくタイプのアプリはシンプルで使いやすいと思いましたが、もう少し機能を追加して、写真をカレンダーに投稿できる機能をつけたいと思いました。
お金を使って消費するサイクルとして、出費→消費→「何に使ったか覚えていないが手持ちのお金は減った」というネガティブな流れから、出費→消費→記録（サイト利用）→「後から楽しんだ記憶を思い出す」という
ポジティブな流れが生まれると思います。特に消耗品・嗜好品は楽しむのは一瞬で使ってしまえば後に残りません。そういったものに多くお金を使う傾向のある方には更に役に立つと思います。
後からメモで再確認できれば、お金の管理ができるだけでなくあの時こんな食事したな等と思い出すことができて、
気持ちの面でより豊かになれると思い、ユーザーに喜ばれるのではないかと思います。


### ターゲットユーザ
家計の支出を管理したいと考える人、日記をつけたいと考えている人、またその両方

### 主な利用シーン
日々の支出状況のメモをするときに。支出内容を確認するときに。いつ何をしたか思い出したいときに

## 主な機能
- ユーザー登録・ログイン（Devise）
- 出費の登録・編集・削除（金額・メモ・日付・写真）
- カレンダー表示 / 一覧 / アルバム / 月次集計
- お気に入り登録
- お問い合わせフォーム

## 技術スタック

### アプリケーション
- Ruby 2.6.3 / Ruby on Rails 5.2
- MySQL（本番） / SQLite（開発）
- Devise（認証）, refile（画像アップロード。上流リポジトリが消滅したため `vendor/gems/refile` に同梱）, kaminari（ページネーション）
- Bootstrap 4 / jQuery / Font Awesome 5
- Puma

### 本番インフラ（AWS / 2026年）
- Docker コンテナ（`ruby:2.6.3-buster` ベース、アセットはビルド時にプリコンパイル）
- AWS EC2（Ubuntu 24.04, t3.micro）上でコンテナを実行
- AWS RDS for MySQL 8.0
- Nginx（リバースプロキシ + SSL 終端）
- Let's Encrypt（証明書、自動更新）
- Amazon Route 53（独自ドメイン）

構築手順とハマりどころ → [docs/deploy-aws.md](docs/deploy-aws.md)
Docker 化以前（2021年頃）の構成 → [docs/history-2021-deploy.md](docs/history-2021-deploy.md)

## ローカルでの起動

### Docker（本番と同じ構成で確認できる）
```bash
docker compose build
docker compose up -d db      # MySQL の初期化を 30 秒ほど待つ
docker compose run --rm web bundle exec rails db:schema:load
docker compose up
```
→ http://localhost:3000

> スキーマ投入は `db:migrate` ではなく **`db:schema:load`** を使う。
> 過去のマイグレーションを最初から再生できない（`db/schema.rb` が正）。

### 直接（開発モード / SQLite）
```bash
bundle install
bin/rails db:schema:load
bin/rails s
```

## 設計書
詳細設計　https://docs.google.com/spreadsheets/d/1KQ-m80WjnQPFBzbuV6UEt1Np-jbZOjp8/edit#gid=549108681
テーブル定義書　https://docs.google.com/spreadsheets/d/1jbmReY-UUXkR2qLMN_y-q7f1S8ueKu_7J8LteT_Dxx8/edit#gid=1398283818

## チャレンジ要素一覧

https://docs.google.com/spreadsheets/d/1gi4e4-OimhfHJIn34Zae_F6jn_Vpe3uyEVb55IoMzN0/edit?usp=sharing

## 開発環境（開発当初 / 2021年）
- 開発環境：AWS Cloud9（Linux ≒ CentOS 上のクラウドIDE）
- 言語：HTML, CSS, JavaScript, Ruby, SQL
- フレームワーク：Ruby on Rails
- JSライブラリ：jQuery

現在（2026年）はローカルが Windows 11 + Docker Desktop、本番が Ubuntu 24.04（EC2）上の
Docker コンテナ。詳細は「技術スタック」節を参照。

## 使用素材
- https://fontawesome.com/v5/search
