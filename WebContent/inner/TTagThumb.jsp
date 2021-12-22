<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	if (strKeyWord.toLowerCase().contains("r18")
			|| strKeyWord.toLowerCase().contains("r-18")
			|| strKeyWord.toLowerCase().contains("18禁")
			|| strKeyWord.toLowerCase().contains("nsfw")) {
		backgroundImageUrl = "/img/R-18.png_360.jpg";
	} else {
		backgroundImageUrl = Common.GetUrl(thumbnailFileName) + "_360.jpg";
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
<%}else{%>
<%if(nCnt==7 || nCnt==15) {%>
<%@ include file="/inner/TAd728x90_mid.jsp"%>
<%}%>
<%}%>
