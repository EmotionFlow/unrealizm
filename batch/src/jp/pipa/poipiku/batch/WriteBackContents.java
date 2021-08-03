package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.WriteBackFile;
import jp.pipa.poipiku.util.ImageUtil;
import jp.pipa.poipiku.util.Log;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class WriteBackContents extends Batch {
	static final int HOLD_HOURS = 36;
	static final String CONTENTS_ROOT = "/var/www/html/poipiku_img";
	static final String CACHE_DIR = "user_img00";
	static final String STORAGE_DIR = "user_img01";
	static List<String> COPY_FILE_NAMES;
	static final String SQL_UPDATE_CONTENT_FILENAME = "UPDATE contents_0000 SET file_name=replace(file_name," +
			"'" + CACHE_DIR + "','" + STORAGE_DIR + "'" +
			") WHERE content_id=?";
	static final String SQL_UPDATE_CONTENT_APPEND_FILENAME = "UPDATE contents_appends_0000 SET file_name=replace(file_name," +
			"'" + CACHE_DIR + "','" + STORAGE_DIR + "'" +
			") WHERE append_id=?";
	static {
		COPY_FILE_NAMES = new ArrayList<>();
		COPY_FILE_NAMES.add("");
		COPY_FILE_NAMES.add("_360.jpg");
		COPY_FILE_NAMES.add("_640.jpg");
	}

	public static void main(String[] args) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		// HDDへの移動対象を抽出
		List<WriteBackFile> moveTargets = WriteBackFile.select(WriteBackFile.Status.Created, HOLD_HOURS);

		Path storagePath = Paths.get(CONTENTS_ROOT, STORAGE_DIR);
		for (WriteBackFile writeBackFile: moveTargets) {
			writeBackFile.updateStatus(WriteBackFile.Status.Moving);

			// HDDへコピー（オリジナル、サムネ）
			for (String f : COPY_FILE_NAMES) {
				Path src = Paths.get(CONTENTS_ROOT, writeBackFile.path, f);
				try {
					Files.copy(src, storagePath.resolve(src.getFileName()));
				} catch (IOException e) {
					e.printStackTrace();
				}
			}

			// contents_0000 or contents_appendsを更新
			try {
				connection = dataSource.getConnection();
				if (writeBackFile.tableCode == WriteBackFile.TableCode.Contents) {
					statement = connection.prepareStatement(SQL_UPDATE_CONTENT_FILENAME);
				} else if (writeBackFile.tableCode == WriteBackFile.TableCode.ContentsAppends) {
					statement = connection.prepareStatement(SQL_UPDATE_CONTENT_APPEND_FILENAME);
				} else {
					continue;
				}
				statement.setInt(1, writeBackFile.rowId);
				statement.executeUpdate();
			} catch (SQLException e) {
				e.printStackTrace();
				Log.d(sql);
			} finally {
				if(statement!=null){try{statement.close();}catch(SQLException ignored){}}
				if(connection!=null){try{connection.close();}catch(SQLException ignored){}}
			}

			// write_back_filesを更新
			writeBackFile.updateStatus(WriteBackFile.Status.Moved);

			// SSD上のファイルを削除
			for (String f : COPY_FILE_NAMES) {
				Path src = Paths.get(CONTENTS_ROOT, writeBackFile.path, f);
				try {
					Files.delete(src);
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
