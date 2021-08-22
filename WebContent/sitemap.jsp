<%@page language="java" contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page trimDirectiveWhitespaces="true"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.*"%>
<%
String[] LANGS = {"ja", "en", "ko", "zh-Hans", "zh-CN", "zh-Hant", "zh-TW", "th"};
String NOW = (new SimpleDateFormat("YYYY-MM-dd")).format(new java.util.Date());
CheckLogin checkLogin = new CheckLogin();
PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.selectMaxGallery = 1000;
cResults.selectMaxSampleGallery = 0;
cResults.selectSampleGallery = 0;
boolean bRtn = cResults.getResults(checkLogin);
%>
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
	<%for (String lang : LANGS) {%>
	<url>
		<loc>https://poipiku.com/?hl=<%=lang%></loc>
		<lastmod><%=NOW%></lastmod>
		<changefreq>always</changefreq>
		<priority>0.5</priority>
	</url>
	<url>
		<loc>https://poipiku.com/PopularTagListPcV.jsp?hl=<%=lang%></loc>
		<lastmod><%=NOW%></lastmod>
		<changefreq>always</changefreq>
		<priority>0.5</priority>
	</url>
	<%for(CTag tag : cResults.m_vContentListWeekly) {%>
	<url>
		<loc>https://poipiku.com/SearchIllustByTagPcV.jsp?hl=<%=lang%>&amp;KWD=<%=URLEncoder.encode(tag.m_strTagTxt, "UTF-8")%></loc>
		<lastmod><%=NOW%></lastmod>
		<changefreq>always</changefreq>
		<priority>0.5</priority>
	</url>
	<%}%>
	<url>
		<loc>https://poipiku.com/NewArrivalPcV.jsp?hl=<%=lang%></loc>
		<lastmod><%=NOW%></lastmod>
		<changefreq>always</changefreq>
		<priority>0.5</priority>
	</url>
	<%}%>
</urlset>
