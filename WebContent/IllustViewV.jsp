<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustViewC cResults = new IllustViewC();
cResults.getParam(request);
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

String strTitle = cResults.m_cContent.m_cUser.m_strNickName;
String[] strs = cResults.m_cContent.m_strDescription.split("¥n");
if(strs.length>0 && strs[0].length()>0) {
	strTitle = strs[0];
}
strTitle = Common.SubStrNum(strTitle, 10);
ArrayList<String> vResult = Util.getRankEmojiDaily(Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<%
		%>
		<title><%=strTitle%></title>
		<script type="text/javascript">
			var g_nPage = 0;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustItemList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"ID" : <%=cResults.m_cContent.m_nUserId%>, "TD" : <%=cResults.m_cContent.m_nContentId%>, "PG" : g_nPage, "MD" : <%=CCnv.MODE_SP%>},
					"url": "/f/IllustViewF.jsp",
					"success": function(data) {
						if(data) {
							g_nPage++;
							$("#IllustItemList").append(data);
							$(".Waiting").remove();
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

			function UpdateFollow(nUserId, nFollowUserId) {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": nUserId, "IID": nFollowUserId },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdFollow_'+nFollowUserId).addClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Following")%>");
						} else if(data.result==2) {
							$('.UserInfoCmdFollow_'+nFollowUserId).removeClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Follow")%>");
						} else {
							DispMsg('フォローできませんでした');
						}
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

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				addContents();
			});

			$(document).ready(function() {
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustItemList").height() - $(window).height() - $(window).scrollTop() < 200) {
						addContents();
					}
				});
			});
		</script>
	</head>

	<body>
		<div class="Wrapper">

			<div class="IllustItemList">
				<%=CCnv.Content2Html(cResults.m_cContent, cCheckLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult)%>
			</div>
			<div id="IllustItemList" class="IllustItemList" style="margin-top: 50px;"></div>

		</div>
	</body>
</html>