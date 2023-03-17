<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) return;

CheckNotifyC results = new CheckNotifyC();
results.m_nUserId = checkLogin.m_nUserId;
results.GetResults();
%>{
"check_comment":<%=results.m_nCheckComment%>,
"check_comment_reply":<%=results.m_nCheckCommentReply%>,
"check_follow":0,
"check_heart":0,
"check_request":<%=results.m_nCheckRequest%>,
"check_gift":<%=results.m_nCheckGift%>,
"check_wave_emoji":<%=results.m_nCheckWaveEmoji%>,
"check_wave_emoji_message":<%=results.m_nCheckWaveEmojiMessage%>,
"check_wave_emoji_message_reply":<%=results.m_nCheckWaveEmojiMessageReply%>,
"notify_comment":0,
"notify_follow":0,
"notify_heart":0,
"notify_request":0,
"notify_gift":0
}