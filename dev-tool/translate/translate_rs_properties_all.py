# 既存のpropertiesファイルを走査して、新たに別の言語のpropertiesファイルを生成するスクリプト

import requests
import json

import translate

# 元の言語
SOURCE_LOCALE = 'en'

# ターゲットとする言語
#TARGET_LOCALES = ['ko', 'zh_Hans', 'zh_Hant', 'th', 'ru', 'vi', 'es']
TARGET_LOCALES = ['es']

PROP_FILE_DIR = '../../WebContent/WEB-INF/classes/'
BASE_NAME = 'rs'
PROP_EXT = '.properties'


for target_locale in TARGET_LOCALES:
    source_file = open(f'{PROP_FILE_DIR}{BASE_NAME}_{SOURCE_LOCALE}{PROP_EXT}', 'r')
    target_file = open(f'{PROP_FILE_DIR}{BASE_NAME}_{target_locale}{PROP_EXT}', 'w')
    line = source_file.readline()
    while line:
        print(line)
        if not line.strip():
            target_file.write("\n")
        elif line[0] == '#':
            target_file.write(line)
        else:
            splitted = line.split('=')
            if len(splitted)>2:
                s = "=".join(splitted[1:])
            else:
                s = splitted[1]
            try:
                word = s.strip().encode('ascii').decode('unicode-escape')
                print(word)
                response = requests.post(f"{translate.SCRIPT_URI}", data={'text': word, 'source': SOURCE_LOCALE, 'target': target_locale})
                resp = json.loads(response.text)
                trans_word = resp['text'].encode('unicode-escape').decode('ascii').replace('\\x', '\\u00')
                target_file.write(f"{splitted[0]}= {trans_word}\n")
            except UnicodeDecodeError:
                target_file.write(line)
        line = source_file.readline()
    target_file.close()
    source_file.close()
