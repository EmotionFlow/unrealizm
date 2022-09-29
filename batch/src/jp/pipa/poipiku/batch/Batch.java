package jp.pipa.poipiku.batch;

import org.apache.velocity.app.Velocity;

import javax.sql.DataSource;

public class Batch {
	static protected DataSource dataSource;
	static protected DataSource replicaDataSource;
	Batch() {
		try {
			Class.forName("jp.pipa.poipiku.Common");
			Class.forName("jp.pipa.poipiku.batch.DBConnection");
		} catch (Exception ex){
			ex.printStackTrace();
		}
		Velocity.init("velocity.properties");
		dataSource = DBConnection.getDataSource();
		replicaDataSource = DBConnection.getReplicaDataSource();
	}
}
