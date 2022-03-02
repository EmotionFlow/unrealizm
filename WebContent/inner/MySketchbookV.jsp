<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/MySketchbookGridPcV.jsp").forward(request,response);
	return;
}

if (isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

MySketchbookC cResults = new MySketchbookC();
cResults.selectMaxGallery = 10;
cResults.getParam(request);
cResults.getResults(checkLogin);

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(!isApp){%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}%>

		<%@ include file="/inner/TSendEmoji.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - My Sketchbook</title>

		<%@ include file="/inner/TRequestIntroduction.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

		<script type="text/javascript">
		<%if(!isApp){%>
		$(function(){
			$('#MenuRequest').addClass('Selected');
			$('#MenuSearch').hide();
			$('#MenuMyRequests').show();
		});
		<%}%>

		let lastContentId = <%=cResults.contentList.size()>0 ? cResults.contentList.get(cResults.contentList.size()-1).m_nContentId : -1%>;
		let page = 0;

		const loadingSpinner = {
			appendTo: "#IllustItemList",
			className: "loadingSpinner",
		}
		const observer = createIntersectionObserver(addContents);

		function addContents(){
			appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
			return $.ajax({
				"type": "post",
				"data": {"SD": lastContentId, "MD": <%=CCnv.MODE_SP%>, "VD": <%=CCnv.VIEW_DETAIL%>, "PG": page},
				"dataType": "json",
				"url": "/<%=isApp?"api":"f"%>/MySketchbookF.jsp",
			}).then((data) => {
				page++;
				if (data.end_id > 0) {
					lastContentId = data.end_id;
					const contents = document.getElementById('IllustItemList');
					$(contents).append(data.html);
					observer.observe(contents.lastElementChild);
				}
				removeLoadingSpinners(loadingSpinner.className);
			}, (error) => {
				DispMsg('Connection error');
			});
		}

		function initContents(){
			const contents = document.getElementById('IllustItemList');
			observer.observe(contents.lastElementChild);
		}

		$(function(){
			updateCategoryMenuPos(0);
			initContents();
		});
		$(document).ready(function(){
			$('html,body').animate({ scrollTop: 0 }, 500);
		});

		</script>
		<%if (!isApp) {%>
		<style>body {padding-top: 79px !important;}</style>
		<%} else {%>
		<style>body {padding-top: 0 !important;}</style>
		<%}%>
	</head>

	<body>
		<%if (!isApp) {%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%} else {%>
		<%@ include file="/inner/TMenuApp.jsp"%>
		<%}%>
		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		<%@ include file="/inner/TTabMenuRequestPotalPc.jsp"%>
		<article class="Wrapper ThumbList">
			<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
			<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
				<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
			</span>
			<%}%>
			<section id="IllustItemList" class="IllustItemList" style="padding-bottom: 100px;">
				<% for (int cnt=1; cnt<cResults.contentList.size(); cnt++) { %>
					<%=CCnv.Content2Html(cResults.contentList.get(cnt), checkLogin.m_nUserId, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
					<% if ((cnt == 2 || cnt == 7) && bSmartPhone){ %>
						<%=Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter)%>
					<%}%>
				<%}%>
				<%if(!cResults.contentList.isEmpty()){%>
				<div style="margin: 50px 30px;">
					ここには、エアスケブ(β)でいただいた作品が表示されます。
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
			</section>
		</article>
		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
	<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>
