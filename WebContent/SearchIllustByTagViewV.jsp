<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

SearchIllustByTagViewC cResults = new SearchIllustByTagViewC();
cResults.getParam(request);
cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(cCheckLogin);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>#<%=Common.ToStringHtml(cResults.m_strKeyword)%></title>
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
					"data": {"TD" : <%=cResults.m_nContentId%>, "KWD" :  decodeURIComponent("<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"), "PG" : g_nPage},
					"url": "/f/SearchIllustByTagViewF.jsp",
					"success": function(data) {
						if(data) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustItemList").append(data);
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