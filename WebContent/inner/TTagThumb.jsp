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
<div class="TagThumb">
	<div class="TagThumbImg" style="background-image:url('<%=backgroundImageUrl%>')"></div>
	<a class="TagThumbImgMask" href="/SearchIllustByTagV.jsp?KWD=<%=URLEncoder.encode(strKeyWord, StandardCharsets.UTF_8)%>"></a>
	<a class="TagInfoTagName" href="/SearchIllustByTagV.jsp?KWD=<%=URLEncoder.encode(strKeyWord, StandardCharsets.UTF_8)%>">
		#<%=Util.toStringHtml(strKeyWord)%>
		<%if(transTxt != null &&  !transTxt.isEmpty()){%>
		<br/><span class="TagInfoTagTransName"><%=Util.toStringHtml(transTxt)%></span>
		<%}%>
	</a>
	<div class="TagThumbBookmarkButton" onclick="UpdateFollowTagFromTagList(<%=checkLogin.m_nUserId%>, '<%=strKeyWord%>', this)"><i class="<%=isFollowTag?"fas":"far"%> fa-star"></i></div>
</div>
