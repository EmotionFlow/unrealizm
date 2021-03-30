package jp.pipa.poipiku;

import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.*;

public final class Order extends Model{
    public int id = -1;
    public int customerId = -1;
    public int sellerId = -1;
    public Status status = Status.Init;
    public CheerPointStatus cheerPointStatus;
    public int paymentTotal = -1;
    public int commissionRateSystemPerMil = 0;
    public int commissionRateAgencyPerMil = 0;
    public int commission = 0;
    public int paymentMethodId = -1;

    public enum Status implements CodeEnum<Status> {
        Init(0),                  // 支払前(初期状態)
        BeforeCapture(10),        // 支払処理中・仮売上
        SettlementOk(20),         // 支払済
        SettlementError(-10),	    // 注文不履行(決済エラー)
        ServerError(-99);	        // 注文不履行(サーバ内部エラー)

        static public Status byCode(int _code) {
            return CodeEnum.getEnum(Status.class, _code);
        }

        @Override
        public int getCode() {
            return code;
        }

        private final int code;
        private Status(int code) {
            this.code = code;
        }
    }

    public enum CheerPointStatus implements CodeEnum<CheerPointStatus> {
        BeforeDistribute(0),     // 分配前
        Distributing(1),        // 分配中
        Distributed(2),         // 分配済
        NotApplicable(-1);	    // 対象外

        static public CheerPointStatus byCode(int _code) {
            return CodeEnum.getEnum(CheerPointStatus.class, _code);
        }

        @Override
        public int getCode() {
            return code;
        }

        private final int code;
        private CheerPointStatus(int code) {
            this.code = code;
        }
    }

    public boolean selectById(final int orderId) {
        DataSource dataSource;
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String sql = "";

        try{
            Class.forName("org.postgresql.Driver");
            dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
            connection = dataSource.getConnection();

            sql = "SELECT * FROM orders WHERE id=?";
            statement = connection.prepareStatement(sql);
            statement.setInt(1, orderId);
            statement.executeQuery();
            resultSet = statement.getResultSet();
            if (resultSet.next()) {
                id = orderId;
                customerId = resultSet.getInt("customer_id");
                sellerId = resultSet.getInt("seller_id");
                status = Status.byCode(resultSet.getInt("status"));
                cheerPointStatus = CheerPointStatus.byCode(resultSet.getInt("cheer_point_status"));
                paymentTotal = resultSet.getInt("payment_total");
                commission = resultSet.getInt("commission");
                commissionRateSystemPerMil = resultSet.getInt("commission_rate_system_per_mil");
                commissionRateAgencyPerMil = resultSet.getInt("commission_rate_agency_per_mil");
                paymentMethodId = resultSet.getInt("payment_method_id");
            }
            resultSet.close(); resultSet=null;
            statement.close(); statement=null;
        } catch (SQLException | NamingException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        } finally {
            try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
            try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
            try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
        }
        return true;
    }

    public int insert() {
        DataSource dataSource;
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String sql = "";
        int result = 0;

        CodeEnum.getEnum(CheerPointStatus.class, 0);

        try{
            Class.forName("org.postgresql.Driver");
            dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
            connection = dataSource.getConnection();

            Integer orderId = null;
            sql = "INSERT INTO orders(" +
                    " customer_id, seller_id, status, payment_total, commission," +
                    " commission_rate_system_per_mil, commission_rate_agency_per_mil," +
                    " cheer_point_status, payment_method_id)" +
                    " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            int idx=1;
            statement.setInt(idx++, customerId);                // customer_id
            statement.setInt(idx++, sellerId);                  // seller_id
            statement.setInt(idx++, Status.Init.code);          // status
            statement.setInt(idx++, paymentTotal);              // payment_total
            statement.setInt(idx++, commission);
            statement.setInt(idx++, commissionRateSystemPerMil);
            statement.setInt(idx++, commissionRateAgencyPerMil);
            statement.setInt(idx++, cheerPointStatus.code);     // cheer_point_status
            statement.setInt(idx++, paymentMethodId);
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

    public boolean capture() {
        if (status != Status.BeforeCapture) {
            errorKind = ErrorKind.StatementError;
            return false;
        }
        return update(Status.SettlementOk, null, null);
    }

    public boolean update(
            final Status newStatus,
            final String newAgencyOrderId,
            final Integer creditcardId) {
        DataSource dataSource;
        Connection connection = null;
        PreparedStatement statement = null;
        String sql = "";
        boolean result;

        try{
            Class.forName("org.postgresql.Driver");
            dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
            connection = dataSource.getConnection();
            sql = String.format(
                    "UPDATE orders SET status=?, %s %s updated_at=now() WHERE id=?",
                    newAgencyOrderId!=null ? "agency_order_id=?," : "",
                    creditcardId!=null ? "creditcard_id=?," : ""
            );

            statement = connection.prepareStatement(sql);
            int idx=1;
            statement.setInt(idx++, newStatus.code);
            if (newAgencyOrderId != null) {
                statement.setString(idx++, newAgencyOrderId);
            }
            if (creditcardId != null) {
                statement.setInt(idx++, creditcardId);
            }
            statement.setInt(idx++, id);
            statement.executeUpdate();
            statement.close(); statement=null;
            errorKind = ErrorKind.None;
            result = true;
        } catch (SQLException | NamingException | ClassNotFoundException e) {
            e.printStackTrace();
            errorKind = ErrorKind.DbError;
            result = false;
        } finally {
            try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
            try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
        }
        return result;
    }
}
