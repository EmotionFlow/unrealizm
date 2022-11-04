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

		<%@ include file="/inner/TCreditCard.jsp"%>
		<%@ include file="/inner/TSendGift.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
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
			initContents();
		});
		$(document).ready(function(){
			$('html,body').animate({ scrollTop: 0 }, 500);
		});

		</script>

		<style>
			<%if (!isApp) {%>
			body {padding-top: 51px !important;}
			<%} else {%>
			body {padding-top: 0 !important;}
			<%}%>

			<%// CCnvで実装するのがしんどかったのでCSSでごまかす%>
            .IllustItem>.IllustInfo>.PrivateIcon  {display: none;}
            .IllustItem>.IllustInfo>.OutOfPeriodIcon  {display: none;}
		</style>
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
				<% for (int cnt=0; cnt<cResults.contentList.size(); cnt++) { %>
					<%=CCnv.SketchbookContent2Html(cResults.contentList.get(cnt), checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
					<% if ((cnt == 2 || cnt == 7) && bSmartPhone){ %>
						<%=Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter)%>
					<%}%>
				<%}%>
				<%if(cResults.contentList.isEmpty()){%>
				<div style="margin: 30px; text-align: center; color:#fffdb1;border: solid;border-radius: 5px;padding: 20px 35px; font-size: 15px;">
					<i class="fas fa-bullhorn" style="font-size: 30px; margin-bottom: 15px"></i><br> <%=_TEX.T("MySketchbookV.Info01")%><br/>
					<div style="margin-top: 10px;">
						<%=_TEX.T("MySketchbookV.Info02")%><br>
						<span style="font-size: 11px">
							<%if(isApp){%>
							<%=_TEX.T("MySketchbookV.Info04")%>
							<%}else{%>
							<a href="/MyEditSettingPcV.jsp?MENUID=REQUEST" style="color:#fffdb1; text-decoration: underline;">
							<%=_TEX.T("MySketchbookV.Info05")%>
							</a>
							<%}%>
							<br><%=_TEX.T("MySketchbookV.Info03")%>
						</span>
					</div>
				</div>
				<div style="margin: 50px 30px;">
					<%=_TEX.T("MySketchbookV.Info06")%>
				</div>

				<div style="text-align: center; color: #000f; text-decoration: underline;">
					<div>
						<%if(isApp){%>
						<%=_TEX.T("MySketchbookV.Info07")%>
						<%}else{%>
						<a href="/MyEditSettingPcV.jsp?MENUID=REQUEST" style="font-weight: 600;">
							<%=_TEX.T("MySketchbookV.Info08")%>
						</a>
						<%}%>
					</div>
					<div style="margin-top: 20px">
						<a href="javascript: void(0);" onclick="dispRequestIntroduction()">
							<%=_TEX.T("MySketchbookV.Info09")%>
						</a>
					</div>
				</div>
				<%}%>
			</section>
		</article>
		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
	<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>
