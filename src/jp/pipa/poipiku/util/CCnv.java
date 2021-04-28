package jp.pipa.poipiku.util;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CTag;
import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.ResourceBundleControl;

public final class CCnv {
	public static final int TYPE_USER_ILLUST = 0;
	public static final int MODE_PC = 0;
	public static final int MODE_SP = 1;
	public static final int VIEW_LIST = 0;
	public static final int VIEW_DETAIL = 1;
	public static final int SP_MODE_WVIEW = 0;
	public static final int SP_MODE_APP = 1;

	private static String getIllustListContext(int nSpMode, int nUserId){
		if(nSpMode==SP_MODE_APP){
			return String.format("/IllustListAppV.jsp?ID=%d", nUserId);
		}else{
			return String.format("/%d/", nUserId);
		}
	}
	private static String getReportFormContext(int nMode){
		return (nMode==MODE_SP)?"/ReportFormV.jsp":"/ReportFormPcV.jsp";
	}
	private static String getIllustFromContext(int nMode, int nSpMode){
		String s = "";
		if(nSpMode==SP_MODE_APP){
			s = "/IllustDetailV.jsp";
		}else if(nMode==MODE_SP){
			s = "/IllustDetailPcV.jsp";
		}else{
			s = "/IllustDetailPcV.jsp";
		}
		return s;
	}

	private static String getSearchCategoryContext(int nMode, int nSpMode){
		String s = "";
		if(nSpMode==SP_MODE_APP){
			s = "/NewArrivalAppV.jsp";
		}else if(nMode==MODE_SP){
			s = "/NewArrivalPcV.jsp";
		}else{
			s = "/NewArrivalPcV.jsp";
		}
		return s;
	}
	private static String getIllustViewContext(int nMode, int nSpMode,  CContent cContent){
		String s = "";
		if(nSpMode==SP_MODE_APP){
			s = String.format("/IllustViewAppV.jsp?ID=%d&TD=%d", cContent.m_nUserId, cContent.m_nContentId);
		}else if(nMode==MODE_SP){
			s = String.format("/IllustViewPcV.jsp?ID=%d&TD=%d", cContent.m_nUserId, cContent.m_nContentId);
		}else{
			s = String.format("/%d/%d.html", cContent.m_nUserId, cContent.m_nContentId);
		}
		return s;
	}
	private static String getMyIllustViewContext(int nMode, int nSpMode,  CContent cContent){
		String s = "";
		if(nSpMode==SP_MODE_APP){
			s = String.format("/MyIllustViewAppV.jsp?ID=%d&TD=%d", cContent.m_nUserId, cContent.m_nContentId);
		}else{
			s = String.format("/MyIllustViewPcV.jsp?ID=%d&TD=%d", cContent.m_nUserId, cContent.m_nContentId);
		}
		return s;
	}
	private static String getThumbClass(CContent cContent){
		String strThumbClass = "";
		// Open class
		if(cContent.m_nOpenId==2) strThumbClass += " Hidden";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_R15) strThumbClass += " R15";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_R18) strThumbClass += " R18";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_R18G) strThumbClass += " R18G";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_PASS) strThumbClass += " Password";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_LOGIN) strThumbClass += " Login";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_FOLLOWER) strThumbClass += " Follower";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER) strThumbClass += " TFollower";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE) strThumbClass += " TFollow";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_T_EACH) strThumbClass += " TEach";
		if(cContent.m_nPublishId==Common.PUBLISH_ID_T_LIST) strThumbClass += " TList";

		// Editor Class
		if(cContent.m_nEditorId==Common.EDITOR_UPLOAD) strThumbClass += " Upload";
		if(cContent.m_nEditorId==Common.EDITOR_PASTE) strThumbClass += " Past";
		if(cContent.m_nEditorId==Common.EDITOR_BASIC_PAINT) strThumbClass += " BasicPaint";
		if(cContent.m_nEditorId==Common.EDITOR_TEXT) strThumbClass += " Text";
		return strThumbClass;
	}
	private static String getContentsFileNumHtml(CContent cContent){
		return (cContent.m_nFileNum>1)?String.format("<i class=\"far fa-images\"></i> %d", cContent.m_nFileNum):"";
	}
	private static void appendIllustItemCategory(StringBuilder strRtn, final CContent cContent, final String SEARCH_CATEGORY, final ResourceBundleControl _TEX, final int loginUserId){
		strRtn.append(String.format("<h2 id=\"IllustItemCategory_%d\" class=\"IllustItemCategory\">", cContent.m_nContentId));
		strRtn.append(String.format("<a class=\"Category C%d\" href=\"%s?CD=%s\">%s</a>",
				cContent.m_nCategoryId, SEARCH_CATEGORY, cContent.m_nCategoryId,
				_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))));
		strRtn.append("</h2>");
		if (cContent.m_nRequestId>0) {
			strRtn.append("<h2 class=\"IllustItemCategory\">");
			strRtn.append(String.format("<a class=\"Request\" href=\"javascript:void(0)\" onclick=\"dispRequestDlg(%d)\">%s</a>",
					cContent.m_nRequestId, _TEX.T("Request")
			));
			strRtn.append("</h2>");
		}
	}
	private static void appendIllustItemCommandSub(StringBuilder strRtn, CContent cContent, int nLoginUserId, int nSpMode, String REPORT_FORM, ResourceBundleControl _TEX){
		strRtn.append("<div class=\"IllustItemCommandSub\">");
		if(cContent.m_nUserId==nLoginUserId) {
			String strTwitterUrl = CTweet.generateAfterTweetMsg(cContent, _TEX);
			strRtn.append(String.format("<a class=\"IllustItemCommandTweet fab fa-twitter\" href=\"%s\" target=\"_blank\"></a>", strTwitterUrl));
			if(nSpMode == SP_MODE_APP) {
				if(cContent.m_nEditorId != Common.EDITOR_TEXT) {
					strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"myurlscheme://reEdit?ID=%d&TD=%d\"></a>", cContent.m_nUserId, cContent.m_nContentId));
				}
			} else {
				if(cContent.m_nEditorId == Common.EDITOR_PASTE) {
					strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"/UpdatePastePcV.jsp?ID=%d&TD=%d\"></a>", cContent.m_nUserId, cContent.m_nContentId));
				} else if(cContent.m_nEditorId == Common.EDITOR_TEXT) {
					strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"/UpdateTextPcV.jsp?ID=%d&TD=%d\"></a>", cContent.m_nUserId, cContent.m_nContentId));
				} else {
					strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"/UpdateFilePcV.jsp?ID=%d&TD=%d\"></a>", cContent.m_nUserId, cContent.m_nContentId));
				}
			}
			strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d, %d, %b)\"></a>", nLoginUserId, cContent.m_nContentId, !cContent.m_strTweetId.isEmpty()));
		} else {
			strRtn.append(String.format("<a class=\"IllustItemCommandInfo fas fa-info-circle\" href=\"%s?ID=%d&TD=%d\"></a>", REPORT_FORM, cContent.m_nUserId, cContent.m_nContentId));
			if(nLoginUserId==1) {
				strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d, %d, %b)\"></a>", nLoginUserId, cContent.m_nContentId, cContent.m_nUserId==1?true:false));
			}
			// ブクマボタン
			strRtn.append("<div class=\"IllustItemCmd\">");
			strRtn.append(String.format("<a id=\"IllustItemBookmarkBtn_%d\" class=\"BtnBase IllustItemBookmarkBtn %s\" href=\"javascript:void(0)\" onclick=\"UpdateBookmark(%d, %d);\"><i class=\"fas fa-star\"></i> %s</a>",
					cContent.m_nContentId,
					(cContent.m_nBookmarkState==CContent.BOOKMARK_BOOKMARKING)?"Selected":"",
					nLoginUserId,
					cContent.m_nContentId,
					_TEX.T("IllustV.Favo")));
			strRtn.append("</div>");	// IllustItemCmd
		}
		strRtn.append("</div>");	// IllustItemCommandSub

	}
	private static void appendIllustItemDesc(StringBuilder strRtn, CContent cContent, int nMode){
		strRtn.append(
			String.format("<h1 id=\"IllustItemDesc_%d\" class=\"IllustItemDesc\" %s>%s</h1>",
				cContent.m_nContentId,
				(cContent.m_strDescription.isEmpty())?"style=\"display: none;\"":"",
				Common.AutoLink(Util.toStringHtml(cContent.m_strDescription), cContent.m_nUserId, nMode)
			)
		);
	}
	private static void appendTag(StringBuilder strRtn, CContent cContent, int nMode, int nSpMode){
		strRtn.append(
			String.format("<h2 id=\"IllustItemTag_%d\" class=\"IllustItemTag\" %s>%s</h2>",
				cContent.m_nContentId,
				(cContent.m_strTagList.isEmpty())?"style=\"display: none;\"":"",
				Common.AutoLink(Util.toStringHtml(cContent.m_strTagList), cContent.m_nUserId, nMode, nSpMode)
			)
		);
	}

	private static void appendMyIllustListItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL) {
		String strFileUrl = Common.GetUrl(cContent.m_strFileName);
		strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s\">", ILLUST_VIEW));
		strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", strFileUrl));

		if(cContent.m_nOpenId==2){
			strRtn.append("<span class=\"IllustInfoPrivate\">");
		} else {
			strRtn.append("<span class=\"IllustInfoPublic\">");
		}
		if(cContent.m_nPublishId==99){
			strRtn.append("<span class=\"Publish Private\"></span>");
		} else if(cContent.m_bLimitedTimePublish){
			if(cContent.m_nOpenId==2){
				strRtn.append("<span class=\"Publish PublishLimitedNotPublished\"></span>");
			} else {
				strRtn.append("<span class=\"Publish PublishLimitedPublished\"></span>");
			}
		}
		strRtn.append("</span>");

		strRtn.append("<span class=\"IllustInfoBottom\">");
		if(cContent.m_nPublishId>=1 && cContent.m_nPublishId<=10) {
			strRtn.append(String.format("<span class=\"Publish PublishIco%02d\"></span>", cContent.m_nPublishId));
		}
		if(cContent.m_nFileNum>1){
			strRtn.append("<span class=\"Num\">").append(getContentsFileNumHtml(cContent)).append("</span>");
		}

		strRtn.append("</span>");	// IllustInfoBottom

		strRtn.append("</a>");
	}

	private static void appendIllustItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL){
		String strFileUrl = "";

		switch(cContent.m_nPublishId) {
		case Common.PUBLISH_ID_R15:
		case Common.PUBLISH_ID_R18:
		case Common.PUBLISH_ID_R18G:
		case Common.PUBLISH_ID_PASS:
		case Common.PUBLISH_ID_LOGIN:
		case Common.PUBLISH_ID_FOLLOWER:
		case Common.PUBLISH_ID_T_FOLLOWER:
		case Common.PUBLISH_ID_T_FOLLOWEE:
		case Common.PUBLISH_ID_T_EACH:
		case Common.PUBLISH_ID_T_LIST:
			// R18の時は1枚目にWarningを出すのでずらす
			cContent.m_nFileNum++;
			strFileUrl = Common.PUBLISH_ID_FILE[cContent.m_nPublishId];
			if(nViewMode==VIEW_DETAIL) {
				strRtn.append("<span class=\"IllustItemThumb\">");
				strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", strFileUrl));
				strRtn.append("</span>");
			} else {
				strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s\">", ILLUST_VIEW));
				strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", strFileUrl));
				strRtn.append("</a>");
			}
			break;
		case Common.PUBLISH_ID_ALL:
		case Common.PUBLISH_ID_HIDDEN:
		default:
			if(cContent.m_nEditorId!=Common.EDITOR_TEXT) {
				_appendIllustItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);
			} else {
				_appendTextItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);
			}
			break;
		}
	}


	private static void appendMyIllustItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL){
		_appendIllustItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);
	}

	private static void _appendIllustItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL) {
		String strFileUrl = Common.GetUrl(cContent.m_strFileName);
		if(nViewMode==VIEW_DETAIL) {
			strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d\">", ILLUST_DETAIL, cContent.m_nUserId, cContent.m_nContentId));
			strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", strFileUrl));
			strRtn.append("</a>");
		} else {
			strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s\">", ILLUST_VIEW));
			strRtn.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", strFileUrl));
			strRtn.append("</a>");
		}
	}


	private static void _appendTextItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL) {
		String strTextBody = Util.toStringHtml(cContent.m_strTextBody);
		if(nViewMode==VIEW_DETAIL) {
			strRtn.append(String.format("<a class=\"IllustItemText\" id=\"IllustItemText_%d\" href=\"%s?ID=%d&TD=%d\">", cContent.m_nContentId, ILLUST_DETAIL, cContent.m_nUserId, cContent.m_nContentId));
			strRtn.append(String.format("<span class=\"IllustItemThumbText\">%s</span>", strTextBody));
			strRtn.append("</a>");
		} else {
			strRtn.append(String.format("<a class=\"IllustItemText\" id=\"IllustItemText_%d\" href=\"%s\">", cContent.m_nContentId, ILLUST_VIEW));
			strRtn.append(String.format("<span class=\"IllustItemThumbText\">%s</span>", strTextBody));
			strRtn.append("</a>");
		}
	}

	private static void appendIllustItemResList(
			StringBuilder strRtn, CContent cContent, int nLoginUserId,
			ArrayList<String> vResult, int nSpMode,
			ResourceBundleControl _TEX){
		strRtn.append(String.format("<div id=\"IllustItemResList_%d\" class=\"IllustItemResList\">", cContent.m_nContentId, cContent.m_nContentId));
		// もらった絵文字展開リンク
		if(cContent.m_strCommentsListsCache.length()>=GridUtil.SELECT_MAX_EMOJI) {
			// 全て表示リンク
			strRtn.append("<div class=\"IllustItemResListTitle\">");
			//if(cContent.m_vComment.size()<=0) {
			//	strRtn.append(_TEX.T("Common.IllustItemRes.Title.Init"));
			//} else {
			//	strRtn.append(_TEX.T("Common.IllustItemRes.Title"));
			//}
			strRtn.append(String.format("<span class=\"TitleShowAll\" onclick=\"ShowAllReaction(%d, this)\">%s</span>", cContent.m_nContentId ,_TEX.T("Common.IllustItemRes.Title.ShowAll")));
			strRtn.append("</div>");	// IllustItemResListTitle
		}
		// もらった絵文字
		for (int i = 0; i < cContent.m_strCommentsListsCache.length(); i = cContent.m_strCommentsListsCache.offsetByCodePoints(i, 1)) {
			strRtn.append(String.format("<span class=\"ResEmoji\">%s</span>", CEmoji.parse(String.valueOf(Character.toChars(cContent.m_strCommentsListsCache.codePointAt(i))))));
		}
		/*
		for(CComment comment : cContent.m_vComment) {
			strRtn.append(String.format("<span class=\"ResEmoji\">%s</span>", CEmoji.parse(comment.m_strDescription)));
		}
		*/


		// 絵文字追加マーク
		strRtn.append(String.format("<span id=\"ResEmojiAdd_%d\" class=\"ResEmojiAdd\"><span class=\"fas fa-plus-square\"></span></span>", cContent.m_nContentId));
		strRtn.append("</div>");	// IllustItemResList
		// 絵文字ボタン
		strRtn.append("<div class=\"IllustItemResBtnList\">");
		// リアクション促し文言
		strRtn.append("<div class=\"IllustItemResListTitle\">");
		if(cContent.m_vComment.size()<=0) {
			strRtn.append(_TEX.T("Common.IllustItemRes.Title.Init"));
		} else {
			strRtn.append(_TEX.T("Common.IllustItemRes.Title"));
		}
		strRtn.append("</div>");	// IllustItemResListTitle
		strRtn.append("<div class=\"ResBtnSetList\">");
		strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem %s\" onclick=\"switchEmojiKeyboard(this, %d, 0)\">%s</a>", (nLoginUserId>0)?"Selected":"", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Recent")));
		strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem %s\" onclick=\"switchEmojiKeyboard(this, %d, 1)\">%s</a>", (nLoginUserId<1)?"Selected":"", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Popular")));
		// 使いまわしバレンタイン
		//strRtn.append(String.format("<a class=\"BtnBase Xmas ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 2)\">%s</a>", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Valentine")));
		// 使いまわし年賀状
		//strRtn.append(String.format("<a class=\"BtnBase Xmas ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 2)\">%s</a>", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Nenga")));
		// X'max
		//strRtn.append(String.format("<a class=\"BtnBase Xmas ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 2)\">%s</a>", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Xmas")));
		// Halloween
		//strRtn.append(String.format("<a class=\"BtnBase Food ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 2)\">%s</a>", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Halloween")));
		// Pocky
		//strRtn.append(String.format("<a class=\"BtnBase Pocky ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 2)\">%s</a>", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Pocky")));
		// Normal
		strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 2)\">%s</a>", cContent.m_nContentId, _TEX.T("IllustV.Emoji.Food")));
		strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 3)\">%s</a>", cContent.m_nContentId, _TEX.T("IllustV.Emoji.All")));
		if(!cContent.m_bCheerNg && (nSpMode != SP_MODE_APP)) {
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 4)\">%s</a>", cContent.m_nContentId, _TEX.T("Cheer")));
		}
		strRtn.append("</div>");	// ResBtnSetList

		if(nLoginUserId>0) {
			// 投げ銭支払い処理中
			strRtn.append("<div class=\"ResEmojiCheerNowPayment\" style=\"display:none\">")
					.append("<span class=\"CheerLoading\"></span><span>")
					.append(_TEX.T("Cheer.PaymentProcessing"))
					.append("</span>")
					.append("</div>");	// ResEmojiCheerNowPayment

			// よく使う絵文字
			strRtn.append("<div class=\"ResEmojiBtnList Recent\">");
			for(String emoji : vResult) {
				strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, '%s', %d, this)\">%s</a>", cContent.m_nContentId, emoji, nLoginUserId, CEmoji.parse(emoji)));
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
				strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, '%s', %d, this)\">%s</a>", cContent.m_nContentId, emoji, nLoginUserId, CEmoji.parse(emoji)));
			}
			strRtn.append("</div>");	// ResEmojiBtnList
		}
		// 食べ物の絵文字
		strRtn.append("<div class=\"ResEmojiBtnList Food\" style=\"display: none;\"></div>");
		// その他の絵文字
		strRtn.append("<div class=\"ResEmojiBtnList All\" style=\"display: none;\"></div>");
		if(!cContent.m_bCheerNg) {
			// ポチ袋
			if (nSpMode == SP_MODE_APP){
				// アプリであることを示すclassを付与して、JS側で区別できるようにする。
				//strRtn.append("<div class=\"ResEmojiBtnList Cheer App\" style=\"display: none;\"></div>");
			} else {
				strRtn.append("<div class=\"ResEmojiBtnList Cheer Browser\" style=\"display: none;\"></div>");
			}
		}
		strRtn.append("</div>");	// IllustItemResList
	}

	public static String toMyThumbHtmlPc(final CContent cContent,  int nLoginUserId, int nMode, final ResourceBundleControl _TEX, final ArrayList<String> vResult) throws UnsupportedEncodingException {
		if(cContent.m_nContentId<=0) return "";

		String ILLUST_LIST = getIllustListContext(SP_MODE_WVIEW, cContent.m_nUserId);
		String REPORT_FORM = getReportFormContext(nMode);
		String ILLUST_DETAIL = getIllustFromContext(nMode, SP_MODE_WVIEW);
		String SEARCH_CATEGORY = getSearchCategoryContext(nMode, SP_MODE_WVIEW);
		String ILLUST_VIEW = getMyIllustViewContext(nMode, SP_MODE_WVIEW, cContent);

		String strThumbClass = getThumbClass(cContent);

		StringBuilder strRtn = new StringBuilder();
		// ユーザ名とフォローボタン
		strRtn.append(String.format("<div class=\"IllustItem %s\" id=\"IllustItem_%d\">", strThumbClass, cContent.m_nContentId));
		strRtn.append("<div class=\"IllustItemUser\">");
		strRtn.append(String.format("<a class=\"IllustItemUserThumb\" href=\"%s\" style=\"background-image:url('%s_120.jpg')\"></a>", ILLUST_LIST, Common.GetUrl(cContent.m_cUser.m_strFileName)));
		strRtn.append(String.format("<h2 class=\"IllustItemUserName\"><a href=\"%s\">%s</a></h2>", ILLUST_LIST, Util.toStringHtml(cContent.m_cUser.m_strNickName)));
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

		appendIllustItemCategory(strRtn, cContent, SEARCH_CATEGORY, _TEX, nLoginUserId);

		// コマンド
		appendIllustItemCommandSub(strRtn, cContent, nLoginUserId, MODE_PC, REPORT_FORM, _TEX);
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		appendIllustItemDesc(strRtn, cContent, nMode);

		// タグ
		appendTag(strRtn, cContent, nMode, SP_MODE_WVIEW);

		// 画像
		appendMyIllustListItemThumb(strRtn, cContent, VIEW_LIST, ILLUST_VIEW, ILLUST_DETAIL);

		// 絵文字
		if(cContent.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			appendIllustItemResList(strRtn, cContent, nLoginUserId, vResult, SP_MODE_WVIEW, _TEX);
		}

		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}

	public static String Content2Html(final CContent cContent,  int nLoginUserId, int nMode, final ResourceBundleControl _TEX, final ArrayList<String> vResult) throws UnsupportedEncodingException {
		return Content2Html(cContent,  nLoginUserId, nMode, _TEX, vResult, VIEW_LIST, SP_MODE_WVIEW);
	}

	public static String Content2Html(final CContent cContent,  int nLoginUserId, int nMode, final ResourceBundleControl _TEX, final ArrayList<String> vResult, int nViewMode) throws UnsupportedEncodingException {
		return Content2Html(cContent,  nLoginUserId, nMode, _TEX, vResult, nViewMode, SP_MODE_WVIEW);
	}

	public static String Content2Html(final CContent cContent, int nLoginUserId, int nMode, final ResourceBundleControl _TEX, final ArrayList<String> vResult, int nViewMode, int nSpMode) throws UnsupportedEncodingException {
		if(cContent.m_nContentId<=0) return "";

		String ILLUST_LIST = getIllustListContext(nSpMode, cContent.m_nUserId);
		String REPORT_FORM = getReportFormContext(nMode);
		String ILLUST_DETAIL = getIllustFromContext(nMode, nSpMode);
		String SEARCH_CATEGORY = getSearchCategoryContext(nMode, nSpMode);
		String ILLUST_VIEW = getIllustViewContext(nMode, nSpMode, cContent);

		String strThumbClass = getThumbClass(cContent);

		StringBuilder strRtn = new StringBuilder();
		// ユーザ名とフォローボタン
		strRtn.append(String.format("<div class=\"IllustItem %s\" id=\"IllustItem_%d\">", strThumbClass, cContent.m_nContentId));
		strRtn.append("<div class=\"IllustItemUser\">");
		strRtn.append(String.format("<a class=\"IllustItemUserThumb\" href=\"%s\" style=\"background-image:url('%s_120.jpg')\"></a>", ILLUST_LIST, Common.GetUrl(cContent.m_cUser.m_strFileName)));
		strRtn.append(String.format("<h2 class=\"IllustItemUserName\"><a href=\"%s\">%s</a></h2>", ILLUST_LIST, Util.toStringHtml(cContent.m_cUser.m_strNickName)));
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
		// カテゴリー
		appendIllustItemCategory(strRtn, cContent, SEARCH_CATEGORY, _TEX, nLoginUserId);
		// コマンド
		appendIllustItemCommandSub(strRtn, cContent, nLoginUserId, nSpMode, REPORT_FORM, _TEX);
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		appendIllustItemDesc(strRtn, cContent, nMode);

		// タグ
		appendTag(strRtn, cContent, nMode, nSpMode);

		// 編集
		if(cContent.m_nUserId==nLoginUserId) {
			// キャプション
			strRtn.append(String.format("<div id=\"IllustItemDescEdit_%d\" class=\"IllustItemDescEdit\">", cContent.m_nContentId));
			strRtn.append(String.format("<textarea class=\"IllustItemDescEditTxt\" maxlength=\"200\">%s</textarea>", Util.toStringHtmlTextarea(cContent.m_strDescription)));
			strRtn.append(String.format("<input class=\"IllustItemTagEditTxt\" type=\"text\" maxlength=\"100\" value=\"%s\" />", Util.toDescString(cContent.m_strTagList)));
			strRtn.append("<div class=\"IllustItemDescEditCmdList\">");
			strRtn.append(String.format("<a class=\"BtnBase IllustItemDescEditCmd\" onclick=\"UpdateDesc(%d, %d, %d)\">OK</a>", cContent.m_nUserId, cContent.m_nContentId, nMode));
			strRtn.append("</div>");	// IllustItemDescEditCmdList
			strRtn.append("</div>");	// IllustItemDescEdit
		}


		// 画像
		appendIllustItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);

		// 2枚目以降用の場所
		strRtn.append("<div class=\"IllustItemThubExpand\"></div>");

		// 全て表示ボタン
		strRtn.append("<div class=\"IllustItemExpand\">");
		if(cContent.m_nFileNum>1) {
			strRtn.append(String.format("<div class=\"IllustItemExpandPassFrame\"><input class=\"IllustItemExpandPass\" name=\"PAS\" type=\"password\" maxlength=\"16\" placeholder=\"%s\" /></div>",
					_TEX.T("ShowAppendFileC.EnterPassword")));
			strRtn.append(String.format("<a class=\"BtnBase IllustItemExpandBtn\" href=\"javascript:void(0)\" onclick=\"ShowAppendFile(%d, %d, %d, this);\"><i class=\"far fa-clone\"></i> %s</a>",
				cContent.m_nUserId,
				cContent.m_nContentId,
				nMode,
				String.format(_TEX.T("IllustView.ExpandBtn"), cContent.m_nFileNum-1)));
		} else if (cContent.m_nEditorId==Common.EDITOR_TEXT) {
			strRtn.append(String.format("<div class=\"IllustItemExpandPassFrame\"><input class=\"IllustItemExpandPass\" name=\"PAS\" type=\"password\" maxlength=\"16\" placeholder=\"%s\" /></div>",
				_TEX.T("ShowAppendFileC.EnterPassword")));
			strRtn.append(String.format("<a class=\"BtnBase IllustItemExpandBtn\" href=\"javascript:void(0)\" onclick=\"ShowAppendFile(%d, %d, %d, this);\">%s</a>",
				cContent.m_nUserId,
				cContent.m_nContentId,
				nMode,
				String.format(_TEX.T("IllustView.ExpandBtnText"), cContent.m_strTextBody.length())));
		}
		strRtn.append("</div>");	// IllustItemExpand


		// 転載禁止表示
		String strSizeAppendex = "";
		if(cContent.m_nFileWidth>0 && cContent.m_nFileHeight>0) {
			strSizeAppendex = "(" + String.format(_TEX.T("UploadFileTweet.OriginalSize"), cContent.m_nFileWidth, cContent.m_nFileHeight) + ")";
		}
		strRtn.append(String.format("<div class=\"IllustItemTProhibit\"><span class=\"TapToFull\">%s</span>%s</div>",
				(nViewMode==VIEW_DETAIL)?String.format(_TEX.T("IllustView.ProhibitMsg.TapToFull"), strSizeAppendex):strSizeAppendex,
				_TEX.T("IllustView.ProhibitMsg")));

		// 絵文字
		if(cContent.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			appendIllustItemResList(strRtn, cContent, nLoginUserId, vResult, nSpMode, _TEX);
		}

		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}

	public static String MyContent2Html(final CContent cContent, int nLoginUserId, int nMode, final ResourceBundleControl _TEX, final ArrayList<String> vResult, int nViewMode, int nSpMode) throws UnsupportedEncodingException {
		if(cContent.m_nContentId<=0) return "";

		//String ILLUST_LIST = getIllustListContext(nMode, nSpMode, cContent.m_nUserId);
		String REPORT_FORM = getReportFormContext(nMode);
		String ILLUST_DETAIL = getIllustFromContext(nMode, nSpMode);
		String SEARCH_CATEGORY = getSearchCategoryContext(nMode, nSpMode);
		String ILLUST_VIEW = getIllustViewContext(nMode, nSpMode, cContent);

		String strThumbClass = getThumbClass(cContent);

		StringBuilder strRtn = new StringBuilder();
		strRtn.append(String.format("<div class=\"IllustItem %s\" id=\"IllustItem_%d\">", strThumbClass, cContent.m_nContentId));

		// カテゴリーとコマンド
		strRtn.append("<div class=\"IllustItemCommand\">");

		appendIllustItemCategory(strRtn, cContent, SEARCH_CATEGORY, _TEX, nLoginUserId);

		// コマンド
		appendIllustItemCommandSub(strRtn, cContent, nLoginUserId, nSpMode, REPORT_FORM, _TEX);
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		appendIllustItemDesc(strRtn, cContent, nMode);

		// タグ
		appendTag(strRtn, cContent, nMode, nSpMode);

		// 編集
		if(cContent.m_nUserId==nLoginUserId) {
			// キャプション
			strRtn.append(String.format("<div id=\"IllustItemDescEdit_%d\" class=\"IllustItemDescEdit\">", cContent.m_nContentId));
			strRtn.append(String.format("<textarea class=\"IllustItemDescEditTxt\" maxlength=\"200\">%s</textarea>", Util.toStringHtmlTextarea(cContent.m_strDescription)));
			strRtn.append(String.format("<input class=\"IllustItemTagEditTxt\" type=\"text\" maxlength=\"100\" value=\"%s\" />", Util.toDescString(cContent.m_strTagList)));
			strRtn.append("<div class=\"IllustItemDescEditCmdList\">");
			strRtn.append(String.format("<a class=\"BtnBase IllustItemDescEditCmd\" onclick=\"UpdateDesc(%d, %d, %d)\">OK</a>", cContent.m_nUserId, cContent.m_nContentId, nMode));
			strRtn.append("</div>");	// IllustItemDescEditCmdList
			strRtn.append("</div>");	// IllustItemDescEdit
		}


		// 画像
		appendMyIllustItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);

		// 2枚目以降用の場所
		strRtn.append("<div class=\"IllustItemThubExpand\"></div>");

		// 2枚目以降ボタン
		strRtn.append("<div class=\"IllustItemExpand\">");
		if(cContent.m_nFileNum>1) {
			strRtn.append(String.format("<div class=\"IllustItemExpandPassFrame\"><input class=\"IllustItemExpandPass\" name=\"PAS\" type=\"password\" maxlength=\"16\" placeholder=\"%s\" /></div>",
					_TEX.T("ShowAppendFileC.EnterPassword")));
			strRtn.append(String.format("<a class=\"BtnBase IllustItemExpandBtn\" href=\"javascript:void(0)\" onclick=\"ShowAppendFile(%d, %d, %d, this);\"><i class=\"far fa-clone\"></i> %s</a>",
					cContent.m_nUserId,
					cContent.m_nContentId,
					nMode,
					String.format(_TEX.T("IllustView.ExpandBtn"), cContent.m_nFileNum-1)));
		}
		strRtn.append("</div>");	// IllustItemExpand

		// 転載禁止表示
		String strSizeAppendex = "";
		if(cContent.m_nFileWidth>0 && cContent.m_nFileHeight>0) {
			strSizeAppendex = "(" + String.format(_TEX.T("UploadFileTweet.OriginalSize"), cContent.m_nFileWidth, cContent.m_nFileHeight) + ")";
		}
		strRtn.append(String.format("<div class=\"IllustItemTProhibit\"><span class=\"TapToFull\">%s</span>%s</div>",
				(nViewMode==VIEW_DETAIL)?String.format(_TEX.T("IllustView.ProhibitMsg.TapToFull"), strSizeAppendex):strSizeAppendex,
				_TEX.T("IllustView.ProhibitMsg")));

		// 絵文字
		if(cContent.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			appendIllustItemResList(strRtn, cContent, nLoginUserId, vResult, nSpMode, _TEX);
		}

		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}

	public static String toThumbHtml(CContent cContent, CheckLogin checkLogin, int nMode, int nSpMode, ResourceBundleControl _TEX) {
		String ILLUST_LIST = getIllustListContext(nSpMode, cContent.m_nUserId);
		String SEARCH_CATEGORY = getSearchCategoryContext(nMode, nSpMode);
		String ILLUST_VIEW = getIllustViewContext(nMode, nSpMode, cContent);

		StringBuilder strRtn = new StringBuilder();
		String strFileNum = getContentsFileNumHtml(cContent);

		strRtn.append("<div class=\"IllustThumb\">");

		// ユーザ情報
		strRtn.append(String.format("<a class=\"IllustUser\" href=\"%s\">", ILLUST_LIST));
		// 画像
		strRtn.append(String.format("<span class=\"IllustUserThumb\" style=\"background-image:url('%s_120.jpg')\"></span>", Common.GetUrl(cContent.m_cUser.m_strFileName)));
		// 名前
		strRtn.append(String.format("<h2 class=\"IllustUserName\">%s</h2>", Util.toStringHtml(cContent.m_cUser.m_strNickName)));
		strRtn.append("</a>");	// IllustItemUser

		// カテゴリ系情報
		strRtn.append("<span class=\"IllustInfo IllustMeta\">");
		// カテゴリ
		strRtn.append(
			String.format("<a class=\"CategoryInfo\" href=\"%s?CD=%d\"><span class=\"Category C%d\">%s</span></a>",
			SEARCH_CATEGORY,
			cContent.m_nCategoryId,
			cContent.m_nCategoryId,
			_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))
			)
		);
		strRtn.append("</span>");	// カテゴリ系情報(IllustInfo)

		// イラスト情報
		strRtn.append(String.format("<a class=\"IllustInfo\" href=\"%s\">", ILLUST_VIEW));
		// キャプション
		strRtn.append(String.format("<span class=\"IllustInfoDesc\">%s</span>", Util.toStringHtml(cContent.m_strDescription)));
		// サムネイル
		String strFileUrl = "";
		boolean bHidden = false;	// テキストモード用カバー画像表示フラグ
		if(checkLogin != null && cContent.m_nUserId == checkLogin.m_nUserId){
			strFileUrl = Common.GetUrl(cContent.m_strFileName);
		} else {
			switch(cContent.m_nPublishId) {
				case Common.PUBLISH_ID_R15:
				case Common.PUBLISH_ID_R18:
				case Common.PUBLISH_ID_R18G:
				case Common.PUBLISH_ID_PASS:
				case Common.PUBLISH_ID_LOGIN:
				case Common.PUBLISH_ID_FOLLOWER:
				case Common.PUBLISH_ID_T_FOLLOWER:
				case Common.PUBLISH_ID_T_FOLLOWEE:
				case Common.PUBLISH_ID_T_EACH:
				case Common.PUBLISH_ID_T_LIST:
					strFileUrl = Common.PUBLISH_ID_FILE[cContent.m_nPublishId];
					bHidden = true;
					break;
				case Common.PUBLISH_ID_ALL:
				case Common.PUBLISH_ID_HIDDEN:
			default:
				strFileUrl = Common.GetUrl(cContent.m_strFileName);
				break;
			}
		}
		strRtn.append("</a>");	// IllustInfo

		if(cContent.m_nEditorId!=Common.EDITOR_TEXT || bHidden) { // イラスト表示もしくはテキストだけど限定画像を表示
			// 画像
			strRtn.append(String.format("<a class=\"IllustThumbImg\" href=\"%s\" ", ILLUST_VIEW));
			if(cContent.m_nOpenId==0 || cContent.m_nOpenId==1){
				strRtn.append(String.format("style=\"background-image:url('%s_360.jpg')\">", strFileUrl));
			} else {
				strRtn.append(String.format("style=\"background: rgba(0,0,0,.7) url('%s_360.jpg');", strFileUrl))
				.append("background-blend-mode: darken;background-size: cover;background-position: 50% 50%;\">");
			}
		} else /*if(cContent.m_nEditorId==Common.EDITOR_TEXT)*/ {
			// テキスト
			strRtn.append(String.format("<a class=\"IllustThumbText\" href=\"%s\" ", ILLUST_VIEW));
			if(!(cContent.m_nOpenId==0 || cContent.m_nOpenId==1)){
				strRtn.append("style=\"background: rgba(0,0,0,.5);\"");
			}
			strRtn.append(">").append(
					Util.toStringHtml(cContent.m_strTextBody.replaceAll("^[\\s　]*", ""))
			);
		}

		// 公開非公開マーク
		if(checkLogin!=null && checkLogin.m_nUserId==cContent.m_nUserId && (cContent.m_nPublishId==99 || cContent.m_bLimitedTimePublish)){
			strRtn.append("<span class=\"IllustInfoCenter\">");
			if(cContent.m_nPublishId==99){
				strRtn.append("<span class=\"Publish Private\"></span>");
			} else if(cContent.m_nOpenId==0 || cContent.m_nOpenId==1){
				strRtn.append("<span class=\"Publish PublishLimitedPublished\"></span>");
			} else {
				strRtn.append("<span class=\"Publish PublishLimitedNotPublished\"></span>");
			}
			strRtn.append("</span>"); // IllustInfoCenter
		}

		// 公開種別マーク
		strRtn.append("<span class=\"IllustInfoBottom\">");
		if(checkLogin!=null && checkLogin.m_nUserId==cContent.m_nUserId){
			if(cContent.m_nPublishId>=1 && cContent.m_nPublishId<=10) {
				strRtn.append(String.format("<span class=\"Publish PublishIco%02d\"></span>", cContent.m_nPublishId));
			}
		}

		// 枚数マーク
		if(cContent.m_nFileNum>1){
			strRtn.append("<span class=\"Num\">").append(strFileNum).append("</span>");
		} else if(cContent.m_nEditorId==Common.EDITOR_TEXT) {
			strRtn.append(String.format("<span class=\"Num\">%d %s</span>", cContent.m_strTextBody.length(), _TEX.T("Common.Unit.Text")));
		}
		strRtn.append("</span>");	// IllustInfoBottom
		strRtn.append("</a>");	// IllustThumbImg | IllustThumbText
		strRtn.append("</div>");	// IllustThumb

		return strRtn.toString();
	}

	private static String _toHtml(CUser cUser, int nMode,  ResourceBundleControl _TEX, int nSpMode){
		String ILLUST_LIST = getIllustListContext(nSpMode, cUser.m_nUserId);
		StringBuilder strRtn = new StringBuilder();
		strRtn.append(String.format("<a class=\"UserThumb\" href=\"%s\">", ILLUST_LIST));
		strRtn.append(String.format("<span class=\"UserThumbImg\" style=\"background-image:url('%s_120.jpg')\"></span>", Common.GetUrl(cUser.m_strFileName)));
		strRtn.append(String.format("<span class=\"UserThumbName\">%s</span>", Util.toStringHtml(cUser.m_strNickName)));
		strRtn.append("</a>");

		return strRtn.toString();
	}

	public static String toHtml(CUser cUser, int nMode,  ResourceBundleControl _TEX) {
		return  _toHtml(cUser, nMode, _TEX, SP_MODE_WVIEW);
	}

	public static String toHtml(CUser cUser, int nMode,  ResourceBundleControl _TEX, int nSpMode) {
		return  _toHtml(cUser, nMode, _TEX, nSpMode);
	}

	private static String _toHtml(CTag cTag, int nMode,  ResourceBundleControl _TEX, int nSpMode) throws UnsupportedEncodingException {
		StringBuffer sb = new StringBuffer();
		sb.append("/SearchIllustByTag");

		if(nSpMode==SP_MODE_APP){
			sb.append("AppV");
		}else if(nMode==MODE_SP){
			sb.append("V");
		}else{
			sb.append("PcV");
		}
		sb.append(".jsp");

		return String.format(
				"<h2 class=\"TagItem\"><a class=\"TagName\" href=\"%s?KWD=%s\">#%s</a></h2>",
				sb.toString(),
				URLEncoder.encode(cTag.m_strTagTxt, "UTF-8"),
				Util.toStringHtml(cTag.m_strTagTxt)
		);
	}

	public static String toHtml(CTag cTag, int nMode,  ResourceBundleControl _TEX) throws UnsupportedEncodingException {
		return _toHtml(cTag, nMode, _TEX, SP_MODE_WVIEW);
	}

	public static String toHtml(CTag cTag, int nMode,  ResourceBundleControl _TEX, int nSpMode) throws UnsupportedEncodingException {
		return _toHtml(cTag, nMode, _TEX, nSpMode);
	}

	/*
	private static String _toHtmlKeyword(CTag cTag, int nMode,  ResourceBundleControl _TEX, int nSpMode) throws UnsupportedEncodingException {
		String SEARCH_ILLUST_KEYWORD = "";
		if(nSpMode==SP_MODE_APP){
			SEARCH_ILLUST_KEYWORD = "/SearchIllustByKeywordAppV.jsp";
		}else if(nMode==MODE_SP){
			SEARCH_ILLUST_KEYWORD = "/SearchIllustByKeywordV.jsp";
		}else{
			SEARCH_ILLUST_KEYWORD = "/SearchIllustByKeywordPcV.jsp";
		}
		return String.format(
			"<h2 class=\"TagItem\"><a class=\"TagName\" href=\"%s?KWD=%s\"><i class=\"fas fa-search\"></i> %s</a></h2>",
			SEARCH_ILLUST_KEYWORD, URLEncoder.encode(cTag.m_strTagTxt, "UTF-8"), Util.toStringHtml(cTag.m_strTagTxt)
		);
	}
	*/

	public static String toHtmlKeyword(CTag cTag, int nMode,  ResourceBundleControl _TEX) throws UnsupportedEncodingException {
		return _toHtml(cTag, nMode, _TEX, SP_MODE_WVIEW);
	}

	public static String toHtmlKeyword(CTag cTag, int nMode,  ResourceBundleControl _TEX, int nSpMode) throws UnsupportedEncodingException {
		return _toHtml(cTag, nMode, _TEX, nSpMode);
	}
}
