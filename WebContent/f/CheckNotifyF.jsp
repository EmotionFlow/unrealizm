<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) return;

CheckNotifyC cResults = new CheckNotifyC();
cResults.m_nUserId = checkLogin.m_nUserId;
cResults.GetResults();
%>{
"check_comment":<%=cResults.m_nCheckComment%>,
"check_comment_reply":<%=cResults.m_nCheckCommentReply%>,
"check_follow":0,
"check_heart":0,
"check_request":<%=cResults.m_nCheckRequest%>,
"check_gift":<%=cResults.m_nCheckGift%>,
"check_wave_emoji":<%=cResults.m_nCheckWaveEmoji%>,
"check_wave_emoji_message":<%=cResults.m_nCheckWaveEmojiMessage%>,
"check_wave_emoji_message_reply":<%=cResults.m_nCheckWaveEmojiMessageReply%>,
"notify_comment":0,
"notify_follow":0,
"notify_heart":0,
"notify_request":0,
"notify_gift":0
}