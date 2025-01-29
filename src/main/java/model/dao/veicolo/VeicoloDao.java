package model.dao.veicolo;
import utils.ConnHandler;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VeicoloDao {
    public List<Veicolo> veicoli_in_arrivoProcedure(String codiceFermata){
        List<Veicolo> veicoli = new ArrayList<Veicolo>();
        try{
            Connection conn = ConnHandler.getConnection();
            CallableStatement cstmt = conn.prepareCall("{call veicoli_in_arrivo(?)}");
            cstmt.setString(1,codiceFermata);
            cstmt.execute();
            ResultSet rs = cstmt.getResultSet();
            while(rs.next()){
                String matricolaVeicolo = rs.getString("matricola");
                int distanzaInFermate = rs.getInt("distanza");
                Veicolo veicolo = new Veicolo(matricolaVeicolo, distanzaInFermate);
                veicoli.add(veicolo);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return veicoli;
    }

    public void aggiorna_posizione(String matricolaVeicolo, String codiceFermata, Connection connection){
        try{
            CallableStatement cstmt = connection.prepareCall("{call aggiorna_posizione(?,?)}");
            cstmt.setString(1,matricolaVeicolo);
            cstmt.setString(2,codiceFermata);
            cstmt.execute();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
