package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.ResourceBundleControl;
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
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class UpFileAppendC extends UpC {
	protected ServletContext servletContext = null;

	UpFileAppendC(ServletContext context){
		servletContext = context;
	}

	public int GetResults(UploadFileAppendCParam cParam, ResourceBundleControl _TEX, boolean calcSize, boolean isApp) {
		//Log.d("START UploadFileAppendC");
		int returnCode = -1;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int historyId = -1;

		// Insert Log
		try {
			List<String> fileNames = new ArrayList<>();
			List<Integer> appendIds = new ArrayList<>();
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT file_name FROM contents_0000 WHERE content_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, cParam.contentId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				appendIds.add(0);
				fileNames.add(resultSet.getString("file_name"));
			}

			sql = "SELECT append_id, file_name FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, cParam.contentId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				appendIds.add(resultSet.getInt("append_id"));
				fileNames.add(resultSet.getString("file_name"));
			}

			sql = "INSERT INTO contents_update_histories(class, user_id, content_id, params, ua, before_appends, before_files, app) VALUES(?, ?, ?, ?, ?, ?, ?, ?) RETURNING id";
			statement = connection.prepareStatement(sql);
			statement.setString(1, "UpFileAppendC");
			statement.setInt(2, cParam.userId);
			statement.setInt(3, cParam.contentId);
			statement.setString(4, null);
			statement.setString(5, cParam.userAgent);
			statement.setString(6, appendIds.stream().map(id -> id.toString()).collect(Collectors.joining(",")));
			statement.setString(7, fileNames.stream().collect(Collectors.joining(",")));
			statement.setBoolean(8, isApp);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				historyId = resultSet.getInt("id");
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

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
				String strRealFileName = servletContext.getRealPath(strFileName);
				cParam.fileItem.write(new File(strRealFileName));
				return returnCode;
			}

			// 存在チェック
			int fileTotalSize = 0;
			boolean bExist = false;
			sql ="SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, cParam.userId);
			statement.setInt(2, cParam.contentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				fileTotalSize += resultSet.getInt("file_size");
				bExist = true;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(!bExist) return returnCode;

			// get comment id
			int nAppendId = -1;
			sql ="INSERT INTO contents_appends_0000(content_id) VALUES(?) RETURNING append_id";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, cParam.contentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				nAppendId = resultSet.getInt("append_id");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			// この後の処理に時間がかかるので、一旦closeする。
			connection.close();connection=null;

			//Log.d("UploadFileAppendC:"+nAppendId);

			// save file
			File cDir = new File(servletContext.getRealPath(Common.getUploadContentsPath(cParam.userId)));
			if(!cDir.exists()) {
				cDir.mkdirs();
			}
			String strRandom = RandomStringUtils.randomAlphanumeric(9);
			String strFileName = String.format("%s/%09d_%09d_%s.%s", Common.getUploadContentsPath(cParam.userId), cParam.contentId, nAppendId, strRandom, ext);
			String strRealFileName = servletContext.getRealPath(strFileName);

			if(!cParam.isPasteUpload){
				cParam.fileItem.write(new File(strRealFileName));
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

			// update file name
			connection = DatabaseUtil.dataSource.getConnection();
			sql ="UPDATE contents_appends_0000 SET file_name=?, file_width=?, file_height=?, file_size=?, file_complex=? WHERE append_id=?";
			statement = connection.prepareStatement(sql);
			statement.setString(1, strFileName);
			statement.setInt(2, nWidth);
			statement.setInt(3, nHeight);
			statement.setLong(4, nFileSize);
			statement.setLong(5, nComplexSize);
			statement.setInt(6, nAppendId);
			statement.executeUpdate();
			statement.close();statement=null;

			// ファイルサイズチェック
			if (calcSize) {
				CacheUsers0000 users  = CacheUsers0000.getInstance();
				CacheUsers0000.User user = users.getUser(cParam.userId);

				// 1枚目は存在チェック時に加算済み
				// 2枚目以降
				sql ="SELECT SUM(file_size) FROM contents_appends_0000 WHERE content_id=?";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, cParam.contentId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					fileTotalSize += resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				if(fileTotalSize>Common.UPLOAD_FILE_TOTAL_SIZE[user.passportId]*1024*1024) {
					Log.d("UPLOAD_FILE_TOTAL_ERROR:"+fileTotalSize);
					sql ="DELETE FROM contents_appends_0000 WHERE append_id=?";
					statement = connection.prepareStatement(sql);
					statement.setInt(1, nAppendId);
					statement.executeUpdate();
					statement.close();statement=null;
					connection.close();connection=null;
					Util.deleteFile(strRealFileName);
					return Common.UPLOAD_FILE_TOTAL_ERROR;
				}

				// update file num
				sql ="UPDATE contents_0000 SET file_num=file_num+1 WHERE content_id=?";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, cParam.contentId);
				statement.executeUpdate();
				statement.close();statement=null;

				if (user.passportId == Common.PASSPORT_ON) {
					statement = connection.prepareStatement("UPDATE contents_0000 SET updated_at=now() WHERE content_id=?");
					statement.setInt(1, cParam.contentId);
					statement.executeUpdate();
					Log.d("update updated_at");
				}

				WriteBackFile writeBackFile = new WriteBackFile();
				writeBackFile.userId = cParam.userId;
				writeBackFile.tableCode = WriteBackFile.TableCode.ContentsAppends;
				writeBackFile.rowId = nAppendId;
				writeBackFile.path = strFileName;
				if (!writeBackFile.insert()) {
					Log.d("writeBackFile.insert() error: " + nAppendId);
				}
			}

			returnCode = nAppendId;
			//Log.d("END UploadFileAppendC");
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
			try{if(cParam.fileItem !=null){cParam.fileItem.delete();cParam.fileItem =null;}}catch(Exception e){;}
		}

		// Update Log
		if (historyId > -1) {
			try {
				List<String> fileNames = new ArrayList<>();
				List<Integer> appendIds = new ArrayList<>();
				connection = DatabaseUtil.dataSource.getConnection();
				sql = "SELECT file_name FROM contents_0000 WHERE content_id=?";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, cParam.contentId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					appendIds.add(0);
					fileNames.add(resultSet.getString("file_name"));
				}

				sql ="SELECT append_id, file_name FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, cParam.contentId);
				resultSet = statement.executeQuery();
				while (resultSet.next()) {
					appendIds.add(resultSet.getInt("append_id"));
					fileNames.add(resultSet.getString("file_name"));
				}

				sql = "UPDATE contents_update_histories SET after_appends=?, after_files=?, duplicated=?, updated_at=now() WHERE id=?";
				statement = connection.prepareStatement(sql);
				statement.setString(1, appendIds.stream().map(id -> id.toString()).collect(Collectors.joining(",")));
				statement.setString(2, fileNames.stream().collect(Collectors.joining(",")));
				statement.setBoolean(3, fileNames.size() != fileNames.stream().distinct().count());
				statement.setInt(4, historyId);
				statement.executeUpdate();
			} catch(Exception e) {
				Log.d(sql);
				e.printStackTrace();
			} finally {
				try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
				try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
				try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
			}
		}

		return returnCode;
	}
}
