<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);
int userId = Util.toInt(request.getParameter("ID"));
if(!checkLogin.m_bLogin || (checkLogin.m_nUserId != userId)) return;

Log.d(String.format("ID: %d, ATTR: %s, VAR: %s", userId, request.getParameter("ATTR"), request.getParameter("VAL")));

UpdateRequestSettingCParam param = new UpdateRequestSettingCParam();
param.GetParam(request);

UpdateRequestSettingC controller = new UpdateRequestSettingC();
boolean result = controller.GetResults(param, checkLogin, _TEX);

%>{"result":<%=result?Common.API_OK:Common.API_NG%>,"error_code":<%=controller.errorKind.getCode()%>}
