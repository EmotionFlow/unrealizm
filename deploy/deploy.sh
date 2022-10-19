#!/bin/bash
set -e

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi
# shellcheck disable=SC1090
source ${ENV_FILE}

echo "本番サーバでai-poipiku環境のpull,buildを実行します"
ssh ${HOST_ALIAS} 'bash -c "cd stg && ./ai-poipiku_pull.sh && ./ai-poipiku_build.sh && cd poipiku && git branch && git log -1"'

echo "."
read -p "このcommitをai-poipiku本番サーバにデプロイします。よろしいですか？(y/N): " yn
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac

ssh ${HOST_ALIAS} 'bash -c "cd stg && sudo ./ai-poipiku_deploy_prod.sh -f"'

git tag -a release-ai-$(date +%Y-%m-%d-%H-%M) -m "Release at $(date)"
git push --tags

echo "ai-poipikuをデプロイしました"
