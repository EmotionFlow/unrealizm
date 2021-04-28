package jp.pipa.poipiku;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class RequestTest {
	@BeforeEach
	void clearTable() throws Exception {
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		String sql = "TRUNCATE TABLE requests";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.executeUpdate();
		statement.close();
	}

	@Test
	public void testNew() {
		Request request = new Request();
		assertNotNull(request);
		assertEquals(request.id, -1);
	}

//	@Test
	public void testInsert() {
		CheckLogin checkLogin = new CheckLogin();
		checkLogin.m_bLogin = true;
		checkLogin.m_nUserId = 21808;
		RequestCreator requestCreator = new RequestCreator(checkLogin);
		requestCreator.tryInsert();
		requestCreator.updateStatus(RequestCreator.Status.Enabled);

		Request request = new Request();
		request.clientUserId = 2;
		request.creatorUserId = 21808;
		request.mediaId = 1;
		request.requestCategory = 1;
		request.amount = 10000;
		request.requestText = "aaaaaaaaaaaaaaaaaaa";
		assertTrue(request.insert());
		assertTrue(1 < request.id);
		assertEquals(2, request.clientUserId);
		assertEquals(21808, request.creatorUserId);
		assertEquals(10000, request.amount);
		assertEquals("aaaaaaaaaaaaaaaaaaa", request.requestText);

		Request request2 = new Request(request.id);
		assertEquals(2, request2.clientUserId);
		assertEquals(21808, request2.creatorUserId);
		assertEquals(10000, request2.amount);
		assertEquals("aaaaaaaaaaaaaaaaaaa", request2.requestText);

	}

	@Test
	public void testUpdateStatus() {
		CheckLogin checkLogin = new CheckLogin();
		checkLogin.m_bLogin = true;
		checkLogin.m_nUserId = 21808;
		RequestCreator requestCreator = new RequestCreator(checkLogin);
		requestCreator.tryInsert();
		requestCreator.updateStatus(RequestCreator.Status.Enabled);

		List<Request> requests = new ArrayList<>();
		for (int i=0; i<60; i++) {
			Request request = new Request();
			request.clientUserId = 2;
			request.creatorUserId = 21808;
			request.mediaId = 1;
			request.requestCategory = 1;
			request.amount = 10000;
			request.requestText = "aaaaaaaaaaaaaaaaaaa";
			request.licenseId = 10;
			assertTrue(request.insert());
			requests.add(request);
		}

		Request r;
		r = requests.get(0);
		assertTrue(r.updateStatus(Request.Status.WaitingApproval), Integer.toString(r.errorKind.getCode()));
		assertTrue(r.accept(), Integer.toString(r.errorKind.getCode()));
		assertTrue(r.deliver(1));

		r = requests.get(1);
		assertTrue(r.updateStatus(Request.Status.WaitingApproval), Integer.toString(r.errorKind.getCode()));
		assertTrue(r.cancel());

		r = requests.get(2);
		assertTrue(r.updateStatus(Request.Status.WaitingApproval), Integer.toString(r.errorKind.getCode()));
		assertTrue(r.accept());
		assertTrue(r.cancel());

		r = requests.get(4);
		assertTrue(r.updateStatus(Request.Status.WaitingApproval), Integer.toString(r.errorKind.getCode()));
		assertTrue(r.accept());

	}

}
