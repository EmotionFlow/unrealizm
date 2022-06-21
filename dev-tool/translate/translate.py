SCRIPT_URI = 'https://script.google.com/macros/s/AKfycbxBAsqbAeDfzmGJmd6hmUjhs-0vjHMuYYboOpR1OkvfNxl8J2foIDPdk3ZdzdTTC6O3/exec'

# 対象言語。rs_??.propertiesの??部分
TARGET_LOCALES = ['ko', 'zh_CN', 'zh_TW', 'th', 'ru', 'vi', 'es']

# TARGET_LOCALESとGoogle translate api の言語コードマップ。中国語が微妙に異なる。
GOOGLE_TRANSLATE_LOCALES = {'ko': 'ko', 'th': 'th', 'zh_CN': 'zh_Hans', 'zh_TW': 'zh_Hant', 'ru': 'ru', 'vi': 'vi', 'es': 'es'}
