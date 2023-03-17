<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

IllustListC results = new IllustListC();
results.getParam(request);

if(results.m_nUserId==-1) {
	if(!checkLogin.m_bLogin) {
		return;
	} else {
		results.m_nUserId = checkLogin.m_nUserId;
	}
}

if(!isApp){
	results.m_bDispUnPublished = (checkLogin.m_nUserId == results.m_nUserId);
} else {
	if(checkLogin.m_nUserId != results.m_nUserId) {
		// 他人のリスト
		results.m_bDispUnPublished = false;
	} else {
		// 自分のリスト
		CAppVersion cAppVersion = new CAppVersion(request.getCookies());
		if(cAppVersion.isValid()){
			if(cAppVersion.isAndroid() && cAppVersion.m_nNum >= 225){
				results.m_bDispUnPublished = false;
			} else {
				results.m_bDispUnPublished = true;
			}
		}else{
			// 古いアプリはCookieにバージョン番号が含まれていないため取得できない。
			results.m_bDispUnPublished = true;
		}
	}
}

checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = results.getResults(checkLogin, true);
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
%>
<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);%>
	<%if(checkLogin.m_nUserId != results.m_nUserId){%>
	<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, nSpMode, _TEX)%>
	<%}else{%>
	<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, nSpMode, _TEX)%>
	<%}%>
	<%if(nCnt==17) {%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
	<%}%>
<%}%>
