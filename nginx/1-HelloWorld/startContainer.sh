#!/bin/bash

# Dockerイメージのビルド
docker image build -t nginx:hello-world .

# Dockerコンテナの作成
docker container create -it --rm  --name hello-nginx -p 18080:80 nginx:hello-world

# Dockerコンテナの起動
docker container start hello-nginx
