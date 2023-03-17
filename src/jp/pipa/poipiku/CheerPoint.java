package jp.pipa.poipiku;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.*;

public final class CheerPoint extends Model{
	public int id;
	public int userId;
	public int acquisitionPoints;
	public int paidPoints;
	public int remainingPoints;
	public int payingPoints;
	public String exchangeRequestId;

	public boolean selectById(final int cheerPointId) {
		// not implemented
		return false;
	}

	public int insert() {
		DataSource dataSource;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int result = 0;

		try{
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			sql = "INSERT INTO public.cheer_points(" +
					" user_id, acquisition_points, remaining_points)" +
					" VALUES (?, ?, ?);";
			statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
			int idx=1;
			statement.setInt(idx++, userId);
			statement.setInt(idx++, acquisitionPoints);
			statement.setInt(idx++, acquisitionPoints); // remaining_points
			statement.executeUpdate();
			resultSet = statement.getGeneratedKeys();
			if(resultSet.next()){
				id = resultSet.getInt(1);
				result = 0;
			} else {
				result = -1;
			}
			resultSet.close(); resultSet=null;
			statement.close(); statement=null;
		} catch (SQLException | NamingException | ClassNotFoundException e) {
			e.printStackTrace();
			result = -1;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

		return result;
	}
}
