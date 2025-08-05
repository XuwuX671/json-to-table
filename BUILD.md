# **ビルド手順 (json-to-table)**

このドキュメントでは、json-to-table ツールをソースコードからビルドする方法について説明します。

## **1. 前提条件**

* **Go言語**: バージョン 1.18 以降がインストールされている必要があります。  
* **日本語フォント**: 画像出力機能で日本語を正しく表示するために、M PLUS 1 Codeフォントが必要です。  
  * [Google Fonts: M PLUS 1 Code](https://fonts.google.com/specimen/M+PLUS+1+Code) からフォントファミリーをダウンロードしてください。  
  * ダウンロードしたZIPを解凍し、MPLUS1Code-Regular.ttfを、json-to-table.goと同じ階層にfontsというディレクトリを作成して、その中に配置してください。

**ディレクトリ構造:**.  
├── fonts/  
│   └── MPLUS1Code-Regular.ttf  
└── json-to-table.go

## **2. ビルドスクリプトの使用 (推奨)**

macOS, Windows, Linux 向けのバイナリを一度に生成するためのビルドスクリプト build.sh を用意しています。

**手順:**

1. 実行権限の付与  
   ターミナルで以下のコマンドを実行し、スクリプトに実行権限を与えます。  
   chmod +x build.sh

2. スクリプトの実行  
   以下のコマンドを実行します。スクリプトは、必要な依存パッケージのダウンロードとビルドを自動的に行います。  
   ./build.sh

3. 成果物の確認  
   ビルドが成功すると、プロジェクトルートに dist_table ディレクトリが作成され、その中に各OS向けの実行可能ファイルが格納されます。  
   * dist_table/macos/json-to-table  
   * dist_table/windows/json-to-table.exe  
   * dist_table/linux/json-to-table

## **3. 手動でのビルド**

特定のプラットフォーム向けに手動でビルドする場合は、以下の手順に従ってください。

1. 依存関係の取得  
   ターミナルでソースコードのあるディレクトリに移動し、以下のコマンドを実行して必要な依存パッケージをダウンロードします。  
   # Goモジュールの初期化 (初回のみ)  
   go mod init json-to-table

   # 依存関係の整理  
   go mod tidy

2. コンパイル  
   ビルドしたいプラットフォームに応じて、以下のコマンドを実行します。  
   * **ローカル環境向け**: go build -o json-to-table  
   * **Windows (64-bit)**: GOOS=windows GOARCH=amd64 go build -o json-to-table.exe  
   * **Linux (64-bit)**: GOOS=linux GOARCH=amd64 go build -o json-to-table