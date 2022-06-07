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
	private final int uidPoipass = 9999998;
	private final int cid = 10000000;
	private final int aidBase = 20000000;
	private final int appendNum = 3;


	@BeforeEach
	void clearTable() throws Exception {
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;

		sql = "DELETE FROM contents_0000 WHERE user_id IN (?, ?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, uid);
		statement.setInt(2, uidPoipass);
		statement.executeUpdate();
		sql = "DELETE FROM contents_appends_0000 WHERE content_id=" + cid;
		statement = connection.prepareStatement(sql);
		statement.executeUpdate();
		sql = "DELETE FROM write_back_files WHERE user_id IN (?, ?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, uid);
		statement.setInt(2, uidPoipass);
		statement.executeUpdate();
		sql = "DELETE FROM users_0000 WHERE user_id IN (?, ?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, uid);
		statement.setInt(2, uidPoipass);
		statement.executeUpdate();

		statement.close();
		connection.close();
	}

	private void setUpTables(int userId) throws SQLException {
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;

		sql = "INSERT INTO users_0000(user_id, password, nickname, passport_id) VALUES (?, ?, ?, ?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, userId);
		statement.setString(2, "pass");
		statement.setString(3, "testuser");
		statement.setInt(4, userId == uidPoipass ? Common.PASSPORT_ON : Common.PASSPORT_OFF);
		statement.executeUpdate();

		sql = "INSERT INTO contents_0000(user_id, content_id, file_num, file_name, file_size) VALUES (?, ?, ?, ?, ?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, userId);
		statement.setInt(2, cid);
		statement.setInt(3, appendNum + 1);
		statement.setString(4, "file-0");
		statement.setInt(5, 5 * 1024 * 1024);
		statement.executeUpdate();

		sql = "INSERT INTO write_back_files(table_code, row_id, path, user_id) VALUES (?, ?, ?, ?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, WriteBackFile.TableCode.Contents.getCode());
		statement.setInt(2, cid);
		statement.setString(3, "file-0");
		statement.setInt(4, userId);
		statement.executeUpdate();


		for (int i = 0; i< appendNum; i++) {
			sql = "INSERT INTO contents_appends_0000(append_id, content_id, file_name, file_size) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, aidBase + i);
			statement.setInt(2, cid);
			statement.setString(3, "append-file-" + i);
			statement.setInt(4, 5 * 1024 * 1024);
			statement.executeUpdate();

			sql = "INSERT INTO write_back_files(table_code, row_id, path, user_id) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, WriteBackFile.TableCode.ContentsAppends.getCode());
			statement.setInt(2, aidBase + i);
			statement.setString(3, "append-file-" + i);
			statement.setInt(4, userId);
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
		setUpTables(uid);
		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		c.newIdList = new int[]{0, aidBase + 0, aidBase + 1, aidBase + 2};

		Arrays.stream(c.newIdList).forEach(System.out::println);
		assertEquals(0, c.GetResults(null));
	}

	@Test
	// HDDに一部移動済の状態で並べ替える
	public void testChanged01() throws SQLException {
		setUpTables(uid);
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
	// 並べ替える
	public void testChanged02() throws SQLException {
		setUpTables(uid);
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
	// 一部画像を削除して並べ替える
	public void testChanged03() throws SQLException {
		setUpTables(uid);
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
	// 画像を全部削除して新しい画像を登録する
	public void testChanged04() throws SQLException {
		setUpTables(uid);
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;
		for (int i = appendNum; i< appendNum + 3; i++) {
			sql = "INSERT INTO contents_appends_0000(append_id, content_id, file_name, file_size) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, aidBase + i);
			statement.setInt(2, cid);
			statement.setString(3, "append-file-" + i);
			statement.setInt(4, 1 * 1024 * 1024);
			statement.executeUpdate();
		}
		connection.close();

		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		c.newIdList = new int[]{aidBase + 3, aidBase + 4, aidBase + 5};
		c.firstNewId = aidBase + 3;

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
	// HDDに移動中
	public void testChanged05() throws SQLException {
		setUpTables(uid);
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

	@Test
	// 画像を追加してサイズオーバーする
	public void testChanged06() throws SQLException {
		setUpTables(uid);
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;
		for (int i = appendNum; i< appendNum + 3; i++) {
			sql = "INSERT INTO contents_appends_0000(append_id, content_id, file_name, file_size) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, aidBase + i);
			statement.setInt(2, cid);
			statement.setString(3, "append-file-" + i);
			statement.setInt(4, 10 * 1024 * 1024 + (i == appendNum ? 1 : 0)); // 合計50MB+1B
			statement.executeUpdate();
		}
		connection.close();

		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		c.newIdList = new int[]{aidBase + 3, aidBase + 4, aidBase + 5, 0, aidBase + 0, aidBase + 2, aidBase + 1};
		c.firstNewId = aidBase + 3;

		assertEquals(Common.UPLOAD_FILE_TOTAL_ERROR, c.GetResults(null));

		assertEquals("file-0", selectContentFile(cid));

		List<String> l;
		l = selectContentAppendFiles(cid);
		assertEquals(3, l.size());
		assertEquals("append-file-0", l.get(0));
		assertEquals("append-file-1", l.get(1));
		assertEquals("append-file-2", l.get(2));

		assertEquals("file-0", selectWriteBackFiles(uid, 0).get(0));

		l = selectWriteBackFiles(uid, 1);
		assertEquals(3, l.size());
		assertEquals("append-file-0", l.get(0));
		assertEquals("append-file-1", l.get(1));
		assertEquals("append-file-2", l.get(2));
	}

	@Test
	// ポイパス会員なら合計50MBを超えても保存できる
	public void testChanged07() throws SQLException {
		setUpTables(uidPoipass);
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;
		for (int i = appendNum; i< appendNum + 3; i++) {
			sql = "INSERT INTO contents_appends_0000(append_id, content_id, file_name, file_size) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, aidBase + i);
			statement.setInt(2, cid);
			statement.setString(3, "append-file-" + i);
			statement.setInt(4, 20 * 1024 * 1024); // 合計80MB
			statement.executeUpdate();
		}
		connection.close();

		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uidPoipass;
		c.contentId = cid;
		c.newIdList = new int[]{aidBase + 3, aidBase + 4, 0, aidBase + 5, aidBase + 0, aidBase + 2, aidBase + 1};
		c.firstNewId = aidBase + 3;

		assertEquals(0, c.GetResults(null));

		assertEquals("append-file-3", selectContentFile(cid));

		List<String> l;
		l = selectContentAppendFiles(cid);
		assertEquals(6, l.size());
		assertEquals("append-file-4", l.get(0));
		assertEquals("file-0", l.get(1));
		assertEquals("append-file-5", l.get(2));
		assertEquals("append-file-0", l.get(3));
		assertEquals("append-file-2", l.get(4));
		assertEquals("append-file-1", l.get(5));

		assertEquals("append-file-3", selectWriteBackFiles(uidPoipass, 0).get(0));

		l = selectWriteBackFiles(uidPoipass, 1);
		assertEquals(6, l.size());
		assertEquals("append-file-4", l.get(0));
		assertEquals("file-0", l.get(1));
		assertEquals("append-file-5", l.get(2));
		assertEquals("append-file-0", l.get(3));
		assertEquals("append-file-2", l.get(4));
		assertEquals("append-file-1", l.get(5));
	}

	@Test
	// ポイパス会員でもサイズオーバー
	public void testChanged08() throws SQLException {
		setUpTables(uidPoipass);
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;
		for (int i = appendNum; i< appendNum + 3; i++) {
			sql = "INSERT INTO contents_appends_0000(append_id, content_id, file_name, file_size) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, aidBase + i);
			statement.setInt(2, cid);
			statement.setString(3, "append-file-" + i);
			statement.setInt(4, 30 * 1024 * 1024); // 合計110MB
			statement.executeUpdate();
		}
		connection.close();

		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uidPoipass;
		c.contentId = cid;
		c.newIdList = new int[]{aidBase + 3, aidBase + 4, 0, aidBase + 5, aidBase + 0, aidBase + 2, aidBase + 1};
		c.firstNewId = aidBase + 3;

		assertEquals(Common.UPLOAD_FILE_TOTAL_ERROR, c.GetResults(null));

		assertEquals("file-0", selectContentFile(cid));

		List<String> l;
		l = selectContentAppendFiles(cid);
		assertEquals(3, l.size());
		assertEquals("append-file-0", l.get(0));
		assertEquals("append-file-1", l.get(1));
		assertEquals("append-file-2", l.get(2));

		assertEquals("file-0", selectWriteBackFiles(uidPoipass, 0).get(0));

		l = selectWriteBackFiles(uidPoipass, 1);
		assertEquals(3, l.size());
		assertEquals("append-file-0", l.get(0));
		assertEquals("append-file-1", l.get(1));
		assertEquals("append-file-2", l.get(2));
	}

	@Test
	// 既存画像+追加画像の合計はサイズオーバーだが、同時に画像を削除することで制限サイズ内に収まるパターン
	public void testChanged09() throws SQLException {
		setUpTables(uid);
		DataSource dataSource = (DataSource)DBConnection.getDataSource();
		Connection connection = dataSource.getConnection();
		PreparedStatement statement;
		String sql;
		for (int i = appendNum; i< appendNum + 3; i++) {
			sql = "INSERT INTO contents_appends_0000(append_id, content_id, file_name, file_size) VALUES (?, ?, ?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, aidBase + i);
			statement.setInt(2, cid);
			statement.setString(3, "append-file-" + i);
			statement.setInt(4, 12 * 1024 * 1024); // 合計56MB
			statement.executeUpdate();
		}
		connection.close();

		UpdateFileOrderC c = new UpdateFileOrderC(null);
		c.userId = uid;
		c.contentId = cid;
		// 5MBのファイルを2つ削除して合計46MB
		c.newIdList = new int[]{aidBase + 3, aidBase + 1, aidBase + 4, aidBase + 5, aidBase + 2};
		c.firstNewId = aidBase + 3;

		assertEquals(0, c.GetResults(null));

		assertEquals("append-file-3", selectContentFile(cid));

		List<String> l;
		l = selectContentAppendFiles(cid);
		assertEquals(4, l.size());
		assertEquals("append-file-1", l.get(0));
		assertEquals("append-file-4", l.get(1));
		assertEquals("append-file-5", l.get(2));
		assertEquals("append-file-2", l.get(3));

		assertEquals("append-file-3", selectWriteBackFiles(uid, 0).get(0));

		l = selectWriteBackFiles(uid, 1);
		assertEquals(4, l.size());
		assertEquals("append-file-1", l.get(0));
		assertEquals("append-file-4", l.get(1));
		assertEquals("append-file-5", l.get(2));
		assertEquals("append-file-2", l.get(3));
	}
}
