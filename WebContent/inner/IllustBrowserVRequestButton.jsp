<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if (false){%>
<%--<%if (!cResults.m_bBlocked && !cResults.m_bBlocking){%>--%>
<a class="UserInfoStateItem BtnBase RequestBtn" href="/RequestNew<%=isApp?"App":"Pc"%>V.jsp?ID=<%=cResults.m_cUser.m_nUserId%>">
	<span class="SendRequestIcon"></span><span class="RequestEnabled"><%=_TEX.T("Request.SendRequest")%></span>
</a>
<%}%>