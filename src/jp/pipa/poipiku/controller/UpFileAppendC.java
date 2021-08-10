package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.ImageUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.RandomStringUtils;

import javax.imageio.ImageIO;
import javax.servlet.ServletContext;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UpFileAppendC extends UpC{
	protected ServletContext m_cServletContext = null;

	UpFileAppendC(ServletContext context){
		m_cServletContext = context;
	}

	public int GetResults(UploadFileAppendCParam cParam, ResourceBundleControl _TEX) {
		//Log.d("START UploadFileAppendC");
		int nRtn = -1;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";


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
			int fileTotalSize = 0;
			boolean bExist = false;
			strSql ="SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				fileTotalSize += cResSet.getInt(1);
				bExist = true;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!bExist) return nRtn;

			// get comment id
			int nAppendId = -1;
			strSql ="INSERT INTO contents_appends_0000(content_id) VALUES(?) RETURNING append_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nAppendId = cResSet.getInt("append_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			// この後の処理に時間がかかるので、一旦closeする。
			cConn.close();cConn=null;

			//Log.d("UploadFileAppendC:"+nAppendId);

			// save file
			File cDir = new File(m_cServletContext.getRealPath(Common.getUploadContentsPath(cParam.m_nUserId)));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strRandom = RandomStringUtils.randomAlphanumeric(9);
			String strFileName = String.format("%s/%09d_%09d_%s.%s", Common.getUploadContentsPath(cParam.m_nUserId), cParam.m_nContentId, nAppendId, strRandom, ext);
			String strRealFileName = m_cServletContext.getRealPath(strFileName);

			if(!cParam.m_bPasteUpload){
				cParam.item_file.write(new File(strRealFileName));
			} else {
				ImageIO.write(cImage, "png", new File(strRealFileName));
			}
			ImageUtil.createThumbIllust(strRealFileName);
			//Log.d("UploadFileAppendC:"+strRealFileName);

			// ファイルサイズ系情報
			int nWidth = 0;
			int nHeight = 0;
			long nFileSize = 0;
			long nComplexSize = 0;
			try {
				int[] size = ImageUtil.getImageSize(strRealFileName);
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

			// update file name
			cConn = DatabaseUtil.dataSource.getConnection();
			strSql ="UPDATE contents_appends_0000 SET file_name=?, file_width=?, file_height=?, file_size=?, file_complex=? WHERE append_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strFileName);
			cState.setInt(2, nWidth);
			cState.setInt(3, nHeight);
			cState.setLong(4, nFileSize);
			cState.setLong(5, nComplexSize);
			cState.setInt(6, nAppendId);
			cState.executeUpdate();
			cState.close();cState=null;

			// ファイルサイズチェック
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			CacheUsers0000.User user = users.getUser(cParam.m_nUserId);
			// 2枚目以降
			strSql ="SELECT SUM(file_size) FROM contents_appends_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				fileTotalSize += cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(fileTotalSize>Common.UPLOAD_FILE_TOTAL_SIZE[user.passportId]*1024*1024) {
				Log.d("UPLOAD_FILE_TOTAL_ERROR:"+fileTotalSize);
				strSql ="DELETE FROM contents_appends_0000 WHERE append_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, nAppendId);
				cState.executeUpdate();
				cState.close();cState=null;
				cConn.close();cConn=null;
				Util.deleteFile(strRealFileName);
				return Common.UPLOAD_FILE_TOTAL_ERROR;
			}

			// update file num
			strSql ="UPDATE contents_0000 SET file_num=file_num+1 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			WriteBackFile writeBackFile = new WriteBackFile();
			writeBackFile.userId = cParam.m_nUserId;
			writeBackFile.tableCode = WriteBackFile.TableCode.ContentsAppends;
			writeBackFile.rowId = nAppendId;
			writeBackFile.path = strFileName;
			if (!writeBackFile.insert()) {
				Log.d("writeBackFile.insert() error: " + cParam.m_nContentId);
			}

			nRtn = nAppendId;
			//Log.d("END UploadFileAppendC");
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
