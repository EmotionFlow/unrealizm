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
	public static final int TYPE_CATEGORY_ILLUST = 5;

	public static final int MODE_PC = 0;
	public static final int MODE_SP = 1;

	private static final String ILLUST_VIEW[][] ={
			{"/IllustViewPcV.jsp", "/IllustViewV.jsp"},
			{"/NewArrivalViewPcV.jsp", "/NewArrivalViewV.jsp"},
			{"/PopularIllustListViewPcV.jsp", "/PopularIllustListViewV.jsp"},
			{"/SearchIllustByKeywordViewPcV.jsp", "/SearchIllustByKeywordViewV.jsp"},
			{"/SearchIllustByTagViewPcV.jsp", "/SearchIllustByTagViewV.jsp"},
			{"/NewArrivalViewPcV.jsp", "/NewArrivalViewV.jsp"},
	};

	public static String Content2Html(CContent cContent,  int nLoginUserId, int nMode, ResourceBundleControl _TEX, ArrayList<String> vResult) throws UnsupportedEncodingException{
		String ILLUST_LIST = (nMode==MODE_SP)?"/IllustListV.jsp":"/IllustListPcV.jsp";
		String REPORT_FORM = (nMode==MODE_SP)?"/ReportFormV.jsp":"/ReportFormPcV.jsp";
		String ILLUST_DETAIL = (nMode==MODE_SP)?"/IllustDetailV.jsp":"/IllustDetailPcV.jsp";
		String SEARCH_CAYEGORY = (nMode==MODE_SP)?"/NewArrivalV.jsp":"/NewArrivalPcV.jsp";
		String LINK_TARG = (nMode==MODE_SP)?"":"target=\"_blank\"";

		StringBuilder strRtn = new StringBuilder();

		// ユーザ名とフォローボタン
		strRtn.append(String.format("<div class=\"IllustItem\" id=\"IllustItem_%d\">", cContent.m_nContentId));
		strRtn.append("<div class=\"IllustItemUser\">");
		strRtn.append(String.format("<a class=\"IllustItemUserThumb\" href=\"%s?ID=%d\" style=\"background-image:url('%s_120.jpg')\"></a>", ILLUST_LIST, cContent.m_nUserId, Common.GetUrl(cContent.m_cUser.m_strFileName)));
		strRtn.append(String.format("<h2 class=\"IllustItemUserName\"><a href=\"%s?ID=%d\">%s</a></h2>", ILLUST_LIST, cContent.m_nUserId, Common.ToStringHtml(cContent.m_cUser.m_strNickName)));
		if(cContent.m_cUser.m_nFollowing != CUser.FOLLOW_HIDE) {
			strRtn.append(String.format("<span id=\"UserInfoCmdFollow\" class=\"BtnBase UserInfoCmdFollow UserInfoCmdFollow_%d %s\" onclick=\"UpdateFollow(%d, %d)\">%s</span>",
					cContent.m_nUserId,
					(cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?"Selected":"",
					nLoginUserId,
					cContent.m_nUserId,
					(cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?_TEX.T("IllustV.Following"):_TEX.T("IllustV.Follow")));
		}
		strRtn.append("</div>");	// IllustItemUser


		// カテゴリーとコマンド
		strRtn.append("<div class=\"IllustItemCommand\">");
		strRtn.append(String.format("<h2 id=\"IllustItemCategory_%d\" class=\"IllustItemCategory\">", cContent.m_nContentId));
		strRtn.append(String.format("<a class=\"Category C%d\" href=\"%s?CD=%s\">%s</a>", cContent.m_nCategoryId, SEARCH_CAYEGORY, cContent.m_nCategoryId, _TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))));
		strRtn.append("</h2>");	// IllustItemCategory

		// カテゴリー編集要
		if(cContent.m_nUserId==nLoginUserId) {
			strRtn.append(String.format("<div id=\"IllustItemCategoryEdit_%d\" class=\"IllustItemCategoryEdit\">", cContent.m_nContentId));
			strRtn.append(String.format("<select id=\"EditCategory_%d\">", cContent.m_nContentId));
			for(int nCategoryId : Common.CATEGORY_ID) {
				strRtn.append((String.format("<option value=\"%d\" %s>%s</option>",
						nCategoryId,
						(nCategoryId==cContent.m_nCategoryId)?"selected":"",
						_TEX.T(String.format("Category.C%d", nCategoryId)))));
			}
			strRtn.append("</select>");
			strRtn.append("</div>");	// IllustItemCategoryEdit
		}

		// コマンド
		strRtn.append("<div class=\"IllustItemCommandSub\">");
		String strDesc = "["+_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))+"]" + cContent.m_strDescription.replaceAll("\n", " ").replaceAll("\r", " ");
		if(strDesc.length()>100) strDesc = strDesc.substring(0, 100);
		String strTwitterUrl=String.format("https://twitter.com/share?url=%s&text=%s&hashtags=%s",
				URLEncoder.encode("https://poipiku.com/"+cContent.m_nUserId+"/"+cContent.m_nContentId+".html", "UTF-8"),
				URLEncoder.encode(String.format(_TEX.T("Twitter.Illust.Desc"), strDesc, cContent.m_cUser.m_strNickName), "UTF-8"),
				URLEncoder.encode(_TEX.T("Common.Title"), "UTF-8"));
		strRtn.append(String.format("<a class=\"IllustItemCommandTweet fab fa-twitter\" href=\"%s\" %s></a>", strTwitterUrl, LINK_TARG));
		if(cContent.m_nUserId==nLoginUserId) {
			strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"javascript:void(0)\" onclick=\"EditDesc(%d)\"></a>", cContent.m_nContentId));
			strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d, %d)\"></a>", nLoginUserId, cContent.m_nContentId));
		} else {
			strRtn.append(String.format("<a class=\"IllustItemCommandInfo fas fa-info-circle\" href=\"%s?TD=%d\"></a>", REPORT_FORM, cContent.m_nContentId));
			if(nLoginUserId==1) {
				strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d, %d)\"></a>", nLoginUserId, cContent.m_nContentId));
			}
		}
		strRtn.append("</div>");	// IllustItemCommandSub
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		strRtn.append(
			String.format("<h1 id=\"IllustItemDesc_%d\" class=\"IllustItemDesc\" %s>%s</h1>",
				cContent.m_nContentId,
				(cContent.m_strDescription.isEmpty())?"style=\"display: none;\"":"",
				Common.AutoLink(Common.ToStringHtml(cContent.m_strDescription), cContent.m_nUserId, nMode)
			)
		);

		// タグ
		strRtn.append(
			String.format("<h2 id=\"IllustItemTag_%d\" class=\"IllustItemTag\" %s>%s</h1>",
				cContent.m_nContentId,
				(cContent.m_strTagList.isEmpty())?"style=\"display: none;\"":"",
				Common.AutoLink(Common.ToStringHtml(cContent.m_strTagList), cContent.m_nUserId, nMode)
			)
		);

		// 編集
		if(cContent.m_nUserId==nLoginUserId) {
			// キャプション
			strRtn.append(String.format("<div id=\"IllustItemDescEdit_%d\" class=\"IllustItemDescEdit\">", cContent.m_nContentId));
			strRtn.append(String.format("<textarea class=\"IllustItemDescEditTxt\" maxlength=\"200\">%s</textarea>", Common.ToStringHtmlTextarea(cContent.m_strDescription)));
			strRtn.append(String.format("<input class=\"IllustItemTagEditTxt\" type=\"text\" maxlength=\"100\" value=\"%s\" />", Util.toDescString(cContent.m_strTagList)));
			strRtn.append("<div class=\"IllustItemDescEditCmdList\">");
			strRtn.append(String.format("<a class=\"BtnBase IllustItemDescEditCmd\" onclick=\"UpdateDesc(%d, %d, %d)\">OK</a>", cContent.m_nUserId, cContent.m_nContentId, nMode));
			strRtn.append("</div>");	// IllustItemDescEditCmdList
			strRtn.append("</div>");	// IllustItemDescEdit
		}


		// 画像
		if(cContent.m_nSafeFilter<Common.SAFE_FILTER_R15) {
			strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d\" target=\"_blank\">", ILLUST_DETAIL, cContent.m_nUserId, cContent.m_nContentId));
			strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cContent.m_strFileName)));
			strRtn.append("</a>");
		} else if(cContent.m_nSafeFilter<Common.SAFE_FILTER_R18) {
			strRtn.append("<span class=\"IllustItemThumb\">");
			strRtn.append("<img class=\"IllustItemThumbImg\" src=\"/img/warning.png\" />");
			strRtn.append("</span>");
		} else {
			strRtn.append("<span class=\"IllustItemThumb\">");
			strRtn.append("<img class=\"IllustItemThumbImg\" src=\"/img/R-18.png\" />");
			strRtn.append("</span>");
		}

		// R18の時は1枚目にWarningを出すのでずらす
		if(cContent.m_nSafeFilter>1) cContent.m_nFileNum++;

		// 2枚目以降
		if(cContent.m_nFileNum>1) {
			strRtn.append("<div class=\"IllustItemThubExpand\">");
			// R18の時は1枚めをここで表示
			if(cContent.m_nSafeFilter>=Common.SAFE_FILTER_R15) {
				strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d\" target=\"_blank\">", ILLUST_DETAIL, cContent.m_nUserId, cContent.m_nContentId));
				strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cContent.m_strFileName)));
				strRtn.append("</a>");
			}
			for(CContentAppend cContentAppend : cContent.m_vContentAppend) {
				strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d&AD=%d\" target=\"_blank\">", ILLUST_DETAIL, cContent.m_nUserId, cContent.m_nContentId, cContentAppend.m_nAppendId));
				strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cContentAppend.m_strFileName)));
				strRtn.append("</a>");
			}
			strRtn.append("</div>");	// IllustItemThubExpand
		}

		// 転載禁止表示
		strRtn.append("<div class=\"IllustItemExpand\">");
		strRtn.append(String.format("<div class=\"IllustItemTProhibit\"><span class=\"TapToFull\">%s</span>%s</div>", _TEX.T("IllustView.ProhibitMsg.TapToFull"), _TEX.T("IllustView.ProhibitMsg")));
		// 2枚目以降ボタン
		if(cContent.m_nFileNum>1) {
		strRtn.append(String.format("<a class=\"BtnBase IllustItemExpandBtn\" href=\"javascript:void(0)\" onclick=\"$('#IllustItem_%d .IllustItemThubExpand').slideDown(300);$(this).hide();\"><i class=\"far fa-clone\"></i> %s</a>",
				cContent.m_nContentId,
				String.format(_TEX.T("IllustView.ExpandBtn"), cContent.m_nFileNum-1)));
		}
		strRtn.append("</div>");	// IllustItemExpand

		// 転載禁止表示
		//strRtn.append(String.format("<div class=\"IllustItemTProhibit\">%s</div>", _TEX.T("IllustView.ProhibitMsg")));

		// ブクマボタン
		strRtn.append("<div class=\"IllustItemCmd\">");
		strRtn.append(String.format("<a id=\"IllustItemBookmarkBtn_%d\" class=\"BtnBase IllustItemBookmarkBtn %s\" href=\"javascript:void(0)\" onclick=\"UpdateBookmark(%d, %d);\"><i class=\"fas fa-star\"></i> %s</a>",
				cContent.m_nContentId,
				(cContent.m_nBookmarkState==CContent.BOOKMARK_BOOKMARKING)?"Selected":"",
				nLoginUserId,
				cContent.m_nContentId,
				_TEX.T("IllustV.Favo")));
		strRtn.append("</div>");	// IllustItemCmd

		// 絵文字
		if(cContent.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			strRtn.append(String.format("<div id=\"IllustItemResList_%d\" class=\"IllustItemResList\">", cContent.m_nContentId));
			strRtn.append("<div class=\"IllustItemResListTitle\">");
			if(cContent.m_vComment.size()<=0) {
				strRtn.append(_TEX.T("Common.IllustItemRes.Title.Init"));
			} else {
				strRtn.append(_TEX.T("Common.IllustItemRes.Title"));
			}
			strRtn.append(String.format("<span class=\"TitleShowAll\" onclick=\"ShowAllReaction(%d, this)\">%s</span>", cContent.m_nContentId ,_TEX.T("Common.IllustItemRes.Title.ShowAll")));
			strRtn.append("</div>");	// IllustItemResListTitle
			// もらった絵文字
			for(CComment comment : cContent.m_vComment) {
				strRtn.append(String.format("<span class=\"ResEmoji\">%s</span>", CEmoji.parse(comment.m_strDescription)));
			}
			strRtn.append(String.format("<span id=\"ResEmojiAdd_%d\" class=\"ResEmojiAdd\"><span class=\"fas fa-plus-square\"></span></span>", cContent.m_nContentId));
			strRtn.append("</div>");	// IllustItemResList
			// 絵文字ボタン
			strRtn.append("<div class=\"IllustItemResBtnList\">");
			strRtn.append("<div class=\"ResBtnSetList\">");
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem %s\" onclick=\"switchEmojiKeyboard(this, %d, 0)\">%s</a>", (nLoginUserId>0)?"Selected":"", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Recent")));
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem %s\" onclick=\"switchEmojiKeyboard(this, %d, 1)\">%s</a>", (nLoginUserId<1)?"Selected":"", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Popular")));
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 2)\">%s</a>", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Food")));
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 3)\">%s</a>", cContent.m_nContentId, _TEX.T("IllustV.Emoji.All")));
			strRtn.append("</div>");	// ResBtnSetList

			if(nLoginUserId>0) {
				// よく使う絵文字
				strRtn.append("<div class=\"ResEmojiBtnList Recent\">");
				for(String emoji : vResult) {
					strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, '%s', %d)\">%s</a>", cContent.m_nContentId, emoji, nLoginUserId, CEmoji.parse(emoji)));
				}
				strRtn.append("</div>");	// ResEmojiBtnList
				// 人気の絵文字
				strRtn.append("<div class=\"ResEmojiBtnList Popular\" style=\"display: none;\"></div>");
			} else {
				// よく使う絵文字
				strRtn.append("<div class=\"ResEmojiBtnList Recent\" style=\"display: none;\"></div>");
				// 人気の絵文字
				strRtn.append("<div class=\"ResEmojiBtnList Popular\">");
				for(String emoji : vResult) {
					strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, '%s', %d)\">%s</a>", cContent.m_nContentId, emoji, nLoginUserId, CEmoji.parse(emoji)));
				}
				strRtn.append("</div>");	// ResEmojiBtnList
			}
			// 食べ物の絵文字
			strRtn.append("<div class=\"ResEmojiBtnList Food\" style=\"display: none;\"></div>");
			// 全ての絵文字
			strRtn.append("<div class=\"ResEmojiBtnList All\" style=\"display: none;\"></div>");
			strRtn.append("</div>");	// IllustItemResList
		}
		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}

	public static String toThumbHtml(CContent cContent, int nType, int nMode,  ResourceBundleControl _TEX) {
		return toThumbHtml(cContent, nType, nMode, "", _TEX);
	}

	public static String toThumbHtml(CContent cContent, int nType, int nMode, int nId, ResourceBundleControl _TEX) {
		return toThumbHtml(cContent, nType, nMode, ""+nId, _TEX);
	}

	public static String toThumbHtml(CContent cContent, int nType, int nMode, String strKeyword, ResourceBundleControl _TEX) {
		String SEARCH_CAYEGORY = (nMode==MODE_SP)?"/NewArrivalV.jsp":"/NewArrivalPcV.jsp";
		StringBuilder strRtn = new StringBuilder();
		String strFileNum = (cContent.m_nFileNum>1)?String.format("<i class=\"far fa-clone\"></i>%d", cContent.m_nFileNum):"";
		strRtn.append(String.format("<a class=\"IllustThumb\" href=\"%s?ID=%d&TD=%d&KWD=%s\">", ILLUST_VIEW[nType][nMode], cContent.m_nUserId, cContent.m_nContentId, strKeyword));
		if(cContent.m_nSafeFilter<2) {
			strRtn.append(String.format("<span class=\"IllustThumbImg\" style=\"background-image:url('%s_360.jpg')\"></span>", Common.GetUrl(cContent.m_strFileName)));
		} else if(cContent.m_nSafeFilter<4) {
			strRtn.append("<span class=\"IllustThumbImg\" style=\"background-image:url('/img/warning.png_360.jpg')\"></span>");
		} else {
			strRtn.append("<span class=\"IllustThumbImg\" style=\"background-image:url('/img/R-18.png_360.jpg')\"></span>");
		}
		strRtn.append("<span class=\"IllustInfo\">");
		strRtn.append(String.format("<span class=\"Category C%d\" onclick=\"location.href='%s?CD=%d';return false;\">%s %s</span>", cContent.m_nCategoryId, SEARCH_CAYEGORY, cContent.m_nCategoryId, _TEX.T(String.format("Category.C%d", cContent.m_nCategoryId)), strFileNum));
		strRtn.append(String.format("<span class=\"IllustInfoDesc\">%s</span>", Common.ToStringHtml(cContent.m_strDescription)));
		strRtn.append("</span>");	// IllustInfo
		strRtn.append("</a>");

		return strRtn.toString();
	}

	public static String toHtml(CUser cUser, int nMode,  ResourceBundleControl _TEX) {
		String ILLUST_LIST = (nMode==MODE_SP)?"/IllustListV.jsp":"/IllustListPcV.jsp";

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<a class=\"UserThumb\" href=\"%s?ID=%d\">", ILLUST_LIST, cUser.m_nUserId));
		strRtn.append(String.format("<span class=\"UserThumbImg\" style=\"background-image:url('%s_120.jpg')\"></span>", Common.GetUrl(cUser.m_strFileName)));
		strRtn.append(String.format("<span class=\"UserThumbName\">%s</span>", Common.ToStringHtml(cUser.m_strNickName)));
		strRtn.append("</a>");

		return strRtn.toString();
	}

	public static String toHtml(CTag cTag, int nMode,  ResourceBundleControl _TEX) throws UnsupportedEncodingException {
		String SEARCH_ILLUST_TAG = (nMode==MODE_SP)?"/SearchIllustByTagV.jsp":"/SearchIllustByTagPcV.jsp";

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<a class=\"TagItem\" href=\"%s?KWD=%s\"><i class=\"fas fa-hashtag\"></i> %s</a>", SEARCH_ILLUST_TAG, URLEncoder.encode(cTag.m_strTagTxt, "UTF-8"), Common.ToStringHtml(cTag.m_strTagTxt)));

		return strRtn.toString();
	}

	public static String toHtmlKeyword(CTag cTag, int nMode,  ResourceBundleControl _TEX) throws UnsupportedEncodingException {
		String SEARCH_ILLUST_KEYWORD = (nMode==MODE_SP)?"/SearchIllustByKeywordV.jsp":"/SearchIllustByKeywordPcV.jsp";

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<a class=\"TagItem\" href=\"%s?KWD=%s\"><i class=\"fas fa-search\"></i> %s</a>", SEARCH_ILLUST_KEYWORD, URLEncoder.encode(cTag.m_strTagTxt, "UTF-8"), Common.ToStringHtml(cTag.m_strTagTxt)));

		return strRtn.toString();
	}
}
