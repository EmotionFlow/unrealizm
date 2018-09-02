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
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

DateFormat cContentDateFromat = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT, request.getLocale());
cContentDateFromat.setTimeZone(Common.GetTimeZone(request));
SimpleDateFormat cImgArg = new SimpleDateFormat("yyyyMMddHHmmss");

String strTitle = "";
String[] strs = cResults.m_cContent.m_strDescription.split("¥n");
if(strs.length>0 && strs[0].length()>0) {
	strTitle = strs[0];
}
strTitle = Common.SubStrNum(strTitle, 10);
String strDesc = cResults.m_cContent.m_strDescription.replaceAll("\n", " ").replaceAll("\r", " ");
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=Common.ToStringHtml(String.format(_TEX.T("IllustViewPc.Title.Desc"), strDesc, cResults.m_cUser.m_strNickName))%>" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(strTitle)%>" />
		<meta name="twitter:description" content="<%=Common.ToStringHtml(String.format(_TEX.T("IllustViewPc.Title.Desc"), strDesc, cResults.m_cUser.m_strNickName))%>" />
		<meta name="twitter:image" content="https://poipiku.com/<%=cResults.m_cContent.m_strFileName%>" />

		<title><%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(strTitle)%></title>

		<script type="text/javascript">
			$(function(){
				$('#MenuHome').addClass('Selected');
			});
		</script>

		<script type="text/javascript">
			var g_nNextId = <%=cResults.m_cContent.m_nContentId%>;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": { "SID" : nStartId, "ID" :  <%=cResults.m_cContent.m_nUserId%>},
					"url": "/f/IllustListTimeLineF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						if(g_nNextId == -1) {
							$('#InfoMsg').show();
						}
						for(var nCnt=0; nCnt<data.result.length; nCnt++) {
							var $objItem = CreateIllustItemPc(data.result[nCnt], <%=cCheckLogin.m_nUserId%>);
							var $objUserInfoCmdFollow = $("#UserInfoCmdFollow").clone(true).attr('id', '');
							$objItem.find('.IllustItemUser').append($objUserInfoCmdFollow);
							$("#IllustItemList").append($objItem);
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function DeleteContent(nContentId) {
				<%if(cCheckLogin.m_bLogin) {%>
				if(!window.confirm('<%=_TEX.T("IllustListV.CheckDelete")%>')) return;
				DeleteContentBase(<%=cCheckLogin.m_nUserId%>, nContentId);
				return false;
				<%} else {%>
				location.href="/";
				<%}%>
			}

			function UpdateFollow() {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": <%=cResults.m_cUser.m_nUserId%>, "CHK": (bFollow)?0:1 },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdFollow').addClass('Selected');
							$('.UserInfoCmdFollow').html("フォロー中");
						} else if(data.result==2) {
							$('.UserInfoCmdFollow').removeClass('Selected');
							$('.UserInfoCmdFollow').html("フォローする");
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
				<%
				if(cResults.m_bReply) {
					CComment cComment = cResults.m_cContent.m_vComment.get(cResults.m_cContent.m_vComment.size()-1);
				%>
				ResComment(<%=cResults.m_cContent.m_nContentId%>, <%=cComment.m_nUserId%>, '<%=Common.ToStringHtml(cComment.m_strNickName)%>');
				<%}%>
				addContents(g_nNextId);
			});

			$(document).ready(function() {
				$(window).bind("scroll", function() {
					$(window).height();
					if($("#IllustItemList").height() - $(window).height() - $(window).scrollTop() < 100) {
						addContents(g_nNextId);
					}
				});
			});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">

			<%=cResults.m_cContent.toHtml(cCheckLogin.m_nUserId, false, _TEX)%>

			<div id="IllustItemList" class="IllustItemList">
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>