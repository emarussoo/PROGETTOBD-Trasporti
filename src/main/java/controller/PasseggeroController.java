package controller;

import model.dao.veicolo.Veicolo;
import model.dao.veicolo.VeicoloDao;
import utils.ConnHandler;
import views.PasseggeroView;

import java.sql.SQLException;
import java.util.List;

public class PasseggeroController {
    public void start(){
        try {
            ConnHandler.changeRole("passeggero");
        } catch(SQLException e) {
            throw new RuntimeException(e);
        }

        PasseggeroView.showMenu();
    }

    public List<Veicolo> veicoliInArrivo(String codiceFermata){
        List<Veicolo> veicoli;
        VeicoloDao veicoloDao = new VeicoloDao();
        veicoli = veicoloDao.veicoli_in_arrivoProcedure(codiceFermata);
        return veicoli;
    }
}
