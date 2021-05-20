<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if (!cResults.m_bBlocked && !cResults.m_bBlocking && !cResults.m_bOwner){%>
<a class="UserInfoStateItem BtnBase" href="javascript: void(0);" onclick="SendGift(<%=cResults.m_cUser.m_nUserId%>, '<%=cResults.m_cUser.m_strNickName%>')">
	<i class="fas fa-gift"></i> <span class="RequestEnabled">さしいれ</span>
</a>
<%}%>
