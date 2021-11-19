<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
boolean isApp = true;

if(!bSmartPhone) {
	request.getRequestDispatcher("/MyIllustListPcV.jsp").forward(request,response);
	return;
}

MyIllustListC cResults = new MyIllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	if(!checkLogin.m_bLogin) {
		getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
		return;
	}
	cResults.m_nUserId = checkLogin.m_nUserId;
}

checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

cResults.m_bDispUnPublished = true;
if(!cResults.getResults(checkLogin) || !cResults.m_bOwner) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=cResults.m_cUser.m_strNickName%></title>
		<%@ include file="/inner/TTweetMyBox.jsp"%>
		<%@ include file="/inner/TSwitchUser.jsp"%>

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
					"url": "/f/MyIllustListAppF.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							console.log(data);
							g_bAdding = false;
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						} else {
							$(window).unbind("scroll.addMyContents");
							console.log("unbind");
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
				$(window).bind("scroll.addMyContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 600) {
						addMyContents();
					}
				});
			});
		</script>
		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		.HeaderSetting {text-align: center; position: absolute; top: 12px; right: 10px;}
		.NoContents {display: block; padding: 250px 0; width: 100%; text-align: center;}
		.TweetMyBox {padding-top: 5px; text-align: center;}
		</style>

		<%if(cResults.m_cUser.m_nPassportId>=Common.PASSPORT_ON && !cResults.m_cUser.m_strBgFileName.isEmpty()) {%>
		<style>
			body {
				background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strBgFileName)%>');
				background-repeat: repeat;
				background-position: 50% top;
				background-attachment: fixed;
			}
		</style>
		<%}%>

		<style>
            #SwitchUserList{
                float: left;
                width: 100%;
                box-sizing: border-box;
                overflow: hidden;
                position: fixed;
                align-items: center;
                justify-content: center;
                background: #fff;
                color: #6d6965;
                flex-flow: column;
                z-index: 999;
            }
            .SwitchUserItem {
                display: flex;
                flex-flow: row nowrap;
                width: 100%;
                height: 55px;
                box-sizing: border-box;
                position: relative;
                text-align: center;
                padding: 2px 2px 2px 2px;
                border-bottom: solid 1px #eee;
                align-items: center;
                color: #6d6965;
            }
            .SwitchUserThumb {
                display: block;
                flex: 0 0 40px;
                height: 40px;
                overflow: hidden;
                border-radius: 40px;
                background-size: cover;
                background-position: 50% 50%;
            }
            .SwitchUserNickname {
                display: block;
                flex: 1 1 80px;
                padding: 0;
                margin: 0 0 0 3px;
                text-align: left;
                font-size: 16px;
                white-space: nowrap;
                overflow: hidden;
            }
            .SwitchUserStatus {
                width: 19px;
                border-left: solid 1px #eee;
                padding: 10px 13px;
                font-size: 16px;
            }
            .SwitchUserStatus > .Selected {
                color: #3498da;
            }
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuApp.jsp" %>
		<%@ include file="/inner/MyIllustListSwitchUserList.jsp"%>
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>

		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/IllustListAppV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>"></a>
					<h2 class="UserInfoUserName"><a href="/IllustListAppV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<span class="UserInfoCmd">
						<span class="TweetMyBox">
							<a id="OpenTweetMyBoxDlgBtn" href="javascript:void(0);" class="BtnBase">
								<i class="fab fa-twitter"></i> <%=_TEX.T("MyIllustListV.TweetMyBox")%>
							</a>
							<a href="/MyRequestListAppV.jsp?MENUID=RECEIVED" class="BtnBase">
								<%=_TEX.T("Request.MyRequests")%>
							</a>
							<a id="MenuSwitchUser" class="BtnBase" href="javascript: void(0);" onclick="toggleSwitchUserList();">
								<%=_TEX.T("SwitchAccount")%>
							</a>
						</span>
					</span>
				</section>
				<section class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/IllustListAppV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_nContentsNumTotal%></span>
					</a>
				</section>
			</div>
		</article>

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
					<%=CCnv.toMyBoxThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_APP, _TEX)%>
					<%}%>
				<%}else{%>
					<span class="NoContents"><%=_TEX.T("IllustListV.NoContents.Me")%></span>
				<%}%>
				<%@ include file="/inner/TAd336x280_mid.jsp"%>
			</section>
		</article>

		<aside class="Wrapper GridList">
			<%@ include file="/inner/ad/TAdSingleAdSpFooter.jsp"%>
		</aside>
	</body>
</html>