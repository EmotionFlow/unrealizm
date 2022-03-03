<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
	boolean bSmartPhone = Util.isSmartPhone(request);
	MySketchbookC cResults = new MySketchbookC();
	cResults.getParam(request);
	cResults.getResults(checkLogin);
	ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
	boolean isApp = false;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<%@ include file="/inner/THeaderCommonPc.jsp"%>
	<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
	<%@ include file="/inner/TSendEmoji.jsp"%>
	<title><%=_TEX.T("MyHomePc.Title")%> | <%=_TEX.T("THeader.Title")%></title>

	<script type="text/javascript">
		$(function(){
			$('#MenuRequest').addClass('Selected');
		});
	</script>

	<%@ include file="/inner/TDeleteContent.jsp"%>
	<%@ include file="/inner/TDispRequestTextDlg.jsp"%>
	<%@ include file="/inner/TRetweetContent.jsp"%>
	<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

	<style>
        body {padding-top: 79px !important;}
        .PoipikuDesc.Event {margin: 10px 0;}
        .RequestEmail {display: block; float: left; width: 100%; margin: 1px 0 0 0; text-decoration: underline; background: #f4f9fb; text-align: center;}
        .PoipikuDesc.Event {margin: 30px 0 0 0;}
        .Wrapper.ViewPc {flex-flow: row-reverse wrap;}
        .Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 113px;}
        .Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
	</style>
</head>

<body>
<%@ include file="/inner/TMenuPc.jsp"%>
<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
<%@ include file="/inner/TTabMenuRequestPotalPc.jsp"%>
<%@ include file="/inner/TRequestIntroduction.jsp"%>

<article class="Wrapper ViewPc">
	<aside class="PcSideBar" style="margin-top: 30px;">
		<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
		<div class="PcSideBarItem">
			<%@ include file="/inner/ad/TAdHomePc300x250_top_right.jsp"%>
		</div>
		<%}%>

		<div class="PcSideBarItem">
			<%@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>
		</div>

		<div class="PcSideBarItem">
		</div>

		<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
		<div class="FixFrame">
			<div class="PcSideBarItem">
				<%@ include file="/inner/ad/TAdHomePc300x600_bottom_right.jsp"%>
			</div>
		</div>
		<%}%>
	</aside>

	<section id="IllustItemList" class="IllustItemList">
		<%if(!cResults.contentList.isEmpty()) {%>
		<div style="margin: 50px 30px;">
			ここには、エアスケブ(β)でクリエイターからいただいた作品が表示されます。
		</div>
		<div style="margin: 0 30px;">
			<p>エアスケブ(β)とは、ポイピクユーザー（依頼主）がお題を依頼し、受け取ったポイピクユーザー（クリエイター）がイラストやテキストを創作してお渡しする仕組みです。</p>
		</div>
		<div class="WhatIsRequest" style="text-align: center; color: #ffffff">

			<a href="javascript: void(0);" style="font-weight: 600;" onclick="dispRequestIntroduction()">
				<i class="fas fa-info-circle" style="font-size: 14px"></i> 詳細を見る
			</a>
		</div>
		<%}%>

		<% int count =10;
			for(; count<cResults.contentList.size(); count++) {
				CContent cContent = cResults.contentList.get(count);%>
		<%= CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW)%>
		<%}%>

	</section>

	<nav class="PageBar">
		<%=CPageBar.CreatePageBarPc("/MyHomePcV.jsp", "", cResults.page, cResults.contentsNum, MyHomePcC.SELECT_MAX_GALLERY)%>
	</nav>
</article>

<%@ include file="/inner/TShowDetail.jsp"%>
<%@ include file="/inner/TFooterSingleAd.jsp"%>
</body>
</html>