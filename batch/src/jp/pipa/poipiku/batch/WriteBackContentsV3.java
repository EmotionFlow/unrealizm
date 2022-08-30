package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CContentAppend;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.WriteBackFile;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.SlackNotifier;

import java.io.IOException;
import java.nio.file.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;


public class WriteBackContentsV3 extends Batch {
	// 一度のバッチ実行でselectするファイルの最大数
	private static int getSelectLimit() {
		int selectLimit = 100;
		Calendar calendar = Calendar.getInstance();
		final int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
		final int hour = LocalTime.now().getHour();
		if (dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY) {
			selectLimit = 80;
		} else if (3 <= hour && hour <= 7){
			selectLimit = 130;
		}

		return selectLimit;
	}

	static List<String> TGT_FILE_NAMES;

	static final String SQL_UPDATE_CONTENT_FILENAME_FMT =
			"UPDATE contents_0000 SET file_name=replace(file_name, '" +
			Common.CONTENTS_CACHE_DIR + "', '%s') WHERE content_id=?";

	static final String SQL_UPDATE_CONTENT_APPEND_FILENAME_FMT =
			"UPDATE contents_appends_0000 SET file_name=replace(file_name, '" +
			Common.CONTENTS_CACHE_DIR + "', '%s') WHERE append_id=?";

	// Common.CONTENTS_STORAGE_DIR_ARY[0] (user_img01) には書き込まない
	static final String[] WRITE_STORAGE_PATH_ARY = {Common.CONTENTS_STORAGE_DIR_ARY[1], Common.CONTENTS_STORAGE_DIR_ARY[2]};

	static {
		TGT_FILE_NAMES = new ArrayList<>();
		TGT_FILE_NAMES.add("");
		TGT_FILE_NAMES.add("_360.jpg");
		TGT_FILE_NAMES.add("_640.jpg");
	}

	private static final String WEBHOOK_URL = "https://hooks.slack.com/services/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";
	private static final SlackNotifier slackNotifier = new SlackNotifier(WEBHOOK_URL);

	private static void notifyError(String msg) {
		Log.d(msg);
//		slackNotifier.notify(msg);
	}

	public static void main(String[] args) {
		Log.d("WriteBackContentsV3 batch start");

		final int h = LocalDateTime.now().getHour();
		if (h == 22 ||h == 23 || h == 0 || h == 1){
			Log.d("処理時間外");
			Log.d("WriteBackContents batch end");
			return;
		}

		// HDDへの移動対象を抽出(contents)
		List<CContent> targetContents = new ArrayList<>();
		String sql = """
            select * from contents_0000 where file_name like '%user_img00%' order by content_id limit ?
			""";
		try (
				Connection connection = DBConnection.getDataSource().getConnection();
				PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, getSelectLimit());
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()){
				targetContents.add(new CContent(resultSet));
			}
		} catch (SQLException throwables) {
			throwables.printStackTrace();
		}

		Log.d("targetContents.size(): " + targetContents.size());

		int pathIdx = 0;
		for (CContent content: targetContents) {
			Log.d("content_id %d".formatted(content.m_nContentId));

			pathIdx++;
			if (WRITE_STORAGE_PATH_ARY.length <= pathIdx) {
				pathIdx = 0;
			}

			Path destDir = Paths.get(
					Common.CONTENTS_ROOT,
					content.m_strFileName.replace(
							Common.CONTENTS_CACHE_DIR, WRITE_STORAGE_PATH_ARY[pathIdx])).getParent();

			// 移動先にディレクトリがなかったら作る
			if (!mkDir(destDir)) continue;

			boolean isSuccess;

			// HDDへコピー（オリジナル、サムネ）
			isSuccess = copyToHDD(content.m_strFileName, destDir, true);

			// contents_0000 or contents_appendsを更新
			isSuccess = updateContentsDB(pathIdx, content.m_nContentId, true);

			// SSD上のファイルを削除
			removeSSDFiles(content.m_strFileName);

			Log.d("content_id %d moved".formatted(content.m_nContentId));
		}

		// HDDへの移動対象を抽出(contents_appends)
		List<CContentAppend> targetContentsAppends = new ArrayList<>();
		sql = """
            select * from contents_appends_0000 where file_name like '%user_img00%' ORDER BY append_id limit ?
			""";
		try (
				Connection connection = DBConnection.getDataSource().getConnection();
				PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, getSelectLimit());
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()){
				targetContentsAppends.add(new CContentAppend(resultSet));
			}
		} catch (SQLException throwables) {
			throwables.printStackTrace();
		}

		Log.d("targetContentsAppends.size(): " + targetContentsAppends.size());

		pathIdx = 0;
		for (CContentAppend contentAppend: targetContentsAppends) {
			Log.d("append_id %d".formatted(contentAppend.m_nAppendId));

			pathIdx++;
			if (WRITE_STORAGE_PATH_ARY.length <= pathIdx) {
				pathIdx = 0;
			}

			Path destDir = Paths.get(
					Common.CONTENTS_ROOT,
					contentAppend.m_strFileName.replace(
							Common.CONTENTS_CACHE_DIR, WRITE_STORAGE_PATH_ARY[pathIdx])).getParent();

			// 移動先にディレクトリがなかったら作る
			if (!mkDir(destDir)) continue;

			boolean isSuccess;

			// HDDへコピー（オリジナル、サムネ）
			isSuccess = copyToHDD(contentAppend.m_strFileName, destDir, true);

			// contents_0000 or contents_appendsを更新
			isSuccess = updateContentsDB(pathIdx, contentAppend.m_nAppendId, false);

			// SSD上のファイルを削除
			removeSSDFiles(contentAppend.m_strFileName);

			Log.d("append_id %d moved".formatted(contentAppend.m_nAppendId));
		}

		Log.d("WriteBackContentsV3 batch end");
	}

	private static boolean mkDir(Path destDir) {
		if (!Files.exists(destDir)) {
			if (!destDir.toFile().mkdir()) {
				notifyError("(WriteBackContentsError)failed to mkdir: " + destDir);
				return false;
			}
		}
		return true;
	}

	private static boolean copyToHDD(String fileName, Path destDir, boolean isLogging) {
		boolean isSuccess = true;
		for (String f : TGT_FILE_NAMES) {
			Path src = Paths.get(Common.CONTENTS_ROOT, fileName + f);
			try {
				Files.copy(src, destDir.resolve(src.getFileName()), StandardCopyOption.REPLACE_EXISTING);
			} catch (NoSuchFileException noSuchFileException) {
				if (isLogging) Log.d("(WriteBackContentsError)Files.copy, NoSuchFileException :" + src);
				isSuccess = false;
			} catch (IOException e) {
				if (isLogging) notifyError("(WriteBackContentsError)Files.copy, IOException:" + src);
				e.printStackTrace();
				isSuccess = false;
			}
		}
		return isSuccess;
	}

	private static boolean removeSSDFiles(String fileName) {
		boolean isSuccess = true;
		for (String f : TGT_FILE_NAMES) {
			Path src = Paths.get(Common.CONTENTS_ROOT, fileName + f);
			try {
				Files.delete(src);
			} catch (IOException e) {
				notifyError("(WriteBackContentsError)SSD上のファイル削除に失敗:" + src);
				e.printStackTrace();
				isSuccess = false;
			}
		}
		return isSuccess;
	}

	private static boolean updateContentsDB(int pathIdx, int rowId, boolean isContent) {
		boolean isSuccess = true;
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = dataSource.getConnection();
			if (isContent) {
				sql = SQL_UPDATE_CONTENT_FILENAME_FMT.formatted(WRITE_STORAGE_PATH_ARY[pathIdx]);
				statement = connection.prepareStatement(sql);
			} else {
				sql = SQL_UPDATE_CONTENT_APPEND_FILENAME_FMT.formatted(WRITE_STORAGE_PATH_ARY[pathIdx]);
				statement = connection.prepareStatement(sql);
			}
			if (isSuccess){
				statement.setInt(1, rowId);
				statement.executeUpdate();
			}
		} catch (SQLException e) {
			Log.d(sql);
			e.printStackTrace();
			isSuccess = false;
		} finally {
			if(statement!=null){try{statement.close();}catch(SQLException ignored){}}
			if(connection!=null){try{connection.close();}catch(SQLException ignored){}}
		}
		return isSuccess;
	}
}
