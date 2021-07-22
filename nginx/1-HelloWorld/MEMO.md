## nginx起動メモ

```bash
$ ./startContainer.sh 
```

![image](https://user-images.githubusercontent.com/43694794/126630923-65dbbfd9-a286-480f-9f18-c0a6ed3aae5f.png)

Hello Worldは単純にnginxコンテナを起動するだけ。

## 設定ファイルやドキュメントルートを探る

なぜWelcomeページが表示されたのか、設定ファイルやドキュメントルートをたどって理解する。

### 設定ファイル

主要な設定は`/etc/nginx/nginx.conf`に書かれている。重要なところのみ抜粋してみると、

```bash
root@c149f4199123:/etc/nginx# cat nginx.conf 

# workerのユーザ名
user  nginx;

# サーバ全体の設定
http {
    # 中略...

    # conf.dディレクトリ配下の設定ファイルをhttpコンテキストへ展開
    include /etc/nginx/conf.d/*.conf;
}
```

更に、バーチャルホストごとの細かな設定も見てみると、以下のように書かれている。

```bash
root@c149f4199123:/etc/nginx# cat conf.d/default.conf 
server {
    # 80番ポートへのリクエストを受付
    listen       80;
    # nginxが起動しているサーバに対するホスト名
    server_name  localhost;

    # リクエストURLごとの設定を記述
    location / {
        # ドキュメントルート
        root   /usr/share/nginx/html;
        # indexファイルの優先順
        index  index.html index.htm;
    }
    # 中略...
}
```

ドキュメントルートを確認してみると、確かに画面で表示されたHTMLと対応していることが分かった。

```bash
root@c149f4199123:/etc/nginx# ls /usr/share/nginx/html
50x.html  index.html

root@c149f4199123:/etc/nginx# cat /usr/share/nginx/html/index.html 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
# 中略...

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```