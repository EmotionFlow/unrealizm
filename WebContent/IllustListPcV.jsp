<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

IllustListC cResults = new IllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}
cResults.SELECT_MAX_GALLERY = 30;
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNum)%>" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(String.format(_TEX.T("IllustListPc.Title"), cResults.m_cUser.m_strNickName))%>" />
		<meta name="twitter:description" content="<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNum)%>" />
		<%if(!cResults.m_cUser.m_strFileName.isEmpty()) {%>
		<meta name="twitter:image" content="<%=Common.GetPoipikuUrl(cResults.m_cUser.m_strFileName)%>" />
		<%}%>
		<title><%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(String.format(_TEX.T("IllustListPc.Title"), cResults.m_cUser.m_strNickName))%></title>

		<script type="text/javascript">
		$(function(){
			<%if(cResults.m_bOwner) {%>
			$('#MenuMe').addClass('Selected');
			<%} else {%>
			$('#MenuSearch').addClass('Selected');
			<%}%>
		});

		$(function(){
			updateCategoryMenuPos(0);
			/*
			$(window).bind("scroll.slideHeader", function() {
				$('.UserInfo.Float').css('background-position-y', $(this).scrollTop()/5 + 'px');
			});
			*/
		});
		</script>

		<script>
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
		</script>
		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		<%if(!bSmartPhone) {%>
		@media screen and (min-width:1188px){
		.Wrapper.ThumbList {width: 1188px;}
		}
		<%}%>
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jspf"%>



		<div class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<div class="UserInfoBg"></div>
				<div class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
					<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Common.ToStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<span class="UserInfoCmd">
						<%
						String strTwitterUrl=String.format("https://twitter.com/share?url=%s&text=%s&hashtags=%s",
								URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"),
								URLEncoder.encode(String.format("%s%s", cResults.m_cUser.m_strNickName, _TEX.T("Twitter.UserAddition")), "UTF-8"),
								URLEncoder.encode(_TEX.T("THeader.Title"), "UTF-8"));
						%>
						<%if(!cCheckLogin.m_bLogin) {%>
						<a id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
						<a id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" href="/"></a>
						<%} else if(cResults.m_bOwner) {%>
						<a class="BtnBase UserInfoCmdFollow" href="/MyEditSettingPcV.jsp"><i class="fas fa-cog"></i> <%=_TEX.T("MyEditSetting.Title.Setting")%></a>
						<a class="BtnBase UserInfoCmdFollow" href="<%=strTwitterUrl%>" target="_blank"><i class="fab fa-twitter"></i> <%=_TEX.T("Twitter.Share.MyUrl.Btn")%></a>
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
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>" target="_blank"></a>
						</span>
						<%}%>
					</span>
				</div>
				<%if(cResults.m_bOwner) {%>
				<span class="UserInfoState">
					<span class="UserInfoStateItem Selected">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_nContentsNum%></span>
					</span>
					<a class="UserInfoStateItem" href="/FollowListPcV.jsp">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follow")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowNum%></span>
					</a>
				</span>
				<%}%>
			</div>
		</div>

		<div class="Wrapper ThumbList">
			<%if(cResults.m_vCategoryList.size()>0) {%>
			<div id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn <%if(cResults.m_strKeyword.isEmpty()){%> Selected<%}%>" href="/<%=cResults.m_nUserId%>/"><%=_TEX.T("Category.All")%></a>
				<%for(CTag cTag : cResults.m_vCategoryList) {%>
				<a class="BtnBase CategoryBtn <%if(cTag.m_strTagTxt.equals(cResults.m_strKeyword)){%> Selected<%}%>" href="/IllustListPcV.jsp?ID=<%=cResults.m_nUserId%>&KWD=<%=URLEncoder.encode(cTag.m_strTagTxt, "UTF-8")%>"><%=Util.toDescString(cTag.m_strTagTxt)%></a>
				<%}%>
			</div>
			<%}%>

			<div id="IllustThumbList" class="IllustThumbList">
				<%//if(!bSmartPhone) {%>
				<%//@ include file="/inner/TAdPc300x250_top_right.jspf"%>
				<%//}%>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_PC, _TEX)%>
					<%//if(nCnt==17) {%>
					<%//@ include file="/inner/TAdPc300x250_bottom_right.jspf"%>
					<%//}%>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/IllustListPcV.jsp", String.format("&ID=%d&KWD=%s", cResults.m_nUserId, URLEncoder.encode(cResults.m_strKeyword, "UTF-8")), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooterBase.jspf"%>
		<%//@ include file="/inner/TFooter.jspf"%>
	</body>
</html>