package jp.pipa.poipiku.batch;

import org.apache.velocity.app.Velocity;

import javax.sql.DataSource;

public class Batch {
	static protected DataSource dataSource;
	static protected DataSource repilcaDataSource;
	static {
		try {
			Class.forName("jp.pipa.poipiku.Common");
			Class.forName("jp.pipa.poipiku.batch.DBConnection");
		} catch (Exception ignore){}
		Velocity.init("velocity.properties");
		dataSource = DBConnection.getDataSource();
		repilcaDataSource = DBConnection.getReplicaDataSource();
	}
}
