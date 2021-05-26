<%@page import="jp.pipa.poipiku.controller.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
FollowListC cBlockListResults = new FollowListC();
cBlockListResults.getParam(request);
cBlockListResults.m_nMode = 1;
cBlockListResults.m_nPage = cResults.m_nListPage;
cBlockListResults.SELECT_MAX_GALLERY = 30;
cBlockListResults.getResults(checkLogin);
%>
<script type="application/javascript">
	$(function(){
		$(document).on("click", "#BlockListPageBar .PageBarItem", function(ev){
			const pageNum = $(ev.target).attr("data-page");
			$.ajax({
				"type": "POST",
				"url": "/f/BlockListF.jsp",
				"data": "MAX=<%=cBlockListResults.SELECT_MAX_GALLERY%>&MD=1&PG=" + pageNum,
			}).then(
				function(htmlList){
					$.ajax({
						"type": "POST",
						"url": "/f/PageBarF.jsp",
						"data": "TOTAL=<%=cBlockListResults.m_nContentsNum%>&PARPAGE=<%=cBlockListResults.SELECT_MAX_GALLERY%>&PG=" + pageNum,
					}).then(
						function(htmlPageBar){
							$("#BlockListPageBar").empty();
							$("#BlockListPageBar").append(htmlPageBar);
						}
					)
					$("#BlockList").html(htmlList);
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
	<div id="BlockList" class="IllustThumbList">
		<%for(int nCnt = 0; nCnt< cBlockListResults.m_vContentList.size(); nCnt++) {
			CUser cUser = cBlockListResults.m_vContentList.get(nCnt);%>
		<%=CCnv.toHtmlUser(cUser, CCnv.MODE_PC, _TEX)%>
		<%if(bSmartPhone && (nCnt+1)%15==0) {%>
		<%@ include file="/inner/TAd336x280_mid.jsp"%>
		<%}%>
		<%}%>
	</div>

	<nav id="BlockListPageBar" class="PageBar">
		<%=CPageBar.CreatePageBarSp(null, null, cBlockListResults.m_nPage, cBlockListResults.m_nContentsNum, cBlockListResults.SELECT_MAX_GALLERY)%>
	</nav>
</div>
