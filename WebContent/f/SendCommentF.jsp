<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class SendCommentCParam {
	public int m_nContentId = -1;
	public int m_nUserId = -1;
	public int m_nToUserId = -1;
	public String m_strDescription = "";

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nContentId		= Common.ToInt(cRequest.getParameter("IID"));
			m_strDescription	= Common.TrimAll(cRequest.getParameter("DES"));
			m_nUserId			= Common.ToInt(cRequest.getParameter("UID"));
			m_nToUserId			= Math.max(Common.ToInt(cRequest.getParameter("TOD")), 0);
		} catch(Exception e) {
			m_nContentId = -1;
			m_nUserId = -1;
			m_strDescription = "";
		}
	}
}

class SendCommentC {
	public boolean GetResults(SendCommentCParam cParam, ResourceBundleControl _TEX) {
		if (cParam.m_strDescription.isEmpty()) return false;

		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// 投稿存在確認(不正アクセス対策)
			boolean bExist = false;
			int nMakingUserId = 0;
			strSql = "SELECT * FROM contents_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				bExist = true;
				nMakingUserId = cResSet.getInt("user_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!bExist) {
				return false;
			}

			// add new comment
			strSql = "INSERT INTO comments_0000(content_id, description, user_id, to_user_id) VALUES(?, ?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.setString(2, Common.SubStrNum(cParam.m_strDescription, 200));
			cState.setInt(3, cParam.m_nUserId);
			cState.setInt(4, cParam.m_nToUserId);
			cState.executeUpdate();
			cState.close();cState=null;


			// Add tags
			// get all comments
			ArrayList<CComment> arrComment = new ArrayList<CComment>();
			strSql = "SELECT * FROM comments_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			while(cResSet.next()) {
				CComment comment = new CComment();
				comment.m_strDescription = Common.ToString(cResSet.getString("description"));
				arrComment.add(comment);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			// clear old tags
			strSql = "DELETE FROM tags_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;
			// append tag in comment
			Pattern ptn = Pattern.compile("#([\\w\\p{InHiragana}\\p{InKatakana}\\p{InHalfwidthAndFullwidthForms}\\p{InCJKUnifiedIdeographs}!$%()\\*\\+\\-\\.,\\/\\[\\]:;=?@^_`{|}~]+)", Pattern.MULTILINE);
			for(CComment comment : arrComment) {
				Matcher matcher = ptn.matcher(comment.m_strDescription.replaceAll("　", " ")+"\n");
				strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, 1)";
				cState = cConn.prepareStatement(strSql);
				for (int nNum=0; matcher.find() && nNum<20; nNum++) {
					try {
						cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
						cState.setInt(2, cParam.m_nContentId);
						cState.executeUpdate();
					} catch(Exception e) {
						e.printStackTrace();
					}
				}
				cState.close();cState=null;
			}

			// update making comment num
			strSql ="UPDATE contents_0000 SET comment_num=(SELECT COUNT(*) FROM comments_0000 WHERE content_id=?) WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.setInt(2, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			bRtn = true; // 以下実行されなくてもOKを返す
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}
%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

SendCommentCParam cParam = new SendCommentCParam();
cParam.GetParam(request);
boolean bRtn = false;
if( cCheckLogin.m_bLogin && cParam.m_nUserId == cCheckLogin.m_nUserId ) {
	SendCommentC cResults = new SendCommentC();
	bRtn = cResults.GetResults(cParam, _TEX);
}
%><%=bRtn%>