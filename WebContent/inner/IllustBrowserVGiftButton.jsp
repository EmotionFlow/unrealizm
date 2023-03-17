<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if (false){%>
<%--<%if (!results.m_bBlocked && !results.m_bBlocking && !results.m_bOwner){%>--%>
<a class="UserInfoStateItem BtnBase GiftBtn" href="javascript: void(0);" onclick="SendGift(<%=results.m_cUser.m_nUserId%>, '<%=results.m_cUser.m_strNickName%>')">
	<i class="fas fa-gift"></i> <span class="RequestEnabled"><%=_TEX.T("Ofuse")%></span>
</a>
<%}%>
