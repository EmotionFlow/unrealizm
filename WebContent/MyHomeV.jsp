<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
	return;
}

MyHomeC cResults = new MyHomeC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
ArrayList<String> vResult = Util.getRankEmojiDaily(Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>home</title>
		<script>
			var g_nPage = 1;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustItemList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"PG" : g_nPage},
					"url": "/f/MyHomeF.jsp",
					"success": function(data) {
						if(data) {
							g_nPage++;
							$("#IllustItemList").append(data);
							g_bAdding = false;
						} else {
							$(window).unbind("scroll.addContents");
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function DeleteContent(nUserId, nContentId) {
				if(!window.confirm('<%=_TEX.T("IllustListV.CheckDelete")%>')) return;
				DeleteContentBase(nUserId, nContentId);
				return false;
			}

			function MoveTab() {
				sendObjectMessage("moveTabNewArrival")
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustItemList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
			});
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>
		<div class="Wrapper">
			<%if(cResults.m_vContentList.size()<=0) {%>
			<div id="InfoMsg" style="float: left; width: 100%; padding: 160px 0 0 0; text-align: center;">
				ポイピクへようこそ<br />
				<br />
				放置絵ポイポイ<br />
				練習ポイポイ<br />
				らくがきポイポイ<br />
				進捗ポイポイ<br />
				<br />
				<br />
				<a class="BtnBase" href="javascript:void(0)" onclick="MoveTab()">
					フォローする人を探す
				</a>
			</div>
			<%}%>
			<div id="IllustItemList" class="IllustItemList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%= CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult)%>
					<%if((nCnt+1)%5==0) {%>
					<%@ include file="/inner/TAdMid.jspf"%>
					<%}%>
				<%}%>
			</div>

		</div>
	</body>
</html>