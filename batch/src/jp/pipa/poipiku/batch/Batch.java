package jp.pipa.poipiku.batch;

import org.apache.velocity.app.Velocity;

import javax.sql.DataSource;

public class Batch {
	static protected DataSource dataSource;
	static {
		try {
			Class.forName("jp.pipa.poipiku.Common");
		} catch (Exception igunore){};
		Velocity.init("velocity.properties");
		dataSource = DBConnection.getDataSource();
	}
}
