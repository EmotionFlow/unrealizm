<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}
request.setCharacterEncoding("UTF-8");
String strKeyword = Common.ToString(request.getParameter("KWD"));
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("SearchTagByKeyword.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("SearchTagByKeyword.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuSearch').addClass('Selected');
			$('#HeaderSearchBox').val('<%=Common.ToStringHtml(strKeyword)%>');
		});
		</script>

		<style>
		#HeaderLink {display: none;}
		#HeaderSearchWrapper {display: block;}
		</style>

		<script>
			var g_nNextId = -1;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": { "SID" : nStartId, "KWD" : decodeURIComponent("<%=URLEncoder.encode(strKeyword, "UTF-8")%>")},
					"url": "/f/SearchTagByKeywordF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						for(var nCnt=0; nCnt<data.result_num; nCnt++) {
							var cItem = data.result[nCnt];
							var $objItem = $("<a/>").addClass("TagItem").attr("href", "/SearchIllustByTagPcV.jsp?KWD="+cItem.keyword).text('#'+cItem.keyword);
							$("#IllustThumbList").append($objItem);
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				addContents(g_nNextId);
			});

			$(document).ready(function() {
				$(window).bind("scroll", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 100) {
						addContents(g_nNextId);
					}
				});
			});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<div class="Wrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(strKeyword, "UTF-8")%>">illustration</a>
				<a class="TabMenuItem Selected" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(strKeyword, "UTF-8")%>">tag</a>
				<a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(strKeyword, "UTF-8")%>">user</a>
			</div>

			<div id="IllustThumbList" class="IllustItemList">
			</div>
		</div>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>