package model.dao.abbonamento;

import utils.ConnHandler;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

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

    public boolean timbra_abbonamentoProcedure(String codiceAbbonamento, Connection conn) {
        Boolean status;
        try {
            CallableStatement cstmt = conn.prepareCall("{call timbra_abbonamento(?,?)}");
            cstmt.setString(1, codiceAbbonamento);
            cstmt.registerOutParameter(2, Types.BOOLEAN);
            cstmt.execute();
            status = cstmt.getBoolean(2);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return status;
    }
}
