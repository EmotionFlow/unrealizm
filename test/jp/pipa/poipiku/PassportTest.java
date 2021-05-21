package jp.pipa.poipiku;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

public class PassportTest {
	private static final int testUserId = 77777777;

	@BeforeEach
	void clearTable() throws Exception {
		DataSource dataSource = (DataSource) DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		String sql = "DELETE FROM passports WHERE user_id=?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, testUserId);
		statement.executeUpdate();
		statement.close();
	}

	private CheckLogin createCheckLogin() {
		CheckLogin checkLogin = new CheckLogin();
		checkLogin.m_bLogin = true;
		checkLogin.m_nUserId = testUserId;
		return checkLogin;
	}

	@Test
	public void testNew() {
		CheckLogin checkLogin = createCheckLogin();
		Passport passport = new Passport(checkLogin);
		assertEquals(testUserId, passport.userId);
		assertFalse(passport.exists);
		assertEquals(Passport.Status.NotYet, passport.status);
	}

	@Test
	public void testInsert() {
		CheckLogin checkLogin = createCheckLogin();
		Passport passport = new Passport(checkLogin);
		passport.courseId = 1;
		assertTrue(passport.insert());
		assertTrue(passport.exists);

		Passport passport2 = new Passport(checkLogin);
		assertTrue(passport2.exists);
	}

	@Test
	public void testActivate1() {
		CheckLogin checkLogin = createCheckLogin();
		Passport passport = new Passport(checkLogin);
		passport.courseId = 1;
		assertTrue(passport.insert());
		assertTrue(passport.activate());

		Passport passport2 = new Passport(checkLogin);
		assertNull(passport2.expiredAt);
	}
	
	@Test
	public void testUpdateExpiredEndOfThisMonth() {
		CheckLogin checkLogin = createCheckLogin();
		Passport passport = new Passport(checkLogin);
		passport.courseId = 1;
		assertTrue(passport.insert());
		assertTrue(passport.cancelSubscription());

		Passport passport2 = new Passport(checkLogin);
		LocalDateTime d =
				LocalDateTime.now()
						.plusMonths(1)
						.withDayOfMonth(1)
						.withHour(23)
						.withMinute(59)
						.withSecond(59)
						.withNano(0)
						.minusDays(1);
		assertTrue(Timestamp.valueOf(d).equals(passport2.expiredAt));
	}


}
