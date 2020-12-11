<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

ActivityListC cResults = new ActivityListC();
//パラメータの取得
cResults.GetParam(request);
cResults.m_nUserId = checkLogin.m_nUserId;
//検索結果の取得
cResults.GetResults(checkLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("ActivityList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuAct').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 79px !important;}
		</style>
	</head>
	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/ActivityListPcV.jsp"><%=_TEX.T("THeader.Menu.Act.Reaction")%></a></li>
				<li><a class="TabMenuItem" href="/ActivityAnalyzePcV.jsp"><%=_TEX.T("THeader.Menu.Act.Analyze")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper ItemList">
			<%if(cResults.m_vContentList.size()<=0) {%>
			<div style="display:block; width: 100%; padding: 250px 0; text-align: center;">
				<%=_TEX.T("ActivityList.Message.Default.Recive")%>
			</div>
			<%}else{%>
			<div class="IllustItemList" style="min-height: 600px;">
				<div class="ActivityList">
					<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
						ActivityListC.ActivityInfo activityInfo = cResults.m_vContentList.get(nCnt);%>
					<%if(activityInfo.info_type == Common.NOTIFICATION_TYPE_REACTION) {	// 絵文字が来たお知らせ%>
					<a class="ActivityListItem <%if(activityInfo.had_read){%>HadRead<%}%>" href="/UpdateActivityListV.jsp?TY=<%=activityInfo.info_type%>&ID=<%=activityInfo.user_id%>&TD=<%=activityInfo.content_id%>&APP=0">
						<span class="ActivityListThumb">
							<%if(activityInfo.content_type==Common.CONTENT_TYPE_IMAGE) {%>
							<span class="ActivityListThumbImg" style="background-image: url('<%=Common.GetUrl(activityInfo.info_thumb)%>_360.jpg')"></span>
							<%} else if(activityInfo.content_type==Common.CONTENT_TYPE_TEXT) {%>
							<span class="ActivityListThumbTxt"><%=Util.toStringHtml(activityInfo.info_thumb)%></span>
							<%}%>
						</span>
						<span class="ActivityListBody">
							<span class="ActivityListTitle">
								<span class="Date"><%=(new SimpleDateFormat("YYYY MM/dd HH:mm")).format(activityInfo.info_date)%></span>
								<span class="Title"><%=_TEX.T("ActivityList.Message.Comment")%></span>
							</span>
							<span class="ActivityListDesc">
								<%for (int i = 0; i < activityInfo.info_desc.length(); i = activityInfo.info_desc.offsetByCodePoints(i, 1)) {%>
								<%=CEmoji.parse(String.valueOf(Character.toChars(activityInfo.info_desc.codePointAt(i))))%>
								<%}%>
							</span>
						</span>
						<span class="ActivityListBadge"><%=activityInfo.badge_num%></span>
					</a>
					<%} else if(activityInfo.info_type == Common.NOTIFICATION_TYPE_REACTION) {%>
					<%} else {%>
					<%}%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAd728x90_mid.jsp"%>
					<%}%>
					<%}%>
				</div>
			</div>
			<%}%>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>