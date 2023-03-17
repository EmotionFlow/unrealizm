package jp.pipa.poipiku.util;

import okhttp3.*;
import org.codehaus.jackson.map.ObjectMapper;

import java.io.IOException;

public final class SlackNotifier {
	private static class Message{
		public String text;
	}
	private final String webhookUrl;
	public SlackNotifier(final String _webhookUrl) {
		webhookUrl = _webhookUrl;
	}
	public void notify(String message) {
		Message msg = new Message();
		msg.text = message;

		ObjectMapper mapper = new ObjectMapper();

		OkHttpClient client = new OkHttpClient();
		MediaType MIMEType= MediaType.parse("application/json; charset=utf-8");
		RequestBody requestBody = null;
		try {
			requestBody = RequestBody.create (
					mapper.writeValueAsString(msg),
					MIMEType
			);
			Request request = new Request.Builder()
					.url(webhookUrl)
					.post(requestBody)
					.build();
			client.newCall(request).execute();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
