package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.*;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

import org.codehaus.jackson.map.ObjectMapper;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

class EditedContent {
	public int appendId = 0;
	public int fileWidth = 0;
	public int fileHeight = 0;
	public long filesSize = 0;
	public long fileComplex = 0;
	public String fileName = "";
	public Integer writeBackStatus = null;

	EditedContent(){}

	public void set(ResultSet resultSet) throws SQLException{
		appendId = resultSet.getInt("append_id");
		fileName = Util.toString(resultSet.getString("file_name"));
		fileWidth = resultSet.getInt("file_width");
		fileHeight = resultSet.getInt("file_height");
		filesSize = resultSet.getLong("file_size");
		fileComplex = resultSet.getLong("file_complex");
		writeBackStatus = resultSet.getInt("write_back_status");
		if (resultSet.wasNull()) {
			writeBackStatus = null;
		}
	}

	public int getAppendId() {
		return appendId;
	}

	public String toString(){
		return String.format("%d, %d, %d, %d, %d, %s, %d",
				appendId, fileWidth, fileHeight, filesSize, fileComplex, fileName, writeBackStatus);
	}
}

public class UpdateFileOrderC extends Controller {
	public int userId = -1;
	public int contentId = 0;
	public int[] newIdList = null;

	private ServletContext servletContext = null;

	public UpdateFileOrderC(ServletContext context){
		servletContext = context;
	}

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			userId = Util.toInt(request.getParameter("UID"));
			contentId = Util.toInt(request.getParameter("IID"));
			String strJson	= Common.TrimAll(request.getParameter("AID"));

			//並び換え、削除後のappend_idリスト
			ObjectMapper mapper = new ObjectMapper();
			newIdList = mapper.readValue(strJson, int[].class);
			//Log.d("m_nUserId:" + m_nUserId);
			//Log.d("m_nContentId:" + m_nContentId);
			//Log.d(strJson);

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

	public int GetResults(CheckLogin checkLogin) {
		int nRtn = -1;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			// regist to DB
			connection = DatabaseUtil.dataSource.getConnection();

			//元のファイルリストを取得
			sql = "SELECT 0 as append_id, file_name, file_width, file_height, file_size, file_complex, wbf.status write_back_status" +
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

			sql = "SELECT append_id, file_name, file_width, file_height, file_size, file_complex, wbf.status write_back_status" +
					" FROM contents_appends_0000 c" +
					"   LEFT OUTER JOIN (select row_id, status from write_back_files where table_code=1) wbf ON c.append_id = wbf.row_id" +
					" WHERE c.content_id=?";
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

//			printContentList("---oldList---", oldContentList);

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
					c.fileComplex = foundContent.fileComplex;
					c.writeBackStatus = foundContent.writeBackStatus;
					newContentList.add(c);
				}
			}

			//新リストのappend_idが元リストと1つもマッチしなかったら不正データなので終了
			if (!bExists) {
				Log.d("Unknown append_id.");
				return -3;
			}

			//元リストにあって新リストにないファイルを抽出（削除候補）
			List<EditedContent> cDiff = new ArrayList<>();
			for (EditedContent cOld: oldContentList) {
				boolean bExist = false;
				for (int append_id: newIdList) {
					if (cOld.appendId ==append_id) {
						bExist = true;
						break;
					}
				}
				if(!bExist) {
					cDiff.add(cOld);
				}
			}

//			printContentList("---delList---", cDiff);

			//不要ファイルの削除
			boolean removeHeadFile = false;
			if (!cDiff.isEmpty()) {
				String[] strDelList = new String[cDiff.size()];
				for(int i=0; i<cDiff.size(); i++) {
					EditedContent content = cDiff.get(i);
					int append_id = content.appendId;
					strDelList[i] = Integer.toString(append_id);

					if(servletContext != null && content.fileName !=null && !content.fileName.isEmpty()) {
						String strPath = servletContext.getRealPath(content.fileName);
						ImageUtil.deleteFiles(strPath);
					}

					// 元リストからも削除
					oldContentList.removeIf(c -> c.appendId == append_id && append_id != 0);

					// 先頭画像の削除有無
					if (append_id == 0) removeHeadFile = true;

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

//			printContentList("---newList---", newContentList);

			////// update transaction ///////
			connection.setAutoCommit(false);

			//並び替え
			//先頭画像はcontents_0000にセット
			sql = "UPDATE contents_0000 SET file_name=?,file_width=?,file_height=?,file_size=?,file_complex=? WHERE content_id=?;";
			statement = connection.prepareStatement(sql);
			statement.setString(1, newContentList.get(0).fileName);
			statement.setInt(2, newContentList.get(0).fileWidth);
			statement.setInt(3, newContentList.get(0).fileHeight);
			statement.setLong(4, newContentList.get(0).filesSize);
			statement.setLong(5, newContentList.get(0).fileComplex);
			statement.setInt(6, contentId);
			statement.executeUpdate();
			statement.close();statement=null;

			//2枚目以降はcontents_appends_0000にセット
			sql = "UPDATE contents_appends_0000 SET file_name=?,file_width=?,file_height=?,file_size=?,file_complex=? WHERE content_id=? AND append_id=?";
			statement = connection.prepareStatement(sql);
			for (int i=1; i<newContentList.size(); i++) {
				statement.setString(1, newContentList.get(i).fileName);
				statement.setInt(2, newContentList.get(i).fileWidth);
				statement.setInt(3, newContentList.get(i).fileHeight);
				statement.setLong(4, newContentList.get(i).filesSize);
				statement.setLong(5, newContentList.get(i).fileComplex);
				statement.setInt(6, contentId);
				statement.setInt(7, newContentList.get(i).appendId);
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
			sql = "UPDATE contents_0000 SET file_num=(SELECT COUNT(*) FROM contents_appends_0000 WHERE content_id=?)+1 WHERE content_id=?;";
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
		return nRtn;
	}

	private void printContentList(String title, List<EditedContent> newContentList) {
		System.out.println(title);
		newContentList.stream()
				.sorted(Comparator.comparingInt(EditedContent::getAppendId))
				.forEach(System.out::println);
	}
}
