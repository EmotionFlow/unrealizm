<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if (!results.m_bBlocked && !results.m_bBlocking){%>
<a class="UserInfoStateItem BtnBase RequestBtn" href="/RequestNewAppV.jsp?ID=<%=results.m_cUser.m_nUserId%>">
	<span class="SendRequestIcon"></span><span class="RequestEnabled"><%=_TEX.T("THeader.Menu.Act.Request")%></span>
</a>
<%}%>
