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
if(!cResults.getResults(cCheckLogin) || !cResults.m_bOwner) {
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
			function addMyContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"ID": <%=cResults.m_nUserId%>, "KWD": g_strKeyword,  "PG" : g_nPage},
					"url": "/f/MyIllustListF.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							g_bAdding = false;
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						} else {
							$(window).unbind("scroll.addMyContents");
						}
						$(".Waiting").remove();
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
				$(window).unbind("scroll.addMyContents");
				<%if(!cResults.m_bBlocking && !cResults.m_bBlocked){%>
				$(window).bind("scroll.addMyContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addMyContents();
					}
				});
				addMyContents();
				<%}%>
			}

			$(function(){
				updateCategoryMenuPos(0);
			});
		</script>
		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		.HeaderSetting {text-align: center; position: absolute; top: 12px; right: 10px;}
		.IllustThumb .IllustInfoBottom {
			display: block;
			width: 100%;
			box-sizing: border-box;
			padding: 0px 3px 3px 3px;
			position: absolute;
			bottom: 0;
		}
		.IllustThumb .Num {
			background-repeat: no-repeat;
			min-width: 32px;
			display: block;
			float: left;
			color: white;
			font-size: 11px;
			background: #5bd;
			box-sizing: border-box;
			border-radius: 22px;
			height: 20px;
			padding: 0 5px;
			line-height: 20px;
			text-align: center;
			z-index: 2;
		}
		.IllustThumb .Publish {
			background-repeat: no-repeat;
			min-width: 29px;
			display: block;
			float: left;
			background: #5bd;
			box-sizing: border-box;
			border-radius: 7px;
			height: 20px;
			padding: 0 5px;
			z-index: 2;
		}
		.IllustThumb .PublishIco01{ background-size: contain; background-image: url(/img/ico_warning.png);}
		.IllustThumb .PublishIco04{ background-size: contain; background-image: url(/img/ico_pass.png);}
		.IllustThumb .PublishIco05{ background-size: contain; background-image: url(/img/ico_signin.png);}
		.IllustThumb .PublishIco06{ background-size: contain; background-image: url(/img/ico_favorite.png);}
		.IllustThumb .PublishIco07{ background-size: contain; background-image: url(/img/ico_follower.png);}
		.IllustThumb .PublishIco08{ background-size: contain; background-image: url(/img/ico_follow.png);}
		.IllustThumb .PublishIco09{ background-size: contain; background-image: url(/img/ico_ff.png);}
		.IllustThumb .PublishIco10{ background-size: contain; background-image: url(/img/ico_list.png);}
		.IllustThumb .PublishIco99{ background-size: contain; background-image: url(/img/ico_visible.png);}
		.IllustThumb .PublishLimitedPublished{ background-size: contain; background-image: url(/img/ico_clock.png); background-color: #5585dd;}
		.IllustThumb .PublishLimitedNotPublished{ background-size: contain; background-image: url(/img/ico_clock.png); background-color: #dd5555;}

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
				<%if(Util.isSmartPhone(request) && cCheckLogin.m_bLogin) {%>
				<div class="FooterMenuWrapper">
					<nav class="FooterMenu">
						<a id="MenuMe" class="FooterMenuItem" href="<%=(cCheckLogin.m_bLogin)?"/"+cCheckLogin.m_nUserId+"/":"/"%>">
							<span class="FooterMenuItemIcon"></span>
							<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Me")%></span>
						</a>
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
					</nav>
				</div>
				<%}%>
				<%if(cCheckLogin.m_bLogin) {%>
				<script>
					function UpdateNotify() {
						$.getJSON("/f/CheckNotifyF.jsp", {}, function(data){
							var ntfy_num = Math.min(data.check_comment + data.check_follow + data.check_heart, 99);
							//var strNotifyNum = (ntfy_num>99)?"9+":""+ntfy_num;
							$('#InfoNumAct').html(ntfy_num);
							if(ntfy_num>0) {
								$('#InfoNumAct').show();
							} else {
								$('#InfoNumAct').hide();
							}
						});
					}
					var g_timerUpdateNotify = null;
					$(function(){
						UpdateNotify();
						g_timerUpdateNotify = setInterval(UpdateNotify, 1000*60);
					});
				</script>
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