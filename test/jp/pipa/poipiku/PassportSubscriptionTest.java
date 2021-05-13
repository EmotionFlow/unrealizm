package jp.pipa.poipiku;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.*;

public class PassportSubscriptionTest {
	private static final int testUserId = 99999999;

	@BeforeEach
	void clearTable() throws Exception {
		DataSource dataSource = (DataSource) DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		String sql = "DELETE FROM passport_subscriptions WHERE user_id=?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, testUserId);
		statement.executeUpdate();

		sql = "DELETE FROM order_details WHERE order_id IN (SELECT id FROM orders WHERE customer_id=?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, testUserId);
		statement.executeUpdate();

		sql = "DELETE FROM orders WHERE customer_id=?";
		statement = connection.prepareStatement(sql);
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
	public void testBuyNew() {
		CheckLogin checkLogin = createCheckLogin();
		checkLogin.m_nPassportId = 0;

		PassportSubscription passport = new PassportSubscription(checkLogin);
		passport.isSkipSettlement = true;

		boolean buyResult = passport.buy(1, "", "", "", "");
		assertTrue(buyResult);

		buyResult = passport.buy(1, "", "", "", "");
		assertFalse(buyResult);
	}

	@Test
	public void testBuyExpired() throws SQLException {
		CheckLogin checkLogin = createCheckLogin();
		checkLogin.m_nPassportId = 0;

		PassportSubscription passport = new PassportSubscription(checkLogin);
		passport.isSkipSettlement = true;

		boolean buyResult = passport.buy(1, "", "", "", "");
		assertTrue(buyResult);

		DataSource dataSource = (DataSource) DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		String sql = "UPDATE passport_subscriptions SET cancel_datetime=current_timestamp - interval '1 minute' WHERE user_id=?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, testUserId);
		statement.executeUpdate();

		buyResult = passport.buy(1, "", "", "", "");
		assertTrue(buyResult);
	}

	@Test
	public void testBuyUnderContract() throws SQLException {
		CheckLogin checkLogin = createCheckLogin();
		checkLogin.m_nPassportId = 0;

		PassportSubscription passport = new PassportSubscription(checkLogin);
		passport.isSkipSettlement = true;

		boolean buyResult = passport.buy(1, "", "", "", "");
		assertTrue(buyResult);

		DataSource dataSource = (DataSource) DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		String sql = "UPDATE passports SET expired_at=current_timestamp + interval '1 minute' WHERE user_id=?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, testUserId);
		statement.executeUpdate();

		buyResult = passport.buy(1, "", "", "", "");
		assertFalse(buyResult);
	}
}
