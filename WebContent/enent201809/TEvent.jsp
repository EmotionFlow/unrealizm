<%@page import="jp.pipa.poipiku.Common"%>
<%@page import="org.eclipse.jdt.internal.compiler.parser.NLSTag"%>
<%@page import="jp.pipa.poipiku.util.Log"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="javax.sql.DataSource"%>
<%
{
	int nPostNum = 0;
	String strSql = "";
	boolean bRtn = false;
	DataSource dsPostgres = null;
	Connection cConn = null;
	PreparedStatement cState = null;
	ResultSet cResSet = null;

	try {
		Class.forName("org.postgresql.Driver");
		dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
		cConn = dsPostgres.getConnection();


		// content main
		int nStartContentId = 0;
		strSql = "SELECT * FROM contents_0000 WHERE upload_date<='2018/09/25 20:00' order by upload_date DESC LIMIT 1";
		cState = cConn.prepareStatement(strSql);
		cResSet = cState.executeQuery();
		if(cResSet.next()) {
			nStartContentId = cResSet.getInt("content_id");
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;
		System.out.println("nContentId:"+nStartContentId);

		int nLastContentId = 0;
		strSql = "SELECT max(content_id) FROM contents_0000";
		cState = cConn.prepareStatement(strSql);
		cResSet = cState.executeQuery();
		if(cResSet.next()) {
			nLastContentId = cResSet.getInt(1);
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;
		nPostNum = nLastContentId - nStartContentId;
	} catch(Exception e) {
		Log.d(strSql);
		e.printStackTrace();
	} finally {
		try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
		try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
		try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
	}
%>
<a href="/enent201809/EventInfo.jsp" style="display: inline-block; width: 600px; margin: 0 0 20px 0; position: relative; color: #fff;">
	<img src="/enent201809/banner_top.png" style="width: 100%;" />
	<span style="display: block; font-size: 26px; width: 100%; font-weight: bold; position: absolute; bottom: 110px; z-index: 2;">
		ただ今<span style="font-size: 80px;"><%=nPostNum/10%></span>本
	</span>
</a>
<%}%>
