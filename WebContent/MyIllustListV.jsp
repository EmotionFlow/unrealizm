<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

IllustListC cResults = new IllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	if(!cCheckLogin.m_bLogin) {
		response.sendRedirect("/StartPoipikuV.jsp");
		return;
	}
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}
cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=cResults.m_cUser.m_strNickName%></title>
		<script>
			var g_nPage = 1; // start 1
			var g_strKeyword = '<%=cResults.m_strKeyword%>';
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"ID": <%=cResults.m_nUserId%>, "KWD": g_strKeyword,  "PG" : g_nPage},
					"url": "/f/IllustListF.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
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

			function UpdateBlock() {
				var bBlocked = $("#UserInfoCmdBlock").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": <%=cResults.m_cUser.m_nUserId%>, "CHK": (bBlocked)?0:1 },
					"url": "/f/UpdateBlockF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdBlock').addClass('Selected');
							$('.UserInfoCmdFollow').removeClass('Selected');
							$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
							$('.UserInfoCmdFollow').hide();
							location.reload(true);
						} else if(data.result==2) {
							$('.UserInfoCmdBlock').removeClass('Selected');
							$('.UserInfoCmdFollow').removeClass('Selected');
							$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
							$('.UserInfoCmdFollow').show();
							location.reload(true);
						} else {
							DispMsg('ブロックできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function changeCategory(elm, param) {
				g_nPage = 0;
				g_strKeyword = param;
				g_bAdding = false;
				$("#IllustThumbList").empty();
				$('#CategoryMenu .CategoryBtn').removeClass('Selected');
				$(elm).addClass('Selected');
				updateCategoryMenuPos(300);
				$(window).unbind("scroll.addContents");
				<%if(!cResults.m_bBlocking && !cResults.m_bBlocked){%>
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
				addContents();
				<%}%>
			}

			$(function(){
				<%if(!cResults.m_bBlocking && !cResults.m_bBlocked){%>
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
				<%}%>
			});

			$(function(){
				updateCategoryMenuPos(0);
			});
		</script>
		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		.HeaderSetting {text-align: center; position: absolute; top: 12px; right: 10px;}
		</style>
	</head>

	<body>
		<header class="Header">
			<div id="HeaderSlider"></div>
			<div class="HeaderWrapper">
				<div id="HeaderTitleWrapper" class="HeaderTitleWrapper">
					<h1 class="HeaderTitle">
						<a id="HeaderLink" class="HeaderLink" href="/">
							<img  class="HeaderImg" src="/img/pc_top_title.jpg" alt="<%=_TEX.T("THeader.Title")%>" />
						</a>
					</h1>
					<a class="HeaderSetting BtnBase UserInfoCmdFollow" href="/MyEditSettingV.jsp"><i class="fas fa-cog"></i> <%=_TEX.T("MyEditSetting.Title.Setting")%></a>
				</div>

				<%if(!Util.isSmartPhone(request)) {%>
				<nav class="FooterMenu">
					<%if(!cCheckLogin.m_bLogin) {%>
					<form method="post" name="login_from_twitter_tmenupc_01" action="/LoginFormTwitterPc.jsp">
						<input id="login_from_twitter_tmenupc_callback_01" type="hidden" name="CBPATH" value=""/>
						<script>{
							let s = document.URL.split("/");
							for(let i=0; i<3; i++){s.shift();}
							$('#login_from_twitter_tmenupc_callback_01').val("/" + s.join("/"));
						}</script>
						<a class="BtnBase Rev HeaderLoginBtnPc" href="javascript:login_from_twitter_tmenupc_01.submit()">
							<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login.Short")%>
						</a>
					</form>
					<%} else {%>
					<!--
					<a id="MenuSearch" class="FooterMenuItem" href="/NewArrivalPcV.jsp">
						<span class="FooterMenuItemIcon"></span>
						<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Search")%></span>
					</a>
					<span class="MenuSep"></span>
					-->
					<a id="MenuHome" class="FooterMenuItem" href="/MyHomePcV.jsp">
						<span class="FooterMenuItemIcon"></span>
						<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Home")%></span>
					</a>
					<a id="MenuUpload" class="FooterMenuItem" href="/UploadFilePcV.jsp">
						<span class="FooterMenuItemIcon"></span>
						<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Upload")%></span>
					</a>
					<a id="MenuAct" class="FooterMenuItem" href="/ActivityListPcV.jsp">
						<span class="FooterMenuItemIcon">
							<div id="InfoNumAct" class="InfoNum">0</div>
						</span>
						<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Act")%></span>
					</a>
					<a id="MenuMe" class="FooterMenuItem" href="<%=(cCheckLogin.m_bLogin)?"/"+cCheckLogin.m_nUserId+"/":"/"%>">
						<span class="FooterMenuItemIcon"></span>
						<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Me")%></span>
					</a>
					<%}%>
				</nav>
				<%}%>
			</div>
		</header>

		<article class="Wrapper">
			<%if(cResults.m_vCategoryList.size()>0) {%>
			<nav id="CategoryMenu" class="CategoryMenu">
				<span class="BtnBase CategoryBtn <%if(cResults.m_strKeyword.isEmpty()){%> Selected<%}%>" onclick="changeCategory(this, '')"><%=_TEX.T("Category.All")%></span>
				<%for(CTag cTag : cResults.m_vCategoryList) {%>
				<span class="BtnBase CategoryBtn <%if(cTag.m_strTagTxt.equals(cResults.m_strKeyword)){%> Selected<%}%>" onclick="changeCategory(this, '<%=cTag.m_strTagTxt%>')"><%=Util.toDescString(cTag.m_strTagTxt)%></span>
				<%}%>
			</nav>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toMyThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, cCheckLogin)%>
				<%}%>
			</section>
		</article>
	</body>
</html>