# 概要

本演習では、findコマンドの簡単な使い方を学んでいきます。
間違いなどございましたら、IssueやPRを頂けるとうれしいです。

[参考](https://man7.org/linux/man-pages/man1/find.1.html)


# 問題

## 1. 単純な検索

「login.html」ファイルのパスをfindコマンドで表示してください。

<details>
<summary>例・解説</summary>

### 例

```bash
$ find . -name login.html
# 出力
./html/login.html
```

findの基本構文は`find [starting-point...] [expression]`となっています。
それぞれが何を表しているのか理解することが、findの全体像を掴む上で大事です。

### starting-point

こちらはシンプルに、どのディレクトリを起点に探索するか指定します。
「...」とあるようにスペース区切りで複数ディレクトリを起点とすることもできます。

また、デフォルト値は「.(カレントディレクトリ)」となります。

### expression

一方expressionは少し複雑です。
いくつか種類があるので、よく使うものに着目して見ていきましょう。

#### Actions

検索により見つかったファイルに対して、適用したい処理を指定します。
見つけたファイルをただ表示するのに留まらず、古いファイルをまとめて退避させたりと、組み合わせ次第で多くの機能を実現できます。

デフォルトは「-print」が指定されており、単純に標準出力へ見つかったファイルパスを出力します。

#### Tests

ここでのテストは、与えられた条件をもとに、各ファイルに対して真偽値の判定をする、ぐらいのニュアンスを表しています。
より具体的に今回の例に当てはめると、「-name」オプションは、探索対象のファイル名を1つ1つのファイルと比較し、真と評価される、つまりファイル名が一致した
もののみを対象とします。

つまり、Testsに相当するオプションは、フィルタの役割を持っています。

---

以上を理解すれば、findコマンドの基本形がなぜこのような表記なのか、見えてくるのではないかと思います。

### コマンド再考

findコマンドの概要が見えてきたところで、最初に例で見たものが何を表しているのか、再度確認してみましょう。

`find . -name login.html`は、カレントディレクトリ(.)を起点に、ファイル名が「login.html」のファイルを探索する処理を実行します。

</details>


## 2. ファイル名をパターンで

<details>
<summary>例・解説</summary>

拡張子が「html」のファイルをfindコマンドで表示してください。

### 例

```bash
$ find . -name '*.html'

# 出力
./html/about.html
./html/index.html
./html/login.html
./tmp/todo.html
./tmp.html
```

この問題で重要なのは、nameオプションの引数を引用符で囲んでいることです。
一見、囲まなくても動くように見えます。試してみましょう。

```bash
$ ls
# カレントディレクトリには複数のHTMLファイルが存在
README.md  backup  html  init.sh  js  read.html  tmp  tmp.html
# 引用符なしで実行
$ find . -name *.html
find: paths must precede expression: `tmp.html'
find: possible unquoted pattern after predicate `-name'?
```

エラーメッセージが表示されました。ざっくり要約すると、nameオプションの引数を引用符で囲むべきだ
といった旨が書かれています。

これは、findコマンドの実行前に、シェルによりワイルドカードが展開されたことが原因です。
展開されると、1つのファイル名を期待するnameオプションが複数のファイル名を受け取ってしまうことになります。
メッセージの通り引用符で囲めば問題は解決しますが、「なぜ引用符で囲む必要があるか」まで理解しておくと、
より正確に記憶できるのではないかと思います。

[参考](https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html)

### コマンド再考

`find . -name '*.html'`は、カレントディレクトリを起点に、拡張子が「html」のファイルを探索する処理を実行します。
ワイルドカードは引用符で囲まれていることにより、シェルのパス展開ではなく、findコマンドによって処理されます。

</details>


## 3. 探して並べ替える

jsディレクトリ配下の拡張子が「js」のファイルをfindコマンドで探し、
更にアルファベット順で並べ替えた結果の上位3件のみを表示してください。

```bash
# 期待結果
./js/config.js
./js/index.js
./js/module.js
```

<details>
<summary>例・解説</summary>

### 例

```bash
$ find ./js -name '*.js' | sort | head -n 3
# 出力
./js/config.js
./js/index.js
./js/module.js
```

### パイプ

検索結果に対するfindコマンドのデフォルトの挙動は、「標準出力」へ表示することでした。
これはつまり、パイプで他のコマンドと連結することで、検索結果を入力として扱えるようになります。
さまざまなコマンドと組み合わせれば、検索結果を更に絞り込んだり、より見やすく整形することもできます。

この問題では、並べ替えとフィルタを適用していました。

### コマンド再考

`find ./js -name '*.js' | sort | head -n 3`は、コマンドが長くなってきたので、少し分けて考えましょう。
まず、findコマンドは、カレントディレクトリ配下の「js」ディレクトリを起点に、拡張子が「js」のファイルを検索しています。

続いて、sortコマンドは、検索結果を標準入力から受け取り、デフォルトの挙動から、アルファベット順にソートした結果を標準出力へ出力します。
そして、headコマンドは、ソート結果を標準入力から受け取り、「n」オプションから、リストの上位3件を標準出力へ出力します。

</details>

## 4. 古いファイルを探す

「tmp」ディレクトリ配下の更新日付が1週間以上古いファイルをfindコマンドで探してください。

<details>
<summary>例・解説</summary>

### 例

```bash
$ find ./tmp -mtime +6
# 出力
./tmp/_.js
./tmp/memo.txt
./tmp/old.js
```

findコマンドは、ファイル名だけでなく、ファイルの更新日時も検索条件に含めることができます。
更新日時(modified time)は、「mtime」オプションで指定します。
mtimeオプションは指定方法が独特で、次のルールに従います。

* +n: n日前より古い
* n: n日前丁度
* -n: n日前より新しい

今回は、1週間以上前なので、「+6」を指定することで、7日以上前に更新されたものが対象となります。

また、「+」はnより大きくなるので、更に古い日付・「-」はnより小さくなるので、nより新しい日付、と捉えると
覚えやすくなるのではないかと思います。

### コマンド再考

</details>

## 5. 古いファイルは退避したい

「tmp」ディレクトリ配下の更新日付が1週間以上古いファイルをfindコマンドで探し、見つかったファイルを
「backup」ディレクトリへ移動させてください。

<details>
<summary>例・解説</summary>

### 例

```bash
find ./tmp -mtime +6 -exec mv {} ./backup \;
# 移動後
$ ls ./backup
_.js  memo.txt  old.j
```

新しく、「exec」オプションが出てきました。
execは、これまで見てきた「name, mtime」のような、どう検索するかを表すTestsではなく、
検索結果をどう処理するかを表す「Actions」に属します。

ですので、オプションも一風変わって、`-exec command ;`、または`-exec command {} +`となっています。
何やら難しそうな表記に見えますが、意味を理解すれば中身が見えてくると思います。

execオプションの後には任意のコマンドが記述できます。
そして、`{}`は検索結果によって置き換わるプレースホルダで、`\;`は、コマンドの引数の区切り(ターミネータ)を表しています。
セミコロンがエスケープされているのは、シェルによってコマンドの区切りと解釈されるのを防ぐためです。

---

#### +との違いは何か

execオプションには二種類の指定方法がありました。
両者の違いは、検索結果を使ってコマンドをどのように実行するかに表れます。

`\;`は、foreachのようなイメージで、検索結果を一件ずつプレースホルダに適用していきます。
一方、`+`は可能な限りコマンドの実行回数を減らすために、検索結果をプレースホルダにまとめて詰め込みます。
例で記述したコマンドをechoに置き換えて見てみると、より違いが見えやすくなるかと思います。

```bash
$ find ./tmp -mtime +6 -exec echo {} \;       
./tmp/_.js
./tmp/memo.txt
./tmp/old.js
$ find ./tmp -mtime +6 -exec echo {} + 
./tmp/_.js ./tmp/memo.txt ./tmp/old.js
```

### コマンド再考

</details>