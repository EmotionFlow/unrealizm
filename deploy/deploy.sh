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

echo "デプロイしました"
