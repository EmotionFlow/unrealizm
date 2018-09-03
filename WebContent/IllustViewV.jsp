<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/IllustViewC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustViewCParam cParam = new IllustViewCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

IllustViewC cResults = new IllustViewC();
if(!cResults.GetResults(cParam)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%
		String strTitle = cResults.m_cContent.m_cUser.m_strNickName;
		String[] strs = cResults.m_cContent.m_strDescription.split("¥n");
		if(strs.length>0 && strs[0].length()>0) {
			strTitle = strs[0];
		}
		strTitle = Common.SubStrNum(strTitle, 10);
		%>
		<title><%=strTitle%></title>
		<script type="text/javascript">
			var g_nPage = 0;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"ID" :  <%=cResults.m_cContent.m_nUserId%>, "TD" : <%=cResults.m_cContent.m_nContentId%>, "PG" : g_nPage, "MD" : <%=CCnv.MODE_SP%>},
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


			function DeleteContent(nContentId) {
				if(!window.confirm('<%=_TEX.T("IllustListV.CheckDelete")%>')) return;
				DeleteContentBase(<%=cCheckLogin.m_nUserId%>, nContentId);
				return false;
			}

			function UpdateFollow() {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": <%=cResults.m_cContent.m_nUserId%>, "CHK": (bFollow)?0:1 },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdFollow').addClass('Selected');
							$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Following")%>");
						} else if(data.result==2) {
							$('.UserInfoCmdFollow').removeClass('Selected');
							$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
						} else {
							DispMsg('フォローできませんでした');
						}
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
				<%=CCnv.toHtml(cResults.m_cContent, cCheckLogin.m_nUserId, CCnv.MODE_SP, _TEX)%>
			</div>
			<div id="IllustItemList" class="IllustItemList">
			</div>
		</div>
	</body>
</html>