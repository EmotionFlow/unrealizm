<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/PopularTagListGridPcV.jsp").forward(request,response);
	return;
}

PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.selectMaxGallery = 45;
cResults.selectMaxSampleGallery = 45;
cResults.selectSampleGallery = 1;
boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("PopularTagList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuNew').addClass('Selected');
			$('#MenuHotTag').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 79px !important;}
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0;}
			.CategoryListItem .CategoryMore {display: block; float: left; width: 100%; text-align: right; font-size: 13px; font-weight: normal; padding: 0 7px; box-sizing: border-box;}
			.SearchResultTitle {margin: 10px 0 0 0;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a></li>
				<li><a class="TabMenuItem Selected" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a></li>
				<li><a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<style>
			.IllustThumb {
                margin: 3px 0 3px 6px;
			}
            .IllustThumbImg{
                position: absolute;
                top: 0;
                left: 0;
            }
            .IllustThumbImgMask {
                width: 100%;
                height: 100%;
                position: absolute;
                top: 0;
                left: 0;
                background-image: linear-gradient(to right, rgba(0, 0, 0, 0.15), rgba(0, 0, 0, 0.15));
            }
            .IllustInfoTag {
                position: absolute;
                top: 64px;
                left: 1px;
                color: #ffffff;
                background: rgba(0,0,0,0.4);
                padding: 2px 4px 2px 4px;
                border-radius: 7px;
			}
			.IllustThumbBookmarkButton {
                position: absolute;
                top: 3px;
                right: 5px;
				font-size: 19px;
			}
		</style>

		<article class="Wrapper ThumbList">
			<section class="CategoryListItem">
				<div class="IllustThumbList">
					<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeListWeekly.size(); nCnt++) {
						ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeListWeekly.get(nCnt);
						String strKeyWord = cResults.m_vTagListWeekly.get(nCnt).m_strTagTxt;
						boolean isFollowTag = cResults.m_vTagListWeekly.get(nCnt).isFollow;
					%>
					<%
					String backgroundImageUrl;
					for(CContent content : m_vContentList) {
						if (strKeyWord.toLowerCase().contains("r18")
								|| strKeyWord.toLowerCase().contains("r-18")
								|| strKeyWord.toLowerCase().contains("18禁")
								|| strKeyWord.toLowerCase().contains("nsfw")) {
							backgroundImageUrl = "/img/R-18.png_360.jpg";
						} else {
							backgroundImageUrl = Common.GetUrl(content.m_strFileName) + "_360.jpg";
						}
					%>

					<div class="IllustThumb" style="height: 112px;" >
						<div class="IllustThumbImg" style="background-image:url('<%=backgroundImageUrl%>')"></div>
						<a class="IllustThumbImgMask" href="/SearchIllustByTagPcV.jsp?KWD=<%=strKeyWord%>"></a>
						<a class="IllustInfoTag" href="/SearchIllustByTagPcV.jsp?KWD=<%=strKeyWord%>">#<%=Util.toStringHtml(strKeyWord)%></a>
						<div class="IllustThumbBookmarkButton" onclick="UpdateFollowTagFromTagList(<%=checkLogin.m_nUserId%>, '<%=strKeyWord%>', this)"><i class="<%=isFollowTag?"fas":"far"%> fa-star"></i></div>
					</div>
					<%}%>
					<%if(nCnt==8 || nCnt==17 || nCnt==26 || nCnt==35 ) {%>
					<%@ include file="/inner/TAd728x90_mid.jsp"%>
					<%}%>
					<%}%>
				</div>
			</section>
		</article>

		<%if(cResults.selectMaxSampleGallery -cResults.selectMaxGallery >0) {%>
		<article class="Wrapper ItemList">
			<section id="IllustThumbList" class="IllustThumbList" style="padding: 0;">
			<%for(int nCnt = cResults.selectMaxSampleGallery; nCnt<cResults.m_vTagListWeekly.size(); nCnt++) {
				CTag cTag = cResults.m_vTagListWeekly.get(nCnt);%>
				<%=CCnv.toHtml(cTag, CCnv.MODE_PC, _TEX)%>
				<%if((nCnt+1)%15==0) {%>
				<%@ include file="/inner/TAd728x90_mid.jsp"%>
				<%}%>
			<%}%>
			</section>
		</article>
		<%}%>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>