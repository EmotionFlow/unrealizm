<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

int result;
int errorCode;
int errorDetailCode;

if (Util.isBot(request)) return;
final String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("unrealizm.com")) {
	Log.d("RetweetContentFへの不正アクセス(referer不一致):" + referer);
	//return;
}

CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	result = Common.API_NG;
	errorCode = RetweetContentC.ErrorKind.DoRetry.getCode();
	errorDetailCode = RetweetContentC.ErrorDetail.NotSignedIn.getCode();
} else {
	RetweetContentC controller = new RetweetContentC();
	controller.getParam(request);
	int controllerResult = controller.getResults(checkLogin);
	if (controllerResult == CTweet.RETWEET_DONE || controllerResult == CTweet.RETWEET_ALREADY) {
		result = Common.API_OK;
	} else {
		result = Common.API_NG;
	}
	errorCode = controller.errorKind.getCode();
	errorDetailCode = controller.errorDetail.getCode();
}

%>{"result":<%=result%>,"error_code":<%=errorCode%>,"error_detail_code":<%=errorDetailCode%>}
