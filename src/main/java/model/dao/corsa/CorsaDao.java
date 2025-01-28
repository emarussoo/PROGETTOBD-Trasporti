package model.dao.corsa;

import utils.ConnHandler;

import java.sql.*;
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

    public LocalTime prossima_partenzaProcedure(String cfConducente, String matricolaVeicolo, String codiceCapolinea){
        LocalTime orario;
        try{
            Connection conn = ConnHandler.getConnection();
            CallableStatement cstmt = conn.prepareCall("{call prossima_partenza(?,?,?,?)}");
            cstmt.setString(1,cfConducente);
            cstmt.setString(2, matricolaVeicolo);
            cstmt.setString(3,codiceCapolinea);
            cstmt.registerOutParameter(4, Types.TIME);
            cstmt.execute();
            orario = cstmt.getTime(4).toLocalTime();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return orario;
    }
}
