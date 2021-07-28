#!/bin/bash
set -e

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi
# shellcheck disable=SC1090
source ${ENV_FILE}

echo "本番サーバでpull,buildを実行します"
ssh ${HOST_ALIAS} 'bash -c "cd stg && ./pull.sh && ./build_java_and_js.sh && cd poipiku && git branch && git log -1"'

echo "."
read -p "このcommitを本番サーバにデプロイします。よろしいですか？(y/N): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

ssh ${HOST_ALIAS} 'bash -c "cd stg && sudo ./deploy_prod.sh -f"'

git tag -a release-$(date +%Y-%m-%d-%H-%M) -m "Release at $(date)"
git push --tags

echo "デプロイしました"
