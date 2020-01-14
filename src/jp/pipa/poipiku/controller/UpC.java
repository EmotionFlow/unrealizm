package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

public class UpC {
    protected static int GetSafeFilterDB(int publishId){
        int safe_filter = Common.SAFE_FILTER_ALL;
        switch(publishId) {
            case Common.PUBLISH_ID_R15:
                safe_filter = Common.SAFE_FILTER_R15;
                break;
            case Common.PUBLISH_ID_R18:
                safe_filter = Common.SAFE_FILTER_R18;
                break;
            case Common.PUBLISH_ID_R18G:
                safe_filter = Common.SAFE_FILTER_R18G;
                break;
        }
        return safe_filter;
    }

    protected static int GetTweetParamDB(boolean isTweetTxt, boolean isTweetImg){
        int ret = 0;
        if(isTweetTxt) ret += 1;
        if(isTweetImg) ret += 2;
        return ret;
    }

    protected static int GetOpenIdDB(Timestamp tsPublishStart){
        if(tsPublishStart.after(new Timestamp(System.currentTimeMillis()))){
            return 0;
        } else {
            return 3;
        }
    }

    protected void AddTags(String strDescription, String strTagList, int nContentId, Connection cConn, PreparedStatement cState) throws SQLException {
        // from description
        if (!strDescription.isEmpty()) {
            // hush tag
            InsertIntoTags(strDescription, Common.HUSH_TAG_PATTERN, 1, nContentId, cConn, cState);
            // my tag
            InsertIntoTags(strDescription, Common.MY_TAG_PATTERN, 3, nContentId, cConn, cState);
        }
        // from tag list
        if (!strTagList.isEmpty()) {
            // normal tag
            InsertIntoTags(strTagList, Common.NORMAL_TAG_PATTERN, 1, nContentId, cConn, cState);
        	// hush tag
            InsertIntoTags(strTagList, Common.HUSH_TAG_PATTERN, 1, nContentId, cConn, cState);
        	// my tag
            InsertIntoTags(strTagList, Common.MY_TAG_PATTERN, 3, nContentId, cConn, cState);
        }
    }

    private void InsertIntoTags(String tag_list, String match_pattern, int tag_type, int content_id, Connection cConn, PreparedStatement cState) throws SQLException{
        Pattern ptn = Pattern.compile(match_pattern, Pattern.MULTILINE);
        Matcher matcher = ptn.matcher(" "+tag_list.replaceAll("　", " ")+"\n");
        String strSql ="INSERT INTO tags_0000(tag_txt, content_id, tag_type) VALUES(?, ?, ?) ON CONFLICT DO NOTHING;";
        cState = cConn.prepareStatement(strSql);
        for (int nNum=0; matcher.find() && nNum<20; nNum++) {
            try {
                cState.setString(1,Common.SubStrNum(matcher.group(1), 64));
                cState.setInt(2, content_id);
                cState.setInt(3, tag_type);
                cState.executeUpdate();
            } catch(Exception e) {
                Log.d("tag duplicate:"+matcher.group(1));
            }
        }
        cState.close();cState=null;
    }
}
