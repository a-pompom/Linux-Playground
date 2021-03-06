# 概要

findコマンドの簡単な使い方をいくつかのサンプルを通して学んでいきます。

## ゴール

findコマンドの基本的な記法を理解し、目的のファイルを探したり、特定の条件を満たすファイルを操作する方法を身につけることを目指します。

## 目次

[toc]


## 構成

本記事では、演習形式でfindコマンドの使い方を見ていきます。最初にやりたいことを提示し、以降にてやりたいことを実現するコマンド例と、簡単な解説を述べます。
利用するファイルは[こちら](https://github.com/a-pompom/Linux-Playground/tree/main/search/1-find)を参照してください。

ファイルをダウンロードし、lsコマンドの実行結果が以下のようになっていれば、実際にコマンドを試すこともできます。

```bash
$ ls 
README.md html      init.sh   js        read.html tmp       tmp.html
```

## 1. 単純な検索

「login.html」ファイルのパスをfindコマンドで表示してください。

### 例・解説

```bash
$ find . -name login.html

# 出力
./html/login.html
```

---

まずは、findコマンドの基本構文を押さえておきましょう。

[参考](https://man7.org/linux/man-pages/man1/find.1.html)

> 記法: `find [starting-point...] [expression]`

それぞれが何を表しているのか理解することが、findの全体像を掴む上で大事です。

### starting-point

どのディレクトリを起点に探索するかを指定します。「...」とあるように、スペース区切りで複数のディレクトリを起点とすることもできます。
また、デフォルト値は「.(カレントディレクトリ)」となります。

### expression

expressionは少し複雑です。いくつか種類があるので、よく使うものに着目して見ていきましょう。

#### Actions

検索により見つかったファイルに対して、適用したい処理を指定します。見つけたファイルをただ表示するのに留まらず、古いファイルをまとめて退避させたりと、組み合わせ次第で多くの機能を実現できます。
デフォルトは「-print」が指定されており、単純に標準出力へ見つかったファイルパスを出力します。

#### Tests

ここでのテストは、与えられた条件をもとに、各ファイルに対して真偽値の判定をする、ぐらいのニュアンスを表しています。より具体的に今回の例に当てはめると、「-name」オプションは、探索対象のファイル名を1つ1つのファイルと比較し、真と評価される、つまりファイル名が一致したもののみを対象とします。
つまり、Testsに相当するオプションは、フィルタの役割を持っています。

---

以上を理解すれば、findコマンドの基本形がなぜこのような表記なのか、見えてくるはずです。

### コマンド再考

findコマンドの概要が見えてきたところで、最初に例で見たものが何を表しているのか、再度確認してみましょう。
`find . -name login.html`は、カレントディレクトリ(.)を起点に、ファイル名が「login.html」のファイルを探索する処理を実行します。


## 2. ファイル名をパターンで

拡張子が「html」のファイルをfindコマンドで表示してください。

### 例・解説

```bash
$ find . -name '*.html'

# 出力
./html/about.html
./html/index.html
./html/login.html
./tmp/todo.html
./tmp.html
```

---

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

エラーメッセージが表示されました。ざっくり要約すると、nameオプションの引数を引用符で囲むべきだ、といった旨が書かれています。

これは、findコマンドを実行する前に、シェルによりワイルドカードが展開されたことが原因です。展開されると、1つのファイル名を期待するnameオプションが複数のファイル名を受け取ってしまうことになります。
メッセージの通り引用符で囲めば問題は解決しますが、「なぜ引用符で囲む必要があるか」まで理解しておくと記法に引用符をつけるべきか否か正確に判断できるようになるはずです。

[参考](https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html)

### コマンド再考

`find . -name '*.html'`は、カレントディレクトリを起点に、拡張子が「html」のファイルを探索する処理を実行します。ワイルドカードは引用符で囲まれていることにより、シェルのパス展開ではなく、findコマンドによって処理されます。


## 3. 探して並べ替える

jsディレクトリ配下の拡張子が「js」のファイルをfindコマンドで探し、
更にアルファベット順で並べ替えた結果の上位3件のみを表示してください。

```bash
# 期待結果
./js/config.js
./js/index.js
./js/module.js
```

### 例・解説

```bash
$ find ./js -name '*.js' | sort | head -n 3
# 出力
./js/config.js
./js/index.js
./js/module.js
```

---

### パイプ

検索結果に対するfindコマンドのデフォルトの挙動は、「標準出力」へ表示することでした。これはつまり、パイプで他のコマンドと連結することで、検索結果を入力として扱えるようになります。
さまざまなコマンドと組み合わせれば、検索結果を更に絞り込んだり、より見やすく整形することもできます。
この問題では、並べ替えとフィルタを適用していました。

### コマンド再考

`find ./js -name '*.js' | sort | head -n 3`は、コマンドが長くなってきたので、少し分けて考えましょう。
まず、findコマンドは、カレントディレクトリ配下の「js」ディレクトリを起点に、拡張子が「js」のファイルを検索しています。

続いて、sortコマンドは検索結果を標準入力から受け取り、デフォルトの挙動によりアルファベット順にソートした結果を標準出力へ出力します。
そして、headコマンドはソート結果を標準入力から受け取り、「n」オプションによりリストの上位3件を標準出力へ出力します。


## 4. 古いファイルを探す

「tmp」ディレクトリ配下の更新日付が1週間以上古いファイルをfindコマンドで探してください。

### 例・解説

```bash
$ find ./tmp -mtime +6
# 出力
./tmp/_.js
./tmp/memo.txt
./tmp/old.js
```

findコマンドは、ファイル名だけでなく、ファイルの更新日時も検索条件に含めることができます。更新日時(modified time)は、「mtime」オプションで指定します。
mtimeオプションは指定方法が独特で、次のルールに従います。

* +n: n日前より古い
* n: n日前丁度
* -n: n日前より新しい

今回は、1週間以上前なので、「+6」を指定することで、7日以上前に更新されたものが対象となります。


## 5. 古いファイルは退避したい

「tmp」ディレクトリ配下の更新日付が1週間以上古いファイルをfindコマンドで探し、見つかったファイルを
「backup」ディレクトリへ移動させてください。


### 例・解説

```bash
find ./tmp -mtime +6 -exec mv {} ./backup \;
# 移動後
$ ls ./backup
_.js  memo.txt  old.j
```

新しく、「exec」オプションが出てきました。
execは、これまで見てきた「name, mtime」のような、どう検索するかを表すTestsではなく、検索結果をどう処理するかを表す「Actions」に属します。
ですので、オプションも一風変わって、`-exec command \;`、または`-exec command {} +`となっています。
何やら難しそうな表記に見えますが、意味を理解すれば中身が見えてくると思います。

execオプションの後には任意のコマンドが記述できます。
そして、`{}`は検索結果によって置き換わるプレースホルダで、`\;`は、コマンドの引数の区切り(ターミネータ)を表しています。
セミコロンがエスケープされているのは、シェルによってコマンドの区切りと解釈されるのを防ぐためです。

---

#### +との違いは何か

execオプションには二種類の指定方法がありました。両者の違いは、検索結果を使ってコマンドをどのように実行するかに表れます。

`\;`は、ループ処理のようなイメージで、検索結果を一件ずつプレースホルダに設定していきます。
一方、`+`は可能な限りコマンドの実行回数を減らすために、検索結果をプレースホルダにまとめて詰め込みます。例で記述したコマンドをechoに置き換えて見てみると、より違いが見えやすくなるかと思います。

```bash
# \;形式は1つずつ出力
$ find ./tmp -mtime +6 -exec echo {} \;       
./tmp/_.js
./tmp/memo.txt
./tmp/old.js
# +形式はまとめて出力
$ find ./tmp -mtime +6 -exec echo {} + 
./tmp/_.js ./tmp/memo.txt ./tmp/old.js
```


## まとめ

本記事では、findコマンドの簡単な例を見てきました。
基本を押さえてオプションと組み合わせていけば、ファイルをただ探す以上の便利なコマンドとなってくれるはずです。
