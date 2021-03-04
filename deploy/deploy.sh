#!/bin/bash
set -e

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi
# shellcheck disable=SC1090
source ${ENV_FILE}

echo "本番サーバ上のリポジトリでgit pullを実行します"
ssh ${HOST_ALIAS} 'bash -c "cd stg && ./pull.sh && cd poipiku && git branch && git log -1"'

read -p "こちらがHEADのcommitを本番サーバにデプロイします。よろしいですか？(y/N): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

ssh ${HOST_ALIAS} 'bash -c "cd stg && ./deploy_prod.sh -f"'

read -p "デプロイしました。tomcatを再起動しますか？(y/N): " yn
case "$yn" in [yY]*) ;; *) echo "tomcatを再起動せず終了しました。" ; exit ;; esac

ssh ${HOST_ALIAS} 'sudo systemctl restart tomcat.service'
echo "本番サーバのtomcatを再起動しました"
