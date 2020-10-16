package jp.pipa.poipiku.controller;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;

import jp.pipa.poipiku.Common;

import javax.servlet.http.HttpServletRequest;

public class UpCParam {
	public int m_nUserId = -1;
	public int m_nCategoryId = 0;
	public String m_strDescription = "";
	public String m_strTagList = "";
	public int m_nPublishId = 0;
	public String m_strPassword = "";
	public String m_strListId = "";
	public boolean m_bLimitedTimePublish = false;
	public Timestamp m_tsPublishStart = null;
	public Timestamp m_tsPublishEnd = null;
	public boolean m_bTweetTxt = false;
	public boolean m_bTweetImg = false;
	public int m_nEditorId = Common.EDITOR_UPLOAD;
	public boolean m_bCheerNg = true;

	protected void GetParams(HttpServletRequest request) throws Exception{
		request.setCharacterEncoding("UTF-8");
		m_nUserId			= Common.ToInt(request.getParameter("UID"));
		m_nCategoryId		= Common.ToIntN(request.getParameter("CAT"), 0, Common.CATEGORY_ID_MAX);
		m_strDescription	= Common.TrimAll(request.getParameter("DES"));
		m_strTagList		= Common.SubStrNum(Common.TrimAll(request.getParameter("TAG")), 100);
		m_nPublishId		= Common.ToIntN(request.getParameter("PID"), 0, Common.PUBLISH_ID_MAX);
		m_strPassword		= Common.SubStrNum(Common.TrimAll(request.getParameter("PPW")), 16);
		m_strListId			= Common.TrimAll(request.getParameter("PLD"));
		m_bLimitedTimePublish=Common.ToBoolean(request.getParameter("LTP"));
		m_tsPublishStart	= Common.ToSqlTimestamp(request.getParameter("PST"));
		m_tsPublishEnd		= Common.ToSqlTimestamp(request.getParameter("PED"));
		m_strDescription	= m_strDescription.replace("＃", "#").replace("♯", "#").replace("\r\n", "\n").replace("\r", "\n");
		if(m_strDescription.startsWith("#")) m_strDescription=" "+m_strDescription;
		m_strTagList		= m_strTagList.replace("＃", "#").replace("♯", "#").replace("\r\n", " ").replace("\r", " ").replace("　", " ");
		m_nEditorId			= Common.ToIntN(request.getParameter("ED"), 0, Common.EDITOR_ID_MAX);
		m_bTweetTxt			= Common.ToBoolean(request.getParameter("TWT"));
		m_bTweetImg			= Common.ToBoolean(request.getParameter("TWI"));
		m_bCheerNg			= Common.ToInt(request.getParameter("CNG"))!=0;

		// format tag list
		if(!m_strTagList.isEmpty()) {
			ArrayList<String> listTag = new ArrayList<String>();
			String tags[] = m_strTagList.split(" ");
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

};
