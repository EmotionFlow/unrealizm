<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%{
	final String path = request.getServletPath();
%>
<nav class="TabMenuWrapper">
	<ul class="TabMenu">
		<li><a class="TabMenuItem <%=path.indexOf("NewArrivalRequestPcV.jsp")>0?"Selected":""%>" href="/NewArrivalRequestPcV.jsp">新着</a></li>
		<li><a class="TabMenuItem <%=path.indexOf("NewArrivalRequestCreatorPcV.jsp")>0?"Selected":""%>" href="/NewArrivalRequestCreatorPcV.jsp">新着クリエイター</a></li>
		<li><a class="TabMenuItem <%=path.indexOf("PopularRequestCreatorPcV.jsp")>0?"Selected":""%>" href="/PopularRequestCreatorPcV.jsp">人気クリエイター</a></li>
	</ul>
</nav>
<%}%>