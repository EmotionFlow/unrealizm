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
		final InfoList activityInfo = cResults.activities.get(nCnt);
		final InfoList.InfoType infoType = InfoList.InfoType.byCode(activityInfo.infoType);
		final InfoList.ContentType contentType = InfoList.ContentType.byCode(activityInfo.contentType);
	%>
		<%
			if(infoType == InfoList.InfoType.Emoji
					|| infoType ==  InfoList.InfoType.Gift
					|| infoType ==  InfoList.InfoType.EmojiReply
					|| infoType ==  InfoList.InfoType.WaveEmoji
					|| infoType ==  InfoList.InfoType.WaveEmojiMessage
					|| infoType ==  InfoList.InfoType.WaveEmojiMessageReply
			) {
		%>

		<a class="ActivityListItem <%if(activityInfo.hadRead){%>HadRead<%}%>"
		   onclick="UpdateActivityList(this, <%=infoType.getCode()%>, <%=activityInfo.userId%>, <%=activityInfo.contentId%>, <%=activityInfo.requestId%>)">

		<span class="ActivityListThumb">
			<%if(infoType == InfoList.InfoType.WaveEmoji || infoType == InfoList.InfoType.WaveEmojiMessage){%>
				<span class="ActivityListThumbImg" style="background-image: url('<%=Common.GetUrl(checkLogin.cacheUser.fileName)%>')"></span>
			<%}else if(infoType == InfoList.InfoType.WaveEmojiMessageReply){%>
				<span class="ActivityListThumbIcon"><i class="fas fa-envelope WaveMessageReplyIcon"></i></span>
			<%}else if(infoType == InfoList.InfoType.Gift){%>
				<span class="ActivityListThumbIcon"><i class="fas fa-gift GiftIcon"></i></span>
			<%}else{%>
				<%if(contentType == InfoList.ContentType.Image) {%>
				<span class="ActivityListThumbImg" style="background-image: url('<%=Common.GetUrl(activityInfo.infoThumb)%>_360.jpg')"></span>
				<%} else if(contentType == InfoList.ContentType.Text) {%>
				<span class="ActivityListThumbTxt"><%=Util.toStringHtml(activityInfo.infoThumb)%></span>
				<%}%>
			<%}%>
		</span>

		<span class="ActivityListBody">
			<span class="ActivityListTitle">
				<span class="Date"><%=cResults.timestampFormat.format(activityInfo.infoDate)%></span>
				<span class="Title">
					<%if(infoType == InfoList.InfoType.Emoji){%>
						<%=_TEX.T("ActivityList.Message.Comment")%>
					<%}else if(infoType == InfoList.InfoType.EmojiReply){%>
						<%=_TEX.T("ActivityList.Message.CommentReply")%>
					<%}else if(infoType == InfoList.InfoType.WaveEmoji){%>
						<%=_TEX.T("ActivityList.Message.WaveEmoji")%>
					<%}else if(infoType == InfoList.InfoType.WaveEmojiMessage){%>
						<i class="far fa-comment-dots"></i><%=_TEX.T("ActivityList.Message.WaveEmojiMessage")%>
					<%}else if(infoType == InfoList.InfoType.WaveEmojiMessageReply){%>
						<i class="far fa-comment-dots"></i><%=_TEX.T("ActivityList.Message.WaveEmojiMessageReply")%>
					<%}else{%>
						<%=Util.toStringHtml(activityInfo.infoDesc)%>
					<%}%>
				</span>
			</span>
			<span class="ActivityListDesc">
				<%if(infoType == InfoList.InfoType.Emoji
						|| infoType == InfoList.InfoType.EmojiReply
						|| infoType == InfoList.InfoType.WaveEmoji
						|| infoType == InfoList.InfoType.WaveEmojiMessage
						|| infoType == InfoList.InfoType.WaveEmojiMessageReply
				){%>
					<%for (int i = 0; i < activityInfo.infoDesc.length(); i = activityInfo.infoDesc.offsetByCodePoints(i, 1)) {%>
					<%=CEmoji.parse(String.valueOf(Character.toChars(activityInfo.infoDesc.codePointAt(i))))%>
					<%}%>
				<%}%>
			</span>
		</span>
		<span class="ActivityListBadge"><%=activityInfo.badgeNum%></span>
		</a>
		<%} else if(infoType == InfoList.InfoType.Request
				|| infoType == InfoList.InfoType.RequestStarted) {
				String[] infoDescLines = activityInfo.infoDesc.split("\n");
		%>
		<a class="ActivityListItem <%if(activityInfo.hadRead){%>HadRead<%}%>"
		   onclick="UpdateActivityList(this, <%=infoType.getCode()%>, <%=activityInfo.userId%>, <%=activityInfo.contentId%>, <%=activityInfo.requestId%>)">
				<span class="ActivityListRequestThumb">
				</span>
			<span class="ActivityListBody">
				<span class="ActivityListTitle">
				<span class="Date"><%=cResults.timestampFormat.format(activityInfo.infoDate)%></span>
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
