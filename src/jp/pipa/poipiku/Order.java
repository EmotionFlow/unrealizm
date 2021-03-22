package jp.pipa.poipiku;

import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.*;

public class Order {
    public int id = -1;
    public enum SettlementStatus implements DbCodeEnum<SettlementStatus> {
        Init(0),                  // 支払前(初期状態)
        BeforeCapture(10),        // 支払中
        SettlementOk(20),         // 支払済
        SettlementError(-10),	    // 注文不履行(決済エラー)
        ServerError(-99);	        // 注文不履行(サーバ内部エラー)

        private final int code;
        private SettlementStatus(int code) {
            this.code = code;
        }

        @Override
        public int getCode() {
            return code;
        }
    }
    public SettlementStatus settlementStatus = SettlementStatus.Init;

    public enum CheerPointStatus implements DbCodeEnum<CheerPointStatus> {
        Init(0),                  // 支払前(初期状態)
        BeforeCapture(10),        // 支払中
        SettlementOk(20),         // 支払済
        SettlementError(-10),	    // 注文不履行(決済エラー)
        ServerError(-99);	        // 注文不履行(サーバ内部エラー)

        private final int code;
        private CheerPointStatus(int code) {
            this.code = code;
        }

        @Override
        public int getCode() {
            return code;
        }
    }
    public CheerPointStatus cheerPointStatus = CheerPointStatus.Init;

    public int customerId = -1;
    public int sellerId = -1;
    public int paymentTotal = -1;

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

            Integer orderId = null;
            sql = "INSERT INTO orders(" +
                    " customer_id, seller_id, status, payment_total, cheer_point_status)" +
                    " VALUES (?, ?, ?, ?, ?)";
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            int idx=1;
            statement.setInt(idx++, customerId);                // customer_id
            statement.setInt(idx++, sellerId);                  // seller_id
            statement.setInt(idx++, SettlementStatus.Init.code);     // status
            statement.setInt(idx++, paymentTotal);              // payment_total
            statement.setInt(idx++, cheerPointStatus.code);     // cheer_point_status
            statement.executeUpdate();
            resultSet = statement.getGeneratedKeys();
            if(resultSet.next()){
                orderId = resultSet.getInt(1);
                Log.d("orders.id", orderId.toString());
                id = orderId;
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

    public int updateSettlementStatus(final SettlementStatus newSettlementStatus, final String newAgencyOrderId) {
        DataSource dataSource;
        Connection connection = null;
        PreparedStatement statement = null;
        String sql = "";
        int result = 0;

        try{
            Class.forName("org.postgresql.Driver");
            dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
            connection = dataSource.getConnection();
            sql = String.format(
                    "UPDATE orders SET status=?, %s updated_at=now() WHERE id=?",
                    newAgencyOrderId!=null ? "agency_order_id=?," : "");

            statement = connection.prepareStatement(sql);
            int idx=1;
            statement.setInt(idx++, newSettlementStatus.code);
            if (newAgencyOrderId != null) {
                statement.setString(idx++, newAgencyOrderId);
            }
            statement.setInt(idx++, id);
            statement.executeUpdate();
            statement.close(); statement=null;
        } catch (SQLException | NamingException | ClassNotFoundException e) {
            e.printStackTrace();
            result = -1;
        } finally {
            try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
            try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
        }
        return result;
    }
}
