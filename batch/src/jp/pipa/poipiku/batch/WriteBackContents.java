package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.WriteBackFile;
import jp.pipa.poipiku.util.Log;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class WriteBackContents extends Batch {
	// SSD上にファイルを保持する時間
	static final int HOLD_IN_CACHE_HOURS = 36;

	// HDDへの移動後も、DBにレコードを保持しておく時間
	static final int HOLD_IN_RECORD_MOVED_HOURS = 180;

	static List<String> TGT_FILE_NAMES;
	static final String SQL_UPDATE_CONTENT_FILENAME =
			"UPDATE contents_0000 SET file_name=replace(file_name," +
			"'" + Common.CONTENTS_CACHE_DIR + "','" + Common.CONTENTS_STORAGE_DIR + "'" +
			") WHERE content_id=?";
	static final String SQL_UPDATE_CONTENT_APPEND_FILENAME =
			"UPDATE contents_appends_0000 SET file_name=replace(file_name," +
			"'" + Common.CONTENTS_CACHE_DIR + "','" + Common.CONTENTS_STORAGE_DIR + "'" +
			") WHERE append_id=?";

	static {
		TGT_FILE_NAMES = new ArrayList<>();
		TGT_FILE_NAMES.add("");
		TGT_FILE_NAMES.add("_360.jpg");
		TGT_FILE_NAMES.add("_640.jpg");
	}

	public static void main(String[] args) {
		if (!WriteBackFile.deleteByStatus(WriteBackFile.Status.Moved, HOLD_IN_RECORD_MOVED_HOURS)){
			Log.d("DBから「ステータス：移動済み」レコード削除に失敗");
		}

		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";

		// HDDへの移動対象を抽出
		List<WriteBackFile> moveTargets = WriteBackFile.select(WriteBackFile.Status.Created, HOLD_IN_CACHE_HOURS);

		for (WriteBackFile writeBackFile: moveTargets) {
			writeBackFile.updateStatus(WriteBackFile.Status.Moving);

			Path destDir = Paths.get(Common.CONTENTS_ROOT, writeBackFile.path.replace(Common.CONTENTS_CACHE_DIR, Common.CONTENTS_STORAGE_DIR)).getParent();

			// 移動先にディレクトリがなかったら作る
			if (!Files.exists(destDir)) {
				if (!destDir.toFile().mkdir()) {
					Log.d("failed to mkdir: " + destDir.toString());
					writeBackFile.updateStatus(WriteBackFile.Status.ErrorOccurred);
					continue;
				}
			}

			boolean isSuccess = true;
			// HDDへコピー（オリジナル、サムネ）
			for (String f : TGT_FILE_NAMES) {
				Path src = Paths.get(Common.CONTENTS_ROOT, writeBackFile.path + f);
				try {
					Files.copy(src, destDir.resolve(src.getFileName()));
				} catch (IOException e) {
					e.printStackTrace();
					isSuccess = false;
				}
			}

			if (!isSuccess) {
				Log.d("HDDへのコピーに失敗");
				writeBackFile.updateStatus(WriteBackFile.Status.ErrorOccurred);
				continue;
			}

			// contents_0000 or contents_appendsを更新
			try {
				connection = dataSource.getConnection();
				if (writeBackFile.tableCode == WriteBackFile.TableCode.Contents) {
					statement = connection.prepareStatement(SQL_UPDATE_CONTENT_FILENAME);
				} else if (writeBackFile.tableCode == WriteBackFile.TableCode.ContentsAppends) {
					statement = connection.prepareStatement(SQL_UPDATE_CONTENT_APPEND_FILENAME);
				} else {
					Log.d("想定外のtable_code: " + writeBackFile.tableCode.getCode());
					isSuccess = false;
				}
				statement.setInt(1, writeBackFile.rowId);
				statement.executeUpdate();
			} catch (SQLException e) {
				Log.d(sql);
				e.printStackTrace();
				isSuccess = false;
			} finally {
				if(statement!=null){try{statement.close();}catch(SQLException ignored){}}
				if(connection!=null){try{connection.close();}catch(SQLException ignored){}}
			}

			if (!isSuccess) {
				Log.d("DB更新に失敗");
				writeBackFile.updateStatus(WriteBackFile.Status.ErrorOccurred);
				continue;
			}

			// SSD上のファイルを削除
			for (String f : TGT_FILE_NAMES) {
				Path src = Paths.get(Common.CONTENTS_ROOT, writeBackFile.path + f);
				try {
					Files.delete(src);
				} catch (IOException e) {
					e.printStackTrace();
					isSuccess = false;
				}
			}

			if (!isSuccess) {
				Log.d("SSD上のファイル削除に失敗");
				writeBackFile.updateStatus(WriteBackFile.Status.ErrorOccurred);
				continue;
			}

			// write_back_filesを更新
			writeBackFile.updateStatus(WriteBackFile.Status.Moved);
		}
	}
}
