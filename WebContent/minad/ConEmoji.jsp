<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
{
<%
for(int i=0; i<Common.CATEGORY_EMOJI.length; i++) {
%>
{
<%
	for(int j=0; j<Common.CATEGORY_EMOJI[i].length; j++) {
%>
"<%=Common.CATEGORY_EMOJI[i][j]%>",
<%
	}
%>
},
<%
}
%>
}