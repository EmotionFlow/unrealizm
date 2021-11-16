package jp.pipa.poipiku;

import jp.pipa.poipiku.controller.Controller;
import jp.pipa.poipiku.controller.UpdateFileOrderC;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class UpdateFileOrderCTest {
	private final int uid = 9999999;
	private final int cid = 10000000;
	private final int aidBase = 20000000;
	private final int appendNum = 3;


	@BeforeEach
	void clearTable() throws Exception {
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;

		sql = "DELETE FROM contents_0000 WHERE user_id=" + uid;
		statement = connection.prepareStatement(sql);
		statement.executeUpdate();
		sql = "DELETE FROM contents_appends_0000 WHERE content_id=" + cid;
		statement = connection.prepareStatement(sql);
		statement.executeUpdate();
		sql = "DELETE FROM write_back_files WHERE user_id=" + uid;
		statement = connection.prepareStatement(sql);
		statement.executeUpdate();

		statement.close();
		connection.close();
	}

	private void setUpTables() throws SQLException {
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;

		sql = "INSERT INTO contents_0000(user_id, content_id, file_num, file_name) VALUES (?, ?, ?, ?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, uid);
		statement.setInt(2, cid);
		statement.setInt(3, appendNum + 1);
		statement.setString(4, "file-0");
		statement.executeUpdate();

		sql = "INSERT INTO write_back_files(table_code, row_id, path, user_id) VALUES (?, ?, ?, ?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, WriteBackFile.TableCode.Contents.getCode());
		statement.setInt(2, cid);
		statement.setString(3, "file-0");
		statement.setInt(4, uid);
		statement.executeUpdate();


		for (int i = 0; i< appendNum; i++) {
			sql = "INSERT INTO contents_appends_0000(append_id, content_id, file_name) VALUES (?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, aidBase + i);
			statement.setInt(2, cid);
			statement.setString(3, "append-file-" + i);
			statement.executeUpdate();

			sql = "INSERT INTO write_back_files(table_code, row_id, path, user_id) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, WriteBackFile.TableCode.ContentsAppends.getCode());
			statement.setInt(2, aidBase + i);
			statement.setString(3, "append-file-" + i);
			statement.setInt(4, uid);
			statement.executeUpdate();
		}

		statement.close();
		connection.close();

	}

	private String selectContentFile(int contentId) throws SQLException{
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		ResultSet resultSet;
		String sql;

		sql = "SELECT * FROM contents_0000 WHERE content_id=" + contentId;
		statement = connection.prepareStatement(sql);
		resultSet = statement.executeQuery();
		resultSet.next();

		return resultSet.getString("file_name");
	}

	private List<String> selectContentAppendFiles(int contentId) throws SQLException{
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		ResultSet resultSet;
		String sql;

		sql = "SELECT * FROM contents_appends_0000 WHERE content_id=" + contentId + " ORDER BY append_id";
		statement = connection.prepareStatement(sql);
		resultSet = statement.executeQuery();

		List<String> l = new ArrayList<>();
		while (resultSet.next()) {
			l.add(resultSet.getString("file_name"));
		}
		return l;
	}

	private List<String> selectWriteBackFiles(int userId, int tableCode) throws SQLException{
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		ResultSet resultSet;
		String sql;

		sql = "SELECT * FROM write_back_files WHERE table_code=" + tableCode + " and user_id=" + userId + " ORDER BY row_id";
		statement = connection.prepareStatement(sql);
		resultSet = statement.executeQuery();

		List<String> l = new ArrayList<>();
		while (resultSet.next()) {
			l.add(resultSet.getString("path"));
		}
		resultSet.close();
		statement.close();
		connection.close();
		return l;
	}

	private List<Integer> selectWriteBackStatus(int userId, int tableCode) throws SQLException{
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		ResultSet resultSet;
		String sql;

		sql = "SELECT * FROM write_back_files WHERE table_code=" + tableCode + " and user_id=" + userId + " ORDER BY row_id";
		statement = connection.prepareStatement(sql);
		resultSet = statement.executeQuery();

		List<Integer> l = new ArrayList<>();
		while (resultSet.next()) {
			l.add(resultSet.getInt("status"));
		}
		resultSet.close();
		statement.close();

		connection.close();
		return l;
	}


	//@Test
	public void testNotChanged() throws SQLException {
		setUpTables();
		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		c.newIdList = new int[]{0, aidBase + 0, aidBase + 1, aidBase + 2};

		Arrays.stream(c.newIdList).forEach(System.out::println);
		assertEquals(0, c.GetResults(null));
	}

	@Test
	public void testChanged01() throws SQLException {
		setUpTables();
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;

		sql = "UPDATE write_back_files SET status=2 WHERE table_code=1 AND row_id=" + (aidBase + 1);
		statement = connection.prepareStatement(sql);
		statement.executeUpdate();

		sql = "DELETE FROM write_back_files WHERE table_code=1 AND row_id=" + (aidBase + 2);
		statement = connection.prepareStatement(sql);
		statement.executeUpdate();

		statement.close();
		connection.close();

		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		c.newIdList = new int[]{0, aidBase + 2, aidBase + 0, aidBase + 1, };

		assertEquals(0, c.GetResults(null));

		assertEquals("file-0", selectContentFile(cid));

		List<String> l;
		l = selectContentAppendFiles(cid);
		assertEquals("append-file-2", l.get(0));
		assertEquals("append-file-0", l.get(1));
		assertEquals("append-file-1", l.get(2));

		assertEquals("file-0", selectWriteBackFiles(uid, 0).get(0));

		l = selectWriteBackFiles(uid, 1);
		//assertEquals("append-file-2", l.get(0));
		assertEquals("append-file-0", l.get(0));
		assertEquals("append-file-1", l.get(1));

		List<Integer> sts;
		sts = selectWriteBackStatus(uid, 0);
		assertEquals(0, sts.get(0));
		sts = selectWriteBackStatus(uid, 1);
		//assertEquals(0, sts.get(0));
		assertEquals(0, sts.get(0));
		assertEquals(2, sts.get(1));
	}

	@Test
	public void testChanged02() throws SQLException {
		setUpTables();
		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		c.newIdList = new int[]{aidBase + 2, aidBase + 0, aidBase + 1, 0};

		assertEquals(0, c.GetResults(null));

		assertEquals("append-file-2", selectContentFile(cid));

		List<String> l;
		l = selectContentAppendFiles(cid);
		assertEquals("append-file-0", l.get(0));
		assertEquals("append-file-1", l.get(1));
		assertEquals("file-0", l.get(2));

		assertEquals("append-file-2", selectWriteBackFiles(uid, 0).get(0));

		l = selectWriteBackFiles(uid, 1);
		assertEquals("append-file-0", l.get(0));
		assertEquals("append-file-1", l.get(1));
		assertEquals("file-0", l.get(2));
	}

	@Test
	public void testChanged03() throws SQLException {
		setUpTables();
		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		c.newIdList = new int[]{aidBase + 1, 0};

		assertEquals(0, c.GetResults(null));

		assertEquals("append-file-1", selectContentFile(cid));

		List<String> l;
		l = selectContentAppendFiles(cid);
		assertEquals(1, l.size());
		assertEquals("file-0", l.get(0));

		assertEquals("append-file-1", selectWriteBackFiles(uid, 0).get(0));

		l = selectWriteBackFiles(uid, 1);
		assertEquals(1, l.size());
		assertEquals("file-0", l.get(0));
	}


	@Test
	public void testChanged04() throws SQLException {
		setUpTables();
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;
		for (int i = appendNum; i< appendNum + 3; i++) {
			sql = "INSERT INTO contents_appends_0000(append_id, content_id, file_name) VALUES (?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, aidBase + i);
			statement.setInt(2, cid);
			statement.setString(3, "append-file-" + i);
			statement.executeUpdate();

			sql = "INSERT INTO write_back_files(table_code, row_id, path, user_id) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, WriteBackFile.TableCode.ContentsAppends.getCode());
			statement.setInt(2, aidBase + i);
			statement.setString(3, "append-file-" + i);
			statement.setInt(4, uid);
			statement.executeUpdate();
		}
		connection.close();

		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		c.newIdList = new int[]{aidBase + 3, aidBase + 4, aidBase + 5};

		assertEquals(0, c.GetResults(null));

		assertEquals("append-file-3", selectContentFile(cid));

		List<String> l;
		l = selectContentAppendFiles(cid);
		assertEquals(2, l.size());
		assertEquals("append-file-4", l.get(0));
		assertEquals("append-file-5", l.get(1));

		assertEquals("append-file-3", selectWriteBackFiles(uid, 0).get(0));

		l = selectWriteBackFiles(uid, 1);
		assertEquals(2, l.size());
		assertEquals("append-file-4", l.get(0));
		assertEquals("append-file-5", l.get(1));
	}

	@Test
	public void testChanged05() throws SQLException {
		setUpTables();
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;

		sql = "UPDATE write_back_files SET status=1 WHERE table_code=1 AND row_id=" + (aidBase + 1);
		statement = connection.prepareStatement(sql);
		statement.executeUpdate();


		statement.close();
		connection.close();

		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		c.newIdList = new int[]{0, aidBase + 2, aidBase + 0, aidBase + 1, };

		assertEquals(-1, c.GetResults(null));
		assertEquals(Controller.ErrorKind.DoRetry, c.errorKind);
	}

}
