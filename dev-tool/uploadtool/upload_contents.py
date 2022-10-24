import json
import requests

POIPIKU_URL = 'https://unrealizm.com/'


def upload_content(_user_id, _user_lk, _description, _upload_file_path):
    cookies = dict(AI_POIPIKU_LK=_user_lk)
    post_data = {
        "DES": _description,
        "UID": _user_id,
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

    r = requests.post(POIPIKU_URL + "f/UploadFileRefTwitterV2F.jsp", cookies=cookies, data=post_data, verify=False)
    ref_tw_resp = json.loads(r.text)
    content_id = ref_tw_resp['content_id']
    print(f'content_id: {content_id}')

    # UploadFileFirstV2F
    post_data = {
        'UID': _user_id,
        'IID': content_id,
        'OID': 1,  # 0:公開, 1:新着避け公開, 2:非公開
        'REC': 1  # 0:新着避けない, 1:新着避けする
    }
    files = {
        'file1': open(_upload_file_path, 'rb')
    }
    r = requests.post(POIPIKU_URL + "f/UploadFileFirstV2F.jsp", cookies=cookies, data=post_data, files=files, verify=False)
    print(r.json())


if __name__ == "__main__":
    user_id = 6230955
    user_lk = 'a946273b3597d1eff47391ba1c71f30edfcd2d475d80d3e17e3dcc2e3d9ebd9b'
    description = 'ですく'
    upload_file_path = '/Users/nino/Desktop/Visual_SQL_JOINS_orig.jpeg'
    upload_content(user_id, user_lk, description, upload_file_path)
