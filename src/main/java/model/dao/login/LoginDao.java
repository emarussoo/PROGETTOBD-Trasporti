package model.dao.login;

import utils.ConnHandler;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

public class LoginDao {
    public LoginDao() {}
    public String loginProcedure(String username, String password) {
        String role = null;
        try{
            Connection conn = ConnHandler.getConnection();
            CallableStatement cstmt = conn.prepareCall("{call login(?,?,?)}");
            cstmt.setString(1,username);
            cstmt.setString(2,password);
            cstmt.registerOutParameter(3,java.sql.Types.VARCHAR);
            cstmt.execute();
            role = cstmt.getString(3);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return role;
    }
}
