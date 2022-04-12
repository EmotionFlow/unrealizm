package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

public class EditGenreInfoC {
	public int genreId = -1;
	public int userId = -1;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("ID"));
			genreId = Util.toInt(request.getParameter("GD"));
		} catch(Exception e) {
			e.printStackTrace();
		}
	}


	public Genre genre;
	public List<GenreTranslation> translationList;
	public boolean getResults(final CheckLogin checkLogin) {
		if(genreId < 0) {
			return false;
		}
		if(checkLogin.m_bLogin && (userId != checkLogin.m_nUserId)){
			Log.d("ログインしているのにUserIdが異なる");
			return false;
		}
		genre = Genre.select(genreId);
		translationList = GenreTranslation.select(genreId);
		return true;
	}

}
