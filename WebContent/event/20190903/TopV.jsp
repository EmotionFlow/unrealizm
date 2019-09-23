<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

SearchUserByTagC cResults = new SearchUserByTagC();
cResults.getParam(request);
cResults.m_strKeyword = "過去1お気に入りのラクガキ";
cResults.SELECT_MAX_GALLERY = 10000;
cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - ポイピク誕生祭</title>
		<style>
			.Wrapper {background: top center url('/event/20190903/1st_300cm_2.png') no-repeat; padding: 909px 0 0 0; background-size: 360px;	position: relative;float: none;}
			.IllustThumbList {display: flex; flex-flow: row wrap; width: 280px; margin: 0 40px; float: none;}
			.UserThumb {display: flex; width: 70px; height: 71.3px;background: none; border: none; padding: 9px 0px 18px 0px;justify-content: flex-end;}
			.UserThumb:nth-child(8n+1), .UserThumb:nth-child(8n+2), .UserThumb:nth-child(8n+3), .UserThumb:nth-child(8n+4) {padding: 24px 0px 3px 0px; justify-content: flex-start;}
			.UserThumb .UserThumbImg {width: 44px; height: 44px; margin: 0; padding: 0;flex: 0 0 44px;}
			.CmdList {display: flex; position: absolute; z-index: 1; width: 360px; height: 150px; top: 565px; justify-content: center; flex-flow: row wrap;}
			.CmdList .CmdPost {display: block; width: 311px; height: 110px; margin-bottom: 35px;}
			.CmdList .CmdMyPos {display: block; width: 146px; height: 150px; margin: 0 8px 0 0;}
			.CmdList .CmdBottom {display: block; width: 146px; height: 150px; margin: 0 0 0 8px;}
			.Wrapper.Bottom {background: bottom center url('/event/20190903/1st_50cm.png') no-repeat; padding: 0; background-size: 360px;}
			.Wrapper.Bottom .CmdTop {display: block; width: 360px; height: 115px;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>

		<article class="Wrapper">
			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CUser cUser = cResults.m_vContentList.get(nCnt);%>
					<a id="user_id_<%=cUser.m_nUserId%>" class="UserThumb" href="/IllustListV.jsp?ID=<%=cUser.m_nUserId%>" title="<%=Common.ToStringHtml(cUser.m_strNickName)%>">
						<span class="UserThumbImg" style="background-image:url('<%=Common.GetUrl(cUser.m_strFileName)%>_120.jpg')"></span>
					</a>
				<%}%>
			</section>
			<div class="CmdList">
				<a class="CmdMyPos" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop: $('#user_id_<%=cCheckLogin.m_nUserId%>').offset().top-50}, 500, 'swing');"></a>
				<a class="CmdBottom" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop: $('#CmdTop').offset().top-500}, 500, 'swing');"></a>
			</div>
		</article>
		<article class="Wrapper Bottom">
			<a id="CmdTop" class="CmdTop" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop: 0}, 500, 'swing');"></a>
		</article>
	</body>
</html>