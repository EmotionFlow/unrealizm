<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ include file="/inner/Common.jsp"%>
<%
int TAG_LIST_NUM = 1;
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);;

String strSql = "";
String strJson = "";
ArrayList<Genre> contents = new ArrayList<Genre>();
ArrayList<Genre> contentsFavo = new ArrayList<>();
StringBuilder tagList = new StringBuilder();
DataSource dataSource = null;
Connection connection = null;
PreparedStatement statement = null;
ResultSet resultSet = null;

try {
	if(checkLogin.m_bLogin) {
		Class.forName("org.postgresql.Driver");
		dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
		connection = dataSource.getConnection();

		strSql = "SELECT * FROM genres ORDER BY content_num_total DESC";
		statement = connection.prepareStatement(strSql);
		resultSet = statement.executeQuery();
		while(resultSet.next()) {
			contents.add(new Genre(resultSet));
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;

		strSql = "SELECT * FROM genres WHERE genre_id IN(SELECT genre_id FROM follow_genres WHERE user_id=?) ORDER BY content_num_total DESC";
		statement = connection.prepareStatement(strSql);
		statement.setInt(1, checkLogin.m_nUserId);
		resultSet = statement.executeQuery();
		while(resultSet.next()) {
			contentsFavo.add(new Genre(resultSet));
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;
	}
	int nCnt = 0;
	tagList.append("var g_arrTagList = [");
	for (Genre genre: contents) {
		genre.genreImage = genre.genreImage.replace("\\", "\\\\").replace("\"", "\\\"").replace("'", "\\'");
		if(nCnt>0) tagList.append(",");
		if(nCnt%100==0) tagList.append("\n");
		tagList.append(String.format("[%d,'%s',%d,'%s']",
				genre.genreId,
				genre.genreName,
				genre.contentNumTotal,
				genre.genreImage));
		nCnt++;
	}
	tagList.append("];\n");

	nCnt = 0;
	tagList.append("var g_arrFavoriteTagList = [");
	for (Genre genre: contentsFavo) {
		genre.genreImage = genre.genreImage.replace("\\", "\\\\").replace("\"", "\\\"").replace("'", "\\'");
		if(nCnt>0) tagList.append(",");
		if(nCnt%100==0) tagList.append("\n");
		tagList.append(String.format("[%d,'%s',%d,'%s']",
				genre.genreId,
				genre.genreName,
				genre.contentNumTotal,
				genre.genreImage));
		nCnt++;
	}

	for (int nCntFav = 0; nCntFav < contents.size() && (nCntFav < 10-contentsFavo.size()); nCntFav++) {
		Genre genre = contents.get(nCntFav);
		//if(tag.m_nTagId<=1) continue;
		genre.genreName = genre.genreName.replace("\\", "\\\\").replace("\"", "\\\"").replace("'", "\\'");
		if(nCnt>0) tagList.append(",");
		tagList.append(String.format("[%d,'%s',%d,'%s']",
				genre.genreId,
				genre.genreName,
				genre.contentNumTotal,
				genre.genreImage));
		nCnt++;
	}
	tagList.append("];");
} catch(Exception e) {
	e.printStackTrace();
	Log.d(strSql);
} finally {
	try{if(resultSet != null)resultSet.close();resultSet=null;}catch(Exception e){;}
	try{if(statement != null)statement.close();statement=null;}catch(Exception e){;}
	try{if(connection != null)connection.close();connection=null;}catch(Exception e){;}
}
%>
<%=tagList.toString()%>

function EscapeString(string) {
	var strHtml = string.replace("\"", "&quot;");
	strHtml = strHtml.replace("&", "&amp;");
	strHtml = strHtml.replace("<", "&lt;");
	strHtml = strHtml.replace(">", "&gt;");

	return strHtml;
}

function ToSingle(strSrc) {
	var han= '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@-.,:';
	var zen= '１２３４５６７８９０ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ＠－．，：';
	var strDst = strSrc;
	for(i=0;i<zen.length;i++) {
		var regex = new RegExp(zen[i], "gm");
		strDst = strDst.replace(regex, han[i]);
	}
	return strDst;
}

function OnTagListUpdate() {
	var strSearch = $("#TagInputTxt").val().toLowerCase();
	var nFindNum = 0;
	var bFindComp = false;
	var strHtml = "";
	if(strSearch.length > 0) {
		for(var i=0; i<g_arrTagList.length; i++) {
			var strTagNameLower = g_arrTagList[i][1].toLowerCase();
			if(strTagNameLower.indexOf(strSearch)>=0) {
				nFindNum++;
				strHtml += CreateTagListItem(g_arrTagList[i][0], g_arrTagList[i][1], g_arrTagList[i][2], g_arrTagList[i][3]);
				if(strTagNameLower==strSearch) {
					bFindComp = true;
				}
			}
			if(nFindNum>9) break;
		}
	} else {
		for(var i=0; i<g_arrFavoriteTagList.length; i++) {
			strHtml += CreateTagListItem(g_arrFavoriteTagList[i][0], g_arrFavoriteTagList[i][1], g_arrFavoriteTagList[i][2], g_arrFavoriteTagList[i][3]);
			bFindComp = true;
		}
	}
	$("#TagInputSuggest").show();
	$("#TagInputSuggest").html(strHtml);
}

function CreateTagListItem(nId, strTagName, nTagNum, strTagFileName) {
	strTagName = EscapeString(strTagName);
	var strTagNameFull = strTagName + " (" + nTagNum + ")";
	var strTagFileName = "//img-cdn.poipiku.com" + strTagFileName;
	$TagInputItem = $('<div></div>').addClass('TagInputItem TagInputItemCandidate').attr('title', strTagNameFull).attr('onclick', 'OnTagListClick('+nId+', "'+strTagName+'", "'+strTagFileName+'")');
	$TagInputImg = $('<img />').addClass('TagInputImg').attr('src', strTagFileName).attr('onerror', 'this.onerror=null;this.src="//img-cdn.poipiku.com/img/default_genre.png"');
	$TagInputTxt = $('<span></span>').addClass('TagInputTxt').html(strTagNameFull);
	$TagInputItem.append($TagInputImg).append($TagInputTxt);
	return $TagInputItem.prop("outerHTML");
}

function OnTagListFocus() {
	$("#TagInputSuggest").show();
}

function OnTagListBlur() {
	$("#TagInputSuggest").hide();
}

function OnTagListToggle() {
	if($("#TagInputSuggest").html().length < 1) {
		OnTagListUpdate();
	} else {
		$("#TagInputSuggest").toggle();
	}
}

function OnTagListClick(nId, strTagName, strTagFileName) {
console.log(nId, strTagName);
	var elTag = $("*[name=TagInputItemData]");
	if(elTag.length >= <%=TAG_LIST_NUM%>) return;
	for(var i=0; i<elTag.length; i++) {
		if($(elTag[i]).val() == nId) return;
	}
	$("#TagInputItemList").append(CreateTagListItemData(nId, strTagName, strTagFileName));
	$("#TagInputSuggest").hide();
	if($("*[name=TagInputItemData]").length >= <%=TAG_LIST_NUM%>) $("#TagInputForm").hide();
}

function CreateTagListItemData(nId, strTagName, strTagFileName) {
	$TagInputItem = $('<div></div>').addClass('TagInputItem');
	var strTagFileName = "//img-cdn.poipiku.com" + strTagFileName;
	$TagInputImg = $('<img />').addClass('TagInputImg').attr('src', strTagFileName).attr('onerror', 'this.onerror=null;this.src="//img-cdn.poipiku.com/img/default_genre.png"');
	$TagInputTxt = $('<span></span>').addClass('TagInputTxt').html(strTagName);
	$TagInputCmd = $('<div></div>').addClass('TagInputCmd fa fa-times').attr('onclick', 'OnTagListDelete('+ nId + ')');
	$TagInputItemData = $('<input />').attr('id', 'TagInputItemData').attr('name','TagInputItemData').attr('type', 'hidden').val(nId);
	$TagInputItem.append($TagInputImg).append($TagInputTxt).append($TagInputCmd).append($TagInputItemData);
	return $TagInputItem.prop("outerHTML");
}

function OnTagListDelete(nId) {
	var elTag = $("*[name=TagInputItemData]");
	for(var i=0; i < elTag.length; i++) {
		if($(elTag[i]).val() == nId) {
			$(elTag[i]).parent().remove();
			break;
		}
	}
	if($("*[name=TagInputItemData]").length < <%=TAG_LIST_NUM%>) $("#TagInputForm").show();
}

var ADDNEWTAG = "<%=_TEX.T("FTagList.AddNewTag")%>";

function OnFocusTagList() {
	if($("#TagInputTxt").val()==ADDNEWTAG) {
		$("#TagInputTxt").val("");
	}
}

function GetTagName(nId) {
	var strTagName = "";
	for(var i=0; i < g_arrTagList.length; i++) {
		if(g_arrTagList[i][0]==nId) {
			strTagName = g_arrTagList[i][1];
			break;
		}
	}
	return strTagName;
}


function attach(obj,eve,func){
	if(obj.attachEvent){
		obj.attachEvent('on'+eve,func);
	}else{
		obj.addEventListener(eve,func,false);
	}
}

attach(window,'load',function(){
	var strHtml = "";
	for(var i=0; i < g_arrFavoriteTagList.length; i++) {
		strHtml += CreateTagListItem(g_arrFavoriteTagList[i][0], g_arrFavoriteTagList[i][1], g_arrFavoriteTagList[i][2], g_arrFavoriteTagList[i][3]);
	}
	$("#TagInputSuggest").html(strHtml);
	$("#TagInputTxt").val(ADDNEWTAG);
});
