package jp.pipa.poipiku.batch;

import org.apache.commons.mail.Email;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.SimpleEmail;

public class CommonsEmailSample extends Batch {

	public static void main(String[] args) {

		final String FROM_NAME = "unrealizm";
		final String FROM_ADDR = "info@unrealizm.com";
		final String SMTP_HOST = "localhost";

		try {
			Email email = new SimpleEmail();
			email.setHostName(SMTP_HOST);
			email.setFrom(FROM_ADDR, FROM_NAME);
			email.setSubject("日本語の件名");
			email.setMsg("日本語メールのテスト");
			email.addTo("ninomiya@pipa.jp");
			email.send();
		} catch (EmailException e) {
			e.printStackTrace();
		}
	}
}
