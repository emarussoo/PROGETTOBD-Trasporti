package controller;

import model.dao.corsa.CorsaDao;
import model.dao.veicolo.Veicolo;
import model.dao.veicolo.VeicoloDao;
import utils.ConnHandler;
import views.AutistaView;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class AutistaController {
    public void start(){
        try {
            ConnHandler.changeRole("autista");
        } catch(SQLException e) {
            throw new RuntimeException(e);
        }

        AutistaView.showMenu();
    }

    public LocalTime prossimaPartenza(String cfConducente, String matricolaVeicolo, String codiceCapolinea){
        CorsaDao corsaDao = new CorsaDao();
        return corsaDao.prossima_partenzaProcedure(cfConducente, matricolaVeicolo, codiceCapolinea);
    }
}
