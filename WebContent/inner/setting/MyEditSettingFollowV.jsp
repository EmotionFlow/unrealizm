<%@page import="jp.pipa.poipiku.controller.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
	static final int SELECT_MAX_GALLERY = 30;
%>
<%
FollowListC cFollowListResults = new FollowListC();
cFollowListResults.getParam(request);
cFollowListResults.m_nMode = 0;
cFollowListResults.m_nPage = results.m_nListPage;
cFollowListResults.selectMaxGallery = SELECT_MAX_GALLERY;
cFollowListResults.getResults(checkLogin);
%>
<script type="application/javascript">
	$(function(){
		$(document).on("click", "#FollowListPageBar .PageBarItem", function(ev){
			const pageNum = $(ev.target).attr("data-page");
			$.ajax({
				"type": "POST",
				"url": "/f/FollowListF.jsp",
				"data": "MAX=<%=SELECT_MAX_GALLERY%>&MD=0&PG=" + pageNum,
			}).then(
				function(htmlList){
					$.ajax({
						"type": "POST",
						"url": "/f/PageBarF.jsp",
						"data": "TOTAL=<%=cFollowListResults.userNum%>&PARPAGE=<%=cFollowListResults.selectMaxGallery%>&PG=" + pageNum,
					}).then(
						function(htmlPageBar){
							$("#FollowListPageBar").empty();
							$("#FollowListPageBar").append(htmlPageBar);
						}
					)
					$("#FollowList").html(htmlList);
					$("*").scrollTop(0);
				},
				function(msg) {
					console.log(msg);
				}
			);
		});
	});
</script>

<div class="SettingList">
	<div id="FollowList" class="IllustThumbList">
		<%for(int nCnt = 0; nCnt< cFollowListResults.userList.size(); nCnt++) {
			CUser cUser = cFollowListResults.userList.get(nCnt);%>
		<%=CCnv.toHtmlUser(cUser, CCnv.MODE_PC, _TEX)%>
		<%if(bSmartPhone && (nCnt+1)%8==0) {%>
		<%@ include file="/inner/TAd336x280_mid.jsp"%>
		<%}%>
		<%}%>
	</div>

	<nav id="FollowListPageBar" class="PageBar">
		<%=CPageBar.CreatePageBarSp(null, null, cFollowListResults.m_nPage, cFollowListResults.userNum, cFollowListResults.selectMaxGallery)%>
	</nav>
</div>
