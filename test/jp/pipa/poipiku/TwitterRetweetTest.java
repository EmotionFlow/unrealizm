package jp.pipa.poipiku;

import jp.pipa.poipiku.util.CTweet;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;

import static org.junit.jupiter.api.Assertions.*;

public class TwitterRetweetTest {
	private static final int testUserId = 88888888;

	@BeforeEach
	void clearTable() throws Exception {
		DataSource dataSource = (DataSource) DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		String sql = "TRUNCATE TABLE twitter_retweets";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.executeUpdate();
		statement.close();
		connection.close();
	}

	private CheckLogin createCheckLogin() {
		CheckLogin checkLogin = new CheckLogin();
		checkLogin.m_bLogin = true;
		checkLogin.m_nUserId = testUserId;
		return checkLogin;
	}

	@Test
	public void testRetweet() {
		CTweet cTweet = new CTweet();

		final int uid = 1851512;
		final int contentId = 5364011;
		final long twId = 1450004197412278274L;

		assertTrue(cTweet.GetResults(uid));

		assertEquals(CTweet.RETWEET_DONE, cTweet.ReTweet(contentId, twId));
		assertEquals(CTweet.RETWEET_ALREADY, cTweet.ReTweet(contentId, twId));


	}
}
