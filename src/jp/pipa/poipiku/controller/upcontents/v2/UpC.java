package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class UpC {
	private static int _getOpenId(boolean bNotRecently){
		return bNotRecently ? 1 : 0;
	}
	protected static int GetOpenId(int nOpenIdPresent, int nPublishId, boolean bNotRecently,
		boolean bLimitedTimePublish, boolean bLimitedTimePublishPresent,
		Timestamp tsPublishStart, Timestamp tsPublishEnd,
		Timestamp tsPublishStartPresent, Timestamp tsPublishEndPresent){

		int nOpenId = 2;
		if(nPublishId == Common.PUBLISH_ID_HIDDEN){
			nOpenId = 2;
		} else if(bLimitedTimePublish){
			if(!bLimitedTimePublishPresent || tsPublishStartPresent==null || tsPublishEndPresent==null){
				nOpenId = 2;
			} else {
				if(tsPublishStart != null || tsPublishEnd != null){
					if(tsPublishStart.equals(tsPublishStartPresent) && tsPublishEnd.equals(tsPublishEndPresent)){
						nOpenId = nOpenIdPresent;   // 公開期間に変更がないのなら、今の公開状態を維持する。
					} else {
						nOpenId = 2; // 1分毎のcronに処理を任せるので、ひとまず非公開にしておく。
					}
				} else {
					nOpenId = _getOpenId(bNotRecently);
				}
			}
		} else {
			nOpenId = _getOpenId(bNotRecently);
		}
		return nOpenId;
	}

	protected void AddTags(String strDescription, String strTagList, int nContentId, Connection connection) throws SQLException {
		// from description
		if (!strDescription.isEmpty()) {
			// hush tag
			InsertIntoTags(strDescription, Common.HUSH_TAG_PATTERN, 1, nContentId, connection);
			// my tag
			InsertIntoTags(strDescription, Common.MY_TAG_PATTERN, 3, nContentId, connection);
		}
		// from tag list
		if (!strTagList.isEmpty()) {
			// normal tag
			InsertIntoTags(strTagList, Common.NORMAL_TAG_PATTERN, 1, nContentId, connection);
			// hush tag
			InsertIntoTags(strTagList, Common.HUSH_TAG_PATTERN, 1, nContentId, connection);
			// my tag
			InsertIntoTags(strTagList, Common.MY_TAG_PATTERN, 3, nContentId, connection);
		}
	}

	private void InsertIntoTags(String tag_list, String match_pattern, int tag_type, int content_id, Connection connection) throws SQLException{
		Pattern ptn = Pattern.compile(match_pattern, Pattern.MULTILINE);
		Matcher matcher = ptn.matcher(" "+tag_list.replaceAll("　", " ")+"\n");
		String strSql ="INSERT INTO genres(genre_name) VALUES(?) ON CONFLICT(genre_name) DO UPDATE SET content_num_total=genres.content_num_total+1 RETURNING genre_id;";
		PreparedStatement statement_genre = connection.prepareStatement(strSql);
		strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type, genre_id) VALUES(?, ?, ?, ?) ON CONFLICT DO NOTHING;";
		PreparedStatement statement_tag = connection.prepareStatement(strSql);
		ResultSet resultSet;
		for (int nNum=0; matcher.find() && nNum<20; nNum++) {
			try {
				// タグ文字列取得
				String tag = Common.SubStrNum(matcher.group(1), 64);
				int genre_id=-1;
				if(tag_type==1) {
					// ジャンルマスターテーブル更新
					statement_genre.setString(1, tag);
					resultSet = statement_genre.executeQuery();
					if(resultSet.next()) {
						genre_id = resultSet.getInt("genre_id");
					}
					resultSet.close();resultSet=null;
				}
				// タグリストテーブル登録
				statement_tag.setString(1, tag);
				statement_tag.setInt(2, content_id);
				statement_tag.setInt(3, tag_type);
				statement_tag.setInt(4, genre_id);
				statement_tag.executeUpdate();
			} catch(Exception e) {
				//e.printStackTrace();
				Log.d("tag duplicate:"+matcher.group(1));
			}
		}
		statement_genre.close();statement_genre=null;
		statement_tag.close();statement_tag=null;
	}
}
