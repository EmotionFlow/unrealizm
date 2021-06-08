package jp.pipa.poipiku.util;

import okhttp3.*;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.json.simple.parser.ContainerFactory;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.io.IOException;

public final class ReCAPTCHA {
	public static final String SITE_KEY = "6Lfdhg8bAAAAALzgmqBkX41NyEQXhWYrOXCImNIp";
	private static final String SECRET_KEY = "6Lfdhg8bAAAAAD00lzcpNUbpGOCLeuLGv6AJg8kX";

	public static class VerifyResult {
		public boolean success = false;
		public String challenge_ts = "";
		public String hostname = "";
		public float score = -1.0f;
		public String action = "";
		public String toString() {
			return String.format("%b, %s, %s, %f, %s", success, challenge_ts, hostname, score, action);
		}
	}

	public static String getScriptTag(String onLoadFuncName) {
		return String.format(
				"<script src=\"https://www.google.com/recaptcha/api.js?render=%s&onload=%s\"></script>",
				SITE_KEY, onLoadFuncName);
	}
	public static VerifyResult verify(String token) {
		final String verifyUrl = String.format(
				"https://www.google.com/recaptcha/api/siteverify?secret=%s&response=%s",
				SECRET_KEY, token
		);
		VerifyResult verifyResult = new VerifyResult();
		OkHttpClient client = new OkHttpClient();
		try {
			Request request = new Request.Builder()
					.url(verifyUrl)
					.build();
			Response response = client.newCall(request).execute();
			JSONParser parser = new JSONParser();
			ContainerFactory containerFactory = new ContainerFactory() {
				@Override
				public Map createObjectContainer() {
					return new LinkedHashMap<>();
				}
				@Override
				public List creatArrayContainer() {
					return new LinkedList<>();
				}
			};

			Map<String, Object> map;
			try {
				map = (Map<String, Object>)parser.parse(response.body().string(), containerFactory);
				verifyResult.success = (Boolean) map.get("success");
				verifyResult.score = ((Number) map.get("score")).floatValue();
			} catch(ParseException pe) {
				Log.d("position: " + pe.getPosition());
				pe.printStackTrace();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return verifyResult;
	}
}
