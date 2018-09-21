<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
String[] CATEGORY_ID = {
		"0",
		"10",
		"1",
		"12",
		"3",
		"4",
		"5",
		"6",
		"7",
		"11",
		"8",
		"9",
};
String[] CATEGORY_NAME = {
		_TEX.T("Category.C0"),
		_TEX.T("Category.C10"),
		_TEX.T("Category.C1"),
		_TEX.T("Category.C12"),
		_TEX.T("Category.C3"),
		_TEX.T("Category.C4"),
		_TEX.T("Category.C5"),
		_TEX.T("Category.C6"),
		_TEX.T("Category.C7"),
		_TEX.T("Category.C11"),
		_TEX.T("Category.C8"),
		_TEX.T("Category.C9"),
};
%>
{
"result": <%=CATEGORY_ID.length%>,
"category_id" : [
<%for(int nCnt=0; nCnt<CATEGORY_ID.length; nCnt++) {%>
"<%=CEnc.E(CATEGORY_ID[nCnt])%>"<%if(nCnt<CATEGORY_ID.length-1){%>,<%}%>
<%}%>
],
"category_name" : [
<%for(int nCnt=0; nCnt<CATEGORY_NAME.length; nCnt++) {%>
"<%=CEnc.E(CATEGORY_NAME[nCnt])%>"<%if(nCnt<CATEGORY_NAME.length-1){%>,<%}%>
<%}%>
]
}
