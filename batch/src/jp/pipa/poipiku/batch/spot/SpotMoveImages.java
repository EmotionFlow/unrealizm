package jp.pipa.poipiku.batch.spot;

import jp.pipa.poipiku.batch.Batch;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.SlackNotifier;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Objects;


public class SpotMoveImages extends Batch {
	static final boolean isDebug = false;
	static final String URL_SCHEME = (isDebug)?"http":"https";
	static final String urlClearUserCacheF = URL_SCHEME + "://poipiku.com/api/ClearUserCacheF.jsp?TOKEN=kkvjaw8per32qt3j28ycb4&ID=";

	private static String getBandWidthLimit() {
		String bandWidthLimit = "3.0m"; // Byte per second
		Calendar calendar = Calendar.getInstance();
		final int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
		final int hour = LocalTime.now().getHour();
		if (dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY) {
			bandWidthLimit = "1.0m";
		} else if (3 <= hour && hour <= 7){
			bandWidthLimit = "6.0m";
		}

		return bandWidthLimit;
	}

	private static final String WEBHOOK_URL = "https://hooks.slack.com/services/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";
	private static final SlackNotifier slackNotifier = new SlackNotifier(WEBHOOK_URL);

	private static final Path RSYNC_CMD_PATH = Paths.get(isDebug ? "/opt/local/bin/rsync" : "/usr/bin/rsync");
	private static final String FROM_IMG_PATH_FMT ="/var/www/html/poipiku/user_img01/%09d";
	private static final String TO_IMG_PATH_FMT = "/var/www/html/poipiku/user_img%02d/";
	private static final Path DEV_NULL = Paths.get("/dev/null");

	private static void notifyError(String msg) {
		Log.d(msg);
		slackNotifier.notify(msg);
	}

	public static void main(String[] args) throws IOException {
		Log.d("SpotMoveImages batch start");

		final int h = LocalDateTime.now().getHour();
		if (h == 22 ||h == 23 || h == 0 || h == 1){
			Log.d("処理時間外");
			Log.d("SpotMoveImages batch end");
			return;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";

		// HDDへの移動対象を抽出
//		List<TmpUser> tmpUsers = TmpUser.selectByUserId(TmpUser.Status.Created, 21808);
		List<TmpUser> tmpUsers = TmpUser.select(TmpUser.Status.Created, 10);

		if (tmpUsers == null) {
			tmpUsers = new ArrayList<>();
		}
		Log.d("moveTargets.size(): " + tmpUsers.size());


		OkHttpClient client = new OkHttpClient();

		for (TmpUser user : tmpUsers) {
			user.updateStatus(TmpUser.Status.Moving);

			// img01側にuserIdのディレクトリがなかったら、コピー対象が存在しないのでスキップする。
			if (Files.notExists(Paths.get(FROM_IMG_PATH_FMT.formatted(user.userId)))){
				user.updateStatus(TmpUser.Status.Skipped);
				continue;
			}

			// rsyncコマンドを発行する
			List<String> cmd = new ArrayList<>();

			// userIdごとにuser_img02,03を振り分け
			final int userImageNumber = (user.userId % 2) + 2;

			cmd.add(RSYNC_CMD_PATH.toString());
			cmd.add("-av");
			cmd.add("--bwlimit=" + getBandWidthLimit());
			cmd.add(FROM_IMG_PATH_FMT.formatted(user.userId));
			cmd.add(TO_IMG_PATH_FMT.formatted(userImageNumber));
			int exitCode = runExternalCommand(cmd, null);

			// エラー処理
			if (exitCode != 0) {
				notifyError("rsync error (uid, exitCode): %d, %d".formatted(user.userId, exitCode));
				user.updateStatus(TmpUser.Status.ErrorOccurred);
				break;
			}

			// DBレコードを更新する
			boolean isDbErr = false;
			try {
				connection = dataSource.getConnection();

				connection.setAutoCommit(false);

				sql = """
				UPDATE contents_0000
				SET file_name = replace(file_name, 'user_img01','user_img%02d')
				WHERE user_id=? AND file_name LIKE '/user_img01%%';
				""".formatted(userImageNumber);

				statement = connection.prepareStatement(sql);
				statement.setInt(1, user.userId);
				statement.executeUpdate();

				sql = """
				UPDATE contents_appends_0000
				SET file_name = replace(file_name, 'user_img01','user_img%02d')
				WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)
				AND file_name LIKE '/user_img01%%';
				""".formatted(userImageNumber);

				statement = connection.prepareStatement(sql);
				statement.setInt(1, user.userId);
				statement.executeUpdate();

				sql = """
				UPDATE users_0000
				SET file_name = replace(file_name, 'user_img01','user_img%02d'),
				header_file_name = replace(header_file_name, 'user_img01','user_img%02d'),
				bg_file_name = replace(bg_file_name, 'user_img01','user_img%02d')
				WHERE user_id = ?;
				""".formatted(userImageNumber,userImageNumber,userImageNumber);

				statement = connection.prepareStatement(sql);
				statement.setInt(1, user.userId);
				statement.executeUpdate();

				connection.commit();

			} catch (SQLException throwables) {
				throwables.printStackTrace();
				isDbErr = true;
			} finally {
				if (statement != null) {
					try {
						statement.close();
						statement = null;
					} catch (SQLException throwables) {
						throwables.printStackTrace();
					}
				}
				if (connection != null) {
					try {
						connection.setAutoCommit(true);
						connection.close();
						connection = null;
					} catch (SQLException e) {
						e.printStackTrace();
					}
				}
			}

			if (isDbErr) {
				notifyError("db error");
				user.updateStatus(TmpUser.Status.ErrorOccurred);
				break;
			}

			// clear user cache
			Request request = new Request.Builder().url(urlClearUserCacheF + user.userId).build();
			try (Response response = client.newCall(request).execute()) {
				if (response.code() != 200) {
					notifyError("ClearUserCacheF error: " + user.userId + " " + Objects.requireNonNull(response.body()).string().replaceAll("\n", ""));
					user.updateStatus(TmpUser.Status.ErrorOccurred);
					break;
				}
			} catch(NullPointerException ignored) {}

			user.updateStatus(TmpUser.Status.Moved);
		}
		Log.d("SpotMoveImages batch end");
	}

	private static int runExternalCommand(List<String> command, Path log) {
		ProcessBuilder pb = new ProcessBuilder(command);
		pb.redirectErrorStream(true);
		if(log==null) {
			pb.redirectOutput(DEV_NULL.toFile());
		} else {
			pb.redirectOutput(log.toFile());
		}

		int exitCode = -1;
		try {
			Process proc = pb.start();
			exitCode = proc.waitFor();
		} catch(IOException | InterruptedException e) {
			e.printStackTrace();
		}
		return exitCode;
	}

}
