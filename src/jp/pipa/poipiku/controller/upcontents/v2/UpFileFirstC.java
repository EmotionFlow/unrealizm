package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.WriteBackFile;
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

public class UpFileFirstC extends UpC {
	protected ServletContext m_cServletContext = null;

	UpFileFirstC(ServletContext context){
		m_cServletContext = context;
	}

	public int GetResults(UploadFileFirstCParam cParam) {
		int returnCode = -1;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		CContent content = null;

		try {
			byte[] imageBinary = null;
			BufferedImage cImage = null;
			if(cParam.isPasteUpload){
				imageBinary = Base64.decodeBase64(cParam.encodedImage.getBytes());
				if(imageBinary == null) return returnCode;
				if(imageBinary.length>1024*1024*20) return returnCode;
				cImage = ImageIO.read(new ByteArrayInputStream(imageBinary));
				if(cImage == null) return returnCode;
			}

			// regist to DB
			connection = DatabaseUtil.dataSource.getConnection();

			// check ext
			if(!cParam.isPasteUpload && cParam.fileItem ==null){
				//Log.d("multipart upload file item is null.");
				return returnCode;
			}

			String ext = null;
			if(!cParam.isPasteUpload){
				ext = ImageUtil.getExt(ImageIO.createImageInputStream(cParam.fileItem.getInputStream()));
			} else {
				ext = ImageUtil.getExt(ImageIO.createImageInputStream(new ByteArrayInputStream(imageBinary)));
			}
			//Log.d("ext: " + ext);
			if((!ext.equals("jpeg")) && (!ext.equals("jpg")) && (!ext.equals("gif")) && (!ext.equals("png"))) {
				Log.d("main item type error");
				String strFileName = String.format("/error_file/%d_%d.error", cParam.userId, cParam.contentId);
				String strRealFileName = m_cServletContext.getRealPath(strFileName);
				cParam.fileItem.write(new File(strRealFileName));
				return returnCode;
			}

			// 存在チェック
			boolean bExist = false;
			sql ="SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, cParam.userId);
			statement.setInt(2, cParam.contentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()){
				bExist = true;
				content = new CContent(resultSet);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			// この後の処理に時間がかかるので、一旦closeする。
			connection.close();connection=null;
			if(!bExist) {
				Log.d("content not exist error : cParam.m_nUserId="+ cParam.userId + ", cParam.m_nContentId="+cParam.contentId);
				return returnCode;
			}

			// save file
			final String uploadContentsPath = Common.getUploadContentsPath(cParam.userId);
			File cDir = new File(m_cServletContext.getRealPath(uploadContentsPath));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			final String strRandom = RandomStringUtils.randomAlphanumeric(9);
			final String strFileName = String.format("%s/%09d_%s.%s", uploadContentsPath, cParam.contentId, strRandom, ext);
			final String strRealFileName = m_cServletContext.getRealPath(strFileName);

			if(!cParam.isPasteUpload){
				cParam.fileItem.write(new File(strRealFileName));
			} else {
				ImageIO.write(cImage, "png", new File(strRealFileName));
			}
			ImageUtil.createThumbIllust(strRealFileName);

			// ファイルサイズ系情報
			FileSizeInfo fileSizeInfo = new FileSizeInfo();
			fileSizeInfo.set(strRealFileName);

			// ファイルサイズチェック
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			CacheUsers0000.User user = users.getUser(cParam.userId);

			connection = DatabaseUtil.dataSource.getConnection();
			if(fileSizeInfo.nFileSize> (long) Common.UPLOAD_FILE_TOTAL_SIZE[user.passportId] *1024*1024) {
				Log.d("UPLOAD_FILE_TOTAL_ERROR:"+fileSizeInfo.nFileSize);
				sql ="DELETE FROM contents_0000 WHERE user_id=? AND content_id=?";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, cParam.userId);
				statement.setInt(2, cParam.contentId);
				statement.executeUpdate();
				statement.close();statement=null;
				connection.close();connection=null;
				Util.deleteFile(strRealFileName);
				return Common.UPLOAD_FILE_TOTAL_ERROR;
			}

			// open_id更新
			int nOpenId = GetOpenId(
				-1,
				cParam.openId,
				cParam.isNotRecently,
				content.m_bLimitedTimePublish,
				content.m_bLimitedTimePublish,
				content.m_timeUploadDate,
				content.m_timeEndDate,
				null,null);

			// update making file_name
			sql ="UPDATE contents_0000 SET file_name=?, open_id=?, not_recently=?, file_width=?, file_height=?, file_size=?, file_complex=?, file_num=1 WHERE content_id=?";
			int idx=1;
			statement = connection.prepareStatement(sql);
			statement.setString(idx++, strFileName);
			statement.setInt(idx++, nOpenId);
			statement.setBoolean(idx++, cParam.isNotRecently);
			statement.setInt(idx++, fileSizeInfo.nWidth);
			statement.setInt(idx++, fileSizeInfo.nHeight);
			statement.setLong(idx++, fileSizeInfo.nFileSize);
			statement.setLong(idx++, fileSizeInfo.nComplexSize);
			statement.setInt(idx++, cParam.contentId);
			statement.executeUpdate();
			statement.close();statement=null;

			WriteBackFile writeBackFile = new WriteBackFile();
			writeBackFile.userId = cParam.userId;
			writeBackFile.tableCode = WriteBackFile.TableCode.Contents;
			writeBackFile.rowId = content.m_nContentId;
			writeBackFile.path = strFileName;
			if (!writeBackFile.insert()) {
				Log.d("writeBackFile.insert() error: " + cParam.contentId);
			}

			returnCode = cParam.contentId;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
			try{if(cParam.fileItem !=null){cParam.fileItem.delete();cParam.fileItem =null;}}catch(Exception e){;}
		}
		return returnCode;
	}
}
