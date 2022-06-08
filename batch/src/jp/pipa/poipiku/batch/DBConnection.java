package jp.pipa.poipiku.batch;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import org.postgresql.ds.PGSimpleDataSource;

public class DBConnection {
	static private PGSimpleDataSource dataSource = null;
	static public PGSimpleDataSource getDataSource() {
		if (dataSource == null) {
			setUp();
		}
		return dataSource;
	}
	static public void setUp() {
		try {
			System.setProperty(Context.INITIAL_CONTEXT_FACTORY, "org.apache.naming.java.javaURLContextFactory");
			System.setProperty(Context.URL_PKG_PREFIXES, "org.apache.naming.java");
			InitialContext initialContext = new InitialContext();

			initialContext.createSubcontext("java:");
			initialContext.createSubcontext("java:comp");
			initialContext.createSubcontext("java:comp/env");
			initialContext.createSubcontext("java:comp/env/jdbc");

			dataSource = new PGSimpleDataSource();
			dataSource.setUser("postgres");
			dataSource.setPassword(System.getProperty("dbPass"));
			dataSource.setDatabaseName("poipiku");
			String[] servers = {System.getProperty("dbHost")};
			dataSource.setServerNames(servers);
			int[] ports = {Integer.parseInt(System.getProperty("dbPort"))};
			dataSource.setPortNumbers(ports);

			initialContext.bind("java:comp/env/jdbc/poipiku", dataSource);
		} catch (javax.naming.NameAlreadyBoundException ignored) {
			;
		} catch (NamingException ex) {
			ex.printStackTrace();
		}
	}

}
