package jp.pipa.poipiku;

import jp.pipa.poipiku.util.SqlUtil;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.*;

public class OrderDetail {
    public int id = -1;

    public enum ProductCategory implements CodeEnum<ProductCategory> {
        Undef(0),
        Pochibukuro(1),
        Passport(2),
        Request(3);

        private final int code;
        private ProductCategory(int code) {
            this.code = code;
        }

        @Override
        public int getCode() {
            return code;
        }
    }
    public ProductCategory productCategory = ProductCategory.Undef;

    public int orderId = -1;
    public Integer contentId = null;
    public Integer requestId = null;
    public Integer contentUserId = null;
    public Integer productId = null;
    public String productName = "";
    public int listPrice = -1;
    public int amountPaid = -1;
    public int quantity = -1;

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

            sql = "INSERT INTO order_details(" +
                    " order_id, content_id, content_user_id, request_id, product_id, product_category_id, product_name, list_price, amount_paid, quantity)" +
                    " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            int idx=1;
            statement.setInt(idx++, orderId);               // order_id
            SqlUtil.setNullOrInt(statement, idx++, contentId);
            SqlUtil.setNullOrInt(statement, idx++, contentUserId);
            SqlUtil.setNullOrInt(statement, idx++, requestId);
            SqlUtil.setNullOrInt(statement, idx++, productId);
            statement.setInt(idx++, productCategory.code);  // product_category_id
            statement.setString(idx++, productName);        // product_name
            statement.setInt(idx++, listPrice);             // list_price
            statement.setInt(idx++, amountPaid);            // amount_paid
            statement.setInt(idx++, quantity);              // quantity
            statement.executeUpdate();
            resultSet = statement.getGeneratedKeys();
            if(resultSet.next()){
                id = resultSet.getInt(1);
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
}
