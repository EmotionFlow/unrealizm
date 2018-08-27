<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class RegistUserCParam {
	public String m_strNickName = "no_name";
	public String m_strPassWord = "";
	public String m_strEmail = "";
	public int m_nLangId = 1;
	public void GetParam(HttpServletRequest cRequest) {
	}
}

class RegistUserC {
	String m_strHashPass="";

	public boolean GetResults(RegistUserCParam cParam) {
		boolean bResult = false;
		String strSql = "";
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;

		try{
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// create password
			for(boolean bLoop=true; bLoop;) {
				cParam.m_strPassWord = "";
				for(int nCnt=0; nCnt<16; nCnt++) {
					cParam.m_strPassWord += String.valueOf((int)(Math.random()*10));
				}

				strSql = "SELECT * FROM users_0000 WHERE password=?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, cParam.m_strPassWord);
				cResSet = cState.executeQuery();
				if(!cResSet.next()) {
					bLoop=false;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// hash password
			MessageDigest md5 = MessageDigest.getInstance("SHA-256");
			md5.reset();
			md5.update((cParam.m_strPassWord + Math.random()).getBytes());
			byte[] hash= md5.digest();

			StringBuffer sb= new StringBuffer();
			for(int i=0; i<hash.length; i++) {
				int d = hash[i];
				if(d < 0) d += 256;
				String m = Integer.toString(d, 16);
				if(d < 16) {
					m = String.format("%1$02x", d);
				}
				sb.append(m);
			}
			m_strHashPass = sb.toString();

			// regist user
			strSql = "INSERT INTO users_0000(nickname, password, hash_password, lang_id, email) VALUES(?, ?, ?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, cParam.m_strNickName);
			cState.setString(2, cParam.m_strPassWord);
			cState.setString(3, m_strHashPass);
			cState.setInt(4, cParam.m_nLangId);
			cState.setString(5, cParam.m_strEmail);
			cState.executeUpdate();
			cState.close();cState=null;

			bResult = true;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}

		return bResult;
	}
}
%><%
boolean bRtn=true;
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);
if(!cCheckLogin.m_bLogin) {

	RegistUserCParam cParam = new RegistUserCParam();
	cParam.GetParam(request);

	RegistUserC cResults = new RegistUserC();
	bRtn = cResults.GetResults(cParam);

	if(bRtn) {
		Cookie cLK = new Cookie("POIPIKU_LK", cResults.m_strHashPass);

		cLK.setMaxAge(Integer.MAX_VALUE);
		cLK.setPath("/");

		response.addCookie(cLK);
	}
}
%>{"result":<%=(bRtn)?1:0%>}