ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi

source ${ENV_FILE}

DEPLOY_PATH="${WEB_CONTENT}WEB-INF/classes"


echo ${WEB_CONTENT}

rsync -av --delete ../bin/jp/ ${DEPLOY_PATH}/jp/
#rsync -av --delete ../build/classes/com/ ${WEB_CONTENT}WEB-INF/classes/com/
