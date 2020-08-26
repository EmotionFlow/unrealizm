<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

MyHomePcC cResults = new MyHomePcC();
cResults.getParam(request);

if(!cCheckLogin.m_bLogin) {
	if(cResults.n_nUserId>0) {
		response.sendRedirect("/"+cResults.n_nUserId+"/");
	} else {
		getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	}
	return;
}

boolean bRtn = cResults.getResults(cCheckLogin);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Emoji.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<title><%=_TEX.T("MyHomePc.Title")%> | <%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<%@ include file="/inner/TDeleteContent.jsp"%>

		<script>
		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){if(!$(e.target).is(".MyUrl")){return false;}});
			});
			<%if(!cCheckLogin.m_bEmailValid && System.currentTimeMillis() % 100 == 0){%>
			Swal.fire({
				html:
					'<style>' +
					' .RequestEmailMsg {text-align: left; font-size: 19px;}' +
					' .RequestEmailSubmit {margin: 30px auto; padding: 10px 30px; -webkit-tap-highlight-color: rgba(255, 255, 255, 0) !important; -webkit-focus-ring-color: rgba(255, 255, 255, 0) !important; outline: none !important;}' +
					' .RequestEmailLater {width: 100%; text-align: left; font-size: 14px; font-weight: 500; margin: 10px 0 5px 0; padding: 0; font-weight: 400; color: #aaaaaa; background: none; border: none;}' +
					' .swal2-popup .swal2-actions {margin: 0;}' +
					'</style>' +
					'<div class="RequestEmailMsg">' + "<%=_TEX.T("RequestEmail.Msg")%>" + '</div>' +
					'<div><a class="BtnBase ResBtnSetItem Selected RequestEmailSubmit" href="/MyEditSettingPcV.jsp?MENUID=MAIL">' +
					'✉️ <%=_TEX.T("RequestEmail.GoSettingPage")%>' +
					'</a></div>',
				focusConfirm: false,
				showConfirmButton: false,
				showCancelButton: true,
				cancelButtonText: "<%=_TEX.T("RequestEmail.Later")%>",
				buttonsStyling: false,
				cancelButtonClass: "RequestEmailLater",
			})
			<%}%>
		});
		</script>

		<style>
			body {padding-top: 83px !important;}
			.PoipikuDesc.Event {margin: 10px 0;}
			.EventItemList {display: block; float: left; width: 100%; margin: 10px 0 0 0;}
			.EventItemList .EventItem {display: block; margin: 0 20px 10px 20px;}
			.EventItemList .EventItem .EventBanner {width: 320px; display: block;}
			.EventItemList .EventItem.Updated {position: relative;}
			.EventItemList .EventItem.Updated:after {display: block; content: ''; position: absolute; width: 50px; height: 46px; background-image: url('/img/upodate_jp.png'); background-size: contain; top: 5px; right: 0px;}
			.RequestEmail {display: block; float: left; width: 100%; margin: 1px 0 0 0; text-decoration: underline; background: #f4f9fb; text-align: center;}
			<%if(!Util.isSmartPhone(request)) {%>
			.PoipikuDesc.Event {margin: 30px 0 0 0;}
			.Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 113px;}
			.Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
			.EventItemList {display: block; float: none; width: 100%; margin: 0 0 0 0;}
			.EventItemList .EventItem {display: block; margin: 0 0 20px 0;}
			.EventItemList .EventItem .EventBanner {width: 300px; display: block;}
			<%}%>
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper ViewPc">
			<%if(bSmartPhone) {%>
			<section class="EventItemList">
				<a class="EventItem" href="/event/20200821_mangaMovie2/TopPcV.jsp">
					<%if(Math.random()>0.5) {%>
					<img class="EventBanner" src="/event/20200821_mangaMovie2/poipiku_2_bn_1.png" />
					<%} else {%>
					<img class="EventBanner" src="/event/20200821_mangaMovie2/poipiku_2_bn_2.png" />
					<%}%>
				</a>
				<a class="EventItem" href="/event/20190901/TopPcV.jsp">
					<img class="EventBanner" src="/event/20190901/banner_spring.png" />
				</a>
				<a class="EventItem" href="/event/20191001/TopPcV.jsp">
					<img class="EventBanner" src="/event/20191001/banner_karapare.png" />
				</a>
			</section>
			<%}%>

			<section id="IllustItemList" class="IllustItemList">

				<%if(cResults.m_vContentList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 150px 10px 50px 10px; text-align: center; box-sizing: border-box;">
					<%=_TEX.T("MyHome.FirstMsg")%>
					<br />
					<a class="BtnBase" href="/NewArrivalPcV.jsp"><%=_TEX.T("MyHome.FirstMsg.FindPeople")%></a>
					<br />
					<br />
					<a class="BtnBase" href="/how_to/TopPcV.jsp"><%=_TEX.T("HowTo.Title")%></a>

				</div>
				<%}%>

				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%= CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL)%>
					<%if(nCnt==4 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>
					<%if(nCnt==9 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
				<%}%>
			</section>

			<%if(!bSmartPhone) {%>
			<aside class="PcSideBar" style="margin-top: 30px;">
				<div class="PcSideBarItem">
					<section class="EventItemList">
						<a class="EventItem" href="/event/20200821_mangaMovie2/TopPcV.jsp">
							<%if(Math.random()>0.5) {%>
							<img class="EventBanner" src="/event/20200821_mangaMovie2/poipiku_2_bn_1.png" />
							<%} else {%>
							<img class="EventBanner" src="/event/20200821_mangaMovie2/poipiku_2_bn_2.png" />
							<%}%>
						</a>
						<a class="EventItem" href="/event/20190901/TopPcV.jsp">
							<img class="EventBanner" src="/event/20190901/banner_spring.png" />
						</a>
						<a class="EventItem" href="/event/20191001/TopPcV.jsp">
							<img class="EventBanner" src="/event/20191001/banner_karapare.png" />
						</a>
					</section>
				</div>

				<div class="PcSideBarItem">
					<%@ include file="/inner/ad/TAdHomePc300x250_top_right.jsp"%>
				</div>

				<div class="PcSideBarItem">
					<div class="PcSideBarItemTitle"><%=_TEX.T("Twitter.Share.MyUrl")%></div>
					<%
					String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
							URLEncoder.encode(String.format("%s%s %s #%s",
									cCheckLogin.m_strNickName,
									_TEX.T("Twitter.UserAddition"),
									String.format(_TEX.T("Twitter.UserPostNum"), cResults.m_nContentsNumTotal),
									_TEX.T("Common.Title")), "UTF-8"),
							URLEncoder.encode("https://poipiku.com/"+cCheckLogin.m_nUserId+"/", "UTF-8"));
					%>
					<div style="text-align: center;">
						<input id="MyUrl" class="MyUrl" type="text" value="https://poipiku.com/<%=cCheckLogin.m_nUserId%>/" onclick="this.select(); document.execCommand('copy');" style="box-sizing: border-box; width: 100%; padding: 5px; margin: 0 0 10px 0;" />
						<a class="BtnBase" href="javascript:void(0)" onclick="$('#MyUrl').select(); document.execCommand('Copy');"><i class="far fa-copy"></i> <%=_TEX.T("Twitter.Share.Copy.Btn")%></a>
						<a class="BtnBase" href="<%=strTwitterUrl%>" target="_blank"><i class="fab fa-twitter"></i> <%=_TEX.T("Twitter.Share.MyUrl.Btn")%></a>
					</div>
				</div>

				<div class="FixFrame">
					<div class="PcSideBarItem">
						<%@ include file="/inner/ad/TAdHomePc300x600_bottom_right.jsp"%>
					</div>
				</div>
			</aside>
			<%}%>

			<nav class="PageBar">
				<%if(bSmartPhone) {%>
				<%=CPageBar.CreatePageBarSp("/MyHomePcV.jsp", "", cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
				<%}else{%>
				<%=CPageBar.CreatePageBarPc("/MyHomePcV.jsp", "", cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
				<%}%>
			</nav>
		</article>
		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>