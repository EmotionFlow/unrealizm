<%@ page import="static jp.pipa.poipiku.controller.ActivityListC.TIMESTAMP_FORMAT" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	out.print(_TEX.T("ActivityList.Message.Default.Recive"));
	return;
}

ActivityListC cResults = new ActivityListC();
//パラメータの取得
cResults.getParam(request);
cResults.userId = checkLogin.m_nUserId;
//検索結果の取得
cResults.getResults(checkLogin);
%>
<%if(cResults.activities.size()==0) {%>
	<div style="display:block; width: 100%; padding: 250px 0; text-align: center;">
		<%=_TEX.T("ActivityList.Message.Default.Recive")%>
	</div>
	<%@ include file="/inner/TAd728x90_mid.jsp"%>
<%} else {%>
	<%for(int nCnt = 0; nCnt<cResults.activities.size(); nCnt++) {
		InfoList activityInfo = cResults.activities.get(nCnt);%>
		<%
			if(activityInfo.infoType == Common.NOTIFICATION_TYPE_REACTION
					|| activityInfo.infoType == Common.NOTIFICATION_TYPE_GIFT) {%>

		<a class="ActivityListItem <%if(activityInfo.hadRead){%>HadRead<%}%>"
		   onclick="UpdateActivityList(this, <%=activityInfo.infoType%>, <%=activityInfo.userId%>, <%=activityInfo.contentId%>, <%=activityInfo.requestId%>)">

		<span class="ActivityListThumb">
			<%if(activityInfo.infoType == Common.NOTIFICATION_TYPE_GIFT){%>
				<span class="ActivityListThumbIcon"><i class="fas fa-gift GiftIcon"></i></span>
			<%}else{%>
				<%if(activityInfo.contentType==Common.CONTENT_TYPE_IMAGE) {%>
				<span class="ActivityListThumbImg" style="background-image: url('<%=Common.GetUrl(activityInfo.infoThumb)%>_360.jpg')"></span>
				<%} else if(activityInfo.contentType==Common.CONTENT_TYPE_TEXT) {%>
				<span class="ActivityListThumbTxt"><%=Util.toStringHtml(activityInfo.infoThumb)%></span>
				<%}%>
			<%}%>
		</span>

		<span class="ActivityListBody">
			<span class="ActivityListTitle">
				<span class="Date"><%=TIMESTAMP_FORMAT.format(activityInfo.infoDate)%></span>
				<span class="Title">
					<%if(activityInfo.contentType==Common.CONTENT_TYPE_IMAGE){%>
					<%=_TEX.T("ActivityList.Message.Comment")%>
					<%}else{%>
					<%=Util.toStringHtml(activityInfo.infoDesc)%>
					<%}%>
				</span>
			</span>
			<span class="ActivityListDesc">
				<%if(activityInfo.contentType==Common.CONTENT_TYPE_IMAGE){%>
					<%for (int i = 0; i < activityInfo.infoDesc.length(); i = activityInfo.infoDesc.offsetByCodePoints(i, 1)) {%>
					<%=CEmoji.parse(String.valueOf(Character.toChars(activityInfo.infoDesc.codePointAt(i))))%>
					<%}%>
				<%}%>
			</span>
		</span>
		<span class="ActivityListBadge"><%=activityInfo.badgeNum%></span>
		</a>
		<%} else if(activityInfo.infoType == Common.NOTIFICATION_TYPE_REQUEST) {
		final String[] infoDescLines = activityInfo.infoDesc.split("\n");
		%>
		<a class="ActivityListItem <%if(activityInfo.hadRead){%>HadRead<%}%>"
		   onclick="UpdateActivityList(this, <%=activityInfo.infoType%>, <%=activityInfo.userId%>, <%=activityInfo.contentId%>, <%=activityInfo.requestId%>)">
				<span class="ActivityListRequestThumb">
				</span>
			<span class="ActivityListBody">
				<span class="ActivityListTitle">
				<span class="Date"><%=TIMESTAMP_FORMAT.format(activityInfo.infoDate)%></span>
					<span class="Title"><%=infoDescLines[0]%></span>
				</span>
				<span class="ActivityListDesc">
					<span class="Title"><%=infoDescLines.length>1 ? infoDescLines[1] : ""%></span>
				</span>
			</span>
		</a>
		<%} else {%>
		<%}%>
		<%if((nCnt+1)%9==0) {%>
		<%@ include file="/inner/TAd728x90_mid.jsp"%>
		<%}%>
	<%}%>
<%}%>
