package jp.pipa.poipiku.util;

import jp.pipa.poipiku.Common;
import org.apache.commons.mail.Email;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.SimpleEmail;

public class EmailUtil {
	public static boolean send(final String toAddress, final String subject, final String body) {
		if (Common.isDevEnv()) {
			Log.d("開発環境のためメール送信をスキップします");
			Log.d("to: " + toAddress);
			Log.d("subject: " + subject);
			Log.d("body: " + body);
			return true;
		}
		final String FROM_NAME = "POIPIKU";
		final String FROM_ADDR = "info@poipiku.com";
		final String SMTP_HOST = "localhost";
		try {
			Email email = new SimpleEmail();
			email.setHostName(SMTP_HOST);
			email.setFrom(FROM_ADDR, FROM_NAME);
			email.setSubject(subject);
			email.setMsg(body);
			email.addTo(toAddress);
			email.send();
		} catch (EmailException e) {
			e.printStackTrace();
		}
		return true;
	}
}
