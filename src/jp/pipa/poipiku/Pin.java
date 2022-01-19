package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public final class Pin extends Model {
	public int id = -1;
	public int userId = -1;
	public int contentId = -1;
	public int dispOrder = -1;

	public Pin(){};

	public Pin(final ResultSet resultSet) throws SQLException {
		set(resultSet);
	}

	private void set(final ResultSet resultSet) throws SQLException {
		id = resultSet.getInt("id");
		userId = resultSet.getInt("user_id");
		contentId = resultSet.getInt("content_id");
		dispOrder = resultSet.getInt("disp_order");
	}

	public boolean select(int userId, int contentId) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		final String sql = "SELECT * FROM pins WHERE user_id=? AND content_id=?";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, contentId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				set(resultSet);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}

	static public int find(int userId, int contentId){
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		final String sql = "SELECT 1 FROM pins WHERE user_id=? AND content_id=?";
		final boolean isFound;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, contentId);
			resultSet = statement.executeQuery();
			isFound = resultSet.next();
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return -1;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return isFound ? 1 : 0;
	}

	static public boolean insert(int userId, int contentId){
		int findResult = Pin.find(userId, contentId);
		if (findResult != 0) {
			Log.d("Pin.findが想定外: " + findResult);
			return false;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "INSERT INTO pins(user_id, content_id, disp_order) VALUES (?,?,?)";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setLong(2, contentId);
			statement.setInt(3, 1);
			statement.executeUpdate();
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}

	public boolean delete(){
		if (id < 0) return false;
		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "DELETE FROM pins WHERE id=?";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, id);
			statement.executeUpdate();
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}

	public boolean updateContentId(int _contentId) {
		if (id < 0) return false;
		Connection connection = null;
		PreparedStatement statement = null;
		final String sql = "UPDATE pins SET content_id=? WHERE id=?";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _contentId);
			statement.setInt(2, id);
			statement.executeUpdate();
			contentId = _contentId;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;

	}

	static public List<Pin> selectByUserId(int userId) {
		List<Pin> pins = new ArrayList<>();
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		final String sql = "SELECT * FROM pins WHERE user_id=? ORDER BY disp_order";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				Pin pin = new Pin(resultSet);
				pins.add(pin);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return pins;
	}
 }
