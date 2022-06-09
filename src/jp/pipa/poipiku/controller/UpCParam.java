package jp.pipa.poipiku.controller;

import java.lang.reflect.Field;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.SupportedLocales;
import jp.pipa.poipiku.UserLocale;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class UpCParam {
	public int m_nUserId = -1;
	public int m_nCategoryId = 0;
	public String m_strDescription = "";
	public String m_strTagList = "";
	public int m_nPublishId = 0;
	public int m_nPublishAllNum = 0;
	public String m_strPassword = "";
	public String m_strListId = "";
	public boolean m_bLimitedTimePublish = false;
	public Timestamp m_tsPublishStart = null;
	public Timestamp m_tsPublishEnd = null;
	public boolean m_bTweetTxt = false;
	public boolean m_bTweetImg = false;
	public boolean m_bTwitterCardThumbnail = false;
	public int m_nEditorId = Common.EDITOR_UPLOAD;
	public boolean m_bCheerNg = true;
	public int genre = -1;
	public int requestId = -1;
	public String privateNote = "";
	public HashMap<Integer, String> descriptionTranslations = new HashMap<>();

	protected void GetParams(HttpServletRequest request) throws Exception{
		request.setCharacterEncoding("UTF-8");
		m_nUserId			= Util.toInt(request.getParameter("UID"));
		m_nCategoryId		= Util.toIntN(request.getParameter("CAT"), 0, Common.CATEGORY_ID_MAX);
		m_strDescription	= Util.deleteInvalidChar(Common.TrimAll(request.getParameter("DES")));
		m_strTagList		= Util.deleteInvalidChar(Common.SubStrNum(Common.TrimAll(request.getParameter("TAG")), 100));
		m_nPublishId		= Util.toIntN(request.getParameter("PID"), 0, Common.PUBLISH_ID_MAX);
		if (m_nPublishId == Common.PUBLISH_ID_ALL || m_nPublishId == Common.PUBLISH_ID_HIDDEN) {
			m_nPublishAllNum = 0;
		} else {
			m_nPublishAllNum    = Util.toIntN(request.getParameter("PUBALL"), 0, 1);
		}
		m_strPassword		= Util.deleteInvalidChar(Common.SubStrNum(Common.TrimAll(request.getParameter("PPW")), 16));
		m_strListId			= Common.TrimAll(request.getParameter("PLD"));
		m_bLimitedTimePublish=Util.toBoolean(request.getParameter("LTP"));
		m_tsPublishStart	= Util.toSqlTimestamp(request.getParameter("PST"));
		m_tsPublishEnd		= Util.toSqlTimestamp(request.getParameter("PED"));
		m_strDescription	= m_strDescription.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
		if(m_strDescription.startsWith("#")) m_strDescription=" "+m_strDescription;
		m_strDescription    = Util.deleteInvalidChar(m_strDescription);
		m_strTagList		= m_strTagList.replace("＃", "#").replace("♯", "#").replace("\r\n", " ").replace("\r", " ").replace("　", " ");
		m_strTagList        = Util.deleteInvalidChar(m_strTagList);
		m_nEditorId			= Util.toIntN(request.getParameter("ED"), 0, Common.EDITOR_ID_MAX);
		m_bTweetTxt			= Util.toBoolean(request.getParameter("TWT"));
		m_bTweetImg			= Util.toBoolean(request.getParameter("TWI"));
		m_bTwitterCardThumbnail = Util.toBoolean(request.getParameter("TWCT"));
		m_bCheerNg			= Util.toInt(request.getParameter("CNG"))!=0;
		genre				= Util.toInt(request.getParameter("GD"));
		requestId           = Util.toInt(request.getParameter("RID"));
		privateNote         = Util.deleteInvalidChar(Common.TrimAll(request.getParameter("NOTE")));

		for (UserLocale userLocale: SupportedLocales.list) {
			String s = request.getParameter("DES" + userLocale.id);
			if (s != null) {
				descriptionTranslations.put(userLocale.id, s.trim());
			}
		}

		// format tag list
		if(!m_strTagList.isEmpty()) {
			ArrayList<String> listTag = new ArrayList<String>();
			String[] tags = m_strTagList.split(" ");
			for(String tag : tags) {
				tag = tag.trim();
				if(tag.isEmpty()) continue;
				if(!tag.startsWith("#")) {
					tag = "#"+tag;
				}
				listTag.add(tag);
			}
			m_strTagList = "";
			if(listTag.size()>0) {
				List<String> listTagUnique = new ArrayList<String>(new LinkedHashSet<String>(listTag));
				if(listTagUnique.size()>0) {
					m_strTagList = " " + String.join(" ", listTagUnique);
				}
			}
		}
	};

	protected int ErrorOccured(Exception e) {
		e.printStackTrace();
		m_nUserId = -1;
		return -99;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("Class: " + this.getClass().getCanonicalName() + "\n");
		sb.append("Settings:\n");
		if (this.getClass().getSuperclass() != null) {
			for (Field field : this.getClass().getSuperclass().getDeclaredFields()) {
				try {
					field.setAccessible(true);
					sb.append(field.getName() + " = " + field.get(this) + "\n");
				} catch (IllegalAccessException e) {
					sb.append(field.getName() + " = " + "access denied\n");
				}
			}
		}

		for (Field field : this.getClass().getDeclaredFields()) {
			try {
				field.setAccessible(true);
				sb.append(field.getName() + " = " + field.get(this) + "\n");
			} catch (IllegalAccessException e) {
				sb.append(field.getName() + " = " + "access denied\n");
			}
		}
		return sb.toString();
	}
};
