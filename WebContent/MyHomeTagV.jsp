<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
	return;
}

MyHomeTagC cResults = new MyHomeTagC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>home</title>
		<script>
		var g_nPage = 1;
		var g_bAdding = false;
		function addContents() {
			if(g_bAdding) return;
			g_bAdding = true;
			var $objMessage = $("<div/>").addClass("Waiting");
			$("#IllustThumbList").append($objMessage);
			$.ajax({
				"type": "post",
				"data": {"PG" : g_nPage},
				"url": "/f/MyHomeTagF.jsp",
				"success": function(data) {
					if(data) {
						g_nPage++;
						$('#InfoMsg').hide();
						$("#IllustThumbList").append(data);
						g_bAdding = false;
						gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
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

		$(function(){
			$(window).bind("scroll.addContents", function() {
				$(window).height();
				if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
					addContents();
				}
			});
		});
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>
		<div class="Wrapper ItemList">
			<div id="IllustThumbList" class="IllustThumbList">
				<%if(cResults.m_vContentList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 160px 0; text-align: center; background-color: #fff;">
					タグやキーワードを<br />
					お気に入り登録すると<br />
					ここに表示されます<br />
				</div>
				<%}%>

				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CTag cTag = cResults.m_vContentList.get(nCnt);%>
					<%if(cTag.m_nTypeId==Common.FOVO_KEYWORD_TYPE_TAG) {%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX)%>
					<%} else {%>
					<%=CCnv.toHtmlKeyword(cTag, CCnv.MODE_SP, _TEX)%>
					<%}%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMid.jsp"%>
					<%}%>
				<%}%>
			</div>

		</div>
	</body>
</html>