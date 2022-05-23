package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.WriteBackFile;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.SlackNotifier;
import org.apache.commons.mail.DefaultAuthenticator;
import org.apache.commons.mail.Email;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.SimpleEmail;
import org.apache.http.cookie.SM;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;


public class CommonsEmailSample extends Batch {

	public static void main(String[] args) {

		final String FROM_NAME = "POIPIKU";
		final String FROM_ADDR = "info@poipiku.com";
		final String SMTP_HOST = "localhost";

		Log.d("WriteBackContents batch start");
		try {
			Email email = new SimpleEmail();
			email.setHostName(SMTP_HOST);
			email.setFrom(FROM_ADDR);
			email.setSubject("TestMail");
			email.setMsg("This is a test mail ... :-)");
			email.addTo("ninomiya@pipa.jp");
			email.send();
		} catch (EmailException e) {
			e.printStackTrace();
		}
	}
}
