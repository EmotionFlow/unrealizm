<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean isApp = false;

MyIllustListC cResults = new MyIllustListC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 48;

// ログインせずにUIDを指定した場合、間違ってマイボックスのURLを聞いてアクセスしている可能性がある
if(!checkLogin.m_bLogin && cResults.m_nUserId>=1) {
	response.sendRedirect("/" + cResults.m_nUserId);
	return;
}

// それ以外の場合でログインしていない場合はログインページへ
if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
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
if(!cResults.getResults(checkLogin) || !cResults.m_bOwner) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
String strUrl = "https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/";
String strTitle = Util.toStringHtml(String.format(_TEX.T("IllustListPc.Title"), cResults.m_cUser.m_strNickName)) + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal);
String strFileUrl = cResults.m_cUser.m_strFileName;
if(strFileUrl.isEmpty()) strFileUrl="/img/poipiku_icon_512x512_2.png";
String strEncodedKeyword = URLEncoder.encode(cResults.m_strTagKeyword, "UTF-8");
g_bShowAd = (cResults.m_cUser.m_nPassportId==Common.PASSPORT_OFF || cResults.m_cUser.m_nAdMode==CUser.AD_MODE_SHOW);

Map<String, String> keyValues;
String strCgiParam = "";
final String thisPagePath = "/MyIllustListGridPcV.jsp";

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%@ include file="/inner/ad/TAdGridPcHeader.jsp"%>
		<title><%=cResults.m_cUser.m_strNickName%></title>
		<%@ include file="/inner/TTweetMyBox.jsp"%>
		<%@ include file="/inner/TSwitchUser.jsp"%>
		<%@ include file="/inner/TWaveMessageDlg.jsp"%>

		<script type="text/javascript">
		$(function(){
			$('#MenuMe').addClass('Selected');
			updateTagMenuPos(100);

			<%if (Util.toString(request.getHeader("Referer")).indexOf("MyIllustList") > 0) { %>
			$(window).scrollTop($("#SortFilterMenu").offset().top - 80);
			<%}%>
		});
		</script>

		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		.HeaderSetting {text-align: center; position: absolute; top: 12px; right: 10px;}
		.NoContents {display: block; padding: 250px 0; width: 100%; text-align: center;}
		.TweetMyBox {padding-top: 5px; text-align: center;}
		.MyBoxSearch {display: flex; flex-flow: row nowrap; text-align: center; width: 300px;}
		.MyBoxSearch .MyBoxSearchBox {display: block; flex: 1 1; height: 26px; width: 152px; padding: 0 5px; box-sizing: border-box; border: solid 1px #3498db; border-radius: 15px 0 0 15px;}
		.MyBoxSearch .MyBoxSearchBtn {display: block; height: 26px; box-sizing: border-box; margin: 0; background-color: #fff; color: #3498db; border: solid 1px #3498db; cursor: pointer; border-left: none;line-height: 25px;border-radius: 0 15px 15px 0; font-size: 14px; padding: 0px 6px 0px 4px;}
		.MyBoxSearch .MyBoxSearchBtn:hover {border: solid 1px #fff; background-color: #3498db; color: #fff;}
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
			#SwitchUserList {
                display: block;
                position: fixed;
                top: 51px;
                right: 30%;
                z-index: 999;
                width: 40%;
                box-sizing: border-box;
                overflow: hidden;
                align-items: center;
                justify-content: center;
                background: #fff;
                color: #6d6965;
                flex-flow: column;
			}
            .SwitchUserItem {
                display: flex;
                flex-flow: row nowrap;
                width: 100%;
                height: 42px;
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
				color: #6d6965;
                display: block;
                flex: 1 1 80px;
                padding: 0;
                margin: 0 0 0 3px;
                text-align: left;
                font-size: 14px;
                white-space: nowrap;
                overflow: hidden;
            }
            .SwitchUserNicknameSelected:hover {
				color: inherit;
			}
			.SwitchUserNicknameOther:hover {
                color: inherit;
                text-decoration: underline;
                cursor: pointer;
            }
            .SwitchUserStatus {
                width: 30px;
                border-left: solid 1px #eee;
                padding: 10px 13px;
                font-size: 16px;
            }
            .SwitchUserStatus > .Selected {
                color: #3498da;
            }
            .SwitchUserStatus > .Other {
                cursor: pointer;
            }
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<script>$(function () {
			$("#MenuSearch").hide();
			$("#MenuSettings").show();
			$("#MenuSwitchUser").show();
		})</script>


		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		<%@ include file="/inner/MyIllustListSwitchUserList.jsp"%>

		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
					<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<%if(cResults.twitterScreenName != null && !cResults.twitterScreenName.isEmpty()) {%>
					<h3 class="UserInfoProfile"><a class="fab fa-twitter" href="https://twitter.com/<%=cResults.twitterScreenName%>">@<%=cResults.twitterScreenName%></a></h3>
					<%}%>
					<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<span class="UserInfoCmd">
						<span class="TweetMyBox">
							<a id="OpenTweetMyBoxDlgBtn" href="javascript:void(0);" class="BtnBase">
								<i class="fab fa-twitter"></i><%=_TEX.T("MyIllustListV.TweetMyBox")%>
							</a>
							<a href="/MyRequestListPcV.jsp?MENUID=RECEIVED" class="BtnBase">
								<%=_TEX.T("Request.MyRequests")%>
							</a>
						</span>
					</span>
				</section>
				<%if(cResults.myWaves != null && !cResults.myWaves.isEmpty()){%>
				<section class="WaveList Pc">
					<span class="WaveListTitle Pc">
						<%=_TEX.T("MyIllustListV.Wave.Received")%>
						<a style="text-decoration: underline; margin-left: 20px" href="/MyEditSettingPcV.jsp?MENUID=EMOJI"><i class="fas fa-wrench"></i><%=_TEX.T("MyIllustListV.Wave.Customize")%></a>
					</span>
					<div class="MyWaves">
						<%@ include file="/inner/TMyWaves.jsp"%>
					</div>
				</section>
				<%}%>
				<%if(cResults.replyWaves != null && !cResults.replyWaves.isEmpty()){%>
				<section class="WaveList">
					<span class="WaveListTitle">
						<%=_TEX.T("MyIllustListV.Wave.Reply")%>
					</span>
					<div class="MyWaves">
						<%@ include file="/inner/TMyReplyWaves.jsp"%>
					</div>
				</section>
				<%}%>
				<section class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/<%=cResults.m_cUser.m_nUserId%>/">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_nContentsNumTotal%></span>
					</a>
				</section>
			</div>
		</article>

		<article class="Wrapper GridList">

			<% boolean isGridPc = true; %>
			<%@include file="/inner/TSortFilterNavigation.jsp"%>

			<%if(cResults.m_vCategoryList.size()>0) {%>
			<nav id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn <%if(cResults.m_strTagKeyword.isEmpty()){%> Selected<%}%>" href="/MyIllustListPcV.jsp"><%=_TEX.T("Category.All")%></a>
				<%for(CTag cTag : cResults.m_vCategoryList) {%>
				<a class="BtnBase CategoryBtn <%if(cTag.m_strTagTxt.equals(cResults.m_strTagKeyword)){%> Selected<%}%>" href="/MyIllustListPcV.jsp?ID=<%=cResults.m_nUserId%>&KWD=<%=URLEncoder.encode(cTag.m_strTagTxt, "UTF-8")%>"><%=Util.toDescString(cTag.m_strTagTxt)%></a>
				<%}%>
			</nav>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%if(cResults.m_vContentList.size()>0){%>
					<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%=CCnv.toMyBoxThumbHtml(cContent, checkLogin, CCnv.MODE_PC, CCnv.SP_MODE_WVIEW, _TEX)%>
						<%if(nCnt==3){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%><%}%>
						<%if(nCnt==19){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_2.jsp"%><%}%>
						<%if(nCnt==35){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_3.jsp"%><%}%>
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

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
