<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<section class="EventItemList">
	<a class="EventItem" href="/event/20200821_mangaMovie2/TopPcV.jsp">
		<%if(Math.random()>0.5) {%>
		<img class="EventBanner" src="/event/20200821_mangaMovie2/poipiku_2_bn_3.png" />
		<%} else {%>
		<img class="EventBanner" src="/event/20200821_mangaMovie2/poipiku_2_bn_4.png" />
		<%}%>
	</a>
	<a class="EventItem" href="/event/20190901/TopPcV.jsp">
		<img class="EventBanner" src="/event/20190901/banner_odai.png" />
	</a>
	<a class="EventItem" href="/event/20191001/TopPcV.jsp">
		<img class="EventBanner" src="/event/20191001/banner_karapare.png" />
	</a>
</section>
