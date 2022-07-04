package jp.pipa.poipiku.util;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import jp.pipa.poipiku.*;

import javax.xml.crypto.Data;

public final class CCnv {
	public static final int TYPE_USER_ILLUST = 0;
	public static final int MODE_PC = 0;
	public static final int MODE_SP = 1;
	public static final int VIEW_LIST = 0;
	public static final int VIEW_DETAIL = 1;
	public static final int SP_MODE_WVIEW = 0;
	public static final int SP_MODE_APP = 1;

	public enum PageCategory {
		MY_BOX, MY_ILLUST_LIST, DEFAULT
	}

	private static final String ILLUST_ITEM_THUMB_IMG = "<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" onload=\"setImgHeightStyle(this)\"/>";

	private static final String DATE_FORMAT_SHORT = "yyyy.MM.dd HH:mm";

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
		}else{
			s = "/IllustDetailPcV.jsp";
		}
		return s;
	}

	private static String getSearchCategoryContext(int nMode, int nSpMode){
		String s = "";
		if(nSpMode==SP_MODE_APP){
			s = "/NewArrivalAppV.jsp";
		}else{
			s = "/NewArrivalPcV.jsp";
		}
		return s;
	}
	private static String getIllustViewContext(int nMode, int nSpMode,  CContent cContent){
		String s = "";
		if(nSpMode==SP_MODE_APP){
			s = String.format("/IllustViewAppV.jsp?ID=%d&TD=%d", cContent.m_nUserId, cContent.m_nContentId);
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
		if(cContent.m_nPublishId==Common.PUBLISH_ID_T_RT) strThumbClass += " TRT";

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
//		if (cContent.m_nRequestId>0) {
//			strRtn.append("<h2 class=\"IllustItemCategory\">");
//			strRtn.append(String.format("<a class=\"Request\" href=\"javascript:void(0)\" onclick=\"dispRequestDlg(%d)\">%s</a>",
//					cContent.m_nRequestId, _TEX.T("Request")
//			));
//			strRtn.append("</h2>");
//		}
	}

	private static void appendIllustItemCommandSub(StringBuilder strRtn, CContent cContent, int nLoginUserId, int nMode, int nSpMode, String REPORT_FORM, ResourceBundleControl _TEX, PageCategory pageCategory){
		strRtn.append("<div class=\"IllustItemCommandSub\">");
		if(cContent.m_nUserId==nLoginUserId
				&& (pageCategory == PageCategory.MY_ILLUST_LIST || pageCategory == PageCategory.MY_BOX)) {

			// シェアボタン
			strRtn.append("<div class=\"IllustItemCmd\" style=\"float:none;display:inline-block;margin-right:14px\">");
			strRtn.append(String.format("<a class=\"NonFrameBtnBase IllustItemShareButton\" style=\"float:none;margin-bottom:-2px\" href=\"javascript:void(0)\" onclick=\"shareContent(%d, %d, %b);\"></a>",
					cContent.m_nUserId,
					cContent.m_nContentId,
					nMode == MODE_SP
			));
			strRtn.append("</div>");    // IllustItemCmd

			// ポイピク内でのピン留め
			strRtn.append("<div class=\"IllustItemCmd\" style=\"float:none;display:inline-block;margin-right:14px\">");
			strRtn.append(String.format("<a id=\"IllustItemPinBtn_%d\" class=\"NonFrameBtnBase IllustItemPinButton fas fa-thumbtack %s\" style=\"float:none;margin-bottom:-2px\" href=\"javascript:void(0)\" onclick=\"UpdatePin(%d, %d);\"></a>",
					cContent.m_nContentId,
					cContent.pinOrder>0?"Selected":"",
					cContent.m_nUserId,
					cContent.m_nContentId
			));
			strRtn.append("</div>");    // IllustItemCmd


			if(nSpMode == SP_MODE_APP) {
				if(cContent.m_nEditorId != Common.EDITOR_TEXT) {
					strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"myurlscheme://reEdit?ID=%d&TD=%d\"></a>", cContent.m_nUserId, cContent.m_nContentId));
				}
			} else {
				final String updateJsp;
				if(cContent.m_nEditorId == Common.EDITOR_PASTE) {
					updateJsp = "UpdatePastePcV";
				} else if(cContent.m_nEditorId == Common.EDITOR_TEXT) {
					updateJsp = "UpdateTextPcV";
				} else {
					updateJsp = "UpdateFilePcV";
				}
				strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"/%s.jsp?ID=%d&TD=%d\"></a>",
						updateJsp, cContent.m_nUserId, cContent.m_nContentId));

			}
			strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d, %d, %b)\"></a>", nLoginUserId, cContent.m_nContentId, !cContent.m_strTweetId.isEmpty()));
		} else {
			// 通報ボタン
			strRtn.append(String.format("<a class=\"IllustItemCommandInfo fas fa-info-circle\" href=\"%s?ID=%d&TD=%d\"></a>", REPORT_FORM, cContent.m_nUserId, cContent.m_nContentId));
			if(nLoginUserId==1) {
				strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d, %d, %b)\"></a>", nLoginUserId, cContent.m_nContentId, cContent.m_nUserId==1?true:false));
			}

			// シェアボタン
			strRtn.append("<div class=\"IllustItemCmd\">");
			strRtn.append(String.format("<a class=\"NonFrameBtnBase IllustItemShareButton\" href=\"javascript:void(0)\" onclick=\"shareContent(%d, %d, %b);\"></a>",
					cContent.m_nUserId,
					cContent.m_nContentId,
					nMode == MODE_SP
					));
			strRtn.append("</div>");    // IllustItemCmd

			// ブクマボタン
			strRtn.append("<div class=\"IllustItemCmd\">");
			strRtn.append(String.format("<a id=\"IllustItemBookmarkBtn_%d\" class=\"NonFrameBtnBase IllustItemBookmarkBtn\" href=\"javascript:void(0)\" onclick=\"UpdateBookmark(%d, %d);\"><i class=\"%s fa-bookmark\"></i></a>",
					cContent.m_nContentId,
					nLoginUserId,
					cContent.m_nContentId,
					(cContent.m_nBookmarkState==CContent.BOOKMARK_BOOKMARKING)?"fas":"far"
					));
			strRtn.append("</div>");	// IllustItemCmd
		}
		strRtn.append("</div>");	// IllustItemCommandSub

	}
	private static void appendIllustItemDesc(StringBuilder strRtn, CContent cContent, int nMode){
		final String def = cContent.m_strDescription;
		final String trs = cContent.m_strDescriptionTranslated;
		final boolean trsExist = trs!=null && !trs.isEmpty();
		final String descShowFirst = trsExist ? trs : def;

		String desc;

		final int firstDispLen = Common.EDITOR_DESC_MAX[0][0] + 300;
		int moreIndex = -1;
		if (descShowFirst.length() > firstDispLen) {
			moreIndex = descShowFirst.indexOf("\n", firstDispLen);
		}

		if (moreIndex < 0) {
			desc = Common.AutoLink(Util.toStringHtml(descShowFirst), cContent.m_nUserId, nMode);
		} else {
			desc = Common.AutoLink(Util.toStringHtml(descShowFirst.substring(0, moreIndex)), cContent.m_nUserId, nMode);
			desc += "<a class=\"IllustItemDescMoreLink\" onclick=\"readMoreDescription(this);\">...more</a>";
			desc += String.format(
					"<span class=\"IllustItemDescMore\" style=\"display:none;\">%s</span>",
					Common.AutoLink(Util.toStringHtml(descShowFirst.substring(moreIndex)), cContent.m_nUserId, nMode)
					);
		}
		if (trsExist) {
			strRtn.append("<div class=\"fas fa-language IllustItemDescTranslation\" onclick=\"toggleIllustItemDesc(this)\"></div>");
		}
		strRtn.append("<h1 id=\"IllustItemDesc_%d\" class=\"IllustItemDesc\" %s>".formatted(
				cContent.m_nContentId,
				(descShowFirst.isEmpty())?"style=\"display: none;\"":""
		));
		strRtn.append(desc);
		strRtn.append("</h1>");

		if (trsExist) {
			strRtn.append("<h1 class=\"IllustItemDesc\" style=\"display: none;\">");
			strRtn.append(Common.AutoLink(Util.toStringHtml(def), cContent.m_nUserId, nMode));
			strRtn.append("</h1>");
		}
	}

	private static HashMap<String, String> getTagNameTranslations(CheckLogin checkLogin, CContent content, List<String> tagNameList) {
		HashMap<String, String> translationMap = new HashMap<>();

		final String sql = """
						SELECT t.tag_txt, gt.trans_text
						FROM tags_0000 t
						         LEFT JOIN genre_translations gt ON t.genre_id = gt.genre_id
						WHERE t.content_id = ?
						  AND t.tag_type = 1
						  AND gt.type_id = 0
						  AND gt.lang_id = ?
						""";
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql);
				) {
			statement.setInt(1, content.m_nContentId);
			statement.setInt(2, checkLogin.m_nLangId);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				translationMap.put(resultSet.getString(1), resultSet.getString(2));
			}
			resultSet.close();
		} catch (SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return translationMap;
	}

	private static void appendTag(StringBuilder strRtn, CheckLogin checkLogin, CContent cContent, int nMode, int nSpMode){
		if (cContent.m_strTagList.isEmpty()) {
			strRtn.append("""
                    <h2 id="IllustItemTag_%d" style="display: none;"></h2>
					""".formatted(cContent.m_nContentId));
		} else {
			List<String> tagNameList = List.of(cContent.m_strTagList.split(" "));
			HashMap<String, String> translationMap = getTagNameTranslations(checkLogin, cContent, tagNameList);

			StringBuilder sb = new StringBuilder();
			String appOrPc = nSpMode==SP_MODE_APP?"App":"Pc";
			String withoutHashMark;
			String href = "";
			boolean isMyTag;
			for (String tagName: tagNameList) {
				if (tagName.isEmpty()) continue;

				isMyTag = (tagName.indexOf("##") == 0);
				if (isMyTag) {
					href = "/IllustList%sV.jsp?ID=%d&KWD=%s".formatted(
							appOrPc,
							checkLogin.m_nUserId,
							tagName.substring(2)
					);
				} else {
					href = "/SearchIllustByTag%sV.jsp?KWD=%s".formatted(
						appOrPc, tagName.substring(1)
					);
				}

				withoutHashMark = tagName.substring(1);
				sb.append("""
                        <a class="AutoLink%s" href="%s">
                        <div class="TagLabel">
							<div class="TagName">%s</div>
						""".formatted(isMyTag?"MyTag":"", href, tagName));

				if (translationMap.get(withoutHashMark) != null) {
					sb.append("""
							<div class="TagTrans">%s</div>
							""".formatted(translationMap.get(withoutHashMark)));
				}
				sb.append("</div></a>");
			}

			strRtn.append(
					"""
					<h2 id="IllustItemTag_%d" class="IllustItemTag">%s</h2>
					""".formatted(
							cContent.m_nContentId,
							sb.toString()
//							Common.AutoLink(Util.toStringHtml(cContent.m_strTagList), cContent.m_nUserId, nMode, nSpMode)
					)
			);
		}
	}

	private static void appendMyIllustListItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL) {
		String strFileUrl = Common.GetUrl(cContent.m_strFileName);
		strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s\">", ILLUST_VIEW));
		strRtn.append(String.format(ILLUST_ITEM_THUMB_IMG, strFileUrl));

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

	private static void appendContentItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL){
		final String strFileUrl;
		final int publishId = cContent.m_nPublishId;
		if (publishId == Common.PUBLISH_ID_ALL || !cContent.nowAvailable() || cContent.publishAllNum == 1) {
			if(cContent.m_nEditorId!=Common.EDITOR_TEXT) {
				appendIllustItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, Common.GetUrl(cContent.m_strFileName));
			} else {
				appendTextItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);
			}
		} else {
			cContent.m_nFileNum++;
			strFileUrl = Common.PUBLISH_ID_FILE[cContent.m_nPublishId];
			appendIllustItemThumb(strRtn, null, nViewMode, ILLUST_VIEW, strFileUrl);
		}
	}

	private static void appendMyIllustItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW){
		appendIllustItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, Common.GetUrl(cContent.m_strFileName));
	}

	private static void appendIllustInfoIcon(StringBuilder strRtn,  CContent content) {
		if (content == null) return;
		if (!content.nowAvailable()) {
			strRtn.append("<div class=\"IllustInfo\">");
			if (content.m_bLimitedTimePublish) {
				strRtn.append("<div class=\"OutOfPeriodIcon\"></div>");
			} else {
				strRtn.append("<div class=\"PrivateIcon\"></div>");
			}
			strRtn.append("</div>");
		}
	}

	public static void appendIllustItemThumb(StringBuilder strRtn, CContent cContent, CContentAppend contentAppend, int nViewMode, String ILLUST_VIEW, String strFileUrl) {
		if(nViewMode==VIEW_DETAIL) {
			appendIllustInfoIcon(strRtn, cContent);
			strRtn.append("<a class=\"IllustItemThumb");
			strRtn.append("\" href=\"javascript:void(0)\"");
			if (cContent != null) {
				strRtn.append(String.format(" onclick=\"showIllustDetail(%d, %d, %d)\"", cContent.m_nUserId, cContent.m_nContentId, contentAppend==null ? -1 : contentAppend.m_nAppendId));
			}
			strRtn.append(">");
		} else {
			strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s\">", ILLUST_VIEW));
		}
		strRtn.append(String.format(ILLUST_ITEM_THUMB_IMG, strFileUrl));
		strRtn.append("</a>");
	}

	public static void appendIllustItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW, String strFileUrl) {
		appendIllustItemThumb(strRtn, cContent, null, nViewMode, ILLUST_VIEW, strFileUrl);
	}

	private static void appendTextItemThumb(StringBuilder strRtn, CContent cContent, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL) {
		String className = "IllustItemThumbText";
		if(cContent.novelDirection==1) {
			className += " Vertical";
		}

		if(nViewMode==VIEW_DETAIL) {
			appendIllustInfoIcon(strRtn, cContent);
			strRtn.append(String.format("<a class=\"IllustItemText\" id=\"IllustItemText_%d\" href=\"%s?ID=%d&TD=%d\">", cContent.m_nContentId, ILLUST_DETAIL, cContent.m_nUserId, cContent.m_nContentId));
			strRtn.append(String.format("<span class=\"%s\">%s</span>", className, Util.replaceForGenEiFont(cContent.novelHtml)));
			strRtn.append("</a>");
		} else {
			strRtn.append(String.format("<a class=\"IllustItemText\" id=\"IllustItemText_%d\" href=\"%s\">", cContent.m_nContentId, ILLUST_VIEW));
			strRtn.append(String.format("<span class=\"%s\">%s</span>", className, Util.replaceForGenEiFont(cContent.novelHtmlShort)));
			strRtn.append("</a>");
		}
	}

	public static void appendResEmoji(
			StringBuilder sb,
			final int contentUserId,
			final String comments,
			final int lastCommentId,
			final int loginUserId
	) {
		final String resEmojiFormat;
		if (contentUserId != loginUserId) {
			resEmojiFormat = "<span class=\"ResEmoji\">%s</span>";
		} else {
			resEmojiFormat = "<a class=\"ResEmoji\" href=\"javascript:void(0)\" onclick=\"replyEmoji(this)\">%s</a>";
		}
		for (int i = 0; i < comments.length(); i = comments.offsetByCodePoints(i, 1)) {
			sb.append(
					String.format(
							resEmojiFormat,
							CEmoji.parse(String.valueOf(Character.toChars(comments.codePointAt(i))))
					)
			);
		}
		// lastCommentId
		sb.append("""
                <data class="LastCommentId" value="%d"></data>
				""".formatted(lastCommentId));
	}

	private static void appendIllustItemResList(
			StringBuilder strRtn, final CContent cContent, int nLoginUserId,
			final ArrayList<String> vEmoji, int nSpMode,
			final ResourceBundleControl _TEX){

		final boolean isOwnerAndHidden = cContent.m_nUserId==nLoginUserId && !cContent.nowAvailable();
		strRtn.append(
			String.format(
				"<div id=\"IllustItemResList_%d\" class=\"IllustItemResList\" %s>",
				cContent.m_nContentId,
				isOwnerAndHidden && cContent.m_strCommentsListsCache.length()>0 ? "style=\"display:block;\"" : ""
			)
		);
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
		appendResEmoji(strRtn, cContent.m_nUserId,
				cContent.m_strCommentsListsCache, cContent.m_nCommentsListsCacheLastId, nLoginUserId);

		// 絵文字追加マーク
		strRtn.append(
			String.format(
				"<span id=\"ResEmojiAdd_%d\" class=\"ResEmojiAdd\" %s><span class=\"fas fa-plus-square\"></span></span>",
				cContent.m_nContentId,
				isOwnerAndHidden ? "style=\"display:none;\"" : ""
			)
		);

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

		// リプライボタン
		strRtn.append("""
        <a class="ReplyBtn fas fa-reply" onclick="switchEmojiReply(%d, %d, %d)"></a>
        """.formatted(cContent.m_nContentId, nLoginUserId, nLoginUserId==cContent.m_nUserId ? 1 : 2));

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
			for(String emoji : vEmoji) {
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
			for(String emoji : vEmoji) {
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
		strRtn.append("</div>");	// IllustItemResBtnList

		// リプライ
		if (nLoginUserId == cContent.m_nUserId) {
			strRtn.append("""
					<div class="IllustItemReplyInfo">
						<a class="ReplyBtn fas fa-reply" onclick="switchEmojiReply(%d, null, 0)"></a>
						<div class="IllustItemReplyInfoTitle">
						%s
						<a class="ReplyInfoBtn" href="javascript:void(0)" onclick="dispReplyEmojiInfo();">
						<i class="fas fa-info-circle"></i>
						</a>
						</div>
					</div>
					""".formatted(cContent.m_nContentId, _TEX.T("IllustView.Reply.ForMyContent")));
		} else {
			strRtn.append("""
					<div class="IllustItemReplyList">
						<a class="ReplyBtn fas fa-reply" onclick="switchEmojiReply(%d, null, 0)"></a>
						<div class="IllustItemReplyListTitle">
						%s
						<a class="ReplyInfoBtn" href="javascript:void(0)" onclick="dispReplyEmojiInfo();">
						<i class="fas fa-info-circle"></i>
						</a>
						</div>
						<div id="ReplyEmojiList_%d" class="IllustItemResList"></div>
					</div>
					""".formatted(cContent.m_nContentId, _TEX.T("IllustView.Reply.FromCreator"), cContent.m_nContentId));
		}

		// こそフォロ促し
		strRtn.append(String.format("<div id=\"EncourageFollowUp_%d\" class=\"EncourageFollowUp\" style=\"display:none\">", cContent.m_nContentId));
		strRtn.append("<span>").append(_TEX.T("EncourageFollowUp")).append("</span>");
		strRtn.append(String.format("<span class=\"BtnBase UserInfoCmdFollow UserInfoCmdFollow_%d %s\" onclick=\"UpdateFollowUser(%d,%d)\">%s</span>",
				cContent.m_nUserId,
				(cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?"Selected":"",
				nLoginUserId,
				cContent.m_nUserId,
				(cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?_TEX.T("IllustV.Following"):_TEX.T("IllustV.Follow")));
		strRtn.append("</div>");
	}

	public static String Content2Html(
			final CContent cContent,  CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode) throws UnsupportedEncodingException {
		return _Content2Html(cContent, checkLogin, nMode, _TEX, vEmoji, nViewMode, nSpMode, PageCategory.DEFAULT);
	}

	public static String Content2Html(
			final CContent cContent, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode, PageCategory pageCategory) throws UnsupportedEncodingException {
		return _Content2Html(cContent, checkLogin, nMode, _TEX, vEmoji, nViewMode, nSpMode, pageCategory);
	}

	private static String _Content2Html(
			final CContent cContent, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode, PageCategory pageCategory) {

		final int nLoginUserId = checkLogin.m_nUserId;
		if (cContent.m_nContentId <= 0) return "";

		final String ILLUST_LIST = getIllustListContext(nSpMode, cContent.m_nUserId);
		final String REPORT_FORM = getReportFormContext(nMode);
		final String ILLUST_DETAIL = getIllustFromContext(nMode, nSpMode);
		final String SEARCH_CATEGORY = getSearchCategoryContext(nMode, nSpMode);
		final String ILLUST_VIEW = getIllustViewContext(nMode, nSpMode, cContent);

		final String strThumbCssClass = getThumbClass(cContent);

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<div class=\"IllustItem %s\" id=\"IllustItem_%d\">", strThumbCssClass, cContent.m_nContentId));

		// ユーザ名とフォローボタン
		appendIllustItemUser(strRtn, cContent, nLoginUserId, _TEX, ILLUST_LIST, true, false);

		// カテゴリーとコマンド
		strRtn.append("<div class=\"IllustItemCommand\">");
		appendIllustItemCategory(strRtn, cContent, SEARCH_CATEGORY, _TEX, nLoginUserId);
		appendIllustItemCommandSub(strRtn, cContent, nLoginUserId, nMode, nSpMode, REPORT_FORM, _TEX, pageCategory);
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		appendIllustItemDesc(strRtn, cContent, nMode);

		// タグ
		appendTag(strRtn, checkLogin, cContent, nMode, nSpMode);

		// 編集
		if(cContent.m_nUserId==nLoginUserId) {
			appendIllustItemDescEdit(strRtn, cContent, nMode);
		}

		// 画像
		appendContentItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);

		// 2枚目以降用の場所
		strRtn.append("<div class=\"IllustItemThubExpand\"></div>");

		// 全て表示ボタン
		appendIllustItemExpand(strRtn, cContent, _TEX, nSpMode);

		// サムネイルへの重畳表示
		appendOverlayToThumbnail(strRtn, cContent, _TEX, nViewMode);

		// 絵文字
		if(cContent.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			appendIllustItemResList(strRtn, cContent, nLoginUserId, vEmoji, nSpMode, _TEX);
		}

		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}


	public static String SketchbookContent2Html(
			final CContent cContent, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode) throws UnsupportedEncodingException {
		return _SketchbookContent2Html(cContent, checkLogin, nMode, _TEX, vEmoji, nViewMode, nSpMode, PageCategory.DEFAULT);
	}

	public static String SketchbookContent2Html(
			final CContent cContent, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode, PageCategory pageCategory) throws UnsupportedEncodingException {
		return _SketchbookContent2Html(cContent, checkLogin, nMode, _TEX, vEmoji, nViewMode, nSpMode, pageCategory);
	}

	private static String _SketchbookContent2Html(
			final CContent cContent, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode, PageCategory pageCategory) {

		if (cContent.m_nContentId <= 0) return "";

		final int nLoginUserId = checkLogin.m_nUserId;

		final String ILLUST_LIST = getIllustListContext(nSpMode, cContent.m_nUserId);
		final String REPORT_FORM = getReportFormContext(nMode);
		final String ILLUST_DETAIL = getIllustFromContext(nMode, nSpMode);
		final String SEARCH_CATEGORY = getSearchCategoryContext(nMode, nSpMode);
		final String ILLUST_VIEW = getIllustViewContext(nMode, nSpMode, cContent);

		final String strThumbCssClass = getThumbClass(cContent);

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<div class=\"IllustItem %s\" id=\"IllustItem_%d\">", strThumbCssClass, cContent.m_nContentId));

		// ユーザ名とフォローボタン
		appendIllustItemUser(strRtn, cContent, nLoginUserId, _TEX, ILLUST_LIST, false, true);

		// カテゴリーとコマンド
		strRtn.append("<div class=\"IllustItemCommand\">");
		appendIllustItemCategory(strRtn, cContent, SEARCH_CATEGORY, _TEX, nLoginUserId);
		appendIllustItemCommandSub(strRtn, cContent, nLoginUserId, nMode, nSpMode, REPORT_FORM, _TEX, pageCategory);
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		appendIllustItemDesc(strRtn, cContent, nMode);

		// タグ
		appendTag(strRtn, checkLogin, cContent, nMode, nSpMode);

		// 画像
		appendContentItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);

		// 2枚目以降用の場所
		strRtn.append("<div class=\"IllustItemThubExpand\"></div>");

		// 全て表示ボタン
		appendIllustItemExpand(strRtn, cContent, _TEX, nSpMode);

		// サムネイルへの重畳表示
		appendOverlayToThumbnail(strRtn, cContent, _TEX, nViewMode);

		// 絵文字
		if(cContent.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			appendIllustItemResList(strRtn, cContent, nLoginUserId, vEmoji, nSpMode, _TEX);
		}

		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}


	private static void appendOverlayToThumbnail(StringBuilder strRtn, CContent cContent, ResourceBundleControl _TEX, int nViewMode) {
		String strSizeAppendix = "";
		if (cContent.m_nFileWidth > 0 && cContent.m_nFileHeight > 0) {
			strSizeAppendix = "(" + String.format(_TEX.T("UploadFileTweet.OriginalSize"), cContent.m_nFileWidth, cContent.m_nFileHeight) + ")";
		}
		strRtn.append(String.format("<div class=\"IllustItemTProhibit\"><span class=\"TapToFull\">%s</span>%s</div>",
				(nViewMode == VIEW_DETAIL) ? String.format(_TEX.T("IllustView.ProhibitMsg.TapToFull"), strSizeAppendix) : strSizeAppendix,
				_TEX.T("IllustView.ProhibitMsg")));
	}

	private static void appendIllustItemExpand( StringBuilder strRtn, CContent cContent, ResourceBundleControl _TEX, int nSpMode) {
		strRtn.append("<div class=\"IllustItemExpand\">");
		if(cContent.m_nFileNum>1) {
			appendIllustItemExpandPassFrame(_TEX, strRtn);

			final String mark;
			if (cContent.publishAllNum > 0) {
				mark = String.format("<span class=\"Publish PublishIcoBlue%02d\"></span>", cContent.m_nPublishId);
			} else {
				mark = "<i class=\"far fa-clone\"></i>";
			}

			strRtn.append(String.format("<a class=\"BtnBase IllustItemExpandBtn\" href=\"javascript:void(0)\" onclick=\"ShowAppendFile(%d, %d, %d, this);\">%s %s</a>",
				cContent.m_nUserId,
				cContent.m_nContentId,
					nSpMode,
				mark,
				String.format(_TEX.T("IllustView.ExpandBtn"), cContent.m_nFileNum-1)));
		} else if (cContent.m_nEditorId==Common.EDITOR_TEXT && (cContent.novelDirection==0 || cContent.m_nPublishId != Common.PUBLISH_ID_ALL)) {
			appendIllustItemExpandPassFrame(_TEX, strRtn);
			strRtn.append(String.format("<a class=\"BtnBase IllustItemExpandBtn\" href=\"javascript:void(0)\" onclick=\"ShowAppendFile(%d, %d, %d, this);\">%s</a>",
				cContent.m_nUserId,
				cContent.m_nContentId,
					nSpMode,
				String.format(_TEX.T("IllustView.ExpandBtnText"), cContent.m_strTextBody.length())));
		}
		strRtn.append("</div>");	// IllustItemExpand
	}

	private static void appendIllustItemDescEdit(StringBuilder strRtn, CContent cContent, int nMode) {
		strRtn.append(String.format("<div id=\"IllustItemDescEdit_%d\" class=\"IllustItemDescEdit\">", cContent.m_nContentId));
		strRtn.append(String.format("<textarea class=\"IllustItemDescEditTxt\" maxlength=\"200\">%s</textarea>", Util.toStringHtmlTextarea(cContent.m_strDescription)));
		strRtn.append(String.format("<input class=\"IllustItemTagEditTxt\" type=\"text\" maxlength=\"100\" value=\"%s\" />", Util.toDescString(cContent.m_strTagList)));
		strRtn.append("<div class=\"IllustItemDescEditCmdList\">");
		strRtn.append(String.format("<a class=\"BtnBase IllustItemDescEditCmd\" onclick=\"UpdateDesc(%d, %d, %d)\">OK</a>", cContent.m_nUserId, cContent.m_nContentId, nMode));
		strRtn.append("</div>");    // IllustItemDescEditCmdList
		strRtn.append("</div>");    // IllustItemDescEdit
	}

	private static void appendIllustItemUser(StringBuilder strRtn, CContent cContent, int nLoginUserId, ResourceBundleControl _TEX, String ILLUST_LIST, boolean showFollowLabel, boolean showGiftBtn) {
		strRtn.append("<div class=\"IllustItemUser\">");
		strRtn.append(String.format("<a class=\"IllustItemUserThumb\" href=\"%s\" style=\"background-image:url('%s_120.jpg')\"></a>", ILLUST_LIST, Common.GetUrl(cContent.m_cUser.m_strFileName)));
		strRtn.append(String.format("<h2 class=\"IllustItemUserName\"><a href=\"%s\">%s</a></h2>", ILLUST_LIST, Util.toStringHtml(cContent.m_cUser.m_strNickName)));

		final boolean following = cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING;
		String followLabel = following ? _TEX.T("IllustV.Following"): _TEX.T("IllustV.Follow");
		if (!showFollowLabel) {
			followLabel = followLabel.substring(0, 1);
		}

		if (showGiftBtn) {
			strRtn.append(String.format("<span class=\"UserInfoCmdGift\" onclick=\"SendGift(%d, '%s')\"><i class=\"fas fa-gift\"></i></span>",
					cContent.m_nUserId, cContent.m_cUser.m_strNickName));
		}
		if(cContent.m_cUser.m_nFollowing != CUser.FOLLOW_HIDE) {
			strRtn.append(String.format("<span class=\"BtnBase UserInfoCmdFollow UserInfoCmdFollow_%d %s %s\"  onclick=\"UpdateFollowUser%s(%d, %d)\">%s</span>",
					cContent.m_nUserId,
					(cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?"Selected":"",
					showFollowLabel ? "" : "NoLabel",
					showFollowLabel ? "" : "NoLabel",
					nLoginUserId,
					cContent.m_nUserId,
					followLabel));
		}
		strRtn.append("</div>");	// IllustItemUser
	}

	private static void appendIllustItemExpandPassFrame(ResourceBundleControl _TEX, StringBuilder strRtn) {
		strRtn.append(String.format("<div class=\"IllustItemExpandPassFrame\">" +
						"<input class=\"IllustItemExpandPass\" name=\"PAS\" type=\"text\" maxlength=\"16\" placeholder=\"%s\" />" +
						"<a class=\"IllustItemExpandPassVisible Display\" style=\"display:none\" href=\"javascript:void(0)\" onclick=\"visibleContentPassword(this)\">%s</a>" +
						"<a class=\"IllustItemExpandPassVisible Hide\" href=\"javascript:void(0)\" onclick=\"hideContentPassword(this)\">%s</a>" +
						"</div>",
				_TEX.T("ShowAppendFileC.EnterPassword"),
				_TEX.T("ShowAppendFileC.EnterPassword.Show"),
				_TEX.T("ShowAppendFileC.EnterPassword.Hide")
				));
	}

	public static String MyContent2Html(final CContent cContent, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX, final ArrayList<String> vResult, int nViewMode, int nSpMode) throws UnsupportedEncodingException {
		if(cContent.m_nContentId<=0) return "";

		final int nLoginUserId = checkLogin.m_nUserId;
		final String REPORT_FORM = getReportFormContext(nMode);
		final String SEARCH_CATEGORY = getSearchCategoryContext(nMode, nSpMode);
		final String ILLUST_VIEW = getIllustViewContext(nMode, nSpMode, cContent);

		String strThumbClass = getThumbClass(cContent);

		StringBuilder strRtn = new StringBuilder();
		strRtn.append(String.format("<div class=\"IllustItem %s\" id=\"IllustItem_%d\">", strThumbClass, cContent.m_nContentId));

		// カテゴリーとコマンド
		strRtn.append("<div class=\"IllustItemCommand\">");

		appendIllustItemCategory(strRtn, cContent, SEARCH_CATEGORY, _TEX, nLoginUserId);

		// コマンド
		appendIllustItemCommandSub(strRtn, cContent, nLoginUserId, nMode, nSpMode, REPORT_FORM, _TEX, PageCategory.MY_BOX);
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		appendIllustItemDesc(strRtn, cContent, nMode);

		// タグ
		appendTag(strRtn, checkLogin, cContent, nMode, nSpMode);

		// 編集
		if(cContent.m_nUserId==nLoginUserId) {
			// キャプション
			appendIllustItemDescEdit(strRtn, cContent, nMode);
		}

		// 画像
		appendMyIllustItemThumb(strRtn, cContent, nViewMode, ILLUST_VIEW);

		// 2枚目以降用の場所
		strRtn.append("<div class=\"IllustItemThubExpand\"></div>");

		// 2枚目以降ボタン
		strRtn.append("<div class=\"IllustItemExpand\">");
		if(cContent.m_nFileNum>1) {
			strRtn.append(String.format("<div class=\"IllustItemExpandPassFrame\"><input class=\"IllustItemExpandPass\" name=\"PAS\" type=\"text\" maxlength=\"16\" placeholder=\"%s\" /></div>",
					_TEX.T("ShowAppendFileC.EnterPassword")));
			strRtn.append(String.format("<a class=\"BtnBase IllustItemExpandBtn\" href=\"javascript:void(0)\" onclick=\"ShowAppendFile(%d, %d, %d, this);\"><i class=\"far fa-clone\"></i> %s</a>",
					cContent.m_nUserId,
					cContent.m_nContentId,
					nSpMode,
					String.format(_TEX.T("IllustView.ExpandBtn"), cContent.m_nFileNum-1)));
		}
		strRtn.append("</div>");	// IllustItemExpand

		// 転載禁止表示
		appendOverlayToThumbnail(strRtn, cContent, _TEX, nViewMode);

		// 絵文字
		if(cContent.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			appendIllustItemResList(strRtn, cContent, nLoginUserId, vResult, nSpMode, _TEX);
		}

		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}


	private static String _toThumbHtml(final CContent cContent, final CheckLogin checkLogin, int nMode, int nSpMode, final ResourceBundleControl _TEX, PageCategory pageCategory) {
		final String ILLUST_LIST = getIllustListContext(nSpMode, cContent.m_nUserId);
		final String SEARCH_CATEGORY = getSearchCategoryContext(nMode, nSpMode);
		final String ILLUST_VIEW = getIllustViewContext(nMode, nSpMode, cContent);

		StringBuilder strRtn = new StringBuilder();

		strRtn.append("<div class=\"IllustThumb");
		if (cContent.pinOrder > 0) {
			strRtn.append(" Pined");
		}
		if (pageCategory == PageCategory.MY_BOX) {
			strRtn.append((nMode==MODE_SP ? " IllustThumbMyBoxSp" : " IllustThumbMyBoxPc"));
			if (checkLogin.m_nPassportId==Common.PASSPORT_ON) {
				strRtn.append((nMode==MODE_SP ? " ShowTimestampSp" : " ShowTimestampPc"));
			}
		}
		strRtn.append("\">");

		if (pageCategory != PageCategory.MY_BOX) {
			// ユーザ情報
			strRtn.append(String.format("<a class=\"IllustUser\" href=\"%s\">", ILLUST_LIST));
			// 画像
			strRtn.append(String.format("<span class=\"IllustUserThumb\" style=\"background-image:url('%s_120.jpg')\"></span>", Common.GetUrl(cContent.m_cUser.m_strFileName)));
			// 名前
			strRtn.append(String.format("<h2 class=\"IllustUserName\">%s</h2>", Util.toStringHtml(cContent.m_cUser.m_strNickName)));
			// Pin
			if (cContent.pinOrder > 0) {
				strRtn.append("<span class=\"IllustUserPin fas fa-thumbtack\"></span>");
			}
			strRtn.append("</a>");    // IllustItemUser
		}

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

		// Pin, Note
		if (pageCategory == PageCategory.MY_BOX && cContent.pinOrder > 0) {
			strRtn.append("<span class=\"IllustInfoPin fas fa-thumbtack\"></span>");
		} else if (cContent.m_nUserId==checkLogin.m_nUserId && !cContent.privateNote.isEmpty()) {
			strRtn.append("<span class=\"IllustInfoPin far fa-sticky-note\" onclick=\"TogglePrivateNote($(this).parent().parent(),'" +
					Util.toQuotedString(cContent.privateNote, "'") +
					"')\"></span>");
		}

		strRtn.append("</span>");	// カテゴリ系情報(IllustInfo)

		// イラスト情報
		strRtn.append(String.format("<a class=\"IllustInfo\" href=\"%s\">", ILLUST_VIEW));
		// キャプション
		final String description =
				(cContent.m_strDescriptionTranslated!=null&&!cContent.m_strDescriptionTranslated.isEmpty())
				? cContent.m_strDescriptionTranslated : cContent.m_strDescription;

		strRtn.append(String.format(
				"<span class=\"IllustInfoDesc\">%s</span>",
				Util.toStringHtml(description)
				)
		);
		// サムネイル
		final String strFileUrl;
		final boolean bHidden;	// テキストモード用カバー画像表示フラグ
		if (pageCategory == PageCategory.MY_BOX && cContent.m_nUserId == checkLogin.m_nUserId) {
			strFileUrl = Common.GetUrl(cContent.m_strFileName);
			bHidden = false;
		} else {
			cContent.setThumb();
			strFileUrl = cContent.thumbImgUrl;
			bHidden = cContent.isHideThumbImg;
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
		} else {
			// テキスト
			appendIllustThumbText(strRtn, cContent, ILLUST_VIEW);
		}

		// 公開非公開マーク
		if(pageCategory == PageCategory.MY_BOX
				&& checkLogin.m_nUserId==cContent.m_nUserId
				&& (!cContent.nowAvailable() || cContent.m_bLimitedTimePublish)){
			strRtn.append("<span class=\"IllustInfoCenter\"" +
							(cContent.novelDirection==1 ? "style=\"top:0px;left:0px\"" : "") +
					">");

			if (cContent.m_bLimitedTimePublish) {
				strRtn.append("<span class=\"Publish PublishLimited" + (cContent.nowAvailable()?"":"Not") + "Published\"></span>");
			} else {
				strRtn.append("<span class=\"Publish Private\"></span>");
			}

			strRtn.append("</span>"); // IllustInfoCenter
		}

		// 公開種別マーク
		strRtn.append("<span class=\"IllustInfoBottom\">");
		if(cContent.publishAllNum == 1
				|| pageCategory == PageCategory.MY_BOX && checkLogin.m_nUserId==cContent.m_nUserId){

			// TODO publish_idの運用方針変更。R18+フォロワー限定のような、複数掛け対応。
			if(cContent.isValidPublishId() && cContent.m_nPublishId != Common.PUBLISH_ID_ALL) {
				strRtn.append(String.format("<span class=\"Publish PublishIco%02d\"></span>", cContent.m_nPublishId));
			}
		}

		// 枚数マーク
		if(cContent.m_nFileNum>1){
			strRtn.append("<span class=\"Num\">").append(getContentsFileNumHtml(cContent)).append("</span>");
		} else if(cContent.m_nEditorId==Common.EDITOR_TEXT) {
			strRtn.append(String.format("<span class=\"Num\">%d %s</span>", cContent.m_strTextBody.length(), _TEX.T("Common.Unit.Text")));
		}
		strRtn.append("</span>");	// IllustInfoBottom
		strRtn.append("</a>");	// IllustThumbImg | IllustThumbText
		if (pageCategory == PageCategory.MY_BOX && checkLogin.m_nPassportId==Common.PASSPORT_ON) {
			final SimpleDateFormat dateFormat = new SimpleDateFormat(DATE_FORMAT_SHORT);

			// created_at
			final String createdAt = cContent.createdAt == null ? "----.--.--" : dateFormat.format(cContent.createdAt);
			strRtn.append(String.format("<div class=\"IllustUser DateTime\"><i class=\"far fa-calendar\"></i> %s</div>",createdAt));
			// updated_at
			final String updatedAt = cContent.updatedAt == null ? "----.--.--" : dateFormat.format(cContent.updatedAt);
			strRtn.append(String.format("<div class=\"IllustUser DateTime\" style=\"border-bottom:none\"><i class=\"fas fa-pen\"></i> %s</div>",updatedAt));
		}
		strRtn.append("</div>");	// IllustThumb
		return strRtn.toString();
	}

	public static String toMyBoxThumbHtml(final CContent cContent, final CheckLogin checkLogin, int nMode, int nSpMode, final ResourceBundleControl _TEX) {
		return _toThumbHtml(cContent, checkLogin, nMode, nSpMode, _TEX, PageCategory.MY_BOX);
	}

	public static String toThumbHtml(final CContent cContent, final CheckLogin checkLogin, int nMode, int nSpMode, final ResourceBundleControl _TEX) {
		return _toThumbHtml(cContent, checkLogin, nMode, nSpMode, _TEX, PageCategory.DEFAULT);
	}

	private static void appendIllustThumbText(StringBuilder sb, CContent cContent, String ILLUST_VIEW) {
		String className = "IllustThumbText";
		if(cContent.novelDirection==1) {
			className += " Vertical";
		}
		sb.append(String.format("<a class=\"%s\" href=\"%s\" ", className, ILLUST_VIEW));
		if(!(cContent.nowAvailable())){
			sb.append("style=\"background: rgba(0,0,0,.5);\"");
		}
		sb.append(">").append(Util.replaceForGenEiFont(cContent.novelHtmlShort));
	}

//	private static String _toHtmlUser(CUser cUser, int nMode,  ResourceBundleControl _TEX, int nSpMode){
//		String ILLUST_LIST = getIllustListContext(nSpMode, cUser.m_nUserId);
//		StringBuilder strRtn = new StringBuilder();
//		strRtn.append(String.format("<a class=\"UserThumb\" href=\"%s\">", ILLUST_LIST));
//		strRtn.append(String.format("<span class=\"UserThumbImg\" style=\"background-image:url('%s_120.jpg')\"></span>", Common.GetUrl(cUser.m_strFileName)));
//		strRtn.append(String.format("<span class=\"UserThumbName\">%s</span>", Util.toStringHtml(cUser.m_strNickName)));
//		strRtn.append("</a>");
//
//		return strRtn.toString();
//	}

	private static String _toHtmlUser(CUser cUser, int nMode,  ResourceBundleControl _TEX, int nSpMode){
		String ILLUST_LIST = getIllustListContext(nSpMode, cUser.m_nUserId);
		String headerFileName = "";
		if(!cUser.m_strHeaderFileName.isEmpty()) {
			headerFileName = String.format("background-image: url('%s');", Common.GetUrl(cUser.m_strHeaderFileName) + "_360.jpg");
		}
		return String.format(
			"<a class=\"UserInfo Thumb\" href=\"%s\" style=\"%s\">" +
					"<span class=\"UserInfoBg\"></span>" +
					"<section class=\"UserInfoUser\">" +
					"<span class=\"UserInfoUserThumb\" style=\"background-image:url('%s_120.jpg')\"></span>" +
					"<span class=\"UserInfoUserName\">%s</span>" +
					"<span class=\"UserInfoProfile\">%s</span>" +
					"</section></a>",
				ILLUST_LIST,
				headerFileName,
				Common.GetUrl(cUser.m_strFileName),
				Util.toStringHtml(cUser.m_strNickName),
				Util.toStringHtml(cUser.m_strProfile)
		);
	}

	public static String toHtmlUser(CUser cUser, int nMode,  ResourceBundleControl _TEX) {
		return  _toHtmlUser(cUser, nMode, _TEX, SP_MODE_WVIEW);
	}

	public static String toHtmlUser(CUser cUser, int nMode,  ResourceBundleControl _TEX, int nSpMode) {
		return  _toHtmlUser(cUser, nMode, _TEX, nSpMode);
	}
	public static String toHtmlUserMini(CUser cUser, int nMode,  ResourceBundleControl _TEX, int nSpMode) {
		String ILLUST_LIST = getIllustListContext(nSpMode, cUser.m_nUserId);
		String headerFileName = "";
		if(!cUser.m_strHeaderFileName.isEmpty()) {
			headerFileName = String.format("background-image: url('%s');", Common.GetUrl(cUser.m_strHeaderFileName) + "_360.jpg");
		}
		return String.format(
				"<a class=\"UserInfo ThumbSmall\" href=\"%s\" style=\"%s\">" +
						"<span class=\"UserInfoBg \"></span>" +
						"<section class=\"UserInfoUser \">" +
						"<span class=\"UserInfoUserThumb \" style=\"background-image:url('%s_120.jpg')\"></span>" +
						"<span class=\"UserInfoUserName \">%s</span>" +
						"<span class=\"UserInfoProfile \">%s</span>" +
						"</section></a>",
				ILLUST_LIST,
				headerFileName,
				Common.GetUrl(cUser.m_strFileName),
				Util.toStringHtml(cUser.m_strNickName),
				Util.toStringHtml(cUser.m_strProfile)
		);
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
