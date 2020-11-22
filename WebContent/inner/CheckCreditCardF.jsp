<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;
CheckCreditCardC cResults = new CheckCreditCardC();
int nResult = cResults.getResults(checkLogin);
//JSON元データを格納する連想配列
Map<String, Object> root = null;
ObjectMapper mapper = null;

try {
    //ユーザの情報
    root = new HashMap<>();
    root.put("result", nResult);

    //JSONに変換して出力
    mapper = new ObjectMapper();
    Log.d(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
    out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
} catch(JsonGenerationException e)  {
    e.printStackTrace();
} finally {
    root = null;
    mapper = null;
}
%>