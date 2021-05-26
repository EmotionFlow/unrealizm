package jp.pipa.poipiku;

import javax.sql.DataSource;
import java.sql.*;

import org.apache.velocity.app.Velocity;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class RequestStartedNotifierTest {
	@BeforeEach
	void clearTable() throws Exception {
		Velocity.init("velocity.properties");
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		java.sql.Connection connection = dataSource.getConnection();
		String sql = "DELETE FROM info_lists WHERE info_type=5";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.executeUpdate();
		statement.close();

		sql = "UPDATE request_creators SET notified=0 WHERE user_id=1";
		statement = connection.prepareStatement(sql);
		statement.executeUpdate();
		statement.close();

	}

	@Test
	public void testNotify() {
		RequestStartedNotifier notifier = new RequestStartedNotifier();
		RequestCreator creator = new RequestCreator(1);
		assertEquals(RequestCreator.NOTIFIED_NOT_YET, creator.notified);
		assertTrue(notifier.notifyRequestStarted(1));

		RequestCreator creator2 = new RequestCreator(1);
		assertEquals(RequestCreator.NOTIFIED_STARTED, creator2.notified);
		assertFalse(notifier.notifyRequestStarted(1));
	}
}
