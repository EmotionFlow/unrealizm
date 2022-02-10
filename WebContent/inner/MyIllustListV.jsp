<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	request.getRequestDispatcher("/MyIllustListGridPcV.jsp").forward(request,response);
	return;
}

MyIllustListC cResults = new MyIllustListC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 15;

// ログインせずにUIDを指定した場合、間違ってマイボックスのURLを聞いてアクセスしている可能性がある
if(!checkLogin.m_bLogin && cResults.m_nUserId>=1) {
	response.sendRedirect("/" + cResults.m_nUserId);
	return;
}

// それ以外の場合でログインしていない場合はログインページへ
if(!checkLogin.m_bLogin) {
	if (!isApp) {
		getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
	}
	return;
}

if(cResults.m_nUserId < 0){
	// パラメータなしだったら自分のマイボックス
	cResults.m_nUserId = checkLogin.m_nUserId;
} else if(checkLogin.m_nUserId != cResults.m_nUserId) {
	// 自分と異なるuserIdが指定されていたら、その人のトップへ遷移。
	response.sendRedirect("/"+cResults.m_nUserId);
	return;
}

cResults.m_bDispUnPublished = true;
if (isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
if (!cResults.getResults(checkLogin) || !cResults.m_bOwner) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
String strUrl = "https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/";
String strTitle = Util.toStringHtml(String.format(_TEX.T("IllustListPc.Title"), cResults.m_cUser.m_strNickName)) + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal);
String strFileUrl = cResults.m_cUser.m_strFileName;
if(strFileUrl.isEmpty()) strFileUrl="/img/poipiku_icon_512x512_2.png";
String strEncodedKeyword = URLEncoder.encode(cResults.m_strTagKeyword, "UTF-8");

Map<String, String> keyValues;
String strCgiParam = "";
final String thisPagePath = "/MyIllustList" + (isApp?"App":"Pc") + "V.jsp";

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(!isApp){%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}%>

		<script>setTimeZoneOffsetCookie();</script>

		<%if(!isApp){%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<%}%>

		<title><%=cResults.m_cUser.m_strNickName%></title>
		<%@ include file="/inner/TTweetMyBox.jsp"%>
		<%@ include file="/inner/TSwitchUser.jsp"%>

		<script type="text/javascript">
		$(function(){
			$('#MenuMe').addClass('Selected');
			updateTagMenuPos(100);
			<%if (Util.toString(request.getHeader("Referer")).indexOf("MyIllustList") > 0) { %>
			$(window).scrollTop($("#SortFilterMenu").offset().top - 80);
			<%}%>
		});

		function TogglePrivateNote($element, message) {
			const cls = 'PrivateNote';
			if($element.children('.' + cls).length <= 0) {
				$element.append($("<div/>").attr("class", cls));
			}
			const $note = $($element.children('.' + cls)[0]);
			$note.text(message);
			if ($note.hasClass('slide-up')) {
				$note.addClass('slide-down', 2000, 'swing');
				$note.removeClass('slide-up');
			} else {
				$note.removeClass('slide-down');
				$note.addClass('slide-up', 2000, 'swing');
			}
		}
		</script>
		<style>
            .IllustThumb > .PrivateNote {
                position: absolute;
                background: rgba(255,255,255,0.9);
                height: 125px;
                width: 100%;
				font-size: 12px;
                border-top: 1px solid #d9d9d9;
			}

            .PrivateNote.slide-up
            {
                bottom: 0 !important;
            }

            .PrivateNote.slide-down
            {
                bottom: -475px !important;
            }

		</style>

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
	</head>

	<body>
		<%if(!isApp){%>
		<%@ include file="/inner/TMenuPc.jsp" %>
		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		<script>$(function () {
			$("#MenuSearch").hide();
			$("#MenuUpload").show();
			$("#MenuSettings").show();
			$("#MenuSwitchUser").show();
		})</script>
		<%}else{%>
		<%@ include file="/inner/TMenuApp.jsp" %>
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>
		<%}%>

		<%@ include file="/inner/MyIllustListSwitchUserList.jsp"%>

		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
					<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<span class="UserInfoCmd">
						<span class="TweetMyBox">
							<a id="OpenTweetMyBoxDlgBtn" href="javascript:void(0);" class="BtnBase">
								<i class="fab fa-twitter"></i><%=_TEX.T("MyIllustListV.TweetMyBox")%>
							</a>
							<a href="/MyRequestList<%=isApp?"App":"Pc"%>V.jsp?MENUID=RECEIVED" class="BtnBase">
								<%=_TEX.T("Request.MyRequests")%>
							</a>
							<%if(isApp){%>
							<a id="MenuSwitchUser" class="BtnBase" href="javascript: void(0);" onclick="toggleSwitchUserList();">
								<%=_TEX.T("SwitchAccount")%>
							</a>
							<%}%>
						</span>
						<%@ include file="/inner/TUserShareCmd.jsp"%>
					</span>
				</section>
				<section class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/<%=cResults.m_cUser.m_nUserId%>/">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_nContentsNumTotal%></span>
					</a>
				</section>
			</div>
		</article>

		<article class="Wrapper">
			<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
			<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
				<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
			</span>
			<%}%>

			<% boolean isGridPc = false; %>
			<%@include file="TSortFilterNavigation.jsp"%>

			<%if(cResults.m_vCategoryList.size()>0) {%>
			<nav id="TagMenu" class="TagMenu">
				<a class="BtnBase TagBtn <%if(cResults.m_strTagKeyword.isEmpty()){%> Selected<%}%>" href="<%=thisPagePath%>">
					<i class="fas fa-tag TagIcon"></i><%=_TEX.T("Category.All")%></a>
				<%
					keyValues = cResults.getParamKeyValueMap();
					keyValues.remove("KWD");
					keyValues.remove("PG");
					strCgiParam = Common.getCgiParamStr(keyValues);
					for(final CTag cTag : cResults.m_vCategoryList) {%>
				<a class="BtnBase TagBtn <%if(cTag.m_strTagTxt.equals(cResults.m_strTagKeyword)){%> Selected<%}%>" href="<%=thisPagePath%>?<%=strCgiParam%>&KWD=<%=URLEncoder.encode(cTag.m_strTagTxt, "UTF-8")%>"><%=Util.toDescString(cTag.m_strTagTxt)%></a>
				<%
					}
				%>
			</nav>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%if(cResults.m_vContentList.size()>0){%>
					<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%=CCnv.toMyBoxThumbHtml(cContent, checkLogin, CCnv.MODE_SP, !isApp ? CCnv.SP_MODE_WVIEW : CCnv.SP_MODE_APP, _TEX)%>
						<%if(nCnt==14) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>
						<%if(nCnt==29) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
					<%}%>
				<%}else{%>
					<span class="NoContents"><%=_TEX.T("IllustListV.NoContents.Me")%></span>
				<%}%>
			</section>

			<nav class="PageBar">
				<%
					keyValues = cResults.getParamKeyValueMap();
					keyValues.remove("PG");
					strCgiParam = "&" + Common.getCgiParamStr(keyValues);
				%>
				<%=CPageBar.CreatePageBarSp(thisPagePath, strCgiParam, cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
				<%
					keyValues.clear();
				%>
			</nav>
		</article>

		<%if(!isApp){%>
		<%@ include file="/inner/TFooterSingleAd.jsp"%>
		<%}%>
	</body>
</html>
