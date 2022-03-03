<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%{
	final String path = request.getServletPath();
	Log.d(path);
%>
<nav class="TabMenuWrapper">
	<ul class="TabMenu">
		<li><a class="TabMenuItem <%=path.indexOf("MySketchbook")>0?"Selected":""%>" href="/MySketchbook<%=isApp?"App":"Pc"%>V.jsp">マイスケブ</a></li>
		<li><a class="TabMenuItem <%=path.indexOf("NewArrivalRequestCreator")>0?"Selected":""%>" href="/NewArrivalRequestCreator<%=isApp?"App":"Pc"%>V.jsp">新着クリエイター</a></li>
	</ul>
</nav>
<%}%>
