import json
import requests
from requests.auth import HTTPBasicAuth

UNREALIZM_URL = 'https://unrealizm.com/'


def upload_content(_user_id, _user_lk, _description, _prompt, _upload_file_path):
    cookies = dict(UNREALIZM_LK=_user_lk)
    post_data = {
        "DES": _description,
        "AI_PRMPT": _prompt,
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

    r = requests.post(UNREALIZM_URL + "f/UploadFileRefTwitterV2F.jsp",
                      cookies=cookies,
                      data=post_data,
                      verify=False,
                      auth=HTTPBasicAuth("ur", "west2929"))
    ref_tw_resp = json.loads(r.text)
    content_id = ref_tw_resp['content_id']
    print(f'content_id: {content_id}')

    # UploadFileFirstV2F
    post_data = {
        'UID': _user_id,
        'IID': content_id,
        'OID': 0,  # 0:公開, 1:新着避け公開, 2:非公開
        'REC': 0  # 0:新着避けない, 1:新着避けする
    }
    files = {
        'file1': open(_upload_file_path, 'rb')
    }
    r = requests.post(UNREALIZM_URL + "f/UploadFileFirstV2F.jsp",
                      cookies=cookies,
                      data=post_data,
                      files=files,
                      verify=False,
                      auth=HTTPBasicAuth("ur", "west2929"))
    print(r.json())


if __name__ == "__main__":
    user_id = 5
    user_lk = 'e5116cb31f5cab74eea3c56195aadf4728a87e4ba9532db2e813e0612d0c66d5'
    description_fmt = 'タイトル %d'
    prompt = 'ismail inceoglu painting of world war two, painting, line art, art concept for a book cover, trending on artstation, by greg manchess and by craig mullins and by kilian eng and by jake parker'
    upload_file_path_fmt = '/Users/nino/stable-diffusion/stable-diffusion/outputs/txt2img-samples/samples/%05d.png'

    for i in range(0, 50):
        upload_file_path = upload_file_path_fmt % i
        description = description_fmt % i
        print(upload_file_path)
        upload_content(user_id, user_lk, description, prompt, upload_file_path)
