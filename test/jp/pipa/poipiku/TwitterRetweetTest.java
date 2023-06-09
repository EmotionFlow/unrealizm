package jp.pipa.poipiku;

import org.junit.jupiter.api.BeforeEach;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;


public class TwitterRetweetTest {
	//private static final int testUserId = 88888888;

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

	/*
	@Test
	public void testRetweet() {
		CTweet cTweet = new CTweet();

		final int uid = 1851512;
		final int contentId = 5364011;
		final long twId = 1450239888238858242L;

		assertTrue(cTweet.GetResults(uid));

		assertEquals(CTweet.RETWEET_DONE, cTweet.ReTweet(contentId, twId));
		assertEquals(CTweet.RETWEET_ALREADY, cTweet.ReTweet(contentId, twId));
	}
	*/
}
