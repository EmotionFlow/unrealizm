<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustViewC cResults = new IllustViewC();
cResults.getParam(request);
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

String strTitle = cResults.m_cContent.m_cUser.m_strNickName;
String[] strs = cResults.m_cContent.m_strDescription.split("¥n");
if(strs.length>0 && strs[0].length()>0) {
	strTitle = strs[0];
}
strTitle = Common.SubStrNum(strTitle, 10);
String strDesc = "["+_TEX.T(String.format("Category.C%d", cResults.m_cContent.m_nCategoryId))+"]" +  cResults.m_cContent.m_strDescription.replaceAll("\n", " ").replaceAll("\r", " ");
if(strDesc.length()>100) strDesc = strDesc.substring(0, 100);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=Common.ToStringHtml(String.format(_TEX.T("IllustView.Title.Desc"), strDesc, cResults.m_cContent.m_cUser.m_strNickName))%>" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(strTitle)%>" />
		<meta name="twitter:description" content="<%=Common.ToStringHtml(String.format(_TEX.T("IllustView.Title.Desc"), strDesc, cResults.m_cContent.m_cUser.m_strNickName))%>" />
		<%if(cResults.m_cContent.m_nSafeFilter<2) {%>
		<meta name="twitter:image" content="<%=Common.GetPoipikuUrl(cResults.m_cContent.m_strFileName)%>_640.jpg" />
		<%} else {%>
		<meta name="twitter:image" content="<%=Common.GetPoipikuUrl("/img/warning.png")%>" />
		<%}%>
		<title><%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(strTitle)%></title>

		<script type="text/javascript">
			$(function(){
				$('#MenuSearch').addClass('Selected');
			});
		</script>

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
					"data": {
						"ID" : <%=cResults.m_cContent.m_nUserId%>,
						"TD" : <%=cResults.m_cContent.m_nContentId%>,
						"PG" : g_nPage,
						"MD" : <%=CCnv.MODE_PC%>,
						"ADF" : <%=cResults.m_cContent.m_nSafeFilter%>},
					"url": "/f/IllustViewF.jsp",
					"success": function(data) {
						if(data) {
							g_nPage++;
							$("#IllustItemList").append(data);
							$(".Waiting").remove();
							g_bAdding = false;
							if(g_nPage>0) {
								console.log(location.pathname+'/'+g_nPage+'.html');
								gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
							}
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
		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper ViewPc">

			<div id="IllustItemList" class="IllustItemList">
				<%=CCnv.Content2Html(cResults.m_cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
			</div>

			<%if(!bSmartPhone) {%>
			<div class="PcSideBar" style="margin-top: 30px;">
				<div class="FixFrame">
					<div class="PcSideBarItem">
						<%@ include file="/inner/TAdPc300x250_top_right.jspf"%>
					</div>

					<div class="PcSideBarItem" style="position: absolute; bottom: 0;">
						<%@ include file="/inner/TAdPc300x250_bottom_right.jspf"%>
					</div>
				</div>
			</div>
			<%}%>

		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>