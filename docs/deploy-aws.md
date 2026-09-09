# AWS デプロイ手順（Docker / EC2 / RDS / Nginx / Let's Encrypt）

Rails 5.2 / Ruby 2.6.3 のアプリを、Docker 化して AWS 上で HTTPS 公開するまでの記録。
2026年に実施。ハマった点は末尾の「注意点・ハマったところ」にまとめてある。

## 構成

```
        ┌──────────── AWS (ap-northeast-1) ────────────┐
利用者 ──HTTPS──▶ Route 53 ──▶ EC2 (Ubuntu 24.04, t3.micro) ──▶ RDS (MySQL 8.0)
                              ├─ Nginx  : 80/443, SSL 終端, HTTP→HTTPS
                              │           Let's Encrypt (certbot, 自動更新)
                              └─ Docker : mymemo-web コンテナ (Puma :3000, 127.0.0.1 のみ)
                                          画像は名前付きボリュームに永続化
```

## 前提
- `Dockerfile` / `docker-compose.yml` / `.env.example` はリポジトリに同梱済み
- スキーマ投入は `db:schema:load`（`db:migrate` は不可。理由は末尾）
- リージョンは `ap-northeast-1`（東京）で統一

---

## Step 1: RDS（MySQL 8.0）

1. RDS → データベースの作成 → 標準作成 → MySQL 8.0
2. テンプレート「無料利用枠」、識別子 `mymemo-db`、`db.t3.micro`、ストレージ 20GB gp3（自動スケーリング off）
3. マスターユーザー名 `admin` / パスワードを控える
4. 接続: デフォルト VPC、**パブリックアクセス なし**、VPC セキュリティグループ新規 `mymemo-rds-sg`
5. 追加設定 → **最初のデータベース名は指定しなくてよい**（アプリ側の `db:create` で作る）
6. 拡張モニタリング off
7. 作成後、**エンドポイント**を控える（`xxxx.ap-northeast-1.rds.amazonaws.com`）

## Step 2: EC2

1. EC2 → インスタンスを起動 → 名前 `mymemo-web`
2. AMI: **Ubuntu Server 24.04 LTS (x86_64)**、タイプ `t3.micro`
3. キーペア新規作成（`.pem` をダウンロード）
4. ネットワーク: デフォルト VPC、パブリック IP 自動割り当て有効、セキュリティグループ新規:
   - SSH (22) ← マイ IP
   - HTTP (80) ← 0.0.0.0/0
   - HTTPS (443) ← 0.0.0.0/0
5. ストレージ: **30GB gp3**（Ubuntu 既定の 8GB では Docker ビルドで枯渇する）
6. 高度な詳細:
   - クレジット仕様: **標準**（無制限はバースト超過時に課金）
   - メタデータ: **IMDSv2 のみ**
   - ユーザーデータ: 下記スクリプトで Docker を自動インストール
7. 起動後、**Elastic IP** を割り当て → インスタンスに関連付け（固定 IP。以降 `<EIP>`）

### ユーザーデータ（初回起動時に Docker を導入）
```bash
#!/bin/bash
set -eux
apt-get update
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker ubuntu
systemctl enable --now docker
```

## Step 3: RDS ↔ EC2 の接続許可
RDS の `mymemo-rds-sg` → インバウンドルール → **MySQL/Aurora (3306) ← ソース = EC2 のセキュリティグループ**（IP ではなく SG を指定）。

---

## Step 4: アプリのデプロイ（EC2 上）

```bash
ssh -i mymemo-key.pem ubuntu@<EIP>

# Docker 導入確認（ユーザーデータ実行完了を待つ）
cloud-init status --wait
docker --version && docker compose version

# ★ t3.micro (1GB) は docker build が OOM で落ちるので swap 2GB を追加
sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# private リポジトリを GitHub PAT (Contents: Read) で clone
git clone https://<PAT>@github.com/mimika74/mymemo.git
cd mymemo

# .env を作成（.env.example を参考に）
nano .env
#   SECRET_KEY_BASE は下記で埋める:
sed -i "s|^SECRET_KEY_BASE=.*|SECRET_KEY_BASE=$(openssl rand -hex 64)|" .env

# ビルド → DB 作成 & スキーマ投入 → 起動
docker build -t mymemo-web .
docker run --rm --env-file .env mymemo-web bundle exec rails db:create db:schema:load
docker run -d --name mymemo-web --env-file .env \
  -p 127.0.0.1:3000:3000 \
  -v mymemo_uploads:/app/tmp/uploads \
  --restart unless-stopped \
  mymemo-web
```

- `-p 127.0.0.1:3000:3000` … コンテナを外部に晒さず、Nginx からのみ接続
- `-v mymemo_uploads:/app/tmp/uploads` … refile のアップロード画像を永続化（無いと再デプロイで消える）

## Step 5: Route 53（DNS）

1. ドメインの登録（`.com` は年 $14 前後）→ 登録者メール宛の **ICANN 確認メールを承認**
2. ホストゾーン → レコードを作成:

   | レコード名 | タイプ | 値 | TTL |
   |---|---|---|---|
   | **（空欄）** | A | `<EIP>` | 300 |
   | `www` | A | `<EIP>` | 300 |

   ※ apex（ドメインそのもの）のレコードは **名前を空欄にする**。`apex` などと入力しない。
3. 反映確認: `nslookup -type=A <ドメイン> 8.8.8.8` で `<EIP>` が返るまで待つ（初回 15〜60 分）

## Step 6: Nginx + Let's Encrypt（EC2 上）

```bash
sudo apt-get update && sudo apt-get install -y nginx

# 設定は 1 行で書ける（Nginx は改行を無視する）。<ドメイン> を実ドメインに置換
echo 'server { listen 80; server_name example.com www.example.com; client_max_body_size 20M; location / { proxy_pass http://127.0.0.1:3000; proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; } }' | sudo tee /etc/nginx/sites-available/mymemo

sudo ln -sf /etc/nginx/sites-available/mymemo /etc/nginx/sites-enabled/mymemo
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

# SSL（IDN の場合は -d に Punycode 形式 xn--... を渡す）
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com
#   メール入力 → 規約 A → HTTP→HTTPS リダイレクトは 2 を選択

sudo certbot renew --dry-run   # 自動更新の確認
```

## Step 7: 後片付け
- EC2 SG から一時的に開けていたポート 3000 のルールを削除（コンテナを `127.0.0.1` バインドにしたので実害はないが掃除）
- `https://<ドメイン>` で 新規登録 → ログイン → 画像アップロード まで確認

---

## 注意点・ハマったところ

### 1. `caching_sha2_password could not be loaded`
RDS MySQL 8.0 の既定認証は `caching_sha2_password`。一方コンテナの `mysql2` gem は
Debian の MariaDB Connector/C にリンクされており、このプラグインを持たないため接続に失敗する。
対処: `mysql:8.0` イメージのクライアントで RDS に繋ぎ、master ユーザーの認証方式を変更する。
```bash
docker run --rm -it mysql:8.0 mysql -h <RDSエンドポイント> -u admin -p
```
```sql
ALTER USER 'admin'@'%' IDENTIFIED WITH mysql_native_password BY '<同じパスワード>';
FLUSH PRIVILEGES;
```

### 2. `db:migrate` が最初から通らない
`db/migrate/20220329230221_drop_tables.rb` が、どのマイグレーションでも作られない
`genres` テーブルを `drop_table` するため、空の DB では必ず失敗する。
新規構築は **`db:schema:load`**（`db/schema.rb` が最新の正）を使う。以降の差分は `db:migrate`。

### 3. 日本語ドメイン（IDN）
certbot には Punycode 形式（`xn--...`）で `-d` を渡す。`nslookup` も Punycode で確認する。

### 4. Route 53 の apex レコード
「ドメインそのもの」の A レコードは、レコード名を **空欄** にして作る。
`apex` や `@` と入力すると `apex.example.com` というサブドメインができてしまう。

### 5. t3.micro のメモリ不足
1GB では `docker build`（nokogiri のネイティブビルド + アセットの JS 圧縮）が OOM で落ちる。
**swap 2GB を先に追加**する（Step 4 参照）。

### 6. `ruby:2.6.3` ベースイメージの APT
土台の Debian が EOL のため、APT リポジトリを `archive.debian.org` に向け直している
（`Dockerfile` 内で対応済み）。

### 7. アセットのプリコンパイル
`config.assets.compile = false`（本番）なので、`assets:precompile` は使い捨てコンテナで
実行するとイメージに入らない。**Dockerfile のビルド時**に実行している。

### 8. 画像アップロードの永続化
refile はローカルファイルシステム（`tmp/uploads`）に保存するため、`-v` で名前付きボリューム
にマウントしないと再デプロイのたびに消える。将来的には `refile-s3` で S3 に移すのが本筋。

---

## 運用メモ

- **更新デプロイ**:
  ```bash
  cd ~/mymemo && git pull
  docker build -t mymemo-web .
  docker rm -f mymemo-web
  docker run -d --name mymemo-web --env-file .env -p 127.0.0.1:3000:3000 \
    -v mymemo_uploads:/app/tmp/uploads --restart unless-stopped mymemo-web
  ```
- **ログ**: `docker logs -f mymemo-web`
- **証明書**: `sudo certbot renew --dry-run` で確認。自動更新は systemd timer 済み
- **DB バックアップ**: RDS コンソールで自動バックアップ設定を確認
- **メール**: `.env` の `SEND_MAIL` / `SEND_MAIL_PASSWORD` が空だと、パスワード再設定と
  お問い合わせフォームの送信は動かない（アプリの起動には影響しない）
- **コスト**: EC2 + RDS + EIP を 24 時間動かすと無料枠終了後は月 $15〜25 程度。
  使わない期間は EC2 / RDS を停止する運用も可
