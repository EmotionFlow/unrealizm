import requests

POIPIKU_URL = 'https://poipiku.com/'
USER_ID = 21808
LK = 'f2c7c07b1d7e32b8491fd5f62d9eef8da99458e724606fb85b0ac99696691f35'

description = 'ですく'

cookies = dict(POIPIKU_LK=LK)
postdata = {
    "DES": description,
    "UID": USER_ID,
    "OPTION_PUBLISH":				"true",
    "OPTION_NOT_TIME_LIMITED": 		"true",
    "TIME_LIMITED_START": 			"",
    "TIME_LIMITED_END": 			"",
    "OPTION_NOT_PUBLISH_NSFW": 		"true",
    "NSFW_VAL": 					"2",
    "OPTION_NO_CONDITIONAL_SHOW": 	"true",
    "SHOW_LIMIT_VAL": 				"6",
    "OPTION_NO_PASSWORD": 			"true",
    "PASSWORD_VAL": 				"",
    "OPTION_SHOW_FIRST": 			"false",
    "OPTION_TWEET": 				"false",
    "OPTION_TWEET_IMAGE": 			"true",
    "OPTION_TWITTER_CARD_THUMBNAIL": "true",
    "OPTION_CHEER_NG": 				"true",
    "OPTION_RECENT": 				"true",
    "NOVEL_DIRECTION_VAL": 			"0",
    "ED": 1,
    "GD": 1,
    "CAT": 1,
    "TAG": "",
    "RID": -1,
    "NOTE":	"",
}

r = requests.post(POIPIKU_URL + "f/UploadFileRefTwitterV2F.jsp", cookies=cookies, data=postdata, verify=False)

print(r.text)

# get content_id

# UploadFileFirstV2F

