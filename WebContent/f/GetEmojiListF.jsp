<%@page import="jp.pipa.poipiku.ResourceBundleControl.CResourceBundleUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class GetEmojiListC {
	public int EMOJI_MAX = 5;

	public int m_nContentId = -1;
	public int m_nCategoryId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			m_nCategoryId	= Common.ToIntN(request.getParameter("CAT"), Common.EMOJI_CAT_FOOD, Common.EMOJI_CAT_ALL);
		} catch(Exception e) {
			;
		}
	}
}
%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

GetEmojiListC cResults = new GetEmojiListC();
cResults.getParam(request);
%>
<% for(String emoji : Common.EMOJI_LIST[cResults.m_nCategoryId]) {%>
	<a class="ResEmojiBtn" href="javascript:void(0)" onclick="SendEmoji(<%=cResults.m_nContentId%>, '<%=emoji%>', <%=cCheckLogin.m_nUserId%>)"><%=CEmoji.parse(emoji)%></a>
<%}%>
