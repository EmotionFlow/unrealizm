<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if (!cResults.m_bBlocked){%>
<a class="UserInfoStateItem BtnBase" href="/RequestNewPcV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>">
	<span class="SendRequestIcon"></span><span class="RequestEnabled">リクエスト</span>
</a>
<%}%>