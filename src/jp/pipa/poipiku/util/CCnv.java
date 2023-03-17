package jp.pipa.poipiku.util;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.controller.ReactionListC;

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

	private static final String ILLUST_ITEM_THUMB_IMG = "<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />";
	private static final String ILLUST_ITEM_THUMB_IMG_FMT = "<img class=\"IllustItemThumbImg\" src=\"%s\" />";

	private static final String DATE_FORMAT_SHORT = "yyyy.MM.dd HH:mm";

	private static String getIllustListContext(int nUserId){
		return String.format("/%d/", nUserId);
	}

	private static String getReportFormContext(int nMode){
		return "/ReportFormV.jsp";
	}

	private static String getIllustFromContext(){
		return "/IllustDetailV.jsp";
	}

	private static String getSearchCategoryContext(){
		return "/NewArrivalV.jsp";
	}
	private static String getIllustViewContext(CContent content){
		return "/%d/%d.html".formatted(content.m_nUserId, content.m_nContentId);
	}
	private static String getThumbClass(CContent content){
		String strThumbClass = "";
		// Open class
		if(content.m_nOpenId==2) strThumbClass += " Hidden";

		if(content.m_nSafeFilter==Common.SAFE_FILTER_R15) strThumbClass += " R15";
		if(content.m_nSafeFilter==Common.SAFE_FILTER_R18) strThumbClass += " R18";
		if(content.m_nSafeFilter==Common.SAFE_FILTER_R18G) strThumbClass += " R18G";
		if(content.m_nSafeFilter==Common.SAFE_FILTER_R18_PLUS) strThumbClass += " R18Plus";

		if(content.m_nPublishId==Common.PUBLISH_ID_PASS) strThumbClass += " Password";
		if(content.m_nPublishId==Common.PUBLISH_ID_LOGIN) strThumbClass += " Login";
		if(content.m_nPublishId==Common.PUBLISH_ID_FOLLOWER) strThumbClass += " Follower";
		if(content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER) strThumbClass += " TFollower";
		if(content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE) strThumbClass += " TFollow";
		if(content.m_nPublishId==Common.PUBLISH_ID_T_EACH) strThumbClass += " TEach";
		if(content.m_nPublishId==Common.PUBLISH_ID_T_LIST) strThumbClass += " TList";
		if(content.m_nPublishId==Common.PUBLISH_ID_T_RT) strThumbClass += " TRT";

		// Editor Class
		if(content.m_nEditorId==Common.EDITOR_UPLOAD) strThumbClass += " Upload";
		if(content.m_nEditorId==Common.EDITOR_PASTE) strThumbClass += " Past";
		if(content.m_nEditorId==Common.EDITOR_BASIC_PAINT) strThumbClass += " BasicPaint";
		if(content.m_nEditorId==Common.EDITOR_TEXT) strThumbClass += " Text";
		return strThumbClass;
	}
	private static String getContentsFileNumHtml(CContent content){
		return (content.m_nFileNum>1)?String.format("<i class=\"far fa-images\"></i> %d", content.m_nFileNum):"";
	}
	private static void appendIllustItemCategory(StringBuilder strRtn, final CContent content, final String SEARCH_CATEGORY, final ResourceBundleControl _TEX, final int loginUserId){
		strRtn.append(String.format("<div id=\"IllustItemCategory_%d\" class=\"IllustItemCategory\">", content.m_nContentId));
		strRtn.append(String.format("<a class=\"Category C%d\" href=\"%s?CD=%s\">%s</a>",
				content.m_nCategoryId, SEARCH_CATEGORY, content.m_nCategoryId,
				_TEX.T(String.format("Category.C%d", content.m_nCategoryId))));
		strRtn.append("</div>");
		if (content.m_nRequestId>0) {
			strRtn.append("<div class=\"IllustItemCategory\">");
			strRtn.append(String.format("<a class=\"Request\" href=\"javascript:void(0)\" onclick=\"dispRequestDlg(%d)\">%s</a>",
					content.m_nRequestId, _TEX.T("Request")
			));
			strRtn.append("</div>");
		}
	}

	private static void appendIllustItemCommandSub(StringBuilder strRtn, CContent content, int nLoginUserId, int nMode, int nSpMode, String REPORT_FORM, ResourceBundleControl _TEX, PageCategory pageCategory){
		strRtn.append("<div class=\"IllustItemCommandSub\">");
		if(content.m_nUserId==nLoginUserId
				&& (pageCategory == PageCategory.MY_ILLUST_LIST || pageCategory == PageCategory.MY_BOX)) {

			// シェアボタン
			strRtn.append("<div class=\"IllustItemCmd\" style=\"float:none;display:inline-block;margin-right:14px\">");
			strRtn.append(String.format("<a class=\"NonFrameBtnBase IllustItemShareButton\" style=\"float:none;margin-bottom:-2px\" href=\"javascript:void(0)\" onclick=\"shareContent(%d, %d, %b);\"></a>",
					content.m_nUserId,
					content.m_nContentId,
					nMode == MODE_SP
			));
			strRtn.append("</div>");    // IllustItemCmd

			// Unrealizm内でのピン留め
			strRtn.append("<div class=\"IllustItemCmd\" style=\"float:none;display:inline-block;margin-right:14px\">");
			strRtn.append(String.format("<a id=\"IllustItemPinBtn_%d\" class=\"NonFrameBtnBase IllustItemPinButton fas fa-thumbtack %s\" style=\"float:none;margin-bottom:-2px\" href=\"javascript:void(0)\" onclick=\"UpdatePin(%d, %d);\"></a>",
					content.m_nContentId,
					content.pinOrder>0?"Selected":"",
					content.m_nUserId,
					content.m_nContentId
			));
			strRtn.append("</div>");    // IllustItemCmd


			if(nSpMode == SP_MODE_APP) {
				if(content.m_nEditorId != Common.EDITOR_TEXT) {
					strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"myurlscheme://reEdit?ID=%d&TD=%d\"></a>", content.m_nUserId, content.m_nContentId));
				}
			} else {
				final String updateJsp;
				if(content.m_nEditorId == Common.EDITOR_PASTE) {
					updateJsp = "UpdatePastePcV2";
				} else if(content.m_nEditorId == Common.EDITOR_TEXT) {
					updateJsp = "UpdateTextPcV2";
				} else {
					updateJsp = "UpdateFilePcV2";
				}
				strRtn.append(String.format("<a class=\"IllustItemCommandEdit far fa-edit\" href=\"/%s.jsp?ID=%d&TD=%d\"></a>",
						updateJsp, content.m_nUserId, content.m_nContentId));

			}
			strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d, %d, %b)\"></a>", nLoginUserId, content.m_nContentId, !content.m_strTweetId.isEmpty()));
		} else {
			// ブクマボタン
			strRtn.append("<div class=\"IllustItemCmd\">");
			strRtn.append(String.format("<a id=\"IllustItemBookmarkBtn_%d\" class=\"NonFrameBtnBase IllustItemBookmarkBtn\" href=\"javascript:void(0)\" onclick=\"UpdateBookmark(%d, %d);\"><i class=\"%s fa-bookmark\"></i></a>",
					content.m_nContentId,
					nLoginUserId,
					content.m_nContentId,
					(content.m_nBookmarkState==CContent.BOOKMARK_BOOKMARKING)?"fas":"far"
					));
			strRtn.append("</div>");	// IllustItemCmd

			// シェアボタン
			strRtn.append("<div class=\"IllustItemCmd\">");
			strRtn.append(String.format("<a class=\"NonFrameBtnBase IllustItemShareButton\" href=\"javascript:void(0)\" onclick=\"shareContent(%d, %d, %b);\"></a>",
					content.m_nUserId,
					content.m_nContentId,
					nMode == MODE_SP
					));
			strRtn.append("</div>");    // IllustItemCmd

			// 通報ボタン
			strRtn.append(String.format("<a class=\"IllustItemCommandInfo fas fa-info-circle\" href=\"%s?ID=%d&TD=%d\"></a>", REPORT_FORM, content.m_nUserId, content.m_nContentId));
			if(nLoginUserId==1) {
				strRtn.append(String.format("<a class=\"IllustItemCommandDelete far fa-trash-alt\" href=\"javascript:void(0)\" onclick=\"DeleteContent(%d, %d, %b)\"></a>", nLoginUserId, content.m_nContentId, content.m_nUserId==1?true:false));
			}
		}
		strRtn.append("</div>");	// IllustItemCommandSub

	}
	private static void appendIllustItemDesc(StringBuilder strRtn, CContent content, int nMode){
		final String def = content.m_strDescription;
		final String trs = content.m_strDescriptionTranslated;
		final boolean trsExist = trs!=null && !trs.isEmpty();
		final String descShowFirst = trsExist ? trs : def;

		String desc;

		final int firstDispLen = Common.EDITOR_DESC_MAX[0][0] + 300;
		int moreIndex = -1;
		if (descShowFirst.length() > firstDispLen) {
			moreIndex = descShowFirst.indexOf("\n", firstDispLen);
		}

		if (moreIndex < 0) {
			desc = Common.AutoLink(Util.toStringHtml(descShowFirst), content.m_nUserId, nMode);
		} else {
			desc = Common.AutoLink(Util.toStringHtml(descShowFirst.substring(0, moreIndex)), content.m_nUserId, nMode);
			desc += "<a class=\"IllustItemDescMoreLink\" onclick=\"readMoreDescription(this);\">...more</a>";
			desc += String.format(
					"<span class=\"IllustItemDescMore\" style=\"display:none;\">%s</span>",
					Common.AutoLink(Util.toStringHtml(descShowFirst.substring(moreIndex)), content.m_nUserId, nMode)
			);
		}
		if (trsExist) {
			strRtn.append("<div class=\"fas fa-language IllustItemDescTranslation\" onclick=\"toggleIllustItemDesc(this)\"></div>");
		}
		strRtn.append("<div id=\"IllustItemDesc_%d\" class=\"IllustItemDesc\" %s>".formatted(
				content.m_nContentId,
				(descShowFirst.isEmpty())?"style=\"display: none;\"":""
		));
		strRtn.append(desc);
		strRtn.append("</div>");

		if (trsExist) {
			strRtn.append("<div class=\"IllustItemDesc\" style=\"display: none;\">");
			strRtn.append(Common.AutoLink(Util.toStringHtml(def), content.m_nUserId, nMode));
			strRtn.append("</div>");
		}
	}

	private static void appendIllustItemPrompt(StringBuilder strRtn, CContent content, ResourceBundleControl _TEX){
		String prompt = content.aiPrompt;

		if (prompt.length() >= 50) {
			prompt = prompt.substring(0, 50);
			prompt += "...";
		}

		strRtn.append("<div id=\"IllustItemPrompt_%d\" class=\"IllustItemPrompt\" %s onclick=\"DispPromptDlg(%d)\">".formatted(
				content.m_nContentId,
				(prompt.isEmpty())?"style=\"display: none;\"":"",
				content.m_nContentId
		));
		strRtn.append("<i class=\"fas fa-terminal\"></i> " + prompt + " <span class=\"ShowMorePrompt\">" + _TEX.T("Common.IllustItemPrompt.MorePrompt") + "</span>");
		strRtn.append("</div>");
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

	private static void appendTag(StringBuilder strRtn, CheckLogin checkLogin, CContent content, int nMode, int nSpMode){
		if (content.m_strTagList.isEmpty()) {
			strRtn.append("""
					<h2 id="IllustItemTag_%d" style="display: none;"></h2>
					""".formatted(content.m_nContentId));
		} else {
			List<String> tagNameList = List.of(content.m_strTagList.split(" "));
			HashMap<String, String> translationMap = getTagNameTranslations(checkLogin, content, tagNameList);

			StringBuilder sb = new StringBuilder();
			String appOrPc = nSpMode==SP_MODE_APP?"App":"";
			String withoutHashMark;
			String href = "";
			boolean isMyTag;
			for (String tagName: tagNameList) {
				if (tagName.isEmpty()) continue;

				isMyTag = (tagName.indexOf("##") == 0);
				if (isMyTag) {
					href = "/IllustList%sV.jsp?ID=%d&KWD=%s".formatted(
							appOrPc,
							content.m_nUserId,
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
							content.m_nContentId,
							sb.toString()
//							Common.AutoLink(Util.toStringHtml(content.m_strTagList), content.m_nUserId, nMode, nSpMode)
					)
			);
		}
	}

	private static void appendMyIllustListItemThumb(StringBuilder strRtn, CContent content, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL) {
		String strFileUrl = Common.GetUrl(content.m_strFileName);
		strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s\">", ILLUST_VIEW));
		strRtn.append(String.format(ILLUST_ITEM_THUMB_IMG, strFileUrl));

		if(content.m_nOpenId==2){
			strRtn.append("<span class=\"IllustInfoPrivate\">");
		} else {
			strRtn.append("<span class=\"IllustInfoPublic\">");
		}
		if(content.m_nPublishId==99){
			strRtn.append("<span class=\"Publish Private\"></span>");
		} else if(content.m_bLimitedTimePublish){
			if(content.m_nOpenId==2){
				strRtn.append("<span class=\"Publish PublishLimitedNotPublished\"></span>");
			} else {
				strRtn.append("<span class=\"Publish PublishLimitedPublished\"></span>");
			}
		}
		strRtn.append("</span>");

		strRtn.append("<span class=\"IllustInfoBottom\">");
		if(content.m_nPublishId>=1 && content.m_nPublishId<=10) {
			strRtn.append(String.format("<span class=\"Publish PublishIco%02d\"></span>", content.m_nPublishId));
		}
		if(content.m_nFileNum>1){
			strRtn.append("<span class=\"Num\">").append(getContentsFileNumHtml(content)).append("</span>");
		}

		strRtn.append("</span>");	// IllustInfoBottom

		strRtn.append("</a>");
	}

	private static void appendContentItemThumb(StringBuilder strRtn, CContent content, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL){
		if (content.thumbImgUrl == null || content.thumbImgUrl.isEmpty()) {
			content.setThumb();
		}

		if (content.m_nEditorId != Common.EDITOR_TEXT) {
			appendIllustItemThumb2(strRtn, content, null, nViewMode, ILLUST_VIEW);
		} else {
			if (content.isHideThumbImg) {
				appendIllustItemThumb2(strRtn, content, null, nViewMode, ILLUST_VIEW);
			} else {
				appendTextItemThumb(strRtn, content, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);
			}
		}
	}

	private static void appendContentItemThumbMiniList(StringBuilder strRtn, CContent content){
		if (content.thumbImgUrl == null || content.thumbImgUrl.isEmpty()) {
			content.setThumb();
		}

		if (content.m_nEditorId != Common.EDITOR_TEXT) {
			appendIllustItemThumb2MiniList(strRtn, content);
		} else {
			if (content.isHideThumbImg) {
				appendIllustItemThumb2MiniList(strRtn, content);
			} else {
				appendTextItemThumbMiniList(strRtn, content);
			}
		}
	}

	private static void appendMyIllustItemThumb(StringBuilder strRtn, CContent content, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL){
		content.setMyImgThumb();
		if (content.m_nEditorId != Common.EDITOR_TEXT) {
			appendIllustItemThumb2(strRtn, content, null, nViewMode, ILLUST_VIEW);
		} else {
			appendTextItemThumb(strRtn, content, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);
		}
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

	public static void appendIllustItemThumb2(StringBuilder strRtn, CContent content, CContentAppend contentAppend, int nViewMode, String ILLUST_VIEW) {
		if (nViewMode == VIEW_DETAIL) {
			appendIllustInfoIcon(strRtn, content);
			strRtn.append("<a class=\"IllustItemThumb");
			strRtn.append("\" href=\"javascript:void(0)\"");
			if (content != null) {
				strRtn.append(String.format(" onclick=\"showIllustDetail(%d, %d, %d)\"", content.m_nUserId, content.m_nContentId, contentAppend == null ? -1 : contentAppend.m_nAppendId));
			}
			strRtn.append(">");
		} else {
			strRtn.append(String.format("<a class=\"IllustItemThumb\" href=\"%s\">", ILLUST_VIEW));
		}
		strRtn.append(String.format(
				ILLUST_ITEM_THUMB_IMG_FMT,
				contentAppend == null ? Common.GetUrl(content.thumbImgUrl) : Common.GetUrl(contentAppend.m_strFileName + "_640.jpg")
		));
		strRtn.append("</a>");
	}

	public static void appendIllustItemThumb2MiniList(StringBuilder strRtn, CContent content) {
		strRtn.append(
				"""
				<a class="IllustItemThumb" href="/%d/%d.html" style="background-image:url('%s')">
				""".formatted(content.m_nUserId, content.m_nContentId, Common.GetUrl(content.thumbImgSmallUrl))
		);
		strRtn.append("</a>");
	}

	private static void appendTextItemThumb(StringBuilder strRtn, CContent content, int nViewMode, String ILLUST_VIEW, String ILLUST_DETAIL) {
		String className = "IllustItemThumbText";
		if(content.novelDirection==1) {
			className += " Vertical";
		}

		if(nViewMode==VIEW_DETAIL) {
			appendIllustInfoIcon(strRtn, content);
			strRtn.append(String.format("<a class=\"IllustItemText\" id=\"IllustItemText_%d\" href=\"%s?ID=%d&TD=%d\">", content.m_nContentId, ILLUST_DETAIL, content.m_nUserId, content.m_nContentId));
			strRtn.append(String.format("<span class=\"%s\">%s</span>", className, Util.replaceForGenEiFont(content.novelHtml)));
			strRtn.append("</a>");
		} else {
			strRtn.append(String.format("<a class=\"IllustItemText\" id=\"IllustItemText_%d\" href=\"%s\">", content.m_nContentId, ILLUST_VIEW));
			strRtn.append(String.format("<span class=\"%s\">%s</span>", className, Util.replaceForGenEiFont(content.novelHtmlShort)));
			strRtn.append("</a>");
		}
	}

	private static void appendTextItemThumbMiniList(StringBuilder strRtn, CContent content) {
		String className = "IllustItemThumbText";
		if(content.novelDirection==1) {
			className += " Vertical";
		}
		strRtn.append(
				"""
				<a class="IllustItemText" id="IllustItemText_%d" href="javascript:void(0)" onclick="showIllustDetail(%d,%d,-1)">
				""".formatted(content.m_nContentId, content.m_nUserId, content.m_nContentId)
		);
		strRtn.append(String.format("<span class=\"%s\">%s</span>", className, Util.replaceForGenEiFont(content.novelHtmlShort)));
		strRtn.append("</a>");
	}

	public static void appendResEmoji(
			StringBuilder sb,
			final int contentUserId,
			final String comments,
			final int lastCommentId,
			final int loginUserId,
			final boolean miniList
	) {
		final String resEmojiFormat;
		if (contentUserId != loginUserId) {
			resEmojiFormat = "<span class=\"ResEmoji\">%s</span>";
		} else {
			resEmojiFormat = "<a class=\"ResEmoji\" href=\"javascript:void(0)\" onclick=\"replyEmoji(this)\">%s</a>";
		}

		List<String> emojiList = new ArrayList<>(comments.length());
		for (int i = 0; i < comments.length(); i = comments.offsetByCodePoints(i, 1)) {
			emojiList.add(String.format(
					resEmojiFormat,
					CEmoji.parse(String.valueOf(Character.toChars(comments.codePointAt(i))))
			));
		}

		if (!miniList) {
			sb.append(String.join("", emojiList));
		} else {
			if (GridUtil.SELECT_MINI_LIST_EMOJI < emojiList.size()) {
				sb.append(
						String.join("",
						emojiList.subList(emojiList.size() - GridUtil.SELECT_MINI_LIST_EMOJI , emojiList.size())
						)
				);
			} else {
				sb.append(String.join("", emojiList));
			}
		}

		// lastCommentId
		sb.append("""
				<data class="LastCommentId" value="%d"></data>
				""".formatted(lastCommentId));
	}

	private static void appendIllustItemResList(
			StringBuilder strRtn, final CContent content, int nLoginUserId,
			final ArrayList<String> vEmoji, int nSpMode,
			final ResourceBundleControl _TEX, boolean miniList){

		final boolean isOwnerAndHidden = content.m_nUserId==nLoginUserId && !content.nowAvailable();
		strRtn.append(
			String.format(
				"<div id=\"IllustItemResList_%d\" class=\"IllustItemResList\" %s>",
				content.m_nContentId,
				isOwnerAndHidden && content.m_strCommentsListsCache.length()>0 ? "style=\"display:block;\"" : ""
			)
		);

		// もらった絵文字展開リンク
		if (!miniList && content.m_strCommentsListsCache.length() >= GridUtil.SELECT_MAX_EMOJI) {
			// 全て表示リンク
			strRtn.append("<div class=\"IllustItemResListTitle\">");
			//if(content.m_vComment.size()<=0) {
			//	strRtn.append(_TEX.T("Common.IllustItemRes.Title.Init"));
			//} else {
			//	strRtn.append(_TEX.T("Common.IllustItemRes.Title"));
			//}
			strRtn.append(String.format("<span class=\"TitleShowAll\" onclick=\"ShowAllReaction(%d, this)\">%s</span>", content.m_nContentId, _TEX.T("Common.IllustItemRes.Title.ShowAll")));
			strRtn.append("</div>");    // IllustItemResListTitle
		}

		// もらった絵文字
		appendResEmoji(strRtn, content.m_nUserId,
				content.m_strCommentsListsCache, content.m_nCommentsListsCacheLastId, nLoginUserId, miniList);

		// 絵文字追加マーク
		strRtn.append(
			String.format(
				"<span id=\"ResEmojiAdd_%d\" class=\"ResEmojiAdd\" %s><span class=\"fas fa-plus-square\"></span></span>",
				content.m_nContentId,
				isOwnerAndHidden ? "style=\"display:none;\"" : ""
			)
		);

		strRtn.append("</div>");	// IllustItemResList

		// 絵文字ボタン
		strRtn.append("<div class=\"IllustItemResBtnList\">");

		if (!miniList) {
			// リアクション促し文言
			strRtn.append("<div class=\"IllustItemResListTitle\">");
			if(content.m_vComment.size()<=0) {
				strRtn.append(_TEX.T("Common.IllustItemRes.Title.Init"));
			} else {
				strRtn.append(_TEX.T("Common.IllustItemRes.Title"));
			}

			// リプライボタン
			strRtn.append("""
				<a class="ReplyBtn fas fa-reply" onclick="switchEmojiReply(%d, %d, %d)"></a>
				""".formatted(content.m_nContentId, nLoginUserId, nLoginUserId==content.m_nUserId ? 1 : 2));
			strRtn.append("</div>");	// IllustItemResListTitle
		}


		strRtn.append("<div class=\"ResBtnSetList\">");
		if (!miniList) {
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem %s\" onclick=\"switchEmojiKeyboard(this, %d, 0, 'Recent')\">%s</a>",
					(nLoginUserId>0)?"Selected":"", content.m_nContentId, _TEX.T("IllustV.Emoji.Recent")));
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem %s\" onclick=\"switchEmojiKeyboard(this, %d, 1, 'Popular')\">%s</a>",
					(nLoginUserId<1)?"Selected":"", content.m_nContentId, _TEX.T("IllustV.Emoji.Popular")));

			// Normal
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 2, 'Food')\">%s</a>", content.m_nContentId, _TEX.T("IllustV.Emoji.Food")));
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 3, 'All')\">%s</a>", content.m_nContentId, _TEX.T("IllustV.Emoji.All")));
//			if(!content.m_bCheerNg && (nSpMode != SP_MODE_APP)) {
//				strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem\" onclick=\"switchEmojiKeyboard(this, %d, 4, 'Cheer')\">%s</a>", content.m_nContentId, _TEX.T("Cheer")));
//			}
		} else {
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem %s\" onclick=\"switchEmojiKeyboardMini(this, %d, 0, 'Recent')\"><i class=\"fas fa-history\"></i></a>",
					(nLoginUserId>0)?"Selected":"",  content.m_nContentId));
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem %s\" onclick=\"switchEmojiKeyboardMini(this, %d, 1, 'Popular')\"><i class=\"far fa-star\"></i></a>",
					(nLoginUserId<1)?"Selected":"", content.m_nContentId));
			strRtn.append(String.format("<a class=\"BtnBase ResBtnSetItem %s\" onclick=\"switchEmojiKeyboardMini(this, %d, 5, 'Random')\"><i class=\"fas fa-random\"></i></a>",
					"", content.m_nContentId));
		}
		strRtn.append("</div>");	// ResBtnSetList

		// 投げ銭支払い処理中
//		strRtn.append("<div class=\"ResEmojiCheerNowPayment\" style=\"display:none\">")
//				.append("<span class=\"CheerLoading\"></span><span>")
//				.append(_TEX.T("Cheer.PaymentProcessing"))
//				.append("</span>")
//				.append("</div>");	// ResEmojiCheerNowPayment

		if (nLoginUserId > 0) {
			String emoji;
			// よく使う絵文字
			strRtn.append("<div class=\"ResEmojiBtnList Recent\">");
			for (int i=0; i<vEmoji.size(); i++) {
				if (miniList && i >= 8) break;
				emoji = vEmoji.get(i);
				strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, '%s', %d, this)\">%s</a>", content.m_nContentId, emoji, nLoginUserId, CEmoji.parse(emoji)));
			}
			strRtn.append("</div>");	// ResEmojiBtnList
			// 人気の絵文字
			strRtn.append("<div class=\"ResEmojiBtnList Popular\" style=\"display: none;\"></div>");
			strRtn.append("<div class=\"ResEmojiBtnList Random\" style=\"display: none;\"></div>");
		} else {
			String emoji;
			// よく使う絵文字
			strRtn.append("<div class=\"ResEmojiBtnList Recent\" style=\"display: none;\"></div>");
			// 人気の絵文字
			strRtn.append("<div class=\"ResEmojiBtnList Popular\">");
			for (int i=0; i<vEmoji.size(); i++) {
				if (miniList && i >= 8) break;
				emoji = vEmoji.get(i);
				strRtn.append(String.format("<a class=\"ResEmojiBtn\" href=\"javascript:void(0)\" onclick=\"SendEmoji(%d, '%s', %d, this)\">%s</a>", content.m_nContentId, emoji, nLoginUserId, CEmoji.parse(emoji)));
			}
			strRtn.append("</div>");	// ResEmojiBtnList
		}

		if (!miniList) {
			// 食べ物の絵文字
			strRtn.append("<div class=\"ResEmojiBtnList Food\" style=\"display: none;\"></div>");
		} else {
			strRtn.append("<div class=\"ResEmojiBtnList Random\" style=\"display: none;\"></div>");
		}

		if (!miniList && nLoginUserId > 0) {
			// その他の絵文字
			strRtn.append("<div class=\"ResEmojiBtnList All\" style=\"display: none;\"></div>");
			if (!content.m_bCheerNg) {
				// ポチ袋
//				if (nSpMode == SP_MODE_APP) {
//					// アプリであることを示すclassを付与して、JS側で区別できるようにする。
//					//strRtn.append("<div class=\"ResEmojiBtnList Cheer App\" style=\"display: none;\"></div>");
//				} else {
//					strRtn.append("<div class=\"ResEmojiBtnList Cheer Browser\" style=\"display: none;\"></div>");
//				}
			}
		}
		strRtn.append("</div>");	// IllustItemResBtnList

		// リプライ
		if (!miniList) {
			if (nLoginUserId == content.m_nUserId) {
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
						""".formatted(content.m_nContentId, _TEX.T("IllustView.Reply.ForMyContent")));
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
						""".formatted(content.m_nContentId, _TEX.T("IllustView.Reply.FromCreator"), content.m_nContentId));
			}

			// フォロー促し
			strRtn.append(String.format("<div id=\"EncourageFollowUp_%d\" class=\"EncourageFollowUp\" style=\"display:none\">", content.m_nContentId));
			strRtn.append("<span>").append(_TEX.T("EncourageFollowUp")).append("</span>");
			strRtn.append(String.format("<span class=\"BtnBase UserInfoCmdFollow UserInfoCmdFollow_%d %s\" onclick=\"UpdateFollowUser(%d,%d)\">%s</span>",
					content.m_nUserId,
					(content.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?"Selected":"",
					nLoginUserId,
					content.m_nUserId,
					(content.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?_TEX.T("IllustV.Following"):_TEX.T("IllustV.Follow")));
			strRtn.append("</div>");
		}
	}

	public static String Content2Html(
			final CContent content,  CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode) throws UnsupportedEncodingException {
		return _Content2Html(content, checkLogin, nMode, _TEX, vEmoji, nViewMode, nSpMode, PageCategory.DEFAULT);
	}

	public static String Content2Html2Column(
		final CContent content,  CheckLogin checkLogin, final ResourceBundleControl _TEX) throws UnsupportedEncodingException {
		final int nLoginUserId = checkLogin.m_nUserId;
		if (content.m_nContentId <= 0) return "";

		final String ILLUST_LIST = getIllustListContext(content.m_nUserId);
		final String SEARCH_CATEGORY = getSearchCategoryContext();
		final String strThumbCssClass = getThumbClass(content);

		StringBuilder strRtn = new StringBuilder();
		strRtn.append(String.format("<div class=\"IllustItem %s\" id=\"IllustItem_%d\" >", strThumbCssClass, content.m_nContentId));
		// 画像orテキスト
		appendContentItemThumbMiniList(strRtn, content);
		// カテゴリー
		appendIllustItemCategory(strRtn, content, SEARCH_CATEGORY, _TEX, checkLogin.m_nUserId);
		// プロンプト
		appendIllustItemPrompt(strRtn, content, _TEX);
		// ユーザ名とフォローボタン
		appendIllustItemUser(strRtn, content, nLoginUserId, _TEX, ILLUST_LIST, false, false, false);
		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}

	public static String Content2Html(
			final CContent content, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode, PageCategory pageCategory) throws UnsupportedEncodingException {
		return _Content2Html(content, checkLogin, nMode, _TEX, vEmoji, nViewMode, nSpMode, pageCategory);
	}

	private static String _Content2Html(
			final CContent content, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode, PageCategory pageCategory) {

		final int nLoginUserId = checkLogin.m_nUserId;
		if (content.m_nContentId <= 0) return "";

		final String ILLUST_LIST = getIllustListContext(content.m_nUserId);
		final String REPORT_FORM = getReportFormContext(nMode);
		final String ILLUST_DETAIL = getIllustFromContext();
		final String SEARCH_CATEGORY = getSearchCategoryContext();
		final String ILLUST_VIEW = getIllustViewContext(content);

		final String strThumbCssClass = getThumbClass(content);

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<div class=\"IllustItem full %s\" id=\"IllustItem_%d\">", strThumbCssClass, content.m_nContentId));

		// ユーザ名とフォローボタン
		appendIllustItemUser(strRtn, content, nLoginUserId, _TEX, ILLUST_LIST, true, false, true);
		// 画像orテキスト
		if (!content.nowAvailable() && content.m_nUserId == nLoginUserId) {
			appendMyIllustItemThumb(strRtn, content, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);
		} else {
			appendContentItemThumb(strRtn, content, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);
		}

		// 2枚目以降用の場所
		strRtn.append("<div class=\"IllustItemThubExpand\"></div>");

		// 全て表示ボタン
		appendIllustItemExpand(strRtn, content, _TEX, nSpMode, false);

		// カテゴリーとコマンド
		strRtn.append("<div class=\"IllustItemCommand\">");
		appendIllustItemCategory(strRtn, content, SEARCH_CATEGORY, _TEX, nLoginUserId);
		appendIllustItemCommandSub(strRtn, content, nLoginUserId, nMode, nSpMode, REPORT_FORM, _TEX, pageCategory);
		strRtn.append("</div>");	// IllustItemCommand

		// プロンプト
		appendIllustItemPrompt(strRtn, content, _TEX);

		// キャプション
		appendIllustItemDesc(strRtn, content, nMode);

		// タグ
		appendTag(strRtn, checkLogin, content, nMode, nSpMode);

		// 編集
		if(content.m_nUserId==nLoginUserId) {
			appendIllustItemDescEdit(strRtn, content, nMode);
		}

		// サムネイルへの重畳表示
		//appendOverlayToThumbnail(strRtn, content, _TEX, nViewMode);

		// 絵文字
		if(content.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			appendIllustItemResList(strRtn, content, nLoginUserId, vEmoji, nSpMode, _TEX, false);
		}

		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}

	public static String SketchbookContent2Html(
			final CContent content, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode) throws UnsupportedEncodingException {
		return _SketchbookContent2Html(content, checkLogin, nMode, _TEX, vEmoji, nViewMode, nSpMode, PageCategory.DEFAULT);
	}

	public static String SketchbookContent2Html(
			final CContent content, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode, PageCategory pageCategory) throws UnsupportedEncodingException {
		return _SketchbookContent2Html(content, checkLogin, nMode, _TEX, vEmoji, nViewMode, nSpMode, pageCategory);
	}

	private static String _SketchbookContent2Html(
			final CContent content, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX,
			final ArrayList<String> vEmoji, int nViewMode, int nSpMode, PageCategory pageCategory) {

		if (content.m_nContentId <= 0) return "";

		final int nLoginUserId = checkLogin.m_nUserId;

		final String ILLUST_LIST = getIllustListContext(content.m_nUserId);
		final String REPORT_FORM = getReportFormContext(nMode);
		final String ILLUST_DETAIL = getIllustFromContext();
		final String SEARCH_CATEGORY = getSearchCategoryContext();
		final String ILLUST_VIEW = getIllustViewContext(content);

		final String strThumbCssClass = getThumbClass(content);

		StringBuilder strRtn = new StringBuilder();

		strRtn.append(String.format("<div class=\"IllustItem %s\" id=\"IllustItem_%d\">", strThumbCssClass, content.m_nContentId));

		// ユーザ名とフォローボタン
		appendIllustItemUser(strRtn, content, nLoginUserId, _TEX, ILLUST_LIST, false, true, true);

		// カテゴリーとコマンド
		strRtn.append("<div class=\"IllustItemCommand\">");
		appendIllustItemCategory(strRtn, content, SEARCH_CATEGORY, _TEX, nLoginUserId);
		appendIllustItemCommandSub(strRtn, content, nLoginUserId, nMode, nSpMode, REPORT_FORM, _TEX, pageCategory);
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		appendIllustItemDesc(strRtn, content, nMode);

		// プロンプト
		appendIllustItemPrompt(strRtn, content, _TEX);

		// タグ
		appendTag(strRtn, checkLogin, content, nMode, nSpMode);

		// 画像
		content.setRequestImgThumb();
		appendContentItemThumb(strRtn, content, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);

		// 2枚目以降用の場所
		strRtn.append("<div class=\"IllustItemThubExpand\"></div>");

		// 全て表示ボタン
		appendIllustItemExpand(strRtn, content, _TEX, nSpMode, false);

		// サムネイルへの重畳表示
		appendOverlayToThumbnail(strRtn, content, _TEX, nViewMode);

		// 絵文字
		if(content.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			appendIllustItemResList(strRtn, content, nLoginUserId, vEmoji, nSpMode, _TEX, false);
		}

		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}


	private static void appendOverlayToThumbnail(StringBuilder strRtn, CContent content, ResourceBundleControl _TEX, int nViewMode) {
		if (content.m_nFileWidth > 0 && content.m_nFileHeight > 0) {
			//String strSizeAppendix = "(" + String.format(_TEX.T("UploadFileTweet.OriginalSize"), content.m_nFileWidth, content.m_nFileHeight) + ")";
		}
//		strRtn.append(String.format("<div class=\"IllustItemTProhibit\"><span class=\"TapToFull\">%s</span>%s</div>",
//				(nViewMode == VIEW_DETAIL) ? String.format(_TEX.T("IllustView.ProhibitMsg.TapToFull"), strSizeAppendix) : strSizeAppendix,
//				_TEX.T("IllustView.ProhibitMsg")));
	}

	private static int getImageRemainNum(CContent content) {
		int remainNum;
		if (content.m_nEditorId != Common.EDITOR_TEXT) {
			remainNum = content.m_nFileNum - 1;
			if (content.passwordEnabled
					|| content.m_nSafeFilter != Common.SAFE_FILTER_ALL
					|| content.isValidPublishId() && content.m_nPublishId != Common.PUBLISH_ID_ALL ) {
				remainNum++;
				if (content.publishAllNum > 0) {
					remainNum--;
				}
			}
		} else { // for TEXT
			remainNum = 0;
			if (content.passwordEnabled
					|| content.m_nSafeFilter != Common.SAFE_FILTER_ALL
					|| content.isValidPublishId() && content.m_nPublishId != Common.PUBLISH_ID_ALL ) {
				remainNum++;
			}
		}
		return remainNum;
	}


	private static void appendIllustItemExpand(StringBuilder strRtn, CContent content,
											ResourceBundleControl _TEX, int nSpMode, boolean miniList) {

		int remainNum = getImageRemainNum(content);

		strRtn.append("<div class=\"IllustItemExpand\">");

		// content.isHideThumbImg, content.publishAllNum,  content.m_nFileNum で、追加表示する画像があるか否かを判定
		if (remainNum > 0) {
			if (content.passwordEnabled) {
				appendIllustItemExpandPassFrame(_TEX, strRtn);
			}

			StringBuilder sb = new StringBuilder();

			if (content.m_nSafeFilter != Common.SAFE_FILTER_ALL) {
				sb.append(
					"""
					<span class="Publish %s SafeFilterIcoBlue%02d"></span>
					""".formatted(miniList ? "Mini" : "", content.m_nSafeFilter));
			}

			if (content.isValidPublishId() && content.m_nPublishId != Common.PUBLISH_ID_ALL) {
				sb.append(
					"""
					<span class="Publish %s PublishIcoBlue%02d"></span>
					""".formatted(miniList?"Mini":"", content.m_nPublishId));
			}

			final String remainLabel;
			if (content.m_nEditorId != Common.EDITOR_TEXT) {
				remainLabel = String.format(_TEX.T(
						"IllustView.ExpandBtn" + (miniList?"Mini":"")
				), remainNum);
			} else {
				remainLabel = String.format(_TEX.T(
						"IllustView.ExpandBtnText" + (miniList?"Mini":"")
				), content.m_strTextBody.length());
			}

			final String onClickFunction;
			if (!miniList) {
				onClickFunction = "ShowAppendFile(%d, %d, %d, this)".formatted(
						content.m_nUserId,
						content.m_nContentId,
						nSpMode);
			} else {
				onClickFunction = "showIllustDetail(%d, %d, -1)".formatted(
						content.m_nUserId,
						content.m_nContentId);
			}
			strRtn.append(
					"""
					<a class="BtnBase IllustItemExpandBtn" href="javascript:void(0)" onclick="%s">%s %s</a>
					""".formatted(onClickFunction, sb, remainLabel)
			);

		}
		strRtn.append("</div>");	// IllustItemExpand
	}

	private static void appendIllustItemDescEdit(StringBuilder strRtn, CContent content, int nMode) {
		strRtn.append(String.format("<div id=\"IllustItemDescEdit_%d\" class=\"IllustItemDescEdit\">", content.m_nContentId));
		strRtn.append(String.format("<textarea class=\"IllustItemDescEditTxt\" maxlength=\"200\">%s</textarea>", Util.toStringHtmlTextarea(content.m_strDescription)));
		strRtn.append(String.format("<input class=\"IllustItemTagEditTxt\" type=\"text\" maxlength=\"100\" value=\"%s\" />", Util.toDescString(content.m_strTagList)));
		strRtn.append("<div class=\"IllustItemDescEditCmdList\">");
		strRtn.append(String.format("<a class=\"BtnBase IllustItemDescEditCmd\" onclick=\"UpdateDesc(%d, %d, %d)\">OK</a>", content.m_nUserId, content.m_nContentId, nMode));
		strRtn.append("</div>");    // IllustItemDescEditCmdList
		strRtn.append("</div>");    // IllustItemDescEdit
	}

	private static void appendIllustItemUser(StringBuilder strRtn, CContent content, int nLoginUserId, ResourceBundleControl _TEX, String ILLUST_LIST, boolean showFollowLabel, boolean showGiftBtn, boolean showFollowBtn) {
		strRtn.append("<div class=\"IllustItemUser\">");
		strRtn.append(String.format("<a class=\"IllustItemUserThumb\" href=\"%s\" style=\"background-image:url('%s_120.jpg')\"></a>", ILLUST_LIST, Common.GetUrl(content.m_cUser.m_strFileName)));
		strRtn.append(String.format("<h2 class=\"IllustItemUserName\"><a href=\"%s\">%s</a></h2>", ILLUST_LIST, Util.toStringHtml(content.m_cUser.m_strNickName)));

		final boolean following = content.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING;
		String followLabel = following ? _TEX.T("IllustV.Following"): _TEX.T("IllustV.Follow");
		if (!showFollowLabel) {
			followLabel = followLabel.substring(0, 1);
		}

		if (showGiftBtn) {
			strRtn.append(String.format("<span class=\"UserInfoCmdGift\" onclick=\"SendGift(%d, '%s')\"><i class=\"fas fa-gift\"></i></span>",
					content.m_nUserId, content.m_cUser.m_strNickName));
		}
		if(showFollowBtn && content.m_cUser.m_nFollowing != CUser.FOLLOW_HIDE) {
			strRtn.append(String.format("<span class=\"BtnBase UserInfoCmdFollow UserInfoCmdFollow_%d %s %s\"  onclick=\"UpdateFollowUser%s(%d, %d)\">%s</span>",
					content.m_nUserId,
					(content.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?"Selected":"",
					showFollowLabel ? "" : "NoLabel",
					showFollowLabel ? "" : "NoLabel",
					nLoginUserId,
					content.m_nUserId,
					followLabel));
		}
		strRtn.append("</div>");	// IllustItemUser
	}

	private static void appendIllustItemExpandPassFrame(ResourceBundleControl _TEX, StringBuilder strRtn) {
		strRtn.append(
				"""
				<div class="IllustItemExpandPassFrame">
				<img class="PasswordIcon" src="//unrealizm.com/img/ico_pass_blue.png"/>
				<input class="IllustItemExpandPass" name="PAS" type="text" maxlength="16" />
				<a class="IllustItemExpandPassVisible Display" style="display:none" href="javascript:void(0)" onclick="visibleContentPassword(this)">%s</a>
				<a class="IllustItemExpandPassVisible Hide" href="javascript:void(0)" onclick="hideContentPassword(this)">%s</a>
				</div>
				""".formatted(
				_TEX.T("ShowAppendFileC.EnterPassword.Show"),
				_TEX.T("ShowAppendFileC.EnterPassword.Hide")
				)
		);
	}

	public static String MyContent2Html(final CContent content, CheckLogin checkLogin, int nMode, final ResourceBundleControl _TEX, final ArrayList<String> vResult, int nViewMode, int nSpMode) throws UnsupportedEncodingException {
		if(content.m_nContentId<=0) return "";

		final int nLoginUserId = checkLogin.m_nUserId;
		final String REPORT_FORM = getReportFormContext(nMode);
		final String SEARCH_CATEGORY = getSearchCategoryContext();
		final String ILLUST_VIEW = getIllustViewContext(content);
		final String ILLUST_DETAIL = getIllustFromContext();

		String strThumbClass = getThumbClass(content);

		StringBuilder strRtn = new StringBuilder();
		strRtn.append(String.format("<div class=\"IllustItem %s\" id=\"IllustItem_%d\">", strThumbClass, content.m_nContentId));

		// カテゴリーとコマンド
		strRtn.append("<div class=\"IllustItemCommand\">");

		appendIllustItemCategory(strRtn, content, SEARCH_CATEGORY, _TEX, nLoginUserId);

		// コマンド
		appendIllustItemCommandSub(strRtn, content, nLoginUserId, nMode, nSpMode, REPORT_FORM, _TEX, PageCategory.MY_BOX);
		strRtn.append("</div>");	// IllustItemCommand

		// キャプション
		appendIllustItemDesc(strRtn, content, nMode);

		// プロンプト
		appendIllustItemPrompt(strRtn, content, _TEX);

		// タグ
		appendTag(strRtn, checkLogin, content, nMode, nSpMode);

		// 編集
		if(content.m_nUserId==nLoginUserId) {
			// キャプション
			appendIllustItemDescEdit(strRtn, content, nMode);
		}

		// 画像
		appendMyIllustItemThumb(strRtn, content, nViewMode, ILLUST_VIEW, ILLUST_DETAIL);

		// 2枚目以降用の場所
		strRtn.append("<div class=\"IllustItemThubExpand\"></div>");

		// 2枚目以降ボタン
		strRtn.append("<div class=\"IllustItemExpand\">");
		if(content.m_nFileNum>1) {
			strRtn.append(String.format("<div class=\"IllustItemExpandPassFrame\"><input class=\"IllustItemExpandPass\" name=\"PAS\" type=\"text\" maxlength=\"16\" placeholder=\"%s\" /></div>",
					_TEX.T("ShowAppendFileC.EnterPassword")));
			strRtn.append(String.format("<a class=\"BtnBase IllustItemExpandBtn\" href=\"javascript:void(0)\" onclick=\"ShowAppendFile(%d, %d, %d, this);\"><i class=\"far fa-clone\"></i> %s</a>",
					content.m_nUserId,
					content.m_nContentId,
					nSpMode,
					String.format(_TEX.T("IllustView.ExpandBtn"), content.m_nFileNum-1)));
		}
		strRtn.append("</div>");	// IllustItemExpand

		// 転載禁止表示
		appendOverlayToThumbnail(strRtn, content, _TEX, nViewMode);

		// 絵文字
		if(content.m_cUser.m_nReaction==CUser.REACTION_SHOW) {
			appendIllustItemResList(strRtn, content, nLoginUserId, vResult, nSpMode, _TEX, false);
		}

		strRtn.append("</div>");	// IllustItem

		return strRtn.toString();
	}


	private static String _toThumbHtml(final CContent content, final CheckLogin checkLogin, int nMode, int nSpMode, final ResourceBundleControl _TEX, PageCategory pageCategory) {
		final String ILLUST_LIST = getIllustListContext(content.m_nUserId);
		final String SEARCH_CATEGORY = getSearchCategoryContext();
		final String ILLUST_VIEW = getIllustViewContext(content);

		StringBuilder strRtn = new StringBuilder();

		strRtn.append("<div class=\"IllustThumb");
		if (content.pinOrder > 0) {
			strRtn.append(" Pined");
		}
		if (pageCategory == PageCategory.MY_BOX) {
			strRtn.append((nMode==MODE_SP ? " IllustThumbMyBoxSp" : " IllustThumbMyBoxPc"));
			if (checkLogin.m_nPassportId==Common.PASSPORT_ON) {
				strRtn.append((nMode==MODE_SP ? " ShowTimestampSp" : " ShowTimestampPc"));
			}
		}
		strRtn.append("\">");

		// サムネイル
		final String strFileUrl;
		final boolean bHidden;	// テキストモード用カバー画像表示フラグ
		if (pageCategory == PageCategory.MY_BOX && content.m_nUserId == checkLogin.m_nUserId) {
			strFileUrl = content.m_strFileName + "_360.jpg";
			bHidden = false;
		} else {
			content.setThumb();
			strFileUrl = content.thumbImgSmallUrl;
			bHidden = content.isHideThumbImg;
		}


		if(content.m_nEditorId!=Common.EDITOR_TEXT || bHidden) { // イラスト表示もしくはテキストだけど限定画像を表示
			// 画像
			strRtn.append(String.format("<a class=\"IllustThumbImg\" href=\"%s\" ", ILLUST_VIEW));
			if(content.m_nOpenId==0 || content.m_nOpenId==1){
				strRtn.append(String.format("style=\"background-image:url('%s')\">", Common.GetUrl(strFileUrl)));
			} else {
				strRtn.append(String.format("style=\"background: rgba(0,0,0,.7) url('%s');", Common.GetUrl(strFileUrl)))
						.append("background-blend-mode: darken;background-size: cover;background-position: 50% 50%;\">");
			}
		} else {
			// テキスト
			appendIllustThumbText(strRtn, content, ILLUST_VIEW);
		}

		// 公開非公開マーク
		if(pageCategory == PageCategory.MY_BOX
				&& checkLogin.m_nUserId==content.m_nUserId
				&& (!content.nowAvailable() || content.m_bLimitedTimePublish)){
			strRtn.append("<span class=\"IllustInfoCenter\"" +
							(content.novelDirection==1 ? "style=\"top:0px;left:0px\"" : "") +
					">");

			if (content.m_bLimitedTimePublish) {
				strRtn.append("<span class=\"Publish PublishLimited" + (content.nowAvailable()?"":"Not") + "Published\"></span>");
			} else {
				strRtn.append("<span class=\"Publish Private\"></span>");
			}

			strRtn.append("</span>"); // IllustInfoCenter
		}

		// 公開種別マーク
		strRtn.append("<span class=\"IllustInfoBottom\">");
		if(content.publishAllNum == 1
				|| pageCategory == PageCategory.MY_BOX && checkLogin.m_nUserId==content.m_nUserId){

			if (content.m_nSafeFilter != Common.SAFE_FILTER_ALL) {
				strRtn.append(String.format("<span class=\"Publish SafeFilterIco%02d\"></span>", content.m_nSafeFilter));
			}
			if (content.isValidPublishId() && content.m_nPublishId != Common.PUBLISH_ID_ALL) {
				strRtn.append(String.format("<span class=\"Publish PublishIco%02d\"></span>", content.m_nPublishId));
			}
			if (content.isPasswordEnabled()) {
				strRtn.append("<span class=\"Publish PasswordIco\"></span>");
			}
		}

		// 枚数マーク
		if(content.m_nFileNum>1){
			strRtn.append("<span class=\"Num\">").append(getContentsFileNumHtml(content)).append("</span>");
		} else if(content.m_nEditorId==Common.EDITOR_TEXT) {
			strRtn.append(String.format("<span class=\"Num Text\"><i class=\"fas fa-font\"></i> %d</span>", content.m_strTextBody.length()));
		}
		strRtn.append("</span>");	// IllustInfoBottom
		strRtn.append("</a>");	// IllustThumbImg | IllustThumbText

		// カテゴリ系情報
		strRtn.append("<span class=\"IllustInfo IllustMeta\">");
		// カテゴリ
		strRtn.append(
				String.format("<a class=\"CategoryInfo\" href=\"%s?CD=%d\"><span class=\"Category C%d\">%s</span></a>",
						SEARCH_CATEGORY,
						content.m_nCategoryId,
						content.m_nCategoryId,
						_TEX.T(String.format("Category.C%d", content.m_nCategoryId))
				)
		);

		if (pageCategory == PageCategory.MY_BOX) {
			// Pin, Note
			if (pageCategory == PageCategory.MY_BOX && content.pinOrder > 0) {
				strRtn.append("<span class=\"IllustInfoPin fas fa-thumbtack\"></span>");
			} else if (content.m_nUserId == checkLogin.m_nUserId && !content.privateNote.isEmpty()) {
				strRtn.append("<span class=\"IllustInfoPin far fa-sticky-note\" onclick=\"TogglePrivateNote($(this).parent().parent(),'" +
						Util.toQuotedString(content.privateNote, "'") +
						"')\"></span>");
			}
		}
		strRtn.append("</span>");    // カテゴリ系情報(IllustInfo)

		// プロンプト
		String prompt = content.aiPrompt;
		if (prompt.length() > 15) {
			prompt = prompt.substring(0, 15) + "...";
		}
		strRtn.append("""
				<span class="IllustInfoPrompt" onclick="DispPromptDlg(%d)">
					<i class="fas fa-terminal"></i> %s
					<span class="ShowMorePrompt">more</span>
				</span>
				""".formatted(content.m_nContentId, prompt));
		// イラスト情報
//		strRtn.append(String.format("<a class=\"IllustInfo\" href=\"%s\">", ILLUST_VIEW));
		strRtn.append("<a class=\"IllustInfo\" href=\"javascript: void(0);\">");

		// キャプション
		final String description =
				(content.m_strDescriptionTranslated!=null&&!content.m_strDescriptionTranslated.isEmpty())
				? content.m_strDescriptionTranslated : content.m_strDescription;

		strRtn.append(String.format(
				"<span class=\"IllustInfoDesc\">%s</span>",
				Util.toStringHtml(description)
				)
		);
		strRtn.append("</a>");	// IllustInfo

		if (pageCategory == PageCategory.MY_BOX && checkLogin.m_nPassportId==Common.PASSPORT_ON) {
			final SimpleDateFormat dateFormat = new SimpleDateFormat(DATE_FORMAT_SHORT);

			// created_at
			final String createdAt = content.createdAt == null ? "----.--.--" : dateFormat.format(content.createdAt);
			strRtn.append(String.format("<div class=\"IllustUser DateTime\"><i class=\"far fa-calendar\"></i> %s</div>",createdAt));
			// updated_at
			final String updatedAt = content.updatedAt == null ? "----.--.--" : dateFormat.format(content.updatedAt);
			strRtn.append(String.format("<div class=\"IllustUser DateTime\" style=\"border-bottom:none\"><i class=\"fas fa-pen\"></i> %s</div>",updatedAt));
		}

		if (pageCategory != PageCategory.MY_BOX) {
			// ユーザ情報
			strRtn.append(String.format("<a class=\"IllustUser\" href=\"%s\">", ILLUST_LIST));
			// 画像
			strRtn.append(String.format("<span class=\"IllustUserThumb\" style=\"background-image:url('%s_120.jpg')\"></span>", Common.GetUrl(content.m_cUser.m_strFileName)));
			// 名前
			strRtn.append(String.format("<h2 class=\"IllustUserName\">%s</h2>", Util.toStringHtml(content.m_cUser.m_strNickName)));
			// Pin
			if (content.pinOrder > 0) {
				strRtn.append("<span class=\"IllustUserPin fas fa-thumbtack\"></span>");
			}
			strRtn.append("</a>");    // IllustItemUser
		}
		strRtn.append("</div>");	// IllustThumb
		return strRtn.toString();
	}

	public static String toMyBoxThumbHtml(final CContent content, final CheckLogin checkLogin, int nMode, int nSpMode, final ResourceBundleControl _TEX) {
		return _toThumbHtml(content, checkLogin, nMode, nSpMode, _TEX, PageCategory.MY_BOX);
	}

	public static String toThumbHtml(final CContent content, final CheckLogin checkLogin, int nMode, int nSpMode, final ResourceBundleControl _TEX) {
		return _toThumbHtml(content, checkLogin, nMode, nSpMode, _TEX, PageCategory.DEFAULT);
	}

	private static void appendIllustThumbText(StringBuilder sb, CContent content, String ILLUST_VIEW) {
		String className = "IllustThumbText";
		if(content.novelDirection==1) {
			className += " Vertical";
		}
		sb.append(String.format("<a class=\"%s\" href=\"%s\" ", className, ILLUST_VIEW));
		if(!(content.nowAvailable())){
			sb.append("style=\"background: rgba(0,0,0,.5);\"");
		}
		sb.append(">").append(Util.replaceForGenEiFont(content.novelHtmlShort));
	}

	public static String toHtmlUser(CUser cUser) {
		String ILLUST_LIST = getIllustListContext(cUser.m_nUserId);
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

	public static String toHtmlUserMini(CUser cUser) {
		String ILLUST_LIST = getIllustListContext(cUser.m_nUserId);
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

	public static String toHtmlTag(CTag cTag, String thumbnailFileName, int userId) throws UnsupportedEncodingException {
		String backgroundImageUrl = "";
		String strKeyWord = cTag.m_strTagTxt;
		boolean isFollowTag = cTag.isFollow;
		int genreId = cTag.m_nGenreId;
		if (strKeyWord.toLowerCase().contains("r18")
				|| strKeyWord.toLowerCase().contains("r-18")
				|| strKeyWord.toLowerCase().contains("18禁")
				|| strKeyWord.toLowerCase().contains("nsfw")) {
			backgroundImageUrl = "/img/R-18.png_360.jpg";
		} else {
			if (!thumbnailFileName.isEmpty()) {
				backgroundImageUrl = Common.GetUrl(thumbnailFileName) + "_360.jpg";
			} else {
				String genreImage = "";
				if (genreId > 0) {
					genreImage = Genre.select(genreId).genreImage;
				}
				if (genreImage.isEmpty()) {
					backgroundImageUrl = Common.GetUrl("/img/default_genre.png");
				} else {
					backgroundImageUrl = Common.GetUrl(genreImage);
				}
			}
		}
		return """
			<div class="TagThumb">
				<div class="TagThumbImg" style="background-image:url('%s')"></div>
				<a class="TagThumbImgMask" href="/SearchIllustByTagV.jsp?KWD=%s"></a>
				<a class="TagInfoTagName" href="/SearchIllustByTagV.jsp?KWD=%s">
					#%s
				</a>
				<div class="TagThumbBookmarkButton" onclick="UpdateFollowTagFromTagList(%d, '%s', this)"><i class="%s fa-star"></i></div>
			</div>
		""".formatted(
			backgroundImageUrl,
			URLEncoder.encode(strKeyWord, StandardCharsets.UTF_8),
			URLEncoder.encode(strKeyWord, StandardCharsets.UTF_8),
			Util.toStringHtml(strKeyWord),
			userId,
			strKeyWord,
			isFollowTag?"fas":"far"
		);
	}

	public static String toReactionDetailListHtml(List<ReactionListC.ReactionDetail> reactionDetails, CheckLogin checkLogin, ResourceBundleControl _TEX, boolean isSmartPhone) {
		StringBuilder sb = new StringBuilder();

		for(int count = 0; count<reactionDetails.size(); count++) {
			ReactionListC.ReactionDetail r = reactionDetails.get(count);
			sb.append("""
				<div class="ReactionDetail%s">
				""".formatted(isSmartPhone?"":" Pc"));
			sb.append("""
				<div class="ReactionDetailEmoji">%s</div>
				""".formatted(CEmoji.parse(r.comment)));

			sb.append("""
				<div class="ReactionDetailUserThumb%s">
				""".formatted(isSmartPhone ? "" : " Pc"));
			if(r.fromUserNickname != null){
				sb.append("""
				<a class="UserInfoUserThumb" style="background-image: url('%s')" href="/%d/"></a>
				""".formatted(
						Common.GetUrl(r.fromUserProfileFile.isEmpty()?"/img/default_user.jpg_120.jpg":r.fromUserProfileFile),
						r.fromUserId
				));
			}else {
				sb.append("""
				<div class="UserInfoUserThumb" style="background-image: url('%s')"></div>
				""".formatted(
						Common.GetUrl("/img/default_user.jpg_120.jpg")
				));
			}
			sb.append("</div>"); // ReactionDetailUserThumb

			if(r.fromUserNickname != null){
				sb.append("""
				<a class="ReactionDetailUserNickName" href="%d">%s</a>
				""".formatted(r.fromUserId, r.fromUserNickname));
			} else {
				sb.append("""
				<div class="ReactionDetailUserNickName">%s</div>
				""".formatted(_TEX.T("ReactionListV.AnonymousUser")));
			}

			sb.append("""
				<div class="ReactionDetailUserFollow">
				""");
			if(r.fromUserId < 0 || r.fromUserId == checkLogin.m_nUserId) {
				sb.append("<div></div>");
			} else if (r.isFollowing) {
				sb.append("""
				<div class="ReactionDetailFollowing">%s</div>
				""".formatted(_TEX.T("ReactionListV.Following")));
			} else {
				sb.append("""
				<a class="BtnBase ReactionDetailFollow UserInfoCmdFollow_%d"
				onclick="UpdateFollowUser(%d,%d)">%s</a>
				""".formatted(r.fromUserId,checkLogin.m_nUserId, r.fromUserId, _TEX.T("IllustV.Follow") ));

			}
			sb.append("</div>"); // ReactionDetailUserFollow

			sb.append("</div>"); // ReactionDetail
		}
		return sb.toString();
	}
}

























