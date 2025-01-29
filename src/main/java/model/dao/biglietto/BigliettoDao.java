package model.dao.biglietto;

import utils.ConnHandler;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

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

    public boolean timbra_bigliettoProcedure(String codiceBiglietto, Connection conn) {
        Boolean status;
        try {
            CallableStatement cstmt = conn.prepareCall("{call timbra_biglietto(?,?)}");
            cstmt.setString(1, codiceBiglietto);
            cstmt.registerOutParameter(2, Types.BOOLEAN);
            cstmt.execute();
            status = cstmt.getBoolean(2);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return status;
    }
}
