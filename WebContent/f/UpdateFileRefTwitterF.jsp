<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateCParam cParam = new UpdateCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

//Log.d("UpdateFileRefTwitterCParam:"+nRtn);
//Log.d("UpdateFileRefTwitterCParam.m_nUserId:"+cParam.m_nUserId);
//Log.d("UpdateFileRefTwitterCParam.m_nContentId:"+cParam.m_nContentId);
//Log.d("UpdateFileRefTwitterCParam.m_nCategoryId:"+cParam.m_nCategoryId);
//Log.d("UpdateFileRefTwitterCParam.m_strDescription:"+cParam.m_strDescription);
//Log.d("UpdateFileRefTwitterCParam.m_strTagList:"+cParam.m_strTagList);
//Log.d("UpdateFileRefTwitterCParam.m_bNotRecently:"+cParam.m_bNotRecently);
//Log.d("UpdateFileRefTwitterCParam.m_bTweetTxt:"+cParam.m_bTweetTxt);
//Log.d("UpdateFileRefTwitterCParam.m_bTweetImg:"+cParam.m_bTweetImg);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UpdateC cResults = new UpdateC();
	nRtn = cResults.GetResults(cParam, cCheckLogin);
}
%>
{
"content_id":<%=nRtn%>
}
