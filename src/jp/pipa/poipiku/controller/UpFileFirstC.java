package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import java.sql.Timestamp;
import java.util.LinkedHashSet;
import java.util.List;

import java.nio.file.Files;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.commons.lang3.RandomStringUtils;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.ImageUtil;
import jp.pipa.poipiku.util.Log;

import javax.servlet.ServletContext;

public class UpFileFirstC {
	protected ServletContext m_cServletContext = null;

	UpFileFirstC(ServletContext context){
		m_cServletContext = context;
	}

	private static int _getOpenId(boolean bNotRecently){
        return bNotRecently ? 1 : 0;
    }

	protected static int GetOpenId(int nPublishId, boolean bNotRecently, boolean bLimitedTimePublish, Timestamp tsPublishStart, Timestamp tsPublishEnd){
        int nOpenId = 2;
        Timestamp tsNow = new Timestamp(System.currentTimeMillis());
        if(nPublishId == Common.PUBLISH_ID_HIDDEN){
            nOpenId = 2;
        } else if(bLimitedTimePublish){
            if(tsPublishStart!=null && tsPublishEnd!=null){
                if(tsPublishStart.before(tsNow) && tsPublishEnd.after(tsNow)){
                    nOpenId = _getOpenId(bNotRecently);
                } else {
                    nOpenId = 2;
                }
            } else if(tsPublishStart!=null && tsPublishEnd==null){
                if(tsPublishStart.before(tsNow)){
                    nOpenId = _getOpenId(bNotRecently);
                } else {
                    nOpenId = 2;
                }
            } else if(tsPublishStart==null && tsPublishEnd!=null){
                if(tsPublishEnd.after(tsNow)){
                    nOpenId = _getOpenId(bNotRecently);
                } else {
                    nOpenId = 2;
                }
            } else {
                nOpenId = _getOpenId(bNotRecently);
            }
        } else {
            nOpenId = _getOpenId(bNotRecently);
        }
        return nOpenId;
    }

	public int GetResults(UploadFileFirstCParam cParam) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		CContent cContent = null;

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// check ext
			if(cParam.item_file==null) return nRtn;
			String ext = ImageUtil.getExt(ImageIO.createImageInputStream(cParam.item_file.getInputStream()));
			if((!ext.equals("jpeg")) && (!ext.equals("jpg")) && (!ext.equals("gif")) && (!ext.equals("png"))) {
				Log.d("main item type error");
				String strFileName = String.format("/error_file/%d_%d.error", cParam.m_nUserId, cParam.m_nContentId);
				String strRealFileName = m_cServletContext.getRealPath(strFileName);
				cParam.item_file.write(new File(strRealFileName));
				return nRtn;
			}

			// 存在チェック
			boolean bExist = false;
			strSql ="SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()){
				bExist = true;
				cContent = new CContent(cResSet);
			}

			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!bExist) {
				Log.d("content not exist error : cParam.m_nUserId="+ cParam.m_nUserId + ", cParam.m_nContentId="+cParam.m_nContentId);
				return nRtn;
			}

			// save file
			File cDir = new File(m_cServletContext.getRealPath(Common.getUploadUserPath(cParam.m_nUserId)));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strRandom = RandomStringUtils.randomAlphanumeric(9);
			String strFileName = String.format("%s/%09d_%s.%s", Common.getUploadUserPath(cParam.m_nUserId), cParam.m_nContentId, strRandom, ext);
			String strRealFileName = m_cServletContext.getRealPath(strFileName);
			cParam.item_file.write(new File(strRealFileName));
			ImageUtil.createThumbIllust(strRealFileName);
			Log.d(strFileName);

			// ファイルサイズ系情報
			int nWidth = 0;
			int nHeight = 0;
			long nFileSize = 0;
			long nComplexSize = 0;
			try {
				int size[] = ImageUtil.getImageSize(strRealFileName);
				nWidth = size[0];
				nHeight = size[1];
				nFileSize = (new File(strRealFileName)).length();
				nComplexSize = ImageUtil.getConplex(strRealFileName);
			} catch(Exception e) {
				nWidth = 0;
				nHeight = 0;
				nFileSize = 0;
				nComplexSize=0;
				Log.d("error getImageSize");
			}
			//Log.d(String.format("nWidth=%d, nHeight=%d, nFileSize=%d, nComplexSize=%d", nWidth, nHeight, nFileSize, nComplexSize));

			// open_id更新
			int nOpenId = GetOpenId(
				cContent.m_nPublishId,
				cParam.m_bNotRecently,
				cContent.m_bLimitedTimePublish,
				cContent.m_timeUploadDate,
				cContent.m_timeEndDate);

			// update making file_name
			strSql ="UPDATE contents_0000 SET file_name=?, open_id=?, not_recently=?, file_width=?, file_height=?, file_size=?, file_complex=?, file_num=1 WHERE content_id=?";
			int idx=1;
			cState = cConn.prepareStatement(strSql);
			cState.setString(idx++, strFileName);
			cState.setInt(idx++, nOpenId);
			cState.setBoolean(idx++, cParam.m_bNotRecently);
			cState.setInt(idx++, nWidth);
			cState.setInt(idx++, nHeight);
			cState.setLong(idx++, nFileSize);
			cState.setLong(idx++, nComplexSize);
			cState.setInt(idx++, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			nRtn = cParam.m_nContentId;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
			try{if(cParam.item_file!=null){cParam.item_file.delete();cParam.item_file=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}
