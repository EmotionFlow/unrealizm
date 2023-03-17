<%@ page import="jp.pipa.poipiku.controller.*"%>
<%@ page import="jp.pipa.poipiku.CTag" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailV.jsp").forward(request,response);
	return;
}

MyHomeTagSettingC setting = new MyHomeTagSettingC();
setting.getParam(request);
setting.getResults(checkLogin);
%>
<div class="SettingList">
	<div id="FollowList" class="IllustThumbList"
		style="margin-left: 0px;margin-top: 7px;margin-bottom: 10px;">
		<%
		String backgroundImageUrl;
		String thumbnailFileName;
		CTag tag;
		String strKeyWord;
		String transTxt;
		boolean isFollowTag = true;
		int genreId;
		for(int nCnt = 0; nCnt< setting.tagList.size(); nCnt++) {
			tag = setting.tagList.get(nCnt);
			strKeyWord = tag.m_strTagTxt;
			thumbnailFileName = setting.sampleContentFile.get(nCnt);
			genreId = tag.m_nGenreId;
			transTxt = tag.m_strTagTransTxt;
		%>
		<%@include file="/inner/TTagThumb.jsp"%>
		<%}%>

	</div>
</div>
