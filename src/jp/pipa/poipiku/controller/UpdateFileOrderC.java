package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.*;
import java.util.List;
import java.util.stream.Collectors;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

import org.codehaus.jackson.map.ObjectMapper;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

class EditedContent {
	public int appendId = 0;
	public int fileWidth = 0;
	public int fileHeight = 0;
	public long filesSize = 0;
	public String fileName = "";
	public Integer writeBackStatus = null;

	EditedContent(){}

	public void set(ResultSet resultSet) throws SQLException{
		appendId = resultSet.getInt("append_id");
		fileName = Util.toString(resultSet.getString("file_name"));
		fileWidth = resultSet.getInt("file_width");
		fileHeight = resultSet.getInt("file_height");
		filesSize = resultSet.getLong("file_size");
		writeBackStatus = resultSet.getInt("write_back_status");
		if (resultSet.wasNull()) {
			writeBackStatus = null;
		}
	}

	public int getAppendId() {
		return appendId;
	}

	public String toString(){
		return String.format("%d, %d, %d, %d, %s, %d",
				appendId, fileWidth, fileHeight, filesSize, fileName, writeBackStatus);
	}
}

public class UpdateFileOrderC extends Controller {
	public int userId = -1;
	public int contentId = 0;
	public int[] newIdList = null;
	public int firstNewId = 0;
	public String newIdsJson = null;
	public String userAgent = null;

	private ServletContext servletContext = null;

	public UpdateFileOrderC(ServletContext context){
		servletContext = context;
	}

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			userId = Util.toInt(request.getParameter("UID"));
			contentId = Util.toInt(request.getParameter("IID"));
			newIdsJson	= Common.TrimAll(request.getParameter("AID"));
			firstNewId = Util.toInt(request.getParameter("FirstNewID"));

			//並び換え、削除後のappend_idリスト
			ObjectMapper mapper = new ObjectMapper();
			newIdList = mapper.readValue(newIdsJson, int[].class);

			userAgent =request.getHeader("user-agent");
			if(newIdList.length > 0) {
				nRtn = 0;
			} else {
				Log.d("New filelist is empty.");
				nRtn = -3;
			}
		} catch(Exception e) {
			e.printStackTrace();
			userId = -1;
			nRtn = -99;
		}
		return nRtn;
	}

	public int GetResults(CheckLogin checkLogin, boolean isApp) {
		int nRtn = -1;
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
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				appendIds.add(0);
				fileNames.add(resultSet.getString("file_name"));
			}

			sql ="SELECT append_id, file_name FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				appendIds.add(resultSet.getInt("append_id"));
				fileNames.add(resultSet.getString("file_name"));
			}

			sql = "INSERT INTO contents_update_histories(class, user_id, content_id, params, ua, before_appends, before_files, app) VALUES(?, ?, ?, ?, ?, ?, ?, ?) RETURNING id";
			statement = connection.prepareStatement(sql);
			statement.setString(1, "UpdateFileOrderC");
			statement.setInt(2, userId);
			statement.setInt(3, contentId);
			statement.setString(4, "{firstNewId: " + firstNewId + ", newIdList: [" + newIdsJson + "]}");
			statement.setString(5, userAgent);
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
			// regist to DB
			connection = DatabaseUtil.dataSource.getConnection();

			//元のファイルリストを取得
			sql = "SELECT 0 as append_id, file_name, file_width, file_height, file_size, wbf.status write_back_status" +
					" FROM contents_0000 c" +
					" LEFT OUTER JOIN (select row_id, status from write_back_files where table_code=0) wbf ON c.content_id = wbf.row_id" +
					" WHERE c.user_id=? AND content_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, contentId);
			resultSet = statement.executeQuery();

			//元の画像情報をファイルリストにセット
			List<EditedContent> oldContentList = new ArrayList<>(newIdList.length);
			if (resultSet.next()) {
				EditedContent c = new EditedContent();
				c.set(resultSet);
				oldContentList.add(c);
			}

			sql = "SELECT append_id, file_name, file_width, file_height, file_size, wbf.status write_back_status" +
					" FROM contents_appends_0000 c" +
					"   LEFT OUTER JOIN (select row_id, status from write_back_files where table_code=1) wbf ON c.append_id = wbf.row_id" +
					" WHERE c.content_id=? ORDER BY append_id";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();

			//元の画像情報をファイルリストにセット
			while (resultSet.next()) {
				EditedContent c = new EditedContent();
				c.set(resultSet);
				oldContentList.add(c);
			}

			resultSet.close();resultSet=null;
			statement.close();statement=null;


			boolean isListUpdated = false;
			final List<Integer> oldIdList =
			oldContentList.stream()
					.map(EditedContent::getAppendId)
					.collect(Collectors.toList());
			Log.d("-------");

			if (oldIdList.size() != newIdList.length) {
				isListUpdated = true;
			} else {
				for (int i=0; i < oldIdList.size(); i++) {
					if (newIdList[i] != oldIdList.get(i)) {
						isListUpdated = true;
						break;
					}
				}
			}

			if (checkLogin != null && checkLogin.isStaff()) {
				printContentList(userId,"---oldList---", oldContentList);
			}

			//write_back_status = 1 (作業中)が見つかったら、少々待って、最初からやり直し。
			if (oldContentList
					.stream()
					.filter(e -> e.writeBackStatus != null)
					.anyMatch(e -> e.writeBackStatus == WriteBackFile.Status.Moving.getCode())
			){
				Log.d("write_back_status = 1 (作業中)が見つかった");
				errorKind = ErrorKind.DoRetry;
				return -1;
			}

			//画像情報を新ファイルリストにコピー
			boolean bExists = false;
			List<EditedContent> newContentList = new ArrayList<>(newIdList.length);
			for (int append_id: newIdList) {
				Optional<EditedContent> cntnt = oldContentList.stream().filter(e -> e.appendId == append_id).findFirst();
				if (cntnt.isPresent()) {
					bExists = true;
					EditedContent foundContent = cntnt.get();
					EditedContent c = new EditedContent();
					c.appendId = foundContent.appendId;
					c.fileName = foundContent.fileName;
					c.fileWidth = foundContent.fileWidth;
					c.fileHeight = foundContent.fileHeight;
					c.filesSize = foundContent.filesSize;
					c.writeBackStatus = foundContent.writeBackStatus;
					newContentList.add(c);
				}
			}

			//新リストのappend_idが元リストと1つもマッチしなかったら不正データなので終了
			if (!bExists) {
				Log.d("Unknown append_id.");
				return -3;
			}

			//新規にアップロードされたファイルを抽出
			List<EditedContent> diffNew = newContentList.stream().filter(cNew -> firstNewId > 0 && cNew.appendId >= firstNewId).collect(Collectors.toList());
			if (checkLogin != null && checkLogin.isStaff()) {
				printContentList(userId,"---diffNewList---", diffNew);
			}

			//元リストにあって新リストにないファイルを抽出（削除候補）
			List<EditedContent> diffOld = new ArrayList<>();
			for (EditedContent cOld: oldContentList) {
				boolean bExist = false;
				for (int append_id: newIdList) {
					if (cOld.appendId ==append_id) {
						bExist = true;
						break;
					}
				}
				if(!bExist) {
					diffOld.add(cOld);
				}
			}

			if (checkLogin != null && checkLogin.isStaff()) {
				printContentList(userId,"---delList---", diffOld);
			}

			// 先頭画像が削除対象かチェック
			boolean removeHeadFile = false;
			for (int i=0; i<diffOld.size(); i++) {
				if (diffOld.get(i).appendId == 0) {
					removeHeadFile = true;
					break;
				}
			}
			// ファイルサイズチェック
			if (diffNew.size() > 0) {
				int fileTotalSize = 0;
				if (!removeHeadFile) {
					// 先頭画像が削除対象でない場合は合計サイズに含める
					sql = "SELECT file_size FROM contents_0000 WHERE user_id=? AND content_id=?";
					statement = connection.prepareStatement(sql);
					statement.setInt(1, userId);
					statement.setInt(2, contentId);
					resultSet = statement.executeQuery();
					if (resultSet.next()) {
						fileTotalSize += resultSet.getInt("file_size");
					}
					resultSet.close();resultSet=null;
					statement.close();statement=null;
				}

				// appendsの合計サイズ計算 (削除対象のファイルは計算に含めない)
				sql = "SELECT SUM(file_size) FROM contents_appends_0000 WHERE content_id=?";
				for (int i=0; i<diffOld.size(); i++) {
					if (i == 0) {
						sql += " AND append_id NOT IN (";
					} else {
						sql += ",";
					}
					sql += "?";
					if (i == diffOld.size()-1) sql += ")";
				}
				statement = connection.prepareStatement(sql);
				statement.setInt(1, contentId);
				for (int i=0; i<diffOld.size(); i++) {
					statement.setInt(i+2, diffOld.get(i).appendId);
				}
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					fileTotalSize += resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;

				CacheUsers0000 users  = CacheUsers0000.getInstance();
				CacheUsers0000.User user = users.getUser(userId);
				if(fileTotalSize > Common.UPLOAD_FILE_TOTAL_SIZE[user.passportId]*1024*1024) {
					// サイズオーバーしていれば新規アップロードされた画像を削除
					Log.d("UPLOAD_FILE_TOTAL_ERROR:" + fileTotalSize);
					String inPhrase = "(";
					for (int i=0; i<diffNew.size(); i++) {
						if (i > 0) inPhrase += ",";
						inPhrase += "?";
					}
					inPhrase += ")";

					for (int i=0; i<diffNew.size(); i++) {
						EditedContent content = diffNew.get(i);
						if(servletContext != null && content.fileName !=null && !content.fileName.isEmpty()) {
							String strPath = servletContext.getRealPath(content.fileName);
							ImageUtil.deleteFiles(strPath);
						Log.d("Deleted " + diffNew.get(i).fileName + " (#" + diffNew.get(i).appendId + ")");
						}
					}
					sql = "DELETE FROM contents_appends_0000 WHERE content_id=? AND append_id IN " + inPhrase;
					statement = connection.prepareStatement(sql);
					statement.setInt(1, contentId);
					for (int i=0; i<diffNew.size(); i++) {
						statement.setInt(i+2, diffNew.get(i).appendId);
					}
					statement.executeUpdate();
					statement.close();statement=null;
					return Common.UPLOAD_FILE_TOTAL_ERROR;
				} else {
					// 上限サイズ内であればWriteBackFile書き込み
					for (int i=0; i<diffNew.size(); i++) {
						WriteBackFile writeBackFile = new WriteBackFile();
						writeBackFile.userId = userId;
						writeBackFile.tableCode = WriteBackFile.TableCode.ContentsAppends;
						writeBackFile.rowId = diffNew.get(i).appendId;
						writeBackFile.path = diffNew.get(i).fileName;
						if (!writeBackFile.insert()) {
							Log.d("writeBackFile.insert() error: " + diffNew.get(i).appendId);
						}
					}
				}
			}

			//不要ファイルの削除
			if (!diffOld.isEmpty()) {
				String[] strDelList = new String[diffOld.size()];
				for(int i=0; i<diffOld.size(); i++) {
					EditedContent content = diffOld.get(i);
					int append_id = content.appendId;
					strDelList[i] = Integer.toString(append_id);

					if(servletContext != null && content.fileName !=null && !content.fileName.isEmpty()) {
						String strPath = servletContext.getRealPath(content.fileName);
						ImageUtil.deleteFiles(strPath);
					}

					// 元リストからも削除
					oldContentList.removeIf(c -> c.appendId == append_id && append_id != 0);

					// write_back_filesにレコードがあったら削除
					if (content.writeBackStatus != null) {
						sql = "DELETE FROM write_back_files WHERE table_code=? AND path=?";
						statement = connection.prepareStatement(sql);
						statement.setInt(1,
								append_id == 0 ? WriteBackFile.TableCode.Contents.getCode() : WriteBackFile.TableCode.ContentsAppends.getCode());
						statement.setString(2, content.fileName);
						statement.executeUpdate();
						statement.close();statement=null;
					}
				}

				//不要レコード削除
				sql = "DELETE FROM contents_appends_0000 WHERE content_id=? AND append_id IN (" + String.join(",", strDelList) + ");";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, contentId);
				statement.executeUpdate();
				statement.close();statement=null;

				//先頭が削除されて1個ずつズレるケース
				if (removeHeadFile) {
					//余る要素の削除
					sql = "DELETE FROM contents_appends_0000 WHERE content_id=? AND append_id=?;";
					statement = connection.prepareStatement(sql);
					statement.setInt(1, contentId);
					statement.setInt(2, oldContentList.get(oldContentList.size() - 1).appendId);
					statement.executeUpdate();
					statement.close();statement=null;
				}
			}

			//append_idの振り直し
			int p = 0;
			for (int i=0; i<newContentList.size(); i++) {
				EditedContent cTmp = newContentList.get(i);
				if (i==0 && oldContentList.get(i).appendId != 0) {
					p = 1;	//先頭削除によりcontents_appendsのファイルを繰り上げるためのオフセット
				}
				if((i+p) < oldContentList.size()) {
					cTmp.appendId = oldContentList.get(i+p).appendId;
					newContentList.set(i, cTmp);
					//Log.d("New appendId:" + cTmp.append_id);
				}
			}

			if (checkLogin != null && checkLogin.isStaff()) {
				printContentList(userId,"---reSortedList---", newContentList);
			}

			////// update transaction ///////
			connection.setAutoCommit(false);

			//並び替え
			//先頭画像はcontents_0000にセット
			sql = "UPDATE contents_0000 SET file_name=?,file_width=?,file_height=?,file_size=? WHERE content_id=?;";
			statement = connection.prepareStatement(sql);
			statement.setString(1, newContentList.get(0).fileName);
			statement.setInt(2, newContentList.get(0).fileWidth);
			statement.setInt(3, newContentList.get(0).fileHeight);
			statement.setLong(4, newContentList.get(0).filesSize);
			statement.setInt(5, contentId);
			statement.executeUpdate();
			statement.close();statement=null;

			//2枚目以降はcontents_appends_0000にセット
			sql = "UPDATE contents_appends_0000 SET file_name=?,file_width=?,file_height=?,file_size=? WHERE content_id=? AND append_id=?";
			statement = connection.prepareStatement(sql);
			for (int i=1; i<newContentList.size(); i++) {
				statement.setString(1, newContentList.get(i).fileName);
				statement.setInt(2, newContentList.get(i).fileWidth);
				statement.setInt(3, newContentList.get(i).fileHeight);
				statement.setLong(4, newContentList.get(i).filesSize);
				statement.setInt(5, contentId);
				statement.setInt(6, newContentList.get(i).appendId);
				statement.executeUpdate();
			}
			statement.close();statement=null;

			sql = "UPDATE write_back_files SET table_code=?, row_id=?, updated_at=now() WHERE path=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, WriteBackFile.TableCode.Contents.getCode());
			statement.setInt(2, contentId);
			statement.setString(3, newContentList.get(0).fileName);
			statement.executeUpdate();

			sql = "UPDATE write_back_files SET table_code=?, row_id=?, updated_at=now() WHERE path=?";
			statement = connection.prepareStatement(sql);
			for (int i=1; i<newContentList.size(); i++) {
				statement.setInt(1, WriteBackFile.TableCode.ContentsAppends.getCode());
				statement.setInt(2, newContentList.get(i).appendId);
				statement.setString(3, newContentList.get(i).fileName);
				statement.executeUpdate();
			}
			statement.close();statement=null;

			//画像枚数の更新
			sql = "UPDATE contents_0000 SET file_num=(SELECT COUNT(*) FROM contents_appends_0000 WHERE content_id=?)+1";

			// ポイパスに加入していて、画像になんらかの変更があったら、updated_atも更新する
			if (checkLogin != null && checkLogin.m_nPassportId == Common.PASSPORT_ON && isListUpdated) {
				Log.d("update updated_at");
				sql += ", updated_at=now()";
			}

			sql += " WHERE content_id=?;";
			statement = connection.prepareStatement(sql);
			statement.setLong(1, contentId);
			statement.setInt(2, contentId);
			statement.executeUpdate();
			statement.close();statement=null;

			connection.commit();
			connection.setAutoCommit(true);
			////// update transaction ///////

			nRtn = 0;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.setAutoCommit(true);connection.close();connection=null;}}catch(Exception e){;}
		}

		// Update Log
		if (historyId > -1) {
			try {
				List<String> fileNames = new ArrayList<>();
				List<Integer> appendIds = new ArrayList<>();
				connection = DatabaseUtil.dataSource.getConnection();
				sql = "SELECT file_name FROM contents_0000 WHERE content_id=?";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, contentId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					appendIds.add(0);
					fileNames.add(resultSet.getString("file_name"));
				}

				sql ="SELECT append_id, file_name FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, contentId);
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

		return nRtn;
	}

	private void printContentList(int userId, String title, List<EditedContent> contentList) {
		Log.d(title + userId);
		contentList.stream()
				//.sorted(Comparator.comparingInt(EditedContent::getAppendId))
				.forEach(el -> Log.d(el.toString()));
	}
}
