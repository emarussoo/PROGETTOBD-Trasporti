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
                String distanzaInFermate = rs.getString(4);
                Veicolo veicolo = new Veicolo(matricolaVeicolo, distanzaInFermate);
                veicoli.add(veicolo);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return veicoli;
    }
}
