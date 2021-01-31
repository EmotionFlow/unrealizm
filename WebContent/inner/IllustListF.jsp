<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

IllustListC cResults = new IllustListC();
cResults.getParam(request);

if(cResults.m_nUserId==-1) {
	if(!checkLogin.m_bLogin) {
		return;
	} else {
		cResults.m_nUserId = checkLogin.m_nUserId;
	}
}

if(!isApp){
	cResults.m_bDispUnPublished = (checkLogin.m_nUserId == cResults.m_nUserId);
} else {
	if(checkLogin.m_nUserId != cResults.m_nUserId) {
		// 他人のリスト
		cResults.m_bDispUnPublished = false;
	} else {
		// 自分のリスト
		CAppVersion cAppVersion = new CAppVersion(request.getCookies());
		if(cAppVersion.isValid()){
			if(cAppVersion.isAndroid() && cAppVersion.m_nNum >= 225){
				cResults.m_bDispUnPublished = false;
			} else {
				cResults.m_bDispUnPublished = true;
			}
		}else{
			// 古いアプリはCookieにバージョン番号が含まれていないため取得できない。
			cResults.m_bDispUnPublished = true;
		}
	}
}

checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(checkLogin, true);
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%if(checkLogin.m_nUserId != cResults.m_nUserId){%>
	<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, nSpMode, _TEX)%>
	<%}else{%>
	<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, nSpMode, _TEX)%>
	<%}%>
	<%if(nCnt==17) {%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
	<%}%>
<%}%>
