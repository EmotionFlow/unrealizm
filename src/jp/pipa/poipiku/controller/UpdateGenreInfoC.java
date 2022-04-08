package jp.pipa.poipiku.controller;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class UpdateGenreInfoC {
	public static final int OK_PARAM = 0;
	public static final int OK_EDIT = 0;
	public static final int ERR_NOT_LOGIN = -1;
	public static final int ERR_TEXT_SIZE_MAX = -2;
	public static final int ERR_TEXT_SIZE_MIN = -3;
	public static final int ERR_NOT_PASSPORT = -4;
	public static final int ERR_NEED_GENRE_NAME = -5;
	public static final int ERR_SAME_GENRE_NAME = -6;
	public static final int ERR_UNKNOWN = -99;

	private final int[] TEXT_MIN = {1, 0, 0};
	private final int[] TEXT_MAX = {16, 64, 1000};
	private final String[] COLUMN = {"genre_name", "genre_desc", "genre_detail"};

	public int userId = -1;
	public int genreId = -1;
	public int langId= -1; // -1：デフォルト、0以上はSupportedLocalesで定義している言語ID。
	public String data = "";

	public Genre.Type type = Genre.Type.Undefined;
	
	public int getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
			genreId = Util.toInt(request.getParameter("GID"));
			data = Common.TrimAll(Common.EscapeInjection(request.getParameter("DATA")));
			final int ty = Util.toInt(request.getParameter("TY"));
			type = Genre.Type.byCode(ty);
			langId = Util.toInt(request.getParameter("LANGID"));
		} catch (Exception e) {
			userId = -1;
			genreId = -1;
			type = Genre.Type.Undefined;
			return ERR_UNKNOWN;
		}
		return OK_PARAM;
	}

	public int getResults(CheckLogin checkLogin, ServletContext context) {
		if(!checkLogin.m_bLogin || checkLogin.m_nUserId!= userId) return ERR_NOT_LOGIN;
		//if(checkLogin.m_nPassportId<=Common.PASSPORT_OFF) return ERR_NOT_PASSPORT;
		if (genreId < 0) return ERR_UNKNOWN;
		if (type.getCode() < 0 || type.getCode() >= COLUMN.length) return ERR_UNKNOWN;
		if (type.getCode() == 0 && data.isEmpty()) return ERR_NEED_GENRE_NAME;
		if (data.length() > TEXT_MAX[type.getCode()]) return ERR_TEXT_SIZE_MAX;
		if (data.length() < TEXT_MIN[type.getCode()]) return ERR_TEXT_SIZE_MIN;

		if (type == Genre.Type.Name && langId < 0) {
			Log.d("ジャンル名の更新は認めない");
			return ERR_UNKNOWN;
		}

		int nRtn = ERR_UNKNOWN;

		if (langId < 0) {
			// get|generate genre id
			Genre genre = Genre.select(genreId);
			if (genre.genreId < 1) {
				Log.d("存在しないGenreを更新しようとした");
				return ERR_UNKNOWN;
			}

			genre.update(type, data);

		} else {
			if (!GenreTranslation.upsert(genreId, langId, type, data, userId)) {
				return ERR_UNKNOWN;
			}
		}

		nRtn = OK_EDIT;
		return nRtn;
	}
}
