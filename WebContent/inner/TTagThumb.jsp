<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	if (strKeyWord.toLowerCase().contains("r18")
			|| strKeyWord.toLowerCase().contains("r-18")
			|| strKeyWord.toLowerCase().contains("18禁")
			|| strKeyWord.toLowerCase().contains("nsfw")) {
		backgroundImageUrl = "/img/R-18.png_360.jpg";
	} else {
		if (!thumbnailFileName.isEmpty()) {
			backgroundImageUrl = Common.GetUrl(thumbnailFileName) + "_360.jpg";
		} else {
			String genreImage = "";
			if (genreId > 0) {
				genreImage = Genre.select(genreId).genreImage;
			}
			if (genreImage.isEmpty()) {
				backgroundImageUrl = Common.GetUrl("/img/default_genre.png");
			} else {
				backgroundImageUrl = Common.GetUrl(genreImage);
			}
		}
	}
%>
<div class="TagThumb<%=bSmartPhone?"":"Pc"%>">
	<div class="TagThumbImg" style="background-image:url('<%=backgroundImageUrl%>')"></div>
	<a class="TagThumbImgMask" href="/SearchIllustByTag<%=isApp?"App":"Pc"%>V.jsp?KWD=<%=strKeyWord%>"></a>
	<a class="TagInfoTagName" href="/SearchIllustByTag<%=isApp?"App":"Pc"%>V.jsp?KWD=<%=strKeyWord%>">#<%=Util.toStringHtml(strKeyWord)%></a>
	<div class="TagThumbBookmarkButton" onclick="UpdateFollowTagFromTagList(<%=checkLogin.m_nUserId%>, '<%=strKeyWord%>', this)"><i class="<%=isFollowTag?"fas":"far"%> fa-star"></i></div>
</div>

<%if(bSmartPhone){%>
<%if(nCnt==8 || nCnt==17 || nCnt==26 || nCnt==35) {%>
<%@ include file="/inner/TAd336x280_mid.jsp"%>
<%}%>
<%}%>
