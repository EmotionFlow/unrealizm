<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.settlement.CardSettlementEpsilon" %>
<%@ page import="jp.pipa.poipiku.util.Log" %>
<%@ page import="jp.pipa.poipiku.Common" %>
<%
	// 例：https://unrealizm.com/api/ChangeRegularlyAmountF.jsp?TOKEN=08yg3qghpwj48q6742o97qwqvh&ID=21808&AMT=300
	boolean result = false;
	String accessIpAddress = request.getRemoteAddr();
	if (!(accessIpAddress.equals("127.0.0.1") || accessIpAddress.equals(Common.GLOBAL_IP_ADDRESS))) return;

	String TOKEN = "08yg3qghpwj48q6742o97qwqvh";
	String token = request.getParameter("TOKEN");
	if (token != null && token.equals(TOKEN)) {
		try {
			int userId = Integer.parseInt(request.getParameter("ID"));
			int amount = Integer.parseInt(request.getParameter("AMT"));
			if (userId>0 && amount>=0 && amount<=300) {
				Log.d(String.format("received: %d, %d", userId, amount));
				CardSettlementEpsilon cardSettlementEpsilon = new CardSettlementEpsilon(userId);
				result = cardSettlementEpsilon.changeRegularlyAmount(amount);
			}
			if (!result) {
				Log.d("changeRegularlyAmount was failed");
			}
		} catch(Exception ex) {
			ex.printStackTrace();
		}
	}
%>
<%=result?"OK":"NG"%>
