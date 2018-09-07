package com.emotionflow.poipiku.util;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import com.emotionflow.poipiku.*;

public class CCnv {
	public static final int MODE_PC = 0;
	public static final int MODE_SP = 1;

	public static String toHtml(CContent cContent,  int nLoginUserId, int nMode, ResourceBundleControl _TEX) throws UnsupportedEncodingException{
		String ILLUST_LIST = (nMode==MODE_SP)?"/IllustListV.jsp":"/IllustListPcV.jsp";
		String REPORT_FORM = (nMode==MODE_SP)?"/ReportFormV.jsp":"/ReportFormPcV.jsp";
		String ILLUST_DETAIL = (nMode==MODE_SP)?"/IllustDetailV.jsp":"/IllustDetailPcV.jsp";

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<div class=\"IllustItem\" id=\"IllustItem_%d\">", cContent.m_nContentId));
		strRtn.append("<div class=\"IllustItemUser\">");
		strRtn.append(String.format("<a class=\"IllustItemUserThumb\" href=\"%s?ID=%d\">", ILLUST_LIST, cContent.m_nUserId));
		strRtn.append(String.format("<img class=\"IllustItemUserThumbImg\" src=\"%s_120.jpg\" />", Common.GetUrl(cContent.m_cUser.m_strFileName)));
		strRtn.append("</a>");
		strRtn.append(String.format("<a class=\"IllustItemUserName\" href=\"%s?ID=%d\">", ILLUST_LIST, cContent.m_nUserId));
		strRtn.append(Common.ToStringHtml(cContent.m_cUser.m_strNickName));
		strRtn.append("</a>");


		if(cContent.m_cUser.m_nFollowing != CUser.FOLLOW_HIDE) {
			strRtn.append(String.format("<span id=\"UserInfoCmdFollow\" class=\"BtnBase UserInfoCmdFollow %s\" onclick=\"UpdateFollow()\">%s</span>",
					(cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?"Selected":"",
							(cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?_TEX.T("IllustV.Following"):_TEX.T("IllustV.Follow")));
		}
		strRtn.append("</div>");

		strRtn.append("<div class=\"IllustItemCommand\">");
		strRtn.append(String.format("<span class=\"Category C%d\">%s</span>", cContent.m_nCategoryId, _TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))));
		strRtn.append("<div class=\"IllustItemCommandSub\">");
		String strUrl = URLEncoder.encode("https://poipiku.com/"+cContent.m_nUserId+"/"+cContent.m_nContentId+".html", "UTF-8");
		strRtn.append(String.format("<a class=\"IllustItemCommandTweet fab fa-twitter-square\" href=\"https://twitter.com/share?url=%s\"></a>", strUrl));
		if(cContent.m_nUserId==nLoginUserId) {
			strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d)\"></a>", cContent.m_nContentId));
		} else {
			strRtn.append(String.format("<a class=\"IllustItemCommandInfo fas fa-info-circle\" href=\"%s?TD=%d\"></a>", REPORT_FORM, cContent.m_nContentId));
		}
		strRtn.append("</div>");
		strRtn.append("</div>");

		if(!cContent.m_strDescription.isEmpty()) {
			strRtn.append("<div class=\"IllustItemDesc\">");
			strRtn.append(Common.AutoLink(Common.ToStringHtml(cContent.m_strDescription), nMode));
			strRtn.append("</div>");
		}

		strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d\" target=\"_blank\">", ILLUST_DETAIL, cContent.m_nUserId, cContent.m_nContentId));
		strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cContent.m_strFileName)));
		strRtn.append("</a>");

		strRtn.append("<div class=\"IllustItemResList\">");
		strRtn.append("<div class=\"IllustItemResListTitle\">");
		if(cContent.m_vComment.size()<=0) {
			strRtn.append(_TEX.T("Common.IllustItemRes.Title.Init"));
		} else {
			strRtn.append(String.format(_TEX.T("Common.IllustItemRes.Title"), cContent.m_vComment.size()));
		}
		strRtn.append("</div>");
		for(CComment comment : cContent.m_vComment) {
			strRtn.append(String.format("<span class=\"ResEmoji\">%s</span>", comment.m_strDescription));
		}
		strRtn.append(String.format("<span id=\"ResEmojiAdd_%d\" class=\"ResEmojiAdd\"><span class=\"fas fa-plus-square\"></span></span>", cContent.m_nContentId));
		strRtn.append("</div>");

		strRtn.append("<div class=\"IllustItemResBtnList\">");
		for(int nCnt=0; nCnt<Common.CATEGORY_EMOJI[cContent.m_nCategoryId].length; nCnt++) {
			strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, %d, %d, %d)\">%s</a>", cContent.m_nContentId, cContent.m_nCategoryId, nCnt, nLoginUserId, Common.ToStringHtml(Common.CATEGORY_EMOJI[cContent.m_nCategoryId][nCnt])));
		}
		strRtn.append("</div>");
		strRtn.append("</div>");

		return strRtn.toString();
	}

	public static String toThumbHtml(CContent cContent, int nMode,  ResourceBundleControl _TEX) {
		String ILLUST_VIEW = (nMode==MODE_SP)?"/IllustViewV.jsp":"/IllustViewPcV.jsp";

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<a class=\"IllustThumb\" href=\"%s?ID=%d&TD=%d\">", ILLUST_VIEW, cContent.m_nUserId, cContent.m_nContentId));
		strRtn.append(String.format("<span class=\"Category C%d\">%s</span>", cContent.m_nCategoryId, _TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))));
		strRtn.append(String.format("<img class=\"IllustThumbImg\" src=\"%s_360.jpg\">", Common.GetUrl(cContent.m_strFileName)));
		strRtn.append("</a>");

		return strRtn.toString();
	}

	public static String toHtml(CUser cUser, int nMode,  ResourceBundleControl _TEX) {
		String ILLUST_LIST = (nMode==MODE_SP)?"/IllustListV.jsp":"/IllustListPcV.jsp";

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<a class=\"UserThumb\" href=\"%s?ID=%d\">", ILLUST_LIST, cUser.m_nUserId));
		strRtn.append(String.format("<span class=\"UserThumbImg\"><img src=\"%s\"></span>", Common.GetUrl(cUser.m_strFileName)));
		strRtn.append(String.format("<span class=\"UserThumbName\">%s</span>", Common.ToStringHtml(cUser.m_strNickName)));
		strRtn.append("</a>");

		return strRtn.toString();
	}

	public static String toHtml(CTag cTag, int nMode,  ResourceBundleControl _TEX) throws UnsupportedEncodingException {
		String SEARCH_ILLUST_TAG = (nMode==MODE_SP)?"/SearchIllustByTagV.jsp":"/SearchIllustByTagPcV.jsp";

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<a class=\"TagItem\" href=\"%s?KWD=%s\">#%s</a>", SEARCH_ILLUST_TAG, URLEncoder.encode(cTag.m_strTagTxt, "UTF-8"), Common.ToStringHtml(cTag.m_strTagTxt)));

		return strRtn.toString();
	}
}
