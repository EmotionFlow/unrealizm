<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%{
	final String path = request.getServletPath();
%>
<nav class="TabMenuWrapper">
	<ul class="TabMenu">
		<li><a class="TabMenuItem <%=path.indexOf("MySketchbook")>0?"Selected":""%>" href="/MySketchbook<%=isApp?"App":"Pc"%>V.jsp"><%=_TEX.T("MySketchbookV.Tab.MyBook")%></a></li>
		<li><a class="TabMenuItem <%=path.indexOf("NewArrivalRequestCreator")>0?"Selected":""%>" href="/NewArrivalRequestCreator<%=isApp?"App":"Pc"%>V.jsp"><%=_TEX.T("MySketchbookV.Tab.NewCreators")%></a></li>
	</ul>
</nav>
<%}%>
