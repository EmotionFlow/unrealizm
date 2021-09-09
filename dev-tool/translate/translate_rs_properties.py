# 既存のpropertiesファイルを走査して、値が"x"の項目について、英語表記を元に自動翻訳するスクリプト
# 日本語・英語は手動で設定して、残りの言語を"x"としておき、本スクリプトで自動翻訳するという運用。

import requests
import json
import os

import translate

PROP_FILE_DIR = '../../WebContent/WEB-INF/classes/'
BASE_NAME = 'rs'
PROP_EXT = '.properties'
SOURCE_LOCALE = 'en'

SRC_DICT = {}
with open(f'{PROP_FILE_DIR}{BASE_NAME}_{SOURCE_LOCALE}{PROP_EXT}', 'r') as source_file:
    line = source_file.readline()
    while line:
        if not line.strip() or line[0] == '#':
            pass
        else:
            splitted = line.split('=')
            if len(splitted)>2:
                s = "=".join(splitted[1:])
            else:
                s = splitted[1]
            SRC_DICT[splitted[0].strip()] = s.strip()
        line = source_file.readline()


for target_locale in translate.TARGET_LOCALES:
    target_file_path = f'{PROP_FILE_DIR}{BASE_NAME}_{target_locale}{PROP_EXT}'
    new_file_path = f'{PROP_FILE_DIR}{BASE_NAME}_{target_locale}{PROP_EXT}.new'

    target_file = open(target_file_path, 'r')
    new_file = open(new_file_path, 'w')
    line = target_file.readline()
    while line:
        print(line)
        if not line.strip():
            new_file.write("\n")
        elif line[0] == '#':
            new_file.write(line)
        else:
            splitted = line.split('=')
            if len(splitted)>2:
                s = "=".join(splitted[1:])
            else:
                s = splitted[1]

            if s.strip() != 'x':
                new_file.write(line)
            else:
                try:
                    word = SRC_DICT[splitted[0].strip()].encode('ascii').decode('unicode-escape')
                    print(word)
                    response = requests.post(translate.SCRIPT_URI, data={'text': word, 'source': SOURCE_LOCALE, 'target': translate.GOOGLE_TRANSLATE_LOCALES[target_locale]})
                    print(response)
                    resp = json.loads(response.text)
                    trans_word = resp['text']
                    new_file.write(f"{splitted[0]}= {trans_word.encode('unicode-escape').decode('ascii')}\n")
                except UnicodeDecodeError:
                    new_file.write(line)
        line = target_file.readline()
    target_file.close()
    new_file.close()
    os.unlink(target_file_path)
    os.rename(new_file_path, target_file_path)
