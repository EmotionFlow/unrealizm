<%@ page import="jp.pipa.poipiku.settlement.CardSettlement"%>
<%@ page import="jp.pipa.poipiku.settlement.Agent" %>
<%@ page import="jp.pipa.poipiku.settlement.VeritransCardSettlement" %>
<%@ page import="jp.pipa.poipiku.settlement.EpsilonCardSettlement" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

SendEmojiC cResults = new SendEmojiC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin, _TEX);
%>{
"result_num" : <%=(bRtn)?1:0%>,
"result" : "<%=CEnc.E(CEmoji.parse(cResults.m_strEmoji))%>",
"error_code" : <%=cResults.m_nErrCode%>
}