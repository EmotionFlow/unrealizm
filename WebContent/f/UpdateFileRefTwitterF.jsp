<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
Log.d("UpdateFileRefTwitterF - UserId:"+cCheckLogin.m_nUserId);

int nRtn = 0;
UpdateParamC cParam = new UpdateParamC();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

Log.d("UpdateFileRefTwitterCParam:"+nRtn);
Log.d("UpdateFileRefTwitterCParam.m_nUserId:"+cParam.m_nUserId);
Log.d("UpdateFileRefTwitterCParam.m_nContentId:"+cParam.m_nContentId);
Log.d("UpdateFileRefTwitterCParam.m_nCategoryId:"+cParam.m_nCategoryId);
Log.d("UpdateFileRefTwitterCParam.m_strDescription:"+cParam.m_strDescription);
Log.d("UpdateFileRefTwitterCParam.m_strTagList:"+cParam.m_strTagList);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UpdateC cResults = new UpdateC();
	nRtn = cResults.GetResults(cParam);
	Log.d("UpdateFileRefTwitterF - OK:"+nRtn);
}
%>
{
"content_id":<%=nRtn%>
}
