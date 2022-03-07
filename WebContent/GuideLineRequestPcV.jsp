<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<%@ include file="/inner/THeaderCommonPc.jsp" %>
	<title>エアスケブ(β) ガイドライン</title>
	<style>
        table {
            width: 100%;
            border-collapse: collapse;
        }

        table td, table th {
            border: solid 1px #fff;
            vertical-align: middle;
            text-align: left;
        }

        table th {
            text-align: center;
        }
	</style>
	<style>
        .AnalogicoInfo {
            display: none;
        }

        .SettingList .SettingListItem {
            color: #fff;
        }
	</style>
</head>

<body>
<%@ include file="/inner/TMenuPc.jsp" %>

<article class="Wrapper">
	<%@include file="inner/GuideLineRequestV.jsp"%>
</article><!--Wrapper-->

<%@ include file="/inner/TFooterBase.jsp" %>
</body>
</html>