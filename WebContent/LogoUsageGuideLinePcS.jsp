<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
	<%@ include file="/inner/THeaderCommonPc.jsp" %>
	<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("LogoUsageGuideLine.Title")%></title>
	<style>
        .SettingList .SettingListItem {
            color: #fff;
        }
		.LogoArea {
            text-align: center;
            display: flex;
            flex-direction: column;
			text-decoration: underline;
		}
		.LogoAreaLogo img{
			padding: 10px;
			margin: 0 0 20px 0;
            background: linear-gradient(45deg, #e0e0e0 25%, transparent 25%, transparent 75%, #e0e0e0 75%),
            linear-gradient(45deg, #e0e0e0 25%, transparent 25%, transparent 75%, #e0e0e0 75%);
            background-color: #ffffff;
		}
        .LogoAreaLogo.Small img {
            background-size: 10px 10px;
            background-position: 0 0, 5px 5px;
        }

        .LogoAreaLogo.Large img {
            background-size: 30px 30px;
            background-position: 0 0, 15px 15px;
        }

	</style>
</head>
<body>
<div id="DispMsg"></div>
<%String searchType = "Contents";%>
<%@ include file="/inner/TMenuPc.jsp"%>
<article class="Wrapper">
	<div class="SettingList">
		<div class="SettingListItem">
			<div class="SettingListTitle" style="text-align: center; font-size: 18px;"><%=_TEX.T("LogoUsageGuideLine.Title")%></div>
			<div class="SettingBody">
				<p><%=_TEX.T("LogoUsageGuideLine.Intro01")%></p>
				<p><%=_TEX.T("LogoUsageGuideLine.Intro02")%></p>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle"><%=_TEX.T("LogoUsageGuideLine.Logo.Title")%></div>
			<div class="SettingBody">
				<div class="LogoArea">
					<a class="LogoAreaLogo Small" href="https://img.poipiku.com/img/pc_top_title-03.png">
						<%=_TEX.T("LogoUsageGuideLine.Logo.Small")%><br>
						<img src="https://img.poipiku.com/img/pc_top_title-03.png" alt="poipiku logo small"/>
					</a>
					<a class="LogoAreaLogo Large" href="https://img.poipiku.com/img/poipiku_icon_512x512_2.png">
						<%=_TEX.T("LogoUsageGuideLine.Logo.Large")%><br>
						<img width="256px" height="256px" src="https://img.poipiku.com/img/poipiku_icon_512x512_2.png" alt="poipiku logo large"/>
					</a>
				</div>
			</div>
			<ul>
				<li><%=_TEX.T("LogoUsageGuideLine.Logo.Notify01")%></li>
				<li><%=_TEX.T("LogoUsageGuideLine.Logo.Notify02")%></li>
			</ul>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle"><%=_TEX.T("LogoUsageGuideLine.ProhibitedMatters.Title")%></div>
			<%=_TEX.T("LogoUsageGuideLine.ProhibitedMatters.Intro")%>
			<div class="SettingBody">
				<ol>
					<li><%=_TEX.T("LogoUsageGuideLine.ProhibitedMatters.Item01")%></li>
					<li><%=_TEX.T("LogoUsageGuideLine.ProhibitedMatters.Item02")%></li>
					<li><%=_TEX.T("LogoUsageGuideLine.ProhibitedMatters.Item03")%></li>
					<li><%=_TEX.T("LogoUsageGuideLine.ProhibitedMatters.Item04")%></li>
					<li><%=_TEX.T("LogoUsageGuideLine.ProhibitedMatters.Item05")%></li>
				</ol>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingBody">
				<p><%=_TEX.T("LogoUsageGuideLine.Other01")%></p>
				<p><%=_TEX.T("LogoUsageGuideLine.Other02")%></p>
			</div>
		</div>
	</div>
</article><!--Wrapper-->

<%@ include file="/inner/TFooterBase.jsp" %>
</body>
</html>