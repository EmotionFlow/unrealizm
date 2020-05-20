<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;
CheckMDKTokenC cResults = new CheckMDKTokenC();
int nResult = cResults.getResults(cCheckLogin);
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