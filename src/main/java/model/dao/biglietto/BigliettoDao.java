package model.dao.biglietto;

import utils.ConnHandler;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

public class BigliettoDao {
    public void aggiunta_bigliettoProcedure(String codiceBiglietto){
        try{
            Connection conn = ConnHandler.getConnection();
            CallableStatement cstmt = conn.prepareCall("{call aggiunta_biglietto(?)}");
            cstmt.setString(1,codiceBiglietto);
            cstmt.execute();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
