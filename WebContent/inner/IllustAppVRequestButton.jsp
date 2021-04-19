<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if (!cResults.m_bBlocked && cResults.m_cUser.m_bRequestEnabled){%>
<a class="UserInfoStateItem BtnBase" href="/RequestNewAppV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>">
	<span class="SendRequestIcon"></span><span class="RequestEnabled">リクエスト送信</span>
</a>
<%}%>
