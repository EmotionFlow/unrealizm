package jp.pipa.poipiku.util;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;

import jp.pipa.poipiku.*;

public class CCnv {
	public static final int TYPE_USER_ILLUST = 0;
	public static final int TYPE_NEWARRIVAL_ILLUST = 1;
	public static final int TYPE_POPULAR_ILLUST = 2;
	public static final int TYPE_KEYWORD_ILLUST = 3;
	public static final int TYPE_TAG_ILLUST = 4;

	public static final int MODE_PC = 0;
	public static final int MODE_SP = 1;

	private static final String ILLUST_VIEW[][] ={
			{"/IllustViewPcV.jsp", "/IllustViewV.jsp"},
			{"/NewArrivalViewPcV.jsp", "/NewArrivalViewV.jsp"},
			{"/PopularIllustListViewPcV.jsp", "/PopularIllustListViewV.jsp"},
			{"/SearchIllustByKeywordViewPcV.jsp", "/SearchIllustByKeywordViewV.jsp"},
			{"/SearchIllustByTagViewPcV.jsp", "/SearchIllustByTagViewV.jsp"},
	};

	public static String Content2Html(CContent cContent,  int nLoginUserId, int nMode, ResourceBundleControl _TEX, ArrayList<String> vResult) throws UnsupportedEncodingException{
		String ILLUST_LIST = (nMode==MODE_SP)?"/IllustListV.jsp":"/IllustListPcV.jsp";
		String REPORT_FORM = (nMode==MODE_SP)?"/ReportFormV.jsp":"/ReportFormPcV.jsp";
		String ILLUST_DETAIL = (nMode==MODE_SP)?"/IllustDetailV.jsp":"/IllustDetailPcV.jsp";

		StringBuilder strRtn = new StringBuilder();

		// ユーザ名とフォローボタン
		strRtn.append(String.format("<div class=\"IllustItem\" id=\"IllustItem_%d\">", cContent.m_nContentId));
		strRtn.append("<div class=\"IllustItemUser\">");
		strRtn.append(String.format("<a class=\"IllustItemUserThumb\" href=\"%s?ID=%d\">", ILLUST_LIST, cContent.m_nUserId));
		strRtn.append(String.format("<img class=\"IllustItemUserThumbImg\" src=\"%s_120.jpg\" />", Common.GetUrl(cContent.m_cUser.m_strFileName)));
		strRtn.append("</a>");
		strRtn.append(String.format("<a class=\"IllustItemUserName\" href=\"%s?ID=%d\">", ILLUST_LIST, cContent.m_nUserId));
		strRtn.append(Common.ToStringHtml(cContent.m_cUser.m_strNickName));
		strRtn.append("</a>");
		if(cContent.m_cUser.m_nFollowing != CUser.FOLLOW_HIDE) {
			strRtn.append(String.format("<span id=\"UserInfoCmdFollow\" class=\"BtnBase UserInfoCmdFollow UserInfoCmdFollow_%d %s\" onclick=\"UpdateFollow(%d, %d)\">%s</span>",
					cContent.m_nUserId,
					(cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?"Selected":"",
					nLoginUserId,
					cContent.m_nUserId,
					(cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?_TEX.T("IllustV.Following"):_TEX.T("IllustV.Follow")));
		}
		strRtn.append("</div>");	// IllustItemUser

		// 画像
		strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d\" target=\"_blank\">", ILLUST_DETAIL, cContent.m_nUserId, cContent.m_nContentId));
		strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cContent.m_strFileName)));
		strRtn.append("</a>");

		// 2枚目以降
		if(cContent.m_nFileNum>1) {
			strRtn.append("<div class=\"IllustItemThubExpand\">");
			for(CContentAppend cContentAppend : cContent.m_vContentAppend) {
				strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d&AD=%d\" target=\"_blank\">", ILLUST_DETAIL, cContent.m_nUserId, cContent.m_nContentId, cContentAppend.m_nAppendId));
				strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cContentAppend.m_strFileName)));
				strRtn.append("</a>");
			}
			strRtn.append("</div>");	// IllustItemThubExpand
		}

		// 転載禁止表示と2枚目以降ボタン
		strRtn.append("<div class=\"IllustItemExpand\">");
		strRtn.append(String.format("<div class=\"IllustItemTProhibit\">%s</div>", _TEX.T("IllustView.ProhibitMsg")));
		if(cContent.m_nFileNum>1) {
			strRtn.append(String.format("<a class=\"IllustItemExpandBtn\" href=\"javascript:void(0)\" onclick=\"$('#IllustItem_%d .IllustItemThubExpand').slideDown(300);$(this).hide();\"><i class=\"far fa-clone\"></i> %s <i class=\"fas fa-chevron-down\"></i></a>",
					cContent.m_nContentId,
					String.format(_TEX.T("IllustView.ExpandBtn"), cContent.m_nFileNum-1)));
		}
		strRtn.append("</div>");	// IllustItemExpand

		// カテゴリーとコマンド
		strRtn.append("<div class=\"IllustItemCommand\">");
		strRtn.append(String.format("<span class=\"Category C%d\">%s</span>", cContent.m_nCategoryId, _TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))));
		strRtn.append("<div class=\"IllustItemCommandSub\">");
		String strUrl = URLEncoder.encode("https://poipiku.com/"+cContent.m_nUserId+"/"+cContent.m_nContentId+".html", "UTF-8");
		strRtn.append(String.format("<a class=\"IllustItemCommandTweet fab fa-twitter\" href=\"https://twitter.com/share?url=%s\"></a>", strUrl));
		if(cContent.m_nUserId==nLoginUserId) {
			strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"javascript:void(0)\" onclick=\"EditDesc(%d)\"></a>", cContent.m_nContentId));
			strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d, %d)\"></a>", nLoginUserId, cContent.m_nContentId));
		} else {
			strRtn.append(String.format("<a class=\"IllustItemCommandInfo fas fa-info-circle\" href=\"%s?TD=%d\"></a>", REPORT_FORM, cContent.m_nContentId));
		}
		strRtn.append("</div>");	// IllustItemCommandSub
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		strRtn.append(
			String.format("<div id=\"IllustItemDesc_%d\" class=\"IllustItemDesc\" %s>%s</div>",
				cContent.m_nContentId,
				(cContent.m_strDescription.isEmpty())?"style=\"display: none;\"":"",
				Common.AutoLink(Common.ToStringHtml(cContent.m_strDescription), nMode)
			)
		);

		// キャプション編集用
		if(cContent.m_nUserId==nLoginUserId) {
			strRtn.append(String.format("<div id=\"IllustItemDescEdit_%d\" class=\"IllustItemDescEdit\">", cContent.m_nContentId));
			strRtn.append(String.format("<textarea class=\"IllustItemDescEditTxt\">%s</textarea>", Common.ToStringHtmlTextarea(cContent.m_strDescription)));
			strRtn.append("<div class=\"IllustItemDescEditCmdList\">");
			strRtn.append(String.format("<a class=\"BtnBase IllustItemDescEditCmd\" onclick=\"UpdateDesc(%d, %d, %d)\">OK</a>", cContent.m_nUserId, cContent.m_nContentId, nMode));
			strRtn.append("</div>");	// IllustItemDescEditCmdList
			strRtn.append("</div>");	// IllustItemDescEdit
		}

		// 絵文字
		strRtn.append("<div class=\"IllustItemResList\">");
		strRtn.append("<div class=\"IllustItemResListTitle\">");
		if(cContent.m_vComment.size()<=0) {
			strRtn.append(_TEX.T("Common.IllustItemRes.Title.Init"));
		} else {
			strRtn.append(String.format(_TEX.T("Common.IllustItemRes.Title"), cContent.m_vComment.size()));
		}
		strRtn.append("</div>");	// IllustItemResListTitle
		for(CComment comment : cContent.m_vComment) {
			strRtn.append(String.format("<span class=\"ResEmoji\">%s</span>", comment.m_strDescription));
		}
		strRtn.append(String.format("<span id=\"ResEmojiAdd_%d\" class=\"ResEmojiAdd\"><span class=\"fas fa-plus-square\"></span></span>", cContent.m_nContentId));
		strRtn.append("</div>");	// IllustItemResList

		strRtn.append("<div class=\"IllustItemResBtnList\">");
		strRtn.append("<div class=\"ResBtnSetList\">");
		strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem Selected\" onclick=\"switchEmojiKeyboard(this, 0)\">%s</a>", _TEX.T("IllustV.Emoji.Popular")));
		strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, 1)\">%s</a>", _TEX.T("IllustV.Emoji.All")));
		strRtn.append("</div>");	// ResBtnSetList
		strRtn.append("<div class=\"ResEmojiBtnList\">");
		for(String emoji : vResult) {
			strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, '%s', %d)\">%s</a>", cContent.m_nContentId, emoji, nLoginUserId, Common.ToStringHtml(emoji)));
		}
		strRtn.append("</div>");	// ResEmojiBtnList
		strRtn.append("<div class=\"ResEmojiBtnList\" style=\"display: none;\">");
		for(String emoji : Common.EMOJI_KEYBORD) {
			strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, '%s', %d)\">%s</a>", cContent.m_nContentId, emoji, nLoginUserId, Common.ToStringHtml(emoji)));
		}
		//for(int nCnt=0; nCnt<Common.CATEGORY_EMOJI[cContent.m_nCategoryId].length; nCnt++) {
		//	strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, %d, %d, %d)\">%s</a>", cContent.m_nContentId, cContent.m_nCategoryId, nCnt, nLoginUserId, Common.ToStringHtml(Common.CATEGORY_EMOJI[cContent.m_nCategoryId][nCnt])));
		//}
		strRtn.append("</div>");	// ResEmojiBtnList
		strRtn.append("</div>");	// IllustItemResBtnList
		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}

	public static String toThumbHtml(CContent cContent, int nType, int nMode,  ResourceBundleControl _TEX) {
		return toThumbHtml(cContent, nType, nMode, "", _TEX);
	}

	public static String toThumbHtml(CContent cContent, int nType, int nMode, String strKeyword, ResourceBundleControl _TEX) {
		StringBuilder strRtn = new StringBuilder();

		String strFileNum = (cContent.m_nFileNum>1)?String.format("<i class=\"far fa-clone\"></i>%d", cContent.m_nFileNum):"";
		strRtn.append(String.format("<a class=\"IllustThumb\" href=\"%s?ID=%d&TD=%d&KWD=%s\">", ILLUST_VIEW[nType][nMode], cContent.m_nUserId, cContent.m_nContentId, strKeyword));
		strRtn.append(String.format("<span class=\"Category C%d\">%s %s</span>", cContent.m_nCategoryId, _TEX.T(String.format("Category.C%d", cContent.m_nCategoryId)), strFileNum));
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
