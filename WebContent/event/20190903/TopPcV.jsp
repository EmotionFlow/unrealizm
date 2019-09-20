<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchUserByTagC cResults = new SearchUserByTagC();
cResults.getParam(request);
cResults.m_strKeyword = "過去1お気に入りのラクガキ";
cResults.SELECT_MAX_GALLERY = 10000;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - ポイピク誕生祭</title>
		<script>
			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
			});
		</script>
		<style>
			.Wrapper {background: top center url('/event/20190903/1st_100cm.png') no-repeat; padding: 1044px 0 0 0; background-size: 360px;	position: relative;float: none;}
			.IllustThumbList {display: flex; flex-flow: row wrap; width: 280px; margin: 0 40px; float: none;}
			.UserThumb {display: flex; width: 70px; height: 72px;background: none; border: none; padding: 9px 0px 19px 0px;justify-content: flex-end;}
			.UserThumb:nth-child(8n+1), .UserThumb:nth-child(8n+2), .UserThumb:nth-child(8n+3), .UserThumb:nth-child(8n+4) {padding: 24px 0px 4px 0px; justify-content: flex-start;}
			.UserThumb .UserThumbImg {width: 44px; height: 44px; margin: 0; padding: 0;flex: 0 0 44px;}
			.CmdList {display: flex; position: absolute; z-index: 1; width: 360px; height: 296px; top: 555px; justify-content: center; flex-flow: row wrap;}
			.CmdList .CmdPost {display: block; width: 311px; height: 110px; margin-bottom: 35px;}
			.CmdList .CmdMyPos {display: block; width: 146px; height: 150px; margin: 0 8px 0 0;}
			.CmdList .CmdBottom {display: block; width: 146px; height: 150px; margin: 0 0 0 8px;}
			.Wrapper.Bottom {background: bottom center url('/event/20190903/1st_50cm.png') no-repeat; padding: 0; background-size: 360px;}
			.Wrapper.Bottom .CmdTop {display: block; width: 360px; height: 115px;}
			<%if(!Util.isSmartPhone(request)) {%>
			.Wrapper {background-size: 600px; padding-top: 1743px;}
			.IllustThumbList {width: 466px; margin: 0 67px; float: none;}
			.UserThumb {width: 116px; height: 119px; padding: 16px 0px 30px 0px;}
			.UserThumb:nth-child(8n+1), .UserThumb:nth-child(8n+2), .UserThumb:nth-child(8n+3), .UserThumb:nth-child(8n+4) {padding: 36px 0px 10px 0px;}
			.UserThumb .UserThumbImg {width: 73px; height: 73px; margin: 0; padding: 0;flex: 0 0 73px; border-radius: 73px;}
			.CmdList {width: 600px; height: 493px; top: 925px; justify-content: center; flex-flow: row wrap;}
			.CmdList .CmdPost {display: block; width: 518px; height: 183px; margin-bottom: 58px;}
			.CmdList .CmdMyPos {display: block; width: 243px; height: 250px; margin: 0 15px 0 0;}
			.CmdList .CmdBottom {display: block; width: 243px; height: 250px; margin: 0 0 0 15px;}
			.Wrapper.Bottom {background-size: 600px;}
			.Wrapper.Bottom .CmdTop {display: block; width: 600px; height: 194px;}
			<%}%>
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CUser cUser = cResults.m_vContentList.get(nCnt);%>
					<a id="user_id_<%=cUser.m_nUserId%>" class="UserThumb" href="/<%=cUser.m_nUserId%>/" title="<%=Common.ToStringHtml(cUser.m_strNickName)%>">
						<span class="UserThumbImg" style="background-image:url('<%=Common.GetUrl(cUser.m_strFileName)%>_120.jpg')"></span>
					</a>
				<%}%>
			</section>
			<div class="CmdList">
				<a class="CmdPost" href="/UploadFilePcV.jsp?TAG=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"></a>
				<a class="CmdMyPos" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop: $('#user_id_<%=cCheckLogin.m_nUserId%>').offset().top-50}, 500, 'swing');"></a>
				<a class="CmdBottom" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop: $('#CmdTop').offset().top-500}, 500, 'swing');"></a>
			</div>
		</article>
		<article class="Wrapper Bottom">
			<a id="CmdTop" class="CmdTop" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop: 0}, 500, 'swing');"></a>
		</article>


		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>