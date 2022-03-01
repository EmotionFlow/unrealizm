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
<%if (!bRtn || results.requests.size() == 0) {%>
	<div style="background: #ffffff; padding: 10px;">
	<%if (!bRtn) {%>
	データ取得時にエラーが発生しました
	<%}else if (results.pageNum==0) { %>
	見つかりませんでした
	<%} else {%>
	これ以上ありません
	<%}%>
	</div>
<%}else{ // if (results.requests.size() == 0) {%>
<%
String uploadJsp = "";
final String requestUserUrlFmt = isApp ? "/IllustListAppV.jsp?ID=%d" : "/%d/";
for(MyRequestListC.Result r : results.requests) {
	switch (r.request.mediaId) {
		case 1:
			uploadJsp = "UploadFilePcV.jsp";
			break;
		case 10:
			uploadJsp = "UploadTextPcV.jsp";
			break;
		default:
			uploadJsp = "UploadFilePcV.jsp";
	}
%>
<div id="RequestPane-<%=r.request.id%>" class="RequestPane">
	<div class="RequestHeader">
		<%if(r.request.amount > 0){%>
		<span class="RequestAmount">¥<%=String.format("%,d",r.request.amount)%></span>
		<%}else{%>
		<span>
			<img class="Twemoji" draggable="false" width="18" height="18" alt="🆓" src="https://twemoji.maxcdn.com/2/72x72/1f193.png">
		</span>
		<%}%>

		<%if(r.request.amount > 0 || r.request.creatorUserId == checkLogin.m_nUserId){%>
		<span class="RequestLimits">
			<%if(r.request.status == Request.Status.WaitingApproval){%>
			<span class="RequestTimeStamp">
				<span class="RequestTimeStampLabel">返答〆</span><span class="RequestTimeStampValue"><%=dateFormat.format(r.request.returnLimit)%></span>
			</span>
			<%}%>
			<%if(r.request.status == Request.Status.WaitingApproval || r.request.status == Request.Status.InProgress){%>
			<span class="RequestTimeStamp">
				<span class="RequestTimeStampLabel">お渡し期限</span><span class="RequestTimeStampValue"><%=dateFormat.format(r.request.deliveryLimit)%></span>
			</span>
			<%}%>
		</span>
		<%}%>
	</div>
	<div class="RequestHeader">
		<div class="RequestLicense">
			<span class="RequestLicenseLabel">用途</span><span class="RequestLicenseTitle" onclick="dispLicense(<%=r.request.licenseId%>)"><%=_TEX.T(String.format("Request.License.%d.title",r.request.licenseId))%></span>
		</div>
	</div>

	<div class="RequestBody">
		<%if(r.request.status == Request.Status.Done){%>
		<%if(r.textSummary!=null && !r.textSummary.isEmpty()){
			String textMore = r.textSummary.length() > 100 ? " ....." : "";
		%>
		<a class="IllustThumbImg"
		   href="/IllustView<%=isApp?"App":"Pc"%>V.jsp?ID=<%=r.request.creatorUserId%>&TD=<%=r.request.contentId%>">
			<span style="color: #6d6965"><%=r.textSummary + textMore%></span>
		</a>
		<%}else{%>
		<a class="IllustThumbImg"
		   href="/IllustView<%=isApp?"App":"Pc"%>V.jsp?ID=<%=r.request.creatorUserId%>&TD=<%=r.request.contentId%>"
		   style="background-image:url('<%=Common.GetUrl(r.contentFileName)%>_640.jpg')">
			<span class="IllustInfoBottom"></span>
		</a>
		<%}%>
		<%}%>
		<p style="word-break: break-word;"><%=Util.toStringHtml(r.request.requestText)%></p>
	</div>
	<div class="RequestFooter">
		<div class="RequestUser">
			<%if(results.category.equals("RECEIVED") && r.request.isClientAnonymous){%>
			<a class="RequestUserLink" href="javascript: void(0);">
				<span class="RequestUserLabel">From</span><span class="RequestUserNickname">匿名リクエスト</span>
			<%}else{%>
			<a class="RequestUserLink" href="<%=String.format(requestUserUrlFmt, results.category.equals("SENT") ? r.request.creatorUserId : r.request.clientUserId)%>">
				<span class="RequestUserLabel"><%=results.category.equals("SENT")?"To":"From"%></span><span class="RequestUserNickname"><%=r.nickname%></span>
				<%}%>
			</a>
		</div>
		<div class="RequestCmd">
			<%if(results.category.equals("RECEIVED") && r.request.status == Request.Status.WaitingApproval){%>
			<a class="BtnBase RequestAgreeBtn" onclick="acceptRequest(<%=r.request.id%>)" href="javascript:void(0)">依頼を受ける</a>
			<%}%>
			<%if(r.request.status == Request.Status.WaitingApproval){%>
			<a class="BtnBase RequestCancelBtn" onclick="cancelRequest(<%=r.request.id%>)" href="javascript:void(0)">
				<%=r.request.clientUserId == checkLogin.m_nUserId ? "キャンセルする" : "見送る"%>
			</a>
			<%}%>
			<%if(results.category.equals("RECEIVED") && r.request.status == Request.Status.InProgress){%>
			<a class="BtnBase RequestDeliveryBtn" onclick="deliveryRequest('<%=uploadJsp%>?ID=<%=checkLogin.m_nUserId%>&RID=<%=r.request.id%>')" href="javascript:void(0);" >お渡しする</a>
			<%}%>
		</div>
	</div>
</div>
<%} // for(MyRequestListC.Result r : results.requests) %>
<%} // // if (results.requests.size() == 0)%>
