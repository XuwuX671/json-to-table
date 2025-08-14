# **JSON to Table (json-to-table)**

このプロジェクトは **magifd2** と **Google の Gemini** の協同開発です。

[English README is here](README.md)

## **概要**

`json-to-table`は、[`magifd2/splunk-cli`](https://github.com/magifd2/splunk-cli) のコンパニオンツールとして開発された、Go言語製の汎用的なコマンドライン補助ツールです。JSON配列を整形されたテーブルとして出力します。標準入力からJSONデータを受け取るため、`splunk-cli ... | jq .results`のようなコマンドの出力を直接パイプして、人間に読みやすい形式や、レポートに貼り付けやすい画像形式に変換することを主な目的としています。

変更点の詳細については、[CHANGELOG](CHANGELOG.md)をご覧ください。

### **主な機能**

* **汎用的な入力**: 標準入力から、オブジェクトのJSON配列を受け取ります。  
* **多彩な出力形式**:  
  * text: ターミナル表示に適した、罫線付きのプレーンテキスト形式。  
  * md: GitHub Flavored Markdown形式のテーブル。  
  * png: **日本語対応の画像形式**。レポートやチャットでの共有に最適です。  
  * *   html: 基本的なスタイルが適用された自己完結型のHTMLファイル。
*   slack-block-kit: SlackのBlock Kit形式のJSON出力。Slackメッセージで直接利用するのに最適です。
* **柔軟なカラム順序指定**:  
  * --columns (-c) フラグで、表示するカラムとその順序を自由に指定できます。  
  * *（残りすべて）やprefix*（前方一致）といった強力なワイルドカードをサポートします。  
* **画像カスタマイズ**:  
  * --titleで画像にタイトルを追加できます。  
  * --font-sizeで文字の大きさを調整できます。  
* **自己完結型**: 日本語フォントをバイナリに埋め込んでいるため、外部ファイルへの依存がなく、単一の実行可能ファイルとして動作します。

## **インストール**

macOS、Windows、Linux向けのコンパイル済みバイナリは[リリースページ](https://github.com/magifd2/json-to-table/releases)から入手できます。

## **使い方**

### **基本的なパイプライン**

splunk-cliの出力をjqで絞り込み、その結果をjson-to-tableに渡すのが基本的な使い方です。

```bash
# splunk-cliの結果をテキスト形式のテーブルで表示  
splunk-cli run --silent -spl "..." | jq .results | json-to-table
```

### **出力形式の指定**

--formatフラグで出力形式を変更できます。

* **Markdown形式でファイルに出力:**  
  ```bash
  splunk-cli run ... | jq .results | json-to-table --format md -o report.md
  ```

* **PNG画像形式でファイルに出力:**  
  ```bash
  splunk-cli run ... | jq .results | json-to-table --format png --title "DNS Query Ranking" -o report.png
  ```

* **HTML形式でファイルに出力:**  
  ```bash
  splunk-cli run ... | jq .results | json-to-table --format html -o report.html
  ```

## **ソースからのビルド**

ソースからビルドするには、Goと`make`がインストールされている必要があります。

1.  **リポジトリをクローン:**
    ```bash
    git clone https://github.com/magifd2/json-to-table.git
    cd json-to-table
    ```

2.  **バイナリのビルド:**
    ```bash
    make build
    ```
    コンパイルされたバイナリは`dist`ディレクトリに配置されます。

3.  **リリース用パッケージ（ZIP）の作成:**  
    ```bash
    make package
    ```
    各OS向けのZIPアーカイブが`dist`ディレクトリに作成され、GitHubリリースにそのまま添付できます。

## **フラグ一覧**

* `--format`: 出力形式 (text, md, png, html, slack-block-kit, blocks)。デフォルトはtext。  
* `-o <file>`: 出力先のファイルパス。デフォルトは標準出力。  
* `--columns, -c <order>`: カラムの表示順序をカンマ区切りで指定。  
* `--title <text>`: PNG出力時のタイトル。  
* `--font-size <number>`: PNG出力時のフォントサイズ。デフォルトは12。
* `--version`: バージョン情報を表示して終了します。

## **謝辞**

このツールは **Mplus 1 Code** フォントを使用しています。このフォントは、SIL Open Font License, Version 1.1 のもとでライセンスされています。素晴らしいフォントを提供してくださった M+ FONTS Project に感謝します。

## **ライセンス**

このプロジェクトはMITライセンスのもとで公開されています。詳細は[LICENSE](LICENSE)ファイルをご覧ください。

## **作者**

[magifd2](https://github.com/magifd2)
