package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

import javax.servlet.http.HttpServletRequest;

public class SendTranslationSuggestionC {
	public int userId = -1;
	public String originalTxt = "";
	public String transLang = "";
	public String suggestionTxt = "";
	public String suggestionUsed = "";
	public String suggestionDesc = "";

	public String userAgent = "";
	public String ipAddress = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
			ipAddress = request.getRemoteAddr();
			if (ipAddress == null) ipAddress = "";
			userAgent = request.getHeader("user-agent");

			originalTxt = Util.toString(request.getParameter("EditOriginalTxt"));
			transLang = Util.toString(request.getParameter("EditTransLang"));
			suggestionTxt = Util.toString(request.getParameter("EditSuggestionTxt"));
			suggestionUsed = Util.toString(request.getParameter("EditSuggestionUsed"));
			suggestionDesc = Util.toString(request.getParameter("EditSuggestionDesc"));

		} catch(Exception e) {
			e.printStackTrace();
			userId = -1;
		}
	}

	final String mailTo = "cs@pipa.jp";
	final String mailSubject = "翻訳の提案";
	final String mailBodyFormat = """
		翻訳の提案を受け付けました。
		
		[対象]
		%s
		
		[提案 言語: %s]
		%s
		
		[使用箇所]
		%s
		
		[説明]
		%s
		
		user id: %d
		IP address: %s
		user agent: %s
		""";

	public boolean getResults(final CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != userId) return false;
		EmailUtil.send(
				mailTo,
				mailSubject,
				mailBodyFormat.formatted(
						originalTxt,
						transLang,
						suggestionTxt,
						suggestionUsed,
						suggestionDesc,
						userId,
						ipAddress,
						userAgent)
				);

		return false;
	}

}
