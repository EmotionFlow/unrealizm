package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.EmailUtil;
import jp.pipa.poipiku.util.Log;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;

import java.io.StringWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class Notifier {
	protected String CATEGORY = "";
	protected int NOTIFICATION_INFO_TYPE = -1;

	public static class User {
		public int id = -1;
		public String nickname;
		public String email;
		public int langId = Common.LANG_ID_JP;
		public String langLabel;
		public User(){};
		protected User(int userId){
			Connection connection = null;
			PreparedStatement statement = null;
			ResultSet resultSet = null;
			final String sql = "SELECT nickname, email, lang_id FROM users_0000 WHERE user_id=?";
			try {
				connection = DatabaseUtil.dataSource.getConnection();

				statement = connection.prepareStatement(sql);
				statement.setInt(1, userId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					id = userId;
					nickname = resultSet.getString("nickname");
					email = resultSet.getString("email");
					langId = resultSet.getInt("lang_id");
					setLangLabel();
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			} catch(Exception e) {
				Log.d(sql);
				e.printStackTrace();
			} finally {
				try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
				try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
				try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
			}
		}
		public void setLangLabel() {
			if (langId == Common.LANG_ID_JP) {
				langLabel = "ja";
			} else {
				langLabel = "en";
			}
		}
		public String toString() {
			return String.format("%d, %s, %s, %d, %s",
					id, nickname, email, langId, langLabel);
		}
	}

	static protected String getServiceName(User user) {
		return user.langLabel.equals("ja") ? "ポイピク" : "POIPIKU";
	}

	protected String merge(Template template, VelocityContext context) {
		StringWriter sw = new StringWriter();
		template.merge(context, sw);
		return sw.toString();
	}

	protected String getVmPath(final String path, final String langLabel){
		// TODO 英語のVMテンプレート実装
		// return langLabel + "/" + CATEGORY + "/" + path;
		return "ja/" + CATEGORY + "/" + path;
	}

	protected Template getTemplate(String vmPath, String langLabel) {
		return Velocity.getTemplate(getVmPath(vmPath, langLabel), "UTF-8");
	}

	protected String getSubject(final String statusName, final String langLabel) {
		return merge(
				getTemplate(statusName + "/subject.vm", langLabel),
				null
		);
	}

	protected Template getBodyTemplate(final String statusName, final String langLabel) {
		return getTemplate(statusName + "/body.vm",langLabel);
	}

	protected Template getTitleTemplate(final String statusName, final String langLabel){
		return Velocity.getTemplate(getVmPath(statusName + "/title.vm", langLabel), "UTF-8");
	}

	protected String getTitle(final String statusName, final String langLabel) {
		return merge(
				getTitleTemplate(statusName, langLabel),
				null
		);
	}

	protected boolean notifyByApp(User to, String body) {
		final String title = getServiceName(to);
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		try {
			final int nBadgeNum = InfoList.selectUnreadBadgeSum(to.id);
			// 通知先デバイストークンの取得
			connection = DatabaseUtil.dataSource.getConnection();
			ArrayList<CNotificationToken> notificationTokens = new ArrayList<>();
			sql = "SELECT * FROM notification_tokens_0000 WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, to.id);
			resultSet = statement.executeQuery();
			while(resultSet.next()) {
				notificationTokens.add(new CNotificationToken(resultSet));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if(notificationTokens.isEmpty()){
				return true;
			}

			// 送信用に登録
			NotificationBuffer notificationBuffer = new NotificationBuffer();
			notificationBuffer.notificationType = NOTIFICATION_INFO_TYPE;
			notificationBuffer.badgeNum = nBadgeNum;
			notificationBuffer.title = title;
			notificationBuffer.subTitle = "";
			notificationBuffer.body = body;
			for(CNotificationToken token : notificationTokens) {
				notificationBuffer.notificationToken = token.m_strNotificationToken;
				notificationBuffer.tokenType = token.m_nTokenType;
				notificationBuffer.insert(connection);
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return true;
	}

	protected enum InsertMode {
		Insert,
		Upsert,
		TryInsert  // on conflict do nothing
	}

	protected boolean notifyByWeb(User to, int requestId, int contentId, int contentType, String description, InsertMode insertMode) {
		InfoList infoList = new InfoList();
		infoList.userId = to.id;
		infoList.requestId = requestId;
		infoList.contentId = contentId;
		infoList.contentType = contentType;
		infoList.infoType = NOTIFICATION_INFO_TYPE;
		infoList.infoDesc = description;
		infoList.badgeNum = 1;
		switch (insertMode) {
			case Insert:
				infoList.insert();
				break;
			case Upsert:
				infoList.upsert();
				break;
			case TryInsert:
				infoList.tryInsert();
				break;
			default:
				break;
		}
		return true;
	}

	protected void notifyByEmail(User toUser, String subject, String body) {
		EmailUtil.send(toUser.email, subject, body);
	}
}
