# 既存のpropertiesファイルを走査して、値が"x"の項目について、英語表記を元に自動翻訳するスクリプト
# 日本語・英語は手動で設定して、残りの言語を"x"としておき、本スクリプトで自動翻訳するという運用。

import requests
import json
import sys

import translate

SOURCE_LOCALE = 'en'

for target_locale in translate.TARGET_LOCALES:
    word = sys.argv[1]
    response = requests.post(translate.SCRIPT_URI, data={'text': word, 'source': SOURCE_LOCALE, 'target': translate.GOOGLE_TRANSLATE_LOCALES[target_locale]})
    resp = json.loads(response.text)
    trans_word = resp['text']
    print(target_locale)
    print(trans_word)
    
