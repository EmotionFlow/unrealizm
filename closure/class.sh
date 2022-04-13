ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi

rsync -av --delete ../build/classes/jp/ ${WEB_CONTENT}WEB-INF/classes/jp/
#rsync -av --delete ../build/classes/com/ ${WEB_CONTENT}WEB-INF/classes/com/
