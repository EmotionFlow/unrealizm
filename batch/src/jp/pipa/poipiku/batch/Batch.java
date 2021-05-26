package jp.pipa.poipiku.batch;

import org.apache.velocity.app.Velocity;

import javax.sql.DataSource;

public class Batch {
	static protected DataSource dataSource;
	static {
		Velocity.init("velocity.properties");
		dataSource = DBConnection.getDataSource();
	}
}
