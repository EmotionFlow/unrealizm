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
	<%@ include file="/inner/TCreditCard.jsp"%>
	<%@ include file="/inner/TSendGift.jsp"%>
	<%@ include file="/inner/TSendEmoji.jsp"%>
	<%@ include file="/inner/TReplyEmoji.jsp"%>
	<title><%=_TEX.T("MyHomePc.Title")%> | <%=_TEX.T("THeader.Title")%></title>

	<script type="text/javascript">
		$(function(){
			$('#MenuRequest').addClass('Selected');
		});
	</script>

	<%@ include file="/inner/TDispRequestTextDlg.jsp"%>
	<%@ include file="/inner/TRetweetContent.jsp"%>
	<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

	<style>
        body {padding-top: 79px !important;}
        .UnrealizmDesc.Event {margin: 10px 0;}
        .RequestEmail {display: block; float: left; width: 100%; margin: 1px 0 0 0; text-decoration: underline; background: #f4f9fb; text-align: center;}
        .UnrealizmDesc.Event {margin: 30px 0 0 0;}
        .Wrapper.ViewPc {flex-flow: row-reverse wrap;}
        .Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 113px;}
        .Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}

		<%// CCnvで実装するのがしんどかったのでCSSでごまかす%>
        .IllustItem>.IllustInfo>.PrivateIcon  {display: none;}
        .IllustItem>.IllustInfo>.OutOfPeriodIcon  {display: none;}
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
		</div>

		<div class="PcSideBarItem">
		</div>

		<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
		<div class="FixFrame">
		</div>
		<%}%>
	</aside>

	<section id="IllustItemList" class="IllustItemList">
		<%if(cResults.contentList.isEmpty()) {%>

		<div style="margin: 30px; text-align: center; color:#fffdb1;border: solid;border-radius: 5px;padding: 20px 0; font-size: 15px;">
			<i class="fas fa-bullhorn" style="font-size: 30px; margin-bottom: 15px"></i><br> <%=_TEX.T("MySketchbookV.Info01")%><br><%=_TEX.T("MySketchbookV.Info02")%>
			<div style="margin-top: 10px;">
			<span style="font-size: 11px">
				<%=_TEX.T("MySketchbookV.Info05")%><br>
				<%=_TEX.T("MySketchbookV.Info03")%>
			</span>
			</div>
		</div>
		<div style="margin: 50px 30px;">
			<%=_TEX.T("MySketchbookV.Info06")%>
		</div>

		<div style="text-align: center; color: #6d6965f">
			<div>
				<a href="/MyEditSettingPcV.jsp?MENUID=REQUEST" style="font-size: 17px; font-weight: 600;">
					<%=_TEX.T("MySketchbookV.Info08")%>
				</a>
			</div>
			<div style="margin-top: 20px">
			<a href="javascript: void(0);" onclick="dispRequestIntroduction()">
				<i class="fas fa-info-circle" style="font-size: 14px"></i> <%=_TEX.T("MySketchbookV.Info09")%>
			</a>
			</div>
		</div>
		<%}%>

		<% int count =0;
			for(; count<cResults.contentList.size(); count++) {
				CContent cContent = cResults.contentList.get(count);%>
		<%= CCnv.SketchbookContent2Html(cContent, checkLogin, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW)%>
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