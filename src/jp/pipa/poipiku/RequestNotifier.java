package jp.pipa.poipiku;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jp.pipa.poipiku.util.Log;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;

import javax.naming.InitialContext;
import javax.sql.DataSource;

public class RequestNotifier {
	private static final String REQUEST_BOARD_URL = "https://poipiku.com/MyRequestListPcV.jsp";
	private static class User {
		public int id = -1;
		public String nickname;
		public String email;
		public int langId = Common.LANG_ID_JP;
		public String langLabel;
		User(int userId){
			DataSource dataSource = null;
			Connection connection = null;
			PreparedStatement statement = null;
			ResultSet resultSet = null;
			final String sql = "SELECT * FROM users_0000 WHERE user_id=?";
			try {
				dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
				connection = dataSource.getConnection();

				statement = connection.prepareStatement(sql);
				statement.setInt(1, userId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					id = userId;
					nickname = resultSet.getString("nickname");
					email = resultSet.getString("email");
					langId = resultSet.getInt("lang_id");
					if (langId == Common.LANG_ID_JP) {
						langLabel = "ja";
					} else {
						langLabel = "en";
					}
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
	}

	static private String getVmPath(final String path, final ResourceBundleControl _TEX){
		// TODO 英語のVMテンプレート実装
		// return _TEX.T("Lang") + "/request/" + path;
		return "ja/request/" + path;
	}

	static private String getVmPath(final String path, final String langLabel){
		// TODO 英語のVMテンプレート実装
		// return langLabel + "/request/" + path;
		return "ja/request/" + path;
	}

	static public void notifyRequestEnabled(final CheckLogin checkLogin, final ResourceBundleControl _TEX){
		try {
			StringWriter sw = new StringWriter();
			VelocityContext context = new VelocityContext();
			context.put("to_name", checkLogin.m_strNickName);
			Template template = Velocity.getTemplate(getVmPath("enabled/body.vm", _TEX), "UTF-8");
			template.merge(context, sw);

			//TODO send email.
			Log.d(sw.toString());

			sw.flush();
		} catch (Exception e) {
			e.printStackTrace();
			Log.d("notifyRequestEnabled failed.");
		}
	}

	static public void notifyRequestReceived(Request request){
		final User client = new User(request.clientUserId);
		final User creator = new User(request.creatorUserId);
		if (client.id > 0 && creator.id > 0) {
			try {
				StringWriter sw = new StringWriter();
				VelocityContext context = new VelocityContext();
				context.put("to_name", creator.nickname);
				context.put("request_board_url",
						String.format("%s?MENUID=RECEIVED&ST=%d&RID=%d",
								REQUEST_BOARD_URL, Request.Status.WaitingAppoval.getCode(), request.id));
				Template template = Velocity.getTemplate(getVmPath("received/body.vm", creator.langLabel), "UTF-8");
				template.merge(context, sw);

				//TODO send email.
				Log.d(sw.toString());

				sw.flush();
			} catch (Exception e) {
				e.printStackTrace();
				Log.d("notifyRequestReceived failed.");
			}
		}
	}

	static public void notifyRequestCanceled(final CheckLogin checkLogin, Request request){
		final User client = new User(request.clientUserId);
		final User creator = new User(request.creatorUserId);
		final User notifyTo = checkLogin.m_nUserId==request.clientUserId ? creator : client;
		if (client.id > 0 && creator.id > 0) {
			try {
				StringWriter sw = new StringWriter();
				VelocityContext context = new VelocityContext();
				context.put("to_name", creator.nickname);
				context.put("request_board_url",
						String.format("%s?MENUID=%s&ST=%d&RID=%d",
								REQUEST_BOARD_URL, notifyTo.equals(client) ? "SENT" : "RECEIVED",
								Request.Status.Canceled.getCode(), request.id));
				Template template = Velocity.getTemplate(getVmPath("canceled/body.vm", notifyTo.langLabel), "UTF-8");
				template.merge(context, sw);

				//TODO send email.
				Log.d(sw.toString());

				sw.flush();
			} catch (Exception e) {
				e.printStackTrace();
				Log.d("notifyRequestCanceled failed.");
			}
		}
	}

	static public void notifyRequestDelivered(Request request) {
		final User client = new User(request.clientUserId);
		final User creator = new User(request.creatorUserId);
		if (client.id > 0 && creator.id > 0) {
			try {
				StringWriter sw = new StringWriter();
				VelocityContext context = new VelocityContext();
				context.put("to_name", creator.nickname);
				context.put("request_board_url",
						String.format("%s?MENUID=%s&ST=%d&RID=%d",
								REQUEST_BOARD_URL, "SENT",
								Request.Status.Canceled.getCode(), request.id));
				Template template = Velocity.getTemplate(getVmPath("delivered/body.vm", client.langLabel), "UTF-8");
				template.merge(context, sw);

				//TODO send email.
				final String to = client.email;
				Log.d(sw.toString());

				sw.flush();
			} catch (Exception e) {
				e.printStackTrace();
				Log.d("notifyRequestDelivered failed.");
			}
		}
	}
}
