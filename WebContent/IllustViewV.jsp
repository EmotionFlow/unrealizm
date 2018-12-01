<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
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
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
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
					"data": {
						"ID" : <%=cResults.m_cContent.m_nUserId%>,
						"TD" : <%=cResults.m_cContent.m_nContentId%>,
						"PG" : g_nPage,
						"MD" : <%=CCnv.MODE_SP%>,
						"ADF" : <%=cResults.m_cContent.m_nSafeFilter%>},
					"url": "/f/IllustViewF.jsp",
					"success": function(data) {
						if(data) {
							g_nPage++;
							$("#IllustItemList").append(data);
							$(".Waiting").remove();
							g_bAdding = false;
							if(g_nPage>0) {
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
		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		</style>
	</head>

	<body>
		<div class="Wrapper">
		<%{%>
			<div class="UserInfo">
				<div class="UserInfoBg"></div>
				<div class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/IllustListV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>"></a>
					<h2 class="UserInfoUserName"><a href="/IllustListV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Common.ToStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_SP)%></h3>
					<span class="UserInfoCmd">
						<%
						String strTwitterUrl=String.format("https://twitter.com/share?url=%s&text=%s&hashtags=%s",
								URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"),
								URLEncoder.encode(String.format("%s%s", cResults.m_cUser.m_strNickName, _TEX.T("Twitter.UserAddition")), "UTF-8"),
								URLEncoder.encode(_TEX.T("THeader.Title"), "UTF-8"));
						%>
						<%if(cResults.m_bOwner) {%>
						&nbsp;
						<%} else if(cResults.m_bBlocking){%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" style="display: none;" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock Selected" onclick="UpdateBlock()"></span>
						<%} else if(cResults.m_bBlocked){%>
						<%} else if(cResults.m_bFollow){%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> Selected" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock " onclick="UpdateBlock()"></span>
						<%} else {%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" onclick="UpdateBlock()"></span>
						<%}%>
						<%if(!cResults.m_bOwner) {%>
						<span class="IllustItemCommandSub">
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>"></a>
						</span>
						<%}%>
					</span>
				</div>
			</div>
			<%}%>

			<div id="IllustItemList" class="IllustItemList">
				<%=CCnv.Content2Html(cResults.m_cContent, cCheckLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult)%>
			</div>

			<div class="UserInfo">
				<div class="UserInfoBg"></div>
				<div class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/IllustListV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>"></a>
					<h2 class="UserInfoUserName"><a href="/IllustListV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Common.ToStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_SP)%></h3>
					<span class="UserInfoCmd">
						<%
						String strTwitterUrl=String.format("https://twitter.com/share?url=%s&text=%s&hashtags=%s",
								URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"),
								URLEncoder.encode(String.format("%s%s", cResults.m_cUser.m_strNickName, _TEX.T("Twitter.UserAddition")), "UTF-8"),
								URLEncoder.encode(_TEX.T("THeader.Title"), "UTF-8"));
						%>
						<%if(cResults.m_bOwner) {%>
						&nbsp;
						<%} else if(cResults.m_bBlocking){%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" style="display: none;" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock Selected" onclick="UpdateBlock()"></span>
						<%} else if(cResults.m_bBlocked){%>
						<%} else if(cResults.m_bFollow){%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> Selected" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock " onclick="UpdateBlock()"></span>
						<%} else {%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" onclick="UpdateBlock()"></span>
						<%}%>
						<%if(!cResults.m_bOwner) {%>
						<span class="IllustItemCommandSub">
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>"></a>
						</span>
						<%}%>
					</span>
				</div>
			</div>
		</div>
	</body>
</html>