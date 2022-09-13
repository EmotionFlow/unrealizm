package jp.pipa.poipiku.util;

import jp.pipa.poipiku.Common;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public final class DatabaseUtil {
	public static DataSource dataSource;
	public static DataSource replicaDataSource;
	static {
		try {
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			if (Common.isDevEnv()) {
				Log.d("dev mode, replicaDataSource = dataSource");
				replicaDataSource = dataSource;
			} else {
				replicaDataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL_REPLICA);
			}
		} catch (ClassNotFoundException | NamingException e) {
			e.printStackTrace();
			dataSource = null;
			replicaDataSource = null;
		}
	}
}
