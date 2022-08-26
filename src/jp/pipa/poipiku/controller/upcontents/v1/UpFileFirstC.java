package jp.pipa.poipiku.controller.upcontents.v1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;


import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.ByteArrayInputStream;

import jp.pipa.poipiku.WriteBackFile;
import jp.pipa.poipiku.util.DatabaseUtil;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.codec.binary.Base64;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.ImageUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.ServletContext;

public class UpFileFirstC extends UpC {
	protected ServletContext m_cServletContext = null;

	UpFileFirstC(ServletContext context){
		m_cServletContext = context;
	}

	public int GetResults(UploadFileFirstCParam cParam) {
		int nRtn = -1;
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
			cConn = DatabaseUtil.dataSource.getConnection();

			// check ext
			if(!cParam.m_bPasteUpload && cParam.item_file==null){
				//Log.d("multipart upload file item is null.");
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
			// この後の処理に時間がかかるので、一旦closeする。
			cConn.close();cConn=null;
			if(!bExist) {
				Log.d("content not exist error : cParam.m_nUserId="+ cParam.m_nUserId + ", cParam.m_nContentId="+cParam.m_nContentId);
				return nRtn;
			}

			// save file
			String uploadContentsPath = Common.getUploadContentsPath(cParam.m_nUserId);
			File cDir = new File(m_cServletContext.getRealPath(uploadContentsPath));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strRandom = RandomStringUtils.randomAlphanumeric(9);
			String strFileName = "";
			strFileName = String.format("%s/%09d_%s.%s", uploadContentsPath, cParam.m_nContentId, strRandom, ext);
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
				int[] size = ImageUtil.getImageSize(strRealFileName);
				nWidth = size[0];
				nHeight = size[1];
			} catch(Exception e) {
				Log.d("error getImageSize %s".formatted(strRealFileName));
				e.printStackTrace();
			}
			try {
				nFileSize = (new File(strRealFileName)).length();
			} catch(Exception e) {
				Log.d("error fileSize %s".formatted(strRealFileName));
				e.printStackTrace();
			}
			try {
				nComplexSize = ImageUtil.getConplex(strRealFileName);
			} catch(Exception e) {
				Log.d("error complexSize %s".formatted(strRealFileName));
				e.printStackTrace();
			}

			// ファイルサイズチェック
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			CacheUsers0000.User user = users.getUser(cParam.m_nUserId);

			cConn = DatabaseUtil.dataSource.getConnection();
			if(nFileSize> (long) Common.UPLOAD_FILE_TOTAL_SIZE[user.passportId] *1024*1024) {
				Log.d("UPLOAD_FILE_TOTAL_ERROR:"+nFileSize);
				strSql ="DELETE FROM contents_0000 WHERE user_id=? AND content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nContentId);
				cState.executeUpdate();
				cState.close();cState=null;
				cConn.close();cConn=null;
				Util.deleteFile(strRealFileName);
				return Common.UPLOAD_FILE_TOTAL_ERROR;
			}

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

			WriteBackFile writeBackFile = new WriteBackFile();
			writeBackFile.userId = cParam.m_nUserId;
			writeBackFile.tableCode = WriteBackFile.TableCode.Contents;
			writeBackFile.rowId = cContent.m_nContentId;
			writeBackFile.path = strFileName;
			if (!writeBackFile.insert()) {
				Log.d("writeBackFile.insert() error: " + cParam.m_nContentId);
			}

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
