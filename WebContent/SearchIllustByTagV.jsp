<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
String strKeyword = Common.ToString(request.getParameter("KWD"));
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title><%=Common.ToStringHtml(strKeyword)%></title>
		<script>
			var g_nNextId = -1;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				console.log("start");
				$.ajaxSingle({
					"type": "post",
					"data": { "SID" : nStartId, "KWD" :  decodeURIComponent("<%=URLEncoder.encode(strKeyword, "UTF-8")%>")},
					"url": "/f/SearchIllustByTagF.jsp",
					"dataType": "json",
					"success": function(data) {
						console.log("done");
						console.log(data);
						g_nNextId = data.end_id;
						for(var nCnt=0; nCnt<data.result_num; nCnt++) {
							$("#IllustThumbList").append(CreateIllustThumb(data.result[nCnt]));
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
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 200) {
						addContents(g_nNextId);
					}
				});
			});
		</script>
	</head>

	<body>
		<div class="Wrapper">
			<div class="AutoLink" style="box-sizing: border-box; margin: 10px 0; padding: 0 5px;">#<%=Common.ToStringHtml(strKeyword)%></div>

			<%@ include file="/inner/TAdTop.jspf"%>

			<div id="IllustThumbList" class="IllustThumbList"></div>

			<%@ include file="/inner/TAdBottom.jspf"%>
		</div>
	</body>
</html>