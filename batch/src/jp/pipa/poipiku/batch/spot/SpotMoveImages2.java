package jp.pipa.poipiku.batch.spot;

import jp.pipa.poipiku.batch.Batch;
import jp.pipa.poipiku.batch.DBConnection;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.SlackNotifier;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;


public class SpotMoveImages2 extends Batch {
	static final boolean isDebug = false;
	static final String urlClearUserCacheF = "http://unrealizm.com/api/ClearUserCacheF.jsp?TOKEN=kkvjaw8per32qt3j28ycb4&ID=";

	private static final String WEBHOOK_URL = "https://hooks.slack.com/services/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";
	private static final SlackNotifier slackNotifier = new SlackNotifier(WEBHOOK_URL);

	private static final Path RSYNC_CMD_PATH = Paths.get(isDebug ? "/opt/local/bin/rsync" : "/usr/bin/rsync");
	private static final String FROM_IMG_PATH_FMT ="/var/www/html/ai_poipiku/user_img01/%09d";
	private static final String TO_IMG_PATH_FMT = "/var/www/html/ai_poipiku/user_img%02d/%09d";
	private static final Path DEV_NULL = Paths.get("/dev/null");

	static class Target {
		int userId;
		int contentId;
		int appendId;
		String fileName;

		public Target(int _userId, int _contentId, int _appendId, String _fileName) {
			userId = _userId;
			contentId = _contentId;
			appendId = _appendId;
			fileName = _fileName;
		}
	}

	private static void notifyError(String msg) {
		Log.d(msg);
		slackNotifier.notify(msg);
	}

	public static void main(String[] args) throws IOException {
		Log.d("SpotMoveImages2 batch start");

		final int h = LocalDateTime.now().getHour();
		if (h == 22 ||h == 23 || h == 0 || h == 1){
			Log.d("処理時間外");
			Log.d("SpotMoveImages batch end");
			return;
		}


		// HDDへの移動対象を抽出
		List<Target> targets = new ArrayList<>();
		try (Connection con = DBConnection.getDataSource().getConnection();
		     PreparedStatement st = con.prepareStatement("""
				select c.user_id, c.content_id, a.append_id, a.file_name
				from contents_appends_0000 a inner join contents_0000 c ON a.content_id = c.content_id
				where a.file_name like '%user_img01%' order by a.append_id limit 50;
				""")) {
			ResultSet r = st.executeQuery();
			while (r.next()) {
				targets.add(new Target(
						r.getInt(1), r.getInt(2), r.getInt(3), r.getString(4)
						));
			}
		} catch (SQLException throwables) {
			throwables.printStackTrace();
		}

		Log.d("moveTargets.size(): " + targets.size());
		if (targets.isEmpty()) return;


		String sql = "";
		OkHttpClient client = new OkHttpClient();

		for (Target target : targets) {
			Path contentFilePath = Paths.get("/var/www/html/ai_poipiku", target.fileName);
			Log.d("tgt: " + contentFilePath);
			// img01側にファイルが本当にあったら、それをコピーする。
			if (Files.exists(contentFilePath)){
				// userIdごとにuser_img02,03を振り分け
				final int userImageNumber = (target.userId % 2) + 2;
				Path copyTo = Paths.get(contentFilePath.toString().replace("img01", "img%02d".formatted(userImageNumber)));

				if (!Files.exists(copyTo.getParent())) {
					copyTo.getParent().toFile().mkdir();
				}

				try {
					Files.copy(contentFilePath, copyTo);
				} catch (FileAlreadyExistsException ex) {
					Log.d("FileAlreadyExists");
				}

				sql = """
					UPDATE contents_appends_0000
					SET file_name = replace(file_name, 'user_img01','user_img%02d')
					WHERE append_id=?;
					""".formatted(userImageNumber);

				try (Connection con = DBConnection.getDataSource().getConnection();
				     PreparedStatement st = con.prepareStatement(sql)
				) {
					st.setInt(1, target.appendId);
					st.executeUpdate();
				} catch (SQLException throwables) {
					throwables.printStackTrace();
				}
			} else {
				String strPath = contentFilePath.toString();
				int i = -1;
				// img02か03にすでにあるか？
				if (Files.exists(Paths.get(strPath.replace("img01", "img02")))){
					i = 2;
				}
				if (Files.exists(Paths.get(strPath.replace("img01", "img03")))){
					i = 3;
				}
				if (i > 1) {
					Log.d("img%02d にすでにあった".formatted(i));
					sql = """
						UPDATE contents_appends_0000
						SET file_name = replace(file_name, 'user_img01','user_img%02d')
						WHERE append_id=?;
						""".formatted(i);

					try (Connection con = DBConnection.getDataSource().getConnection();
					     PreparedStatement st = con.prepareStatement(sql)
					) {
						st.setInt(1, target.appendId);
						st.executeUpdate();
					} catch (SQLException throwables) {
						throwables.printStackTrace();
					}
				} else {
					Log.d("対処不可。何もしない。");
				}
			}
		}
		Log.d("SpotMoveImages2 batch end");
	}
}
