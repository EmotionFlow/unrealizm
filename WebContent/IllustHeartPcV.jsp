<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/IllustHeartC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustHeartCParam cParam = new IllustHeartCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

IllustHeartC cResults = new IllustHeartC();
if(!cResults.GetResults(cParam)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

DateFormat cContentDateFromat = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT, request.getLocale());
cContentDateFromat.setTimeZone(Common.GetTimeZone(request));
SimpleDateFormat cImgArg = new SimpleDateFormat("yyyyMMddHHmmss");
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>ハート</title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<div class="IllustItemList">
				<div class="ItemComment">
					<%for(CComment cComment : cResults.m_cContent.m_vComment) {%>
					<a class="UserThumb" href="/IllustListPcV.jsp?ID=<%=cComment.m_nUserId%>">
						<span class="UserThumbImg">
							<img src="<%=Common.GetUrl(cComment.m_strFileName)%>_120.jpg" />
						</span>
						<span class="UserThumbName">
							<%=Common.ToStringHtml(cComment.m_strNickName)%>
						</span>
					</a>
					<%}%>
				</div>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>