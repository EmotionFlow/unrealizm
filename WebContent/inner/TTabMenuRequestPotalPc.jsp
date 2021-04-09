<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%{
	final String path = request.getServletPath();
%>
<%if(isApp){%>
<nav class="TabMenuWrapper">
	<ul class="TabMenu">
		<li><a class="TabMenuItem <%=path.indexOf("NewArrivalRequestAppV.jsp")>0?"Selected":""%>" href="/NewArrivalRequestAppV.jsp">新着</a></li>
		<li><a class="TabMenuItem <%=path.indexOf("NewArrivalRequestCreatorAppV.jsp")>0?"Selected":""%>" href="/NewArrivalRequestCreatorAppV.jsp">新着クリエイター</a></li>
		<li><a class="TabMenuItem <%=path.indexOf("PopularRequestCreatorAppV.jsp")>0?"Selected":""%>" href="/PopularRequestCreatorAppV.jsp">人気クリエイター</a></li>
	</ul>
</nav>
<%}else{%>
<nav class="TabMenuWrapper">
	<ul class="TabMenu">
		<li><a class="TabMenuItem <%=path.indexOf("NewArrivalRequestPcV.jsp")>0?"Selected":""%>" href="/NewArrivalRequestPcV.jsp">新着</a></li>
		<li><a class="TabMenuItem <%=path.indexOf("NewArrivalRequestCreatorPcV.jsp")>0?"Selected":""%>" href="/NewArrivalRequestCreatorPcV.jsp">新着クリエイター</a></li>
		<li><a class="TabMenuItem <%=path.indexOf("PopularRequestCreatorPcV.jsp")>0?"Selected":""%>" href="/PopularRequestCreatorPcV.jsp">人気クリエイター</a></li>
	</ul>
</nav>
<%}%>

<%}%>
