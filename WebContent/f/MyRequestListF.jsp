<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
	if(!checkLogin.m_bLogin) return;

	MyRequestListC results = new MyRequestListC();
	results.getParam(request);
	boolean bRtn = results.getResults(checkLogin, true);

	SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");

%>
<%for(MyRequestListC.Result r : results.requests) {%>
<div class="RequestPane">
	<div class="RequestHeader">
		<span class="RequestAmount">¥<%=String.format("%,d",r.request.amount)%></span>
		<span class="RequestLimits">
			<span class="RequestTimeStamp">
				<span class="RequestTimeStampLabel">返答期限</span><span class="RequestTimeStampValue"><%=dateFormat.format(r.request.returnLimit)%></span>
			</span>
			<span class="RequestTimeStamp">
				<span class="RequestTimeStampLabel">納品期限</span><span class="RequestTimeStampValue"><%=dateFormat.format(r.request.deliveryLimit)%></span>
			</span>
		</span>
	</div>
	<div class="RequestBody">
		<p><%=Util.toStringHtml(r.request.requestText)%></p>
	</div>
	<div class="RequestFooter">
		<div class="RequestUser">
			<a class="RequestUserLink" href="/<%=results.category.equals("SENT")?r.request.creatorUserId:r.request.clientUserId%>>/">
				<span class="RequestUserLabel"><%=results.category.equals("SENT")?"To":"From"%></span><span class="RequestUserNickname"><%=r.nickname%></span>
			</a>
		</div>
		<div class="RequestCmd">
			<%if(results.category.equals("RECEIVED")){%>
			<a class="BtnBase RequestAgreeBtn" href="javascript:void(0)">承認</a>
			<%}%>
			<a class="BtnBase RequestCancelBtn" href="javascript:void(0)">キャンセル</a>
		</div>
	</div>
</div>
<%}%>
