<%@page language="java" contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page trimDirectiveWhitespaces="true"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%
List<String> langTags = SupportedLocales.list.stream().map(e->e.locale.toLanguageTag()).collect(Collectors.toList());
String NOW = (new SimpleDateFormat("yyyy-MM-dd")).format(new java.util.Date());
CheckLogin checkLogin = new CheckLogin();
PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.selectMaxGallery = 1000;
cResults.selectMaxSampleGallery = 0;
cResults.selectSampleGallery = 0;
cResults.getResults(checkLogin);
%>
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
	<%for (String lang : langTags) {%>
	<url>
		<loc>https://unrealizm.com/?hl=<%=lang%></loc>
		<lastmod><%=NOW%></lastmod>
		<changefreq>weekly</changefreq>
		<priority>0.5</priority>
	</url>
	<url>
		<loc>https://unrealizm.com/PopularTagListPcV.jsp?hl=<%=lang%></loc>
		<lastmod><%=NOW%></lastmod>
		<changefreq>daily</changefreq>
		<priority>0.5</priority>
	</url>
	<%for(CTag tag : cResults.m_vTagListWeekly) {%>
	<url>
		<loc>https://unrealizm.com/SearchIllustByTagPcV.jsp?hl=<%=lang%>&amp;KWD=<%=URLEncoder.encode(tag.m_strTagTxt, StandardCharsets.UTF_8)%></loc>
		<lastmod><%=NOW%></lastmod>
		<changefreq>always</changefreq>
		<priority>0.5</priority>
	</url>
	<%}%>
	<url>
		<loc>https://unrealizm.com/NewArrivalPcV.jsp?hl=<%=lang%></loc>
		<lastmod><%=NOW%></lastmod>
		<changefreq>always</changefreq>
		<priority>0.5</priority>
	</url>
	<%}%>
</urlset>
