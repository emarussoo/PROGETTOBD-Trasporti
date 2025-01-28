package model.dao.corsa;

import utils.ConnHandler;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Time;
import java.time.LocalTime;

public class CorsaDao {

    public void corsa_veicoloProcedure(int numeroTratta, LocalTime orario, String matricolaVeicolo){
        try{
            Connection conn = ConnHandler.getConnection();
            CallableStatement cstmt = conn.prepareCall("{call corsa_veicolo(?,?,?)}");
            cstmt.setInt(1,numeroTratta);
            cstmt.setTime(2, Time.valueOf(orario));
            cstmt.setString(3,matricolaVeicolo);
            cstmt.execute();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void corsa_conducenteProcedure(int numeroTratta, LocalTime orario, String codiceFiscaleConducente){
        try{
            Connection conn = ConnHandler.getConnection();
            CallableStatement cstmt = conn.prepareCall("{call corsa_conducente(?,?,?)}");
            cstmt.setInt(1,numeroTratta);
            cstmt.setTime(2, Time.valueOf(orario));
            cstmt.setString(3,codiceFiscaleConducente);
            cstmt.execute();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
