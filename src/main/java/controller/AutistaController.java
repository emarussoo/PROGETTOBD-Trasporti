package controller;

import model.dao.veicolo.Veicolo;
import model.dao.veicolo.VeicoloDao;
import utils.ConnHandler;
import views.AutistaView;

import java.io.IOException;
import java.sql.SQLException;
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
}
