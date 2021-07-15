package jp.pipa.poipiku.batch;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

//日時, ユーザID, 変更後openid, 変更前コンテンツID, 変更後コンテンツID, ツイート成功/失敗
public class LimitedTimePublishLog {
	public LocalDateTime m_datetime;
	public Integer m_nUserId = 0;
	public Integer m_nOpenId = 0;
	public Integer m_nOldContentId = 0;
	public Integer m_nNewContentId = 0;
	public Integer m_nTweetResult = 0; // 0:ツイートなし, 1:ツイートあり、正常, <0:ツイートあり、異常発生
	public LimitedTimePublishLog(){};
	public LimitedTimePublishLog(LocalDateTime dt, int uid, int oid, int old_cid, int new_cid, int tw_res){
		m_datetime = dt;
		m_nUserId = uid;
		m_nOpenId = oid;
		m_nOldContentId = old_cid;
		m_nNewContentId = new_cid;
		m_nTweetResult = tw_res;
	}
	public String toString(){
		return String.format("%s,%d,%d,%d,%d,%d",
				m_datetime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")),
				m_nUserId==null?-1:m_nUserId,
				m_nOpenId==null?-1:m_nOpenId,
				m_nOldContentId==null?-1:m_nOldContentId,
				m_nNewContentId==null?-1:m_nNewContentId,
				m_nTweetResult
		);
	}
}
