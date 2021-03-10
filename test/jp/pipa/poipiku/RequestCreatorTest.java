package jp.pipa.poipiku;

import javax.sql.DataSource;
import java.sql.*;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import org.postgresql.ds.PGSimpleDataSource;

public class RequestCreatorTest {
	@BeforeEach
	void clearTable() throws Exception {
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		java.sql.Connection connection = dataSource.getConnection();
		String sql = "TRUNCATE TABLE request_creators";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.executeUpdate();
		statement.close();
	}

	@Test
	public void testNew() {
		RequestCreator requestCreator = new RequestCreator();
		assertNotNull(requestCreator);
		assertEquals(requestCreator.userId, -1);
	}

	@Test
	public void testNewWithCheckLogin() {
		CheckLogin checkLogin = new CheckLogin();
		checkLogin.m_bLogin = true;
		checkLogin.m_nUserId = 9999999;
		RequestCreator requestCreator = new RequestCreator(checkLogin);
		assertEquals(requestCreator.userId, checkLogin.m_nUserId);
	}

	@Test
	public void testInsert01() {
		RequestCreator requestCreator = new RequestCreator();
		int ret = requestCreator.tryInsert();
		assertEquals(ret, -1);
	}

	@Test
	public void testInsert02() {
		CheckLogin checkLogin = new CheckLogin();
		checkLogin.m_bLogin = true;
		checkLogin.m_nUserId = 8888888;
		RequestCreator requestCreator = new RequestCreator(checkLogin);
		int ret = requestCreator.tryInsert();
		assertEquals(ret, 8888888);
	}

	@Test
	public void testAllowMedia() {
		CheckLogin checkLogin = new CheckLogin();
		checkLogin.m_bLogin = true;
		checkLogin.m_nUserId = 123;
		RequestCreator requestCreator = new RequestCreator(checkLogin);

		// default
		assertTrue(requestCreator.allowIllust());
		assertFalse(requestCreator.allowNovel());

		requestCreator.updateAllowMedia(false, true);

		// updated
		RequestCreator requestCreator2 = new RequestCreator(checkLogin);
		assertFalse(requestCreator2.allowIllust());
		assertTrue(requestCreator2.allowNovel());
	}
}
