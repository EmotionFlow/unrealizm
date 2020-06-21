<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<div class="FooterAd">
	<%if(Util.isSmartPhone(request)) {%>
		<%if(g_nSafeFilter==Common.AD_ID_ALL){%>







		<%}else{%>
		<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
		<%}%>
	<%} else {%>
		<%if(g_nSafeFilter==Common.AD_ID_ALL){%>







		<%}else{%>
		<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
		<%}%>
	<%}%>
</div>
