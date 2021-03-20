package jp.pipa.poipiku.util;

import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailUtil {
	public static boolean send(final String toAddress, final String subject, final String body) {
		final String FROM_NAME = "POIPIKU";
		final String FROM_ADDR = "info@poipiku.com";
		final String SMTP_HOST = "localhost";
		try{
			Properties objSmtp = System.getProperties();
			objSmtp.put("mail.smtp.host", SMTP_HOST);
			objSmtp.put("mail.host", SMTP_HOST);
			objSmtp.put("mail.smtp.localhost", SMTP_HOST);
			Session objSession = Session.getDefaultInstance(objSmtp, null);
			MimeMessage objMime = new MimeMessage(objSession);
			objMime.setFrom(new InternetAddress(FROM_ADDR, FROM_NAME, "iso-2022-jp"));
			objMime.setRecipients(Message.RecipientType.TO, toAddress);
			objMime.setSubject(subject, "iso-2022-jp");
			objMime.setText(body, "iso-2022-jp");
			objMime.setHeader("Content-Type", "text/plain; charset=iso-2022-jp");
			objMime.setHeader("Content-Transfer-Encoding", "7bit");
			objMime.setSentDate(new java.util.Date());
			Transport.send(objMime);
		} catch (Exception ex) {
			ex.printStackTrace();
			Log.d("メールの送信に失敗しました");
			Log.d("to: " + toAddress);
			Log.d("subject: " + subject);
			Log.d("body: " + body);
			return false;
		}
		return true;
	}
}
