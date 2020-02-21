<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/MyIllustListPcV.jsp").forward(request,response);
	return;
}

IllustListC cResults = new IllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	if(!cCheckLogin.m_bLogin) {
		if(isApp){
			response.sendRedirect("/StartPoipikuAppV.jsp");
		} else {
			response.sendRedirect("/StartPoipikuV.jsp");
		}
		return;
	}
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}
cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
cResults.m_bDispUnPublished = true;
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
		#MenuSettings {
			position: absolute;
			top: 5px;
			right: 9px;
			display: block;
		}
		#MenuSettings .MenuSettingsIcon{
			background: url(/img/menu_pc-05.png);
			background-size: 1500%;
			background-repeat: no-repeat;
			background-position: -395px -28px;
			top: 5px;
			left: 1px;
			position: relative;
			width: 28px;
			display: inline-block;
			height: 28px;
		}
		#MenuSettings .MenuSettingsName{
			display: block;
			width: 100%;
			height: 10px;
			line-height: 10px;
			text-align: center;
			font-size: 9px;
			color: #5bd;
		}
		.NoContents {display: block; padding: 250px 0; width: 100%; text-align: center;}
		</style>
	</head>

	<body>
		<header class="Header">
			<div id="HeaderSlider"></div>
			<div class="HeaderWrapper">
				<div id="HeaderTitleWrapper" class="HeaderTitleWrapper">
					<h1 class="HeaderTitle">
						<a id="HeaderLink" class="HeaderLink" href="/">
							<img  class="HeaderImg" src="/img/pc_top_title-02.png" alt="<%=_TEX.T("THeader.Title")%>" />
						</a>
					</h1>
					<a id="MenuSettings" href="<%="/MyEditSettingPcV.jsp?ID="+cCheckLogin.m_nUserId %>">
						<span class="MenuSettingsIcon"></span>
						<span class="MenuSettingsName"><%=_TEX.T("MyEditSetting.Title.Setting")%></span>
					</a>
				</div>
			</div>
		</header>

		<%if(!isApp && cCheckLogin.m_bLogin) {%>
		<div class="FooterMenuWrapper">
			<nav class="FooterMenu">
				<a id="MenuMe" class="FooterMenuItem Selected" href="<%=(cCheckLogin.m_bLogin) ? "/MyIllustListV.jsp?ID="+cCheckLogin.m_nUserId : "/" %>">
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
				<%if(cResults.m_vContentList.size()>0){%>
					<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%=CCnv.toMyThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, cCheckLogin)%>
					<%}%>
				<%}else{%>
					<span class="NoContents"><%=_TEX.T("IllustListV.NoContents.Me")%></span>
				<%}%>
			</section>
		</article>
	</body>
</html>