<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
//boolean bSmartPhone = Util.isSmartPhone(request);

//if(!bSmartPhone) {
	//getServletContext().getRequestDispatcher("/how_to/TopGridPcV.jsp").forward(request,response);
	//return;
//}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("HowTo.Title")%></title>
		<style>
			.AnalogicoInfo {display: none;}
			.IllustItem .IllustItemCommand .IllustItemCommandSub .IllustItemCommandDelete {display: none;}
		</style>

		<style>
			.HowToFarme {display: block; position: relative;}
			.HowToImage {width: 100%; border: 1px solid #999;}
			.HowToLinkList {display: flex; flex-flow: column; justify-content: center; width: 100%; position: absolute; z-index: 1; top: 94px;}
			.HowToLinkList .HowToLink {display: block; width: 100%; height: 62px; margin: 0 0 8.5px 0;}
			.CmdUp {display: block; position: absolute; width: 100%; height: 57px; left: 0; z-index: 1; bottom: 17px;}
			.HowToPin {margin-bottom:20px;}
			h1 {margin-bottom:10px;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<h1><%=_TEX.T("TwPin.Title")%></h1>
			<div class="HowToFarme">
				<div class="HowToPin">
					<h2><%=_TEX.T("TwPin.Step1")%></h2>
					<img id="HowToImage" class="HowToImage" src="/how_to/tw_pin_01.png" />
				</div>
				<div class="HowToPin">
					<h2><%=_TEX.T("TwPin.Step2")%></h2>
					<img id="HowToImage" class="HowToImage" src="/how_to/tw_pin_02.png" />
				</div>
				<div class="HowToPin">
					<h2><%=_TEX.T("TwPin.Step3")%></h2>
					<img id="HowToImage" class="HowToImage" src="/how_to/tw_pin_03.png" />
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>