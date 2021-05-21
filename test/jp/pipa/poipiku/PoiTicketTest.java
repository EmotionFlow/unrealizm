package jp.pipa.poipiku;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;

import static org.junit.jupiter.api.Assertions.*;

public class PoiTicketTest {
	private static final int testUserId = 88888888;

	@BeforeEach
	void clearTable() throws Exception {
		DataSource dataSource = (DataSource) DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		String sql = "DELETE FROM poi_tickets WHERE user_id=?";
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
	public void testBuy() {
		CheckLogin checkLogin = createCheckLogin();
		checkLogin.m_nPassportId = 0;

		PoiTicket ticket = new PoiTicket(checkLogin);
		ticket.isSkipSettlement = true;

		assertEquals(testUserId, ticket.userId);
		assertEquals(-1, ticket.amount);

		boolean buyResult = ticket.buy(1, 1, "", "", "", "");
		assertTrue(buyResult);

		buyResult = ticket.buy(1, 2, "", "", "", "");
		assertTrue(buyResult);
		assertEquals(testUserId, ticket.userId);
		assertEquals(3, ticket.amount);

		ticket = null;
		ticket = new PoiTicket(checkLogin);
		ticket.isSkipSettlement = true;
		assertEquals(testUserId, ticket.userId);
		assertEquals(3, ticket.amount);

		buyResult = ticket.buy(1, 0, "", "", "", "");
		assertFalse(buyResult);
		assertEquals(testUserId, ticket.userId);
		assertEquals(3, ticket.amount);

		buyResult = ticket.buy(1, -1, "", "", "", "");
		assertFalse(buyResult);
		assertEquals(testUserId, ticket.userId);
		assertEquals(3, ticket.amount);

		buyResult = ticket.buy(1, 4, "", "", "", "");
		assertTrue(buyResult);
		assertEquals(testUserId, ticket.userId);
		assertEquals(7, ticket.amount);

	}

	@Test
	public void testUse() {
		CheckLogin checkLogin = createCheckLogin();
		checkLogin.m_nPassportId = 0;

		PoiTicket ticket = new PoiTicket(checkLogin);
		ticket.isSkipSettlement = true;

		assertFalse(ticket.use());
		ticket.buy(1, 2, "", "", "", "");
		assertTrue(ticket.use());
		assertEquals(1, ticket.amount);

		ticket = new PoiTicket(checkLogin);
		ticket.isSkipSettlement = true;
		assertEquals(1, ticket.amount);
		assertTrue(ticket.use());
		assertEquals(0, ticket.amount);
		assertFalse(ticket.use());
		assertEquals(0, ticket.amount);

		ticket = new PoiTicket(checkLogin);
		ticket.isSkipSettlement = true;
		assertEquals(0, ticket.amount);
	}
}
