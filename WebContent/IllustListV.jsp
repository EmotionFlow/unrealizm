<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustListC cResults = new IllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	if(!cCheckLogin.m_bLogin) {
		response.sendRedirect("/StartPoipikuV.jsp");
		return;
	}
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title><%=cResults.m_cUser.m_strNickName%></title>
		<script>
			var g_nPage = 1; // start 1
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": {"PG" : g_nPage},
					"url": "/f/IllustListF.jsp",
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

			function UpdateBlock() {
				var bBlocked = $("#UserInfoCmdBlock").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": <%=cResults.m_cUser.m_nUserId%>, "CHK": (bBlocked)?0:1 },
					"url": "/f/UpdateBlockF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('#UserInfoCmdBlock').addClass('Selected');
							$('#UserInfoCmdFollow').removeClass('Selected');
							$('#UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
							$('#UserInfoCmdFollow').hide();
						} else if(data.result==2) {
							$('#UserInfoCmdBlock').removeClass('Selected');
							$('#UserInfoCmdFollow').removeClass('Selected');
							$('#UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
							$('#UserInfoCmdFollow').show();
						} else {
							DispMsg('ブロックできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				<%if(!cResults.m_bBlocking && !cResults.m_bBlocked){%>
				$(window).bind("scroll", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
				<%}%>
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
			<div class="UserInfo">
				<div class="UserInfoBg"></div>
				<div class="UserInfoUser">
					<span class="UserInfoUserThumb">
						<%if(!cResults.m_cUser.m_strFileName.isEmpty()) {%>
						<img class="UserInfoUserThumbImg" src="<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>" />
						<%}%>
					</span>
					<span class="UserInfoUserName"><%=cResults.m_cUser.m_strNickName%></span>
					<%if(!cResults.m_cUser.m_strProfile.isEmpty()) {%>
					<span class="UserInfoProgile"><%=Common.ToStringHtml(cResults.m_cUser.m_strProfile)%></span>
					<%}%>
				</div>
				<span class="UserInfoCmd">
					<%if(cResults.m_bOwner) {%>
					<a class="BtnBase UserInfoCmdFollow" href="/MyEditSettingV.jsp"><span class="typcn typcn-cog-outline"></span><%=_TEX.T("MyEditSetting.Title.Setting")%></a>
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
					<%
					String strTwitterUrl="https://twitter.com/share?url=" + URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8");
					%>
					<span class="IllustItemCommandSub">
						<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>"></a>
					</span>
				</span>
				<%if(cResults.m_bOwner) {%>
				<span class="UserInfoState">
					<a class="UserInfoStateItem" href="/FollowListV.jsp">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follow")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowNum%></span>
					</a>
					<a class="UserInfoStateItem" href="/FollowerListV.jsp">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follower")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowerNum%></span>
					</a>
				</span>
				<%}%>
			</div>

			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMid.jspf"%>
					<%}%>
				<%}%>
			</div>

		</div>
	</body>
</html>