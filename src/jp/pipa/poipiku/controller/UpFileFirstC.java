package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.sql.DataSource;


import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.ByteArrayInputStream;

import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.codec.binary.Base64;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.ImageUtil;
import jp.pipa.poipiku.util.Log;

import javax.servlet.ServletContext;

public class UpFileFirstC extends UpC{
	protected ServletContext m_cServletContext = null;

	UpFileFirstC(ServletContext context){
		m_cServletContext = context;
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
			byte[] imageBinary = null;
			BufferedImage cImage = null;
			if(cParam.m_bPasteUpload){
				imageBinary = Base64.decodeBase64(cParam.m_strEncodeImg.getBytes());
				if(imageBinary == null) return nRtn;
				if(imageBinary.length>1024*1024*20) return nRtn;
				cImage = ImageIO.read(new ByteArrayInputStream(imageBinary));
				if(cImage == null) return nRtn;
			}

			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// check ext
			if(!cParam.m_bPasteUpload && cParam.item_file==null){
				Log.d("multipart upload file item is null.");
				return nRtn;
			}

			String ext = null;
			if(!cParam.m_bPasteUpload){
				ext = ImageUtil.getExt(ImageIO.createImageInputStream(cParam.item_file.getInputStream()));
			} else {
				ext = ImageUtil.getExt(ImageIO.createImageInputStream(new ByteArrayInputStream(imageBinary)));
			}
			//Log.d("ext: " + ext);
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
			String strFileName = "";
			strFileName = String.format("%s/%09d_%s.%s", Common.getUploadUserPath(cParam.m_nUserId), cParam.m_nContentId, strRandom, ext);
			String strRealFileName = m_cServletContext.getRealPath(strFileName);

			if(!cParam.m_bPasteUpload){
				cParam.item_file.write(new File(strRealFileName));
			} else {
				ImageIO.write(cImage, "png", new File(strRealFileName));
			}
			ImageUtil.createThumbIllust(strRealFileName);

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
				-1,
				cContent.m_nPublishId,
				cParam.m_bNotRecently,
				cContent.m_bLimitedTimePublish,
				cContent.m_bLimitedTimePublish,
				cContent.m_timeUploadDate,
				cContent.m_timeEndDate,
				null,null);

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
