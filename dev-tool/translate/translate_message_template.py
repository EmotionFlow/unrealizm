# 既存のmessage templateファイルを走査して、新たに別の言語のmessage templateファイルを生成するスクリプト

import requests
import json
import sys
import os
import glob
import translate

# 元の言語
SOURCE_LOCALE = 'en'

# ターゲットとする言語
#TARGET_LOCALES = ["ko", "zh_CN", "zh_TW", "th", "ru", "vi"]
#TARGET_LOCALES = ["ko"]

# clear
## rm -rf ../../WebContent/WEB-INF/message_templates/{ko,zh_CN,zh_TW,th,ru,vi}/register/twitter_follower


TEMPLATE_ROOT = '../../WebContent/WEB-INF/message_templates/'
TEMPLATE_PATH = sys.argv[1]
PROP_EXT = '.properties'

source_path = f"{TEMPLATE_ROOT}{SOURCE_LOCALE}/{TEMPLATE_PATH}/"

for target_locale in translate.TARGET_LOCALES:
    dest_path = f"{TEMPLATE_ROOT}{target_locale}/{TEMPLATE_PATH}/"
    if os.path.exists(dest_path):
        print(f"{dest_path} is exist")
        continue
    os.makedirs(dest_path)
    vm_files = glob.glob(source_path + "*.vm")
    for vm_file in vm_files:
        print(vm_file)
        f = open(vm_file, 'r')
        lines = f.readlines()
        f.close()
        trans_lines = []
        for line in lines:
            line = line.replace(f'#parse("{SOURCE_LOCALE}', f'#parse("{target_locale}')
            if line[0] == "#" or line[0] == '' or line == "\n":
                trans_lines.append(line)
            else:
                try:
                    word = line.encode('ascii').decode('unicode-escape')
                    #print(word)
                    response = requests.post(f"{translate.SCRIPT_URI}", data={'text': word, 'source': SOURCE_LOCALE, 'target': translate.GOOGLE_TRANSLATE_LOCALES[target_locale]})
                    resp = json.loads(response.text)
                    trans_word = resp['text']
                    trans_word = trans_word.replace("$ ", "$")
                    trans_lines.append(trans_word)
                except UnicodeDecodeError:
                    pass
                    # target_file.write(line)
        f = open(f"{dest_path}/{os.path.basename(vm_file)}", 'w')
        f.write("".join(trans_lines))
        f.close()
