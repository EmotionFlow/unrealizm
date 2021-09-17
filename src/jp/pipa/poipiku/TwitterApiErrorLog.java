package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import javax.xml.crypto.Data;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public final class TwitterApiErrorLog extends Model{
    public int userId = -1;
    public long twitterUserid = -1;
    public long targetTwitterUserid = -1;
    public long listId = -1;
    public String callMethod = "";
    public String accessToken = "";
    public int statusCode;
    public int errorCode = -1;
    public String errorMessage = "";
    public Timestamp created_at;

    public TwitterApiErrorLog(){};

    public TwitterApiErrorLog(ResultSet resultSet) throws SQLException{
        userId = resultSet.getInt("user_id");
        twitterUserid = resultSet.getLong("twitter_user_id");
        targetTwitterUserid = resultSet.getLong("target_twitter_user_id");
        listId = resultSet.getLong("list_id");
        callMethod = resultSet.getString("call_method");
        accessToken = resultSet.getString("access_token");
        statusCode = resultSet.getInt("status_code");
        errorCode = resultSet.getInt("error_code");
        errorMessage = resultSet.getString("error_message");
        created_at = resultSet.getTimestamp("created_at");
    }

    public int insert() {
        Connection connection = null;
        PreparedStatement statement = null;
        String sql = "";
        int result = 0;
        try{
            connection = DatabaseUtil.dataSource.getConnection();

            sql = "INSERT INTO public.twitter_api_error_logs(" +
                    " user_id, twitter_user_id, target_twitter_user_id, list_id, call_method, access_token, status_code, error_code, error_message)" +
                    " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            statement = connection.prepareStatement(sql);
            int idx=1;
            statement.setInt(idx++, userId);                // user_id
            statement.setLong(idx++, twitterUserid);        // twitter_user_id
            statement.setLong(idx++, targetTwitterUserid);  // target_twitter_user_id
            statement.setLong(idx++, listId);               // list_id
            statement.setString(idx++, callMethod);         // call_method
            statement.setString(idx++, accessToken);        // access_token
            statement.setInt(idx++, statusCode);            // status_code
            statement.setInt(idx++, errorCode);             // error_code
            statement.setString(idx++, errorMessage);       // error_message
            statement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            result = -1;
        } finally {
            try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
            try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
        }
        return result;
    }

    static public List<TwitterApiErrorLog> selectListErrors(int userId, long listId, int secAgo) {
        List<TwitterApiErrorLog> logs = selectByUserId(userId, secAgo);
        return logs.stream().filter(e -> e.listId==listId).collect(Collectors.toList());
    }

    static public List<TwitterApiErrorLog> selectByUserId(int userId, int secAgo) {
        List<TwitterApiErrorLog> logs = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String sql = "";
        try{
            connection = DatabaseUtil.dataSource.getConnection();

            sql = String.format("SELECT * FROM twitter_api_error_logs WHERE user_id=? AND created_at > now() - INTERVAL '%d sec' ORDER BY created_at DESC", secAgo);
            statement = connection.prepareStatement(sql);
            statement.setInt(1, userId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                TwitterApiErrorLog l = new TwitterApiErrorLog(resultSet);
                logs.add(l);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
            try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
            try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
        }
        return logs;
    }
}
