package model.dao.abbonamento;

import utils.ConnHandler;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

public class AbbonamentoDao {
    public void aggiunta_abbonamentoProcedure(String codiceBiglietto, boolean valido){
        try{
            Connection conn = ConnHandler.getConnection();
            CallableStatement cstmt = conn.prepareCall("{call aggiunta_abbonamento(?,?)}");
            cstmt.setString(1,codiceBiglietto);
            cstmt.setBoolean(2,valido);
            cstmt.execute();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
