package jp.pipa.poipiku;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class DBConnectionTest {
	@BeforeAll
	void setUp() {
		DBConnection.setUp();
	}

	@Test
	public void testGetConnection() {
		try{
			Class.forName("org.postgresql.Driver");
			//Context context = new InitialContext();
			DataSource dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			java.sql.Connection connection = dsPostgres.getConnection();
			assertNotNull(connection);
		} catch (Exception e) {
			fail(e);
		}
	}

	@Test
	public void testGetDataSource() {
		try {
			DataSource dsPostgres = (DataSource)DBConnection.getDataSource();
			assertNotNull(dsPostgres);
			java.sql.Connection connection = dsPostgres.getConnection();
			assertNotNull(connection);
		} catch (Exception e) {
			fail(e);
		}
	}
}
