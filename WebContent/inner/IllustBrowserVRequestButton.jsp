<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if (checkLogin.isStaff()){%>
<%if (!cResults.m_bBlocked && cResults.m_cUser.m_bRequestEnabled){%>
<a class="UserInfoStateItem BtnBase" href="/RequestNewPcV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>">
	<i class="far fa-clipboard"></i> <span class="RequestEnabled">リクエスト</span>
</a>
<%}%>
<%}%>