package jp.pipa.poipiku;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;

import static org.junit.jupiter.api.Assertions.*;

public class UserGroupTest {
	@BeforeEach
	void clearTable() throws Exception {
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		String sql = "TRUNCATE TABLE user_groups";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.executeUpdate();
		statement.close();
	}

	@Test
	public void testNew() {
		UserGroup userGroup = new UserGroup(1);
		assertNotNull(userGroup);
		assertEquals(userGroup.groupId, 0);
		assertEquals(userGroup.userId1, 0);
		assertEquals(userGroup.userId2, 0);
		assertEquals(userGroup.userId3, 0);
		assertEquals(userGroup.loginUserId, 1);
	}

	@Test
	public void testAdd() {
		UserGroup userGroup = new UserGroup(2);

		assertFalse(userGroup.add(0));

		assertTrue(userGroup.add(3));
		assertEquals(2, userGroup.userId1);
		assertEquals(3, userGroup.userId2);

		UserGroup userGroup2 = new UserGroup(2);
		assertEquals(2, userGroup2.loginUserId);
		assertEquals(2, userGroup2.userId1);
		assertEquals(3, userGroup2.userId2);
		assertEquals(0, userGroup2.userId3);

		UserGroup userGroup3 = new UserGroup(3);
		assertEquals(3, userGroup3.loginUserId);
		assertEquals(2, userGroup3.userId1);
		assertEquals(3, userGroup3.userId2);
		assertEquals(0, userGroup3.userId3);

		assertTrue(userGroup3.add(4));

		UserGroup userGroup4 = new UserGroup(2);
		assertEquals(2, userGroup4.loginUserId);
		assertEquals(2, userGroup4.userId1);
		assertEquals(3, userGroup4.userId2);
		assertEquals(4, userGroup4.userId3);

		assertTrue(userGroup4.add(2));
		assertTrue(userGroup4.add(3));
		assertTrue(userGroup4.add(4));

		UserGroup userGroup10 = new UserGroup(10);
		assertFalse(userGroup10.add(3));
		assertEquals(UserGroup.Error.AlreadyLinkedOthers, userGroup10.error);
	}

	@Test
	public void testRemove() {
		UserGroup userGroup = new UserGroup(2);
		assertTrue(userGroup.add(3));
		assertTrue(userGroup.add(4));

		assertFalse(userGroup.remove(2));
		assertTrue(userGroup.remove(3));

		assertEquals(2, userGroup.userId1);
		assertEquals(0, userGroup.userId2);
		assertEquals(4, userGroup.userId3);

		userGroup = new UserGroup(4);
		assertEquals(2, userGroup.userId1);
		assertEquals(0, userGroup.userId2);
		assertEquals(4, userGroup.userId3);

		assertTrue(userGroup.remove(2));
		assertEquals(0, userGroup.groupId);
		assertEquals(0, userGroup.userId1);
		assertEquals(0, userGroup.userId2);
		assertEquals(0, userGroup.userId3);

		userGroup = new UserGroup(4);
		assertEquals(0, userGroup.groupId);
		assertEquals(0, userGroup.userId1);
		assertEquals(0, userGroup.userId2);
		assertEquals(0, userGroup.userId3);
	}


}
