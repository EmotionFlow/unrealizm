package jp.pipa.poipiku.batch;

import javax.naming.Context;
import javax.naming.InitialContext;

import jp.pipa.poipiku.Common;
import org.postgresql.ds.PGSimpleDataSource;

public class DBConnection {
	static private InitialContext initialContext;

	static private PGSimpleDataSource dataSource = null;
	static public PGSimpleDataSource getDataSource() {
		if (dataSource == null) {
			setUp();
		}
		return dataSource;
	}

	static private PGSimpleDataSource replicaDataSource = null;
	static public PGSimpleDataSource getReplicaDataSource() {
		if (replicaDataSource == null) {
			setUpReplica();
		}
		return replicaDataSource;
	}

	static {
		try {
			System.setProperty(Context.INITIAL_CONTEXT_FACTORY, "org.apache.naming.java.javaURLContextFactory");
			System.setProperty(Context.URL_PKG_PREFIXES, "org.apache.naming.java");
			initialContext = new InitialContext();
			initialContext.createSubcontext("java:");
			initialContext.createSubcontext("java:comp");
			initialContext.createSubcontext("java:comp/env");
			initialContext.createSubcontext("java:comp/env/jdbc");
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		setUp();
		setUpReplica();
	}

	static public void setUp() {
		try {
			dataSource = new PGSimpleDataSource();
			dataSource.setUser("postgres");
			dataSource.setPassword(System.getProperty("dbPass"));
			dataSource.setDatabaseName("ai-poipiku");
			String[] servers = {System.getProperty("dbHost")};
			dataSource.setServerNames(servers);
			int[] ports = {Integer.parseInt(System.getProperty("dbPort"))};
			dataSource.setPortNumbers(ports);

			initialContext.bind(Common.DB_POSTGRESQL, dataSource);

		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	static public void setUpReplica() {
		try {
			replicaDataSource = new PGSimpleDataSource();
			replicaDataSource.setUser("postgres");
			replicaDataSource.setPassword(System.getProperty("replicaDbPass"));
			replicaDataSource.setDatabaseName("ai-poipiku-replica");
			String[] servers = {System.getProperty("replicaDbHost")};
			replicaDataSource.setServerNames(servers);
			int[] ports = {Integer.parseInt(System.getProperty("replicaDbPort"))};
			replicaDataSource.setPortNumbers(ports);

			initialContext.bind(Common.DB_POSTGRESQL_REPLICA, replicaDataSource);

		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

}
