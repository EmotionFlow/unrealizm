<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchTagByKeywordC results = new SearchTagByKeywordC();
results.getParam(request);
results.selectMaxGallery = 45;
results.getResults(checkLogin);
g_strSearchWord = results.m_strKeyword;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdSearchUserPcHeader.jsp"%>
		<meta name="description" content="<%=Util.toStringHtml(String.format(_TEX.T("SearchTagByKeyword.Title.Desc"), results.m_strKeyword))%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("SearchTagByKeyword.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuNew').addClass('Selected');
		});
		</script>

		<script>
			$(function(){
				$('#HeaderSearchWrapper').attr("action","/SearchTagByKeywordPcV.jsp");
				$('#HeaderSearchBtn').on('click', SearchTagByKeyword);
			});
		</script>

		<style>
			body {padding-top: 79px !important;}

			<%if(Util.isSmartPhone(request)) {%>
			#HeaderTitleWrapper {display: none;}
			#HeaderSearchWrapper {display: block;}
			<%}%>
		</style>
		<style>
            .IllustThumb {
                margin: 3px 0 3px <%=bSmartPhone ? 6 : 14%>px ;
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

	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(results.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem Selected" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(results.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(results.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper ItemList">
			<section id="IllustThumbList" class="IllustItemList">
				<%
				String backgroundImageUrl;
				CTag tag;
				String strKeyWord;
				boolean isFollowTag;
				for(int nCnt = 0; nCnt< results.tagList.size(); nCnt++) {
					tag = results.tagList.get(nCnt);
					strKeyWord = tag.m_strTagTxt;
					isFollowTag = tag.isFollow;
					if (strKeyWord.toLowerCase().contains("r18")
							|| strKeyWord.toLowerCase().contains("r-18")
							|| strKeyWord.toLowerCase().contains("18禁")
							|| strKeyWord.toLowerCase().contains("nsfw")) {
						backgroundImageUrl = "/img/R-18.png_360.jpg";
					} else {
						backgroundImageUrl = Common.GetUrl(results.sampleContentFile.get(nCnt)) + "_360.jpg";
					}

				%>
				<div class="IllustThumb" style="height: <%=bSmartPhone ? 112 : 142%>px;" >
					<div class="IllustThumbImg" style="background-image:url('<%=backgroundImageUrl%>')"></div>
					<a class="IllustThumbImgMask" href="/SearchIllustByTagPcV.jsp?KWD=<%=strKeyWord%>"></a>
					<a class="IllustInfoTag" href="/SearchIllustByTagPcV.jsp?KWD=<%=strKeyWord%>">#<%=Util.toStringHtml(strKeyWord)%></a>
					<div class="IllustThumbBookmarkButton" onclick="UpdateFollowTagFromTagList(<%=checkLogin.m_nUserId%>, '<%=strKeyWord%>', this)"><i class="<%=isFollowTag?"fas":"far"%> fa-star"></i></div>
				</div>

				<%if(bSmartPhone){%>
				<%if(nCnt==8 || nCnt==17 || nCnt==26 || nCnt==35) {%>
				<%@ include file="/inner/TAd728x90_mid.jsp"%>
				<%}%>
				<%}else{%>
				<%if(nCnt==7 || nCnt==15) {%>
				<%@ include file="/inner/TAd728x90_mid.jsp"%>
				<%}%>
				<%}%>

				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchTagByKeywordPcV.jsp", "&KWD="+URLEncoder.encode(results.m_strKeyword, "UTF-8"), results.m_nPage, results.contentsNum, results.selectMaxGallery)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>