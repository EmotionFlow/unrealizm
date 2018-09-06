<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>recent</title>
		<script>
			var g_nPage = 0;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": {"PG" : g_nPage, "MD" : <%=CCnv.MODE_SP%>},
					"url": "/f/NewArrivalF.jsp",
					"success": function(data) {
						if(data) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
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

			$(function(){
				addContents();
			});

			$(document).ready(function() {
				$(window).bind("scroll", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 200) {
						addContents();
					}
				});
			});
		</script>
	</head>

	<body>
		<div class="Wrapper">

			<div id="IllustThumbList" class="IllustThumbList"></div>

		</div>
	</body>
</html>