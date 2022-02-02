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
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");

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
			updateCategoryMenuPos(100);
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

			<style>
				.SortFilterMenu{
                    display: flex;
                    flex-direction: row;
					justify-content: space-around;
                    padding: 20px 5px 7px 5px;
                    font-size: 18px;
				}
				.SortFilterMenu > .CategoryFilter,
				.CategoryFilterMenu > .Category
				{
                    font-size: 10px;
                    text-align: center;
                    overflow: hidden;
                    white-space: nowrap;
                    box-sizing: border-box;
                    border-radius: 10px;
                    min-width: 50px;
                    max-width: 100%;
                    height: 22px;
                    line-height: 20px;
                    border: 1px solid;
				}
                .CategoryFilterMenu > .Category{
					margin:	7px;
					border: 1px solid #f5f5f5;
				}

				.SortFilterSubMenu > div {
                    display: flex;
                    flex-direction: row;
                    justify-content: space-around;
                    padding: 10px 5px 7px 5px;
                    font-size: 18px;
                    flex-wrap: wrap;
                    align-content: space-around;
				}
			</style>
			<script>
				function showMyBoxSortFilterSubMenu(subMenuId) {
					const $target = $("#"+subMenuId);
					if ($target.css('display') !== 'none') {
						$target.hide();
						return false;
					}
					$("#SortFilterSubMenu > div").hide();
					$target.animate({height: 'show'});
				}
			</script>
			<nav id="SortFilterMenu" class="SortFilterMenu">
				<span onclick="showMyBoxSortFilterSubMenu('SortMenu');" style="color: #ffffff"><i class="fas fa-sort-amount-down"></i></span>
				<span onclick="showMyBoxSortFilterSubMenu('CategoryFilterMenu');" class="CategoryFilter">すべて</span>
				<a id="MenuSearch" class="HeaderTitleSearch fas fa-search" href="javascript:void(0);" onclick="$('#HeaderTitleWrapper').hide();$('#HeaderSearchWrapper').show();"></a>
			</nav>
			<nav id="SortFilterSubMenu" class="SortFilterSubMenu">
				<div id="SortMenu" style="display: none;">
					<i class="fas fa-sort-alpha-down"></i>
					<i class="far fa-calendar"></i>
					<i class="fas fa-pen"></i>
				</div>
				<div id="CategoryFilterMenu" class="CategoryFilterMenu" style="display: none;">
					<%for(int categoryId: Common.CATEGORY_ID) {%>
						<span class="Category C<%=categoryId%>"><%=_TEX.T(String.format("Category.C%d", categoryId))%></span>
					<%}%>
				</div>
				<div id="KeywordFilterMenu" style="display: none;"></div>
			</nav>
			<%if(cResults.m_vCategoryList.size()>0) {%>
			<nav id="TagMenu" class="TagMenu">
				<a class="BtnBase TagBtn <%if(cResults.m_strKeyword.isEmpty()){%> Selected<%}%>" href="/MyIllustList<%=isApp?"App":"Pc"%>V.jsp">
					<i style="font-size: 10px;vertical-align: center;" class="fas fa-tag"></i><%=_TEX.T("Category.All")%></a>
				<%for(final CTag cTag : cResults.m_vCategoryList) {%>
				<a class="BtnBase TagBtn <%if(cTag.m_strTagTxt.equals(cResults.m_strKeyword)){%> Selected<%}%>" href="/MyIllustList<%=isApp?"App":"Pc"%>V.jsp?ID=<%=cResults.m_nUserId%>&KWD=<%=URLEncoder.encode(cTag.m_strTagTxt, "UTF-8")%>"><%=Util.toDescString(cTag.m_strTagTxt)%></a>
				<%}%>
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
				<%if(!isApp){%>
				<%=CPageBar.CreatePageBarSp("/MyIllustListPcV.jsp", String.format("&ID=%d&KWD=%s", cResults.m_nUserId, strEncodedKeyword), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
				<%}else{%>
				<%=CPageBar.CreatePageBarSp("/MyIllustListAppV.jsp", String.format("&ID=%d&KWD=%s", cResults.m_nUserId, strEncodedKeyword), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
				<%}%>
			</nav>
		</article>

		<%if(!isApp){%>
		<%@ include file="/inner/TFooterSingleAd.jsp"%>
		<%}%>
	</body>
</html>
