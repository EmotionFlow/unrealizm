package jp.pipa.poipiku.batch;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import jp.pipa.poipiku.Common;
import org.postgresql.ds.PGSimpleDataSource;

public class DBConnection {
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
		setUp();
		setUpReplica();
	}

	static private InitialContext createInitialContext() throws NamingException{
		InitialContext initialContext = new InitialContext();
		initialContext.createSubcontext("java:");
		initialContext.createSubcontext("java:comp");
		initialContext.createSubcontext("java:comp/env");
		initialContext.createSubcontext("java:comp/env/jdbc");
		return initialContext;
	}


	static public void setUp() {
		try {
			System.setProperty(Context.INITIAL_CONTEXT_FACTORY, "org.apache.naming.java.javaURLContextFactory");
			System.setProperty(Context.URL_PKG_PREFIXES, "org.apache.naming.java");
			dataSource = new PGSimpleDataSource();
			dataSource.setUser("postgres");
			dataSource.setPassword(System.getProperty("dbPass"));
			dataSource.setDatabaseName("poipiku");
			String[] servers = {System.getProperty("dbHost")};
			dataSource.setServerNames(servers);
			int[] ports = {Integer.parseInt(System.getProperty("dbPort"))};
			dataSource.setPortNumbers(ports);

			InitialContext ic = createInitialContext();
			ic.bind(Common.DB_POSTGRESQL, dataSource);

		} catch (javax.naming.NameAlreadyBoundException ignored) {
			;
		} catch (NamingException ex) {
			ex.printStackTrace();
		}
	}

	static public void setUpReplica() {
		try {
			System.setProperty(Context.INITIAL_CONTEXT_FACTORY, "org.apache.naming.java.javaURLContextFactory");
			System.setProperty(Context.URL_PKG_PREFIXES, "org.apache.naming.java");
			replicaDataSource = new PGSimpleDataSource();
			replicaDataSource.setUser("postgres");
			replicaDataSource.setPassword(System.getProperty("replicaDbPass"));
			replicaDataSource.setDatabaseName("poipiku-replica");
			String[] servers = {System.getProperty("replicaDbHost")};
			replicaDataSource.setServerNames(servers);
			int[] ports = {Integer.parseInt(System.getProperty("replicaDbPort"))};
			replicaDataSource.setPortNumbers(ports);

			InitialContext ic = createInitialContext();
			ic.bind(Common.DB_POSTGRESQL_REPLICA, replicaDataSource);

		} catch (javax.naming.NameAlreadyBoundException ignored) {
			;
		} catch (NamingException ex) {
			ex.printStackTrace();
		}
	}

}
