<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateFileOrderC results = new UpdateFileOrderC(getServletContext());
results.userId = checkLogin.m_nUserId;
nRtn = results.GetParam(request);

final int RETRY_MAX = 3;

if (checkLogin.m_bLogin && results.userId ==checkLogin.m_nUserId && nRtn==0) {
	for (int retryCnt=0; retryCnt<RETRY_MAX; retryCnt++) {
		nRtn = results.GetResults(checkLogin, g_isApp);
		if (nRtn == -1 && results.errorKind == Controller.ErrorKind.DoRetry) {
			try {
				Log.d("write back file 作業中");
				Thread.sleep(500);
			} catch (InterruptedException e) {
				e.printStackTrace();
				break;
			}
		} else {
			break;
		}
	}
}
%>
{"result": <%=nRtn%>}
