<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="UserInfo Float">
	<%@ include file="/inner/IllustBrowserVGiftButton.jsp"%>
	<%@ include file="/inner/IllustVBlockButton.jsp"%>
	<div class="UserInfoBg"></div>
	<section class="UserInfoUser">
		<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(results.m_cUser.m_strFileName)%>')" href="/<%=results.m_cUser.m_nUserId%>/"></a>
		<h2 class="UserInfoUserName"><a href="/<%=results.m_cUser.m_nUserId%>/"><%=results.m_cUser.m_strNickName%></a></h2>
	
		<%if(results.twitterScreenName != null && !results.twitterScreenName.isEmpty()) {%>
		<h3 class="UserInfoProfile"><a class="fab fa-twitter" href="https://twitter.com/<%=results.twitterScreenName%>">@<%=results.twitterScreenName%></a></h3>
		<%}%>
	
		<%if(!results.m_cUser.m_strProfile.isEmpty()) {%>
		<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(results.m_cUser.m_strProfile), results.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
		<%}%>
	
		<span class="UserInfoCmd">
			<%if(checkLogin.m_bLogin){%>
			<%@ include file="TFollowButton.jsp"%>
			<%}%>
			<%@ include file="IllustBrowserVRequestButton.jsp"%>
			<%@ include file="TUserShareCmd.jsp"%>
		</span>
	
		<%@ include file="TWaveButtons.jsp"%>
	
	</section>
	<section class="UserInfoState">
		<%@include file="IllustBrowserVUserInfoState.jsp"%>
	</section>
</div>
