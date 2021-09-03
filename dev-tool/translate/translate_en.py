import requests
import json
import sys

from requests.api import post

import translate

print(translate.DEEPL_ENDPOINT)

post_data = {
        'DEEPL_AUTH_KEY': translate.DEEPL_AUTH_KEY,
        'text': sys.argv[1],
        'target_lang': 'US'
        }

print(post_data)

response = requests.post(
    translate.DEEPL_ENDPOINT,
    data=post_data
    )

print('resp: ' + response.text)

resp = json.loads(response.text)
trans_word = resp['translations'][0]['text']

print(trans_word)
