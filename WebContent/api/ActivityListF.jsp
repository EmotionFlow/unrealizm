<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.JsonMappingException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%
	int nResult = 0;

//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) {
	nResult = -1;
}

//パラメータの取得
int m_nUserId = Util.toInt(request.getParameter("ID"));
long m_lDatetime = Util.toLong(request.getParameter("DT"));

Timestamp m_tsDatetime = null;
if(m_lDatetime >= 0){
		m_tsDatetime = new Timestamp(m_lDatetime);
		//Log.d("DT: " + m_tsDatetime.toString());
}

//認証
if (cCheckLogin.m_nUserId!=m_nUserId) {
	nResult = -2;
}


//データ取得
int nLimit = 30;
String strSql = "";
Vector<CComment> m_vComment = new Vector<CComment>();

Connection cConn = null;
PreparedStatement cState = null;
ResultSet cResSet = null;

try{
		Class.forName("org.postgresql.Driver");
		DataSource dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
		cConn = dsPostgres.getConnection();

		// フォロー通知を表示するか
		boolean bDispFollower = false;
		strSql = "SELECT * FROM users_0000 WHERE user_id=?";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, m_nUserId);
		cResSet = cState.executeQuery();
		if(cResSet.next()) {
		int nMailComment	= cResSet.getInt("mail_comment");
		bDispFollower		= ((nMailComment>>>0 & 0x01) == 0x01);
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;

		//リアクション（内部的にはcomment）
		strSql = "SELECT comments_0000.*, T1.file_name, T1.nickname FROM comments_0000"
		+ " LEFT JOIN users_0000 as T1 ON comments_0000.user_id=T1.user_id WHERE content_id IN ("
		+ " SELECT content_id FROM contents_0000 WHERE open_id<>2 AND user_id=?"
		+ " ) AND comments_0000.user_id!=?";
		if(m_tsDatetime != null){
		strSql += " AND upload_date < ?";
		}
		strSql += " ORDER BY comment_id DESC LIMIT ?";

		int idx = 1;
		cState = cConn.prepareStatement(strSql);
		cState.setInt(idx++, m_nUserId);
		cState.setInt(idx++, m_nUserId);
		if(m_tsDatetime != null){
		cState.setTimestamp(idx++, m_tsDatetime);
		}
		cState.setInt(idx++, nLimit);

		cResSet = cState.executeQuery();
		while (cResSet.next()) {
		CComment cComment = new CComment(cResSet);
		cComment.m_nCommentId		= cResSet.getInt("comment_id");
		cComment.m_strDescription	= Util.toString(cResSet.getString("description"));
		cComment.m_timeUploadDate   = cResSet.getTimestamp("upload_date");


		if(cComment.m_strFileName.length()<=0) cComment.m_strFileName="/img/default_user.jpg";
		m_vComment.add(cComment);
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;
		cConn.close();cConn=null;
} catch(Exception e) {
		Log.d(strSql);
		e.printStackTrace();
		nResult=-3;
} finally {
		if(cResSet!=null){cResSet.close();}
		if(cState!=null){cState.close();}
		if(cConn!=null){cConn.close();}
}

//JSON元データを格納する連想配列
Map<String, Object> root = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	root = new HashMap<String, Object>();
		root.put("result", nResult);

	if (nResult == 0) {
		root.put("user_id", m_nUserId);
		root.put("content_num", m_vComment.size());

		//リアクション情報(配列)
		List<Map<String, Object>> reactionList = new ArrayList<Map<String, Object>>();
		for(CComment cComment : m_vComment) {
	Map<String, Object> reaction = new HashMap<String, Object>();
	reaction.put("type", "comment");
	reaction.put("id", cComment.m_nCommentId);
	reaction.put("emoji_url", CEmoji.parseToUrl(cComment.m_strDescription));
	reaction.put("description", _TEX.T("ActivityList.Message.Comment"));
	reaction.put("thumbnail_url", "");
	reaction.put("link_url", Common.GetPoipikuUrl(String.format("/IllustViewAppV.jsp?ID=%d&TD=%d", m_nUserId, cComment.m_nContentId)));
	reaction.put("datetime", cComment.m_timeUploadDate.getTime());
	reactionList.add(reaction);
		}
		root.put("reaction_list", reactionList);
	}

	//JSONに変換して出力
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
} catch(JsonGenerationException e)  {
		e.printStackTrace();
} finally {
	root = null;
	mapper = null;
}
%>
