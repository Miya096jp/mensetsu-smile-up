# 面接スマイルup!

## 概要
面接での印象をUPさせたい就活生、転職者、求職者のためのAI印象診断アプリです。

## 特徴
- ユーザー登録なしで利用することができます
- 面接官の質問に1分間答えるだけでAIの印象診断と改善のアドバイスを受け取れます
- 個人情報は一切保存されません
- 診断に使用した写真はAIの学習に使用されません

## URL
https://mensetsu-smile-up.com/

## 機能
1. トップページで、**診断開始**ボタンをクリック
2. カメラチェックを行い、**次へ**ボタンをクリック
3. 「面接印象診断のやり方」画面にて、任意で「次回からこの説明を表示しない」をチェックし、**次へ**ボタンをクリック
4. 診断画面で**スタート**ボタンをクリック。面接官の質問が流れるので1分で答える。
5. 診断が終了したら、**診断結果を見る**ボタンをクリック
6. 診断結果が表示される。診断結果を読んだら**トップへ戻る**をクリック

### **カメラチェック画面**

<img width="630" height="495" alt="スクリーンショット 2026-07-08 13 38 16" src="https://github.com/user-attachments/assets/4a28f6a0-36b6-4944-b210-596f37680440" />



### **「面接印象診断のやり方」画面**

<img width="628" height="490" alt="スクリーンショット 2026-07-08 13 38 32" src="https://github.com/user-attachments/assets/ade4fee8-864e-4b0f-9788-cfe980624d07" />



### **診断画面**

<img width="627" height="493" alt="スクリーンショット 2026-07-08 13 38 46" src="https://github.com/user-attachments/assets/01c2558c-54d6-43f5-9d77-6e73d511c78c" />



### **診断結果画面**

<img width="624" height="490" alt="スクリーンショット 2026-07-08 13 39 07" src="https://github.com/user-attachments/assets/dffaaac7-95bd-4c0d-98a5-3551528e2409" />



## 動作環境
Docker desktop

## 技術スタック
- バックエンド: Ruby 4.0.5 / Rails 8.1.3
- フロントエンド: Hotwire (Turbo / Stimulus), Tailwind CSS (tailwindcss-rails)
- LLM: Gemini 2.5 Flash, RubyLLM
- テスト: RSpec
- コード品質: RuboCop, Biome
- CI/CD: GitHub Actions
- デプロイ: Docker、Kamal、さくらVPS、GHCR

## 開発環境
**事前準備:**
- Docker desktopのインストール
- Gemini APIキーの取得


1. リポジトリをclone
```bash
git clone https://github.com/Miya096jp/mensetsu-smile-up.git
```

2. リポジトリに移動
```bash
cd mensetsu-smile-up
```

2. .env.exampleをコピーして.envを作成しAPIキーを設定

```bash
cp .env.example .env
```

```text
# .env
GEMINI_API_KEY="<your api key>"
```


3. `docker compose build`でイメージをビルド

4. `docker compose up`でサーバー起動

5. `http://localhost:3000`にアクセス。

## Lint/Test

### Biome
**インストール** 

```bash
brew install biome
```
**実行**
```bash
biome check
```


### RuboCop
```bash
docker compose exec web bundle exec rubocop
```

### Test
```bash
docker compose exec web bundle exec rspec
```
