# 概要

本章では、Ubuntuのイメージを使い、コンテナに出たり入ったりしてみます。
ただ出入りするだけでは面白くないので、PHPのコンパイルを目指して、コンテナの中でも少し動き回ってみます。

また、標準入出力や端末の話が少し出てくるので、その辺りの基礎を固めておきたい方は、[参考書籍](https://www.sbcr.jp/product/4797386479/)をご参照ください。

## 目的

コンテナの出入りという表現では、何やら簡単そうな動作に思えます。
ですが、シンプルなコマンドでありながら、中々に複雑な動きをしており、混乱しやすい部分でもあるので、
段階を踏みながら、少しずつ理解することを目指します。


## Ubuntuイメージの取得

まずは復習がてら、Ubuntuイメージを取りに行ってみましょう。
[Docker Hub](https://hub.docker.com/_/ubuntu)でUbuntuのイメージを見つけたら、指定されたコマンドを実行します。

### タグの指定

以降の実践では、プログラムを動かすことが増えてくるので、イメージのバージョンの差異による意図しない挙動は防ぎたいところです。
ですので、前回少し触れたタグをイメージ名に付与したいと思います。
具体的には、`docker image pull ubuntu:タグ名`でタグ、すなわちイメージのバージョンを指定します。

検証時点では、下図の通り、20.04タグがlatestとなっています。何も指定しなければ20.04タグの付与されたイメージが取得対象となります。
これだけでは、将来的にバージョンが上がると、latestの指すものも変わってしまいます。
`ubuntu:20.04`のように、タグで明示することで、いつでも欲しいバージョンのイメージを手に入れることができます。

![image](https://user-images.githubusercontent.com/43694794/115165497-1714df00-a0e9-11eb-9f14-fb149428b416.png)

※ 厳密にはバージョン20.04のイメージも何度か差し替わっているので、本当に環境を一致させるには、
ダイジェストを指定するべきです。今回はタグにフォーカスするため、タグに絞った説明をしています。

---

補足が長くなってしまいましたが、今度こそイメージを取得します。

```bash
$ docker image pull ubuntu:20.04
# 出力例
20.04: Pulling from library/ubuntu
a70d879fa598: Pull complete 
c4394a92d1f8: Pull complete 
10e6159c56c0: Pull complete 
Digest: sha256:3c9c713e0979e9bd6061ed52ac1e9e1f246c9495aa063619d9d695fb8039aa1f
Status: Downloaded newer image for ubuntu:20.04
docker.io/library/ubuntu:20.04

# イメージを取得できたか確認
$ docker image ls
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       20.04     26b77e58432b   2 weeks ago   72.9MB
```

タグを指定することで、バージョン20.04のUbuntuイメージを手に入れることができました。


## コンテナをつくって動かす

hello-worldイメージのときと同じように、コンテナをつくってみましょう。
コンテナは、`docker container create`コマンドで作成することができます。

```bash
# Ubuntuの20.04タグが付与されたイメージをもとに、名前が「ubuntu_container」のコンテナを作成。
$ docker container create --name ubuntu_container ubuntu:20.04
# 出力例
5bc8d8515a10b6f4795acb52a60b8ffd5a5d14b72f8639fb5e3db462b938e4ac

# 作成できたか確認
$ docker container ls -a
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS    PORTS     NAMES
5bc8d8515a10   ubuntu:20.04   "/bin/bash"   5 seconds ago   Created             ubuntu_container
```

hello-worldコンテナのときから、いくつか変わったことがあります。
書式`docker container create [OPTIONS] IMAGE [COMMAND] [ARG...]`と照らし合わせて見ていきましょう。

まずは、コンテナの名前を覚えやすいものにするため、`--name`オプションで明記しました。
そして、イメージ名の後ろに`:タグ名`を指定しています。タグ名の指定を省略すると、latestタグが付与されたイメージのpullが始まってしまうので、
注意が必要です。

---

つくったコンテナを少しだけ動かしてみます。コンテナを起動するコマンドは、`docker container start <コンテナ名>`で記述します。
コンテナからの出力が見られるように、`-a`オプション(attach)もあわせて指定しておきます。

```bash
$ docker container start -a ubuntu_container
# 出力
ubuntu_container

# コンテナの状態を確認
$ docker container ls -a
# 状態が終了(Exited)となっている
CONTAINER ID   IMAGE          COMMAND       CREATED        STATUS                     PORTS     NAMES
5bc8d8515a10   ubuntu:20.04   "/bin/bash"   12 hours ago   Exited (0) 4 seconds ago             ubuntu_container
```

特に何も表示されないままコンテナが終了したようです。

### COMMANDフィールド

コンテナが起動したときに実行されるコマンドは、`docker container ls`で表示される一覧の「COMMANDフィールド」に書かれています。
書かれているのは、おなじみのbashシェルを表す`/bin/bash`です。

### 対話的なシェル

先ほど実行されたbashシェルは対話(interactive)モードで起動しなかったため、ルートプロセスであるbashが即座に終了し、
コンテナもExitedとなりました。
対話的でない動きは、シェルスクリプトを起動したときの様子をイメージすると、見えてくるかもしれません。

コンテナが起動した状態を保ち、コンテナ内のシェルを動かすには、対話モードでシェルを起動する必要がありそうです。
対話モードであることは、シェル自身のプロセスの標準入出力の向き先が端末を指していることを表します。
[参考](https://www.gnu.org/software/bash/manual/html_node/What-is-an-Interactive-Shell_003f.html)


## コンテナの中に入る

コンテナの中でシェルを対話モードで起動し、ローカルから操作することは、しばしば「コンテナの中に入る」と
表現されます。
コンテナの中に入ることができれば、より柔軟に、より楽しくコンテナを操作できるようになるので、中に入るための準備を整えていきましょう。

### tオプション

先ほども記載した通り、対話モードで動くシェルは、標準入出力が端末と結びついています。
となると、シェルと端末を結びつける設定を追加しなければなりません。
Dockerは、そんなときのために便利なオプションとして、`-t`オプション(tty)を用意してくれています。

`-t`オプションは、公式では`Allocate a pseudo-TTY`と表現されており、擬似端末を割り当てることを意味しています。
擬似端末が具体的に何を指しているかは、後ほどコンテナに入ったときに見ていきます。

#### 端末をつなげてみる

端末をつなげてもう一度コンテナを動かしてみましょう。このとき、一つ注意する点があります。

コンテナの端末や入出力を制御するオプションは、コンテナ作成時にのみ設定できます。
よって、端末をつなげてコンテナを動かすには、一度コンテナを破棄し、もう一度つくり直す必要があります。
これを踏まえて、一連のコマンドを見てみます。

```bash
# 最初に、Exitedとなったコンテナを削除
$ docker container rm ubuntu_container
ubuntu_container
# 「-t」オプションで端末を割り当て、再度コンテナを作成
$ docker container create -t --name ubuntu_container ubuntu:20.04
# 出力例
f5d1c83e7d71bbc0bd5d3678cc970596aca5d5f841e98dcbf5a8815d3134b760

# attachオプションを付与し、コンテナの標準出力を接続してコンテナを起動
$ docker container start -a ubuntu_container
# 出力例 プロンプトが表示される
root@f5d1c83e7d71:/# 
# 標準入力が繋がっておらず、ローカルからは操作できないので、Ctrl+Cで停止
^C

# コンテナの状態を確認すると、状態が「Up(起動中)」となっている
$ docker container ls -a
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS         PORTS     NAMES
f5d1c83e7d71   ubuntu:20.04   "/bin/bash"   2 minutes ago   Up 2 minutes             ubuntu_container
```

重要なのは、コンテナ起動後にプロンプトが表示されたことです。
`-t`オプションにより、bashプロセスへ端末が割り当てられ、対話モードで起動したからこそ、
プロンプトを見ることができるのです。

また、対話モードで起動したシェルは、`exit`コマンドで停止するまで動き続けるので、コンテナもあわせて
起動したままになっています。

---

しかし、まだ問題は残されています。プロンプトが表示されたとき、何かを入力しても、画面には何も表示されませんでした。
なぜこのような動きとなったか、読み解いていきましょう。

#### attachは何を接続しているのか

ポイントとなるのは、`docker container start`コマンドの`-a`オプション(attach)により接続されているものです。

> Attach STDOUT/STDERR and forward signals

と公式で書かれている通り、接続するのは、「標準出力・標準エラー出力」のみです。
どうやら、標準入力はattachしただけではコンテナとはつながらないようです。

これを踏まえて先ほどの動きを整理すると、

* `-t`オプションでコンテナの標準入出力と端末が繋がったことにより、シェルが対話モードで起動
* 対話モードで起動したシェルは、標準出力へプロンプトを出力
* `-a`オプションでコンテナの標準出力が接続されたので、ローカルの端末にプロンプトが表示された
* ただし、ローカルの標準入力はコンテナと繋がっていないので、コンテナ内のシェルは操作できない

といった流れとなります。


### itオプションでコンテナの中へ

残りの問題は、ローカルの標準入力がコンテナに繋がっていないことです。
こちらもDockerがオプションで用意しており、`-i`オプション(interactive)で解決できます。

`-t`オプションと同じように、コンテナをつくり直してから試してみます。

```bash
# 既存コンテナを停止→削除
$ docker container stop ubuntu_container
ubuntu_container
$ docker container rm ubuntu_container
ubuntu_container

# iオプション(interactive)を追加し、コンテナの標準入力も接続
$ docker container create -it --name ubuntu_container ubuntu:20.04
62b39f09670076c0f97c70477a49dd510a1de44cd26a86553641386d1ee85eaf
# attachしてコンテナを起動
$ docker container start -a ubuntu_container

# プロンプトは表示されたが、tオプションのみの場合と同様、標準入力は送信されない
root@62b39f096700:/# echo hello
^C
```

期待した結果とは異なる挙動をとりました。
この辺りは公式ドキュメントでもあまり解説されておらず、ハマったところなので、補足しておきます。
`docker container create`コマンドの`-i`オプションは、公式で

> Keep STDIN open even if not attached

と書かれています。
これは、公式でも深くは言及されていませんでしたが、常に標準入力を繋げる(attach)というよりは、
いつでも標準入力に繋げられる(open)ような挙動をとります。
※ 厳密には、`docker container inspect <コンテナ名>`で確認できる設定値の`Config.AttachStdin`がtrueとなります。

`docker container start`コマンドの`-a`オプションの説明とあわせて読むと、動きが見えやすくなると思います。
こちらは、

> Attach STDOUT/STDERR and forward signals

と書かれています。つまり、コンテナの標準入力は、`docker container create`コマンドで開かれている(open)だけで、
繋がって(attach)はいないようです。

---

やや直感には反しますが、実は`docker container start`コマンドにも`-i`オプションが存在し、
説明にも、`Attach container's STDIN`とあります。
ということで、一度コンテナを停止させ、起動コマンドに`-i`オプションを付与して再度動かしてみましょう。
今度こそ期待通りの結果が得られるはずです。

```bash
# 一度コンテナを停止
$ docker container stop ubuntu_container
ubuntu_container
# -aオプション(attach)で標準出力・標準エラー出力を・-iオプション(interactive)で標準入力を接続
$ docker container start -ai ubuntu_container

# コンテナと標準入力も繋がったことで、コンテナ上でシェルを操作できるようになった
root@62b39f096700:/# ls
bin  boot  dev  etc  home  lib  lib32  lib64  libx32  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

ついにコンテナの中に入ることができました。
`-it`オプションは軽く流されることの多いものではありますが、自身で書いて動かすものである以上、
なぜそのオプションが必要なのかは、最低限理解することを目指してみてください。

※ この辺りの話は公式ドキュメントにはほとんど書かれておらず、手探りで書いたものなので、間違いや、よい参考文献などございましたら、
教えて頂けるとうれしいです。

---

#### 補足 本当にコンテナの標準入出力と端末は繋がっているのか

`-t`オプションを指定することで端末が割り当てられる。公式に書かれているからそうなんだろう、
という理解でも問題はないですが、一応確かめておきたいところです。

せっかくコンテナの中に入れたので、少し探ってみましょう。

特定のプロセスの標準入出力の向き先を調べるには、プロセスのIDが必要となります。
bashシェルはルートプロセス(PID=1)として起動しているので、PIDは明白ですが、念のため確認しておきます。
そして、`/proc/[pid]/fd`ディレクトリ配下には、プロセスと繋がるファイルディスクリプタがシンボリックリンクとして
存在しています。
中でも、「0・1・2」はそれぞれ、標準入力・標準出力・標準エラー出力と対応しています。

[参考](https://man7.org/linux/man-pages/man5/proc.5.html)

ということは、標準入出力が指すシンボリックリンクの向き先が、端末を表すファイルであれば、
本当に端末に繋がっていると言えそうです。確かめてみましょう。

```bash
# psコマンドでbashプロセスのPIDを確認
root@62b39f096700:/# ps
  PID TTY          TIME CMD
    1 pts/0    00:00:00 bash
   13 pts/0    00:00:00 ps

# /proc/[pid]/fdには、プロセスと繋がるファイルディスクリプタが存在
root@62b39f096700:/# ls -al /proc/1/fd 
total 0
dr-x------ 2 root root  0 May  3 12:25 .
dr-xr-xr-x 9 root root  0 May  3 12:25 ..
# 標準入出力は端末に向けられている
lrwx------ 1 root root 64 May  3 12:25 0 -> /dev/pts/0
lrwx------ 1 root root 64 May  3 12:25 1 -> /dev/pts/0
lrwx------ 1 root root 64 May  3 12:25 2 -> /dev/pts/0
lrwx------ 1 root root 64 May  3 12:33 255 -> /dev/pts/0
```

`/dev/pts/0`のptsは、`pseudoterminal slave`の略で、擬似端末を表しています。
ということで、公式ドキュメントにあった通り、擬似端末が割り当てられていたことが確認できました。

[参考](https://linux.die.net/man/4/pts)

#### 補足: docker container runコマンド

書籍などでは、`docker run`あるいは、`docker container run`コマンドをよく見かけるかと思います。

このコマンドは、イメージが無ければpullし、コンテナの作成・起動まで一気に進めてくれるので、実際に使うときは、
非常に便利です。
今回の例も、`docker container run -it --name ubuntu_container ubuntu:20.04`と書くだけで、イメージの取得から
コンテナの起動までが一度で完了します。

しかし、一度にたくさんの操作が裏で動いており、その仕組みをまとめて理解するのは困難です。
まとめて便利にしてくれるコマンドを使わない手はないですが、何を効率化しているのか・裏で何をしているのか理解せずに使うのと、
理解して使うのとでは、雲泥の差があります。

最初はそうなんだ〜ぐらいの理解で流しておき、徐々に知識・経験を積み上げながら立ち向かっていくのがよいかと思います。

[参考](https://docs.docker.com/engine/reference/commandline/container_run/)


## PHPでHelloWorld

コンテナの中に入ってしまえば、後はUbuntuを操作するのと同じ感覚でシェルを動かすことができます。
より複雑な操作は次章以降に譲り、本章ではPHPのHello Worldプログラムを動作させるところまで頑張ってみましょう。

### PHPのインストール

今後コンテナの理解を深めていく上で、手軽にWebサーバが起動できるとコンテナの学習に集中できるので、
PHPを題材に扱っていきます。
PHPを使っていくためにも、環境を整えていきましょう。

※ PHP公式ドキュメントのインストール手順は情報がかなり古かったので、「PHP install」と検索し、より良さそうな手順があれば
そちらに従ってください。 今回はシンプルに考えられるよう、aptコマンドでインストールします。


```bash
# パッケージリストを更新
root@5a5e56181e7f:/home# apt update
Get:1 http://security.ubuntu.com/ubuntu focal-security InRelease [109 kB]
# ...中略

# php本体をインストール
root@5a5e56181e7f:/# apt install php
Reading package lists... Done

# タイムゾーンを決めるためのロケーションを設定
# 6. Asia, 79. Tokyoを選択
Please select the geographic area in which you live. Subsequent configuration questions will narrow this down by presenting a list of cities, representing
the time zones in which they are located.

# ...中略
done.
Processing triggers for php7.4-cli (7.4.3-4ubuntu2.4) ...
Processing triggers for libapache2-mod-php7.4 (7.4.3-4ubuntu2.4) ...
```

これで、インストールできたはずです。念のため、バージョンを表示するコマンドで確認してみましょう。

```bash
root@5a5e56181e7f:/# php --version

PHP 7.4.3 (cli) (built: Oct  6 2020 15:47:56) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.3, Copyright (c), by Zend Technologies
```

PHPをインストールできたことが確認できました。

### PHPでHello World

最後のステップとして、インストールしたPHPで世界にあいさつをしていきます。
軽く動かす程度なので、homeディレクトリ配下にechoコマンドで直接ファイルを出力するやり方を採用します。

次章以降は、プログラムもファイルへ記述していきます。

```bash
# 作業用ディレクトリとして、homeディレクトリへ移動
root@5a5e56181e7f:/# cd home
root@5a5e56181e7f:/home# 

# PHPでHello Worldするため、hello.phpファイルを作成
root@5a5e56181e7f:/home# echo "<?php" > hello.php
root@5a5e56181e7f:/home# echo "echo 'hello, PHP' . PHP_EOL;" >> hello.php

# つくったファイルの中身を確認
root@5a5e56181e7f:/home# cat ./hello.php 
<?php
echo 'hello, PHP' . PHP_EOL;

# phpコマンドに-fオプションを付与すると、ファイルを解析し、処理を実行してくれる
root@5a5e56181e7f:/home# php -f ./hello.php 
hello, PHP
```

無事、PHPを動かすことができました。
ここからファイルをローカルとやり取りしたり、ネットワークを繋げてWebサーバとして動かしたりと、
徐々にできることを増やしていきます。

とは言え、コンテナに入る準備で疲れ果てたことだと思いますので、一旦ここまでとします。

## まとめ

本章では、Dockerコンテナの中に入ることを目指し、必要なコマンド・オプションを掘り下げていきました。
コンテナの中に入ることは、コンテナ操作の基本として、何度も実践することになるので、実践/知識の確認を繰り返しながら、
理解を深めてみてください。