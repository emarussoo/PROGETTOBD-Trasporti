package controller;

import model.dao.abbonamento.AbbonamentoDao;
import model.dao.biglietto.BigliettoDao;
import model.dao.corsa.CorsaDao;
import utils.ConnHandler;
import views.GestoreView;

import java.sql.SQLException;
import java.time.LocalTime;

public class GestoreController {
    public void start(){
        try {
            ConnHandler.changeRole("gestore");
        } catch(SQLException e) {
            throw new RuntimeException(e);
        }

        GestoreView.showMenu();
    }

    public void aggiungiBiglietto(String codiceBiglietto){
        BigliettoDao bigliettoDao = new BigliettoDao();
        bigliettoDao.aggiunta_bigliettoProcedure(codiceBiglietto);
    }

    public void aggiungiAbbonamento(String codiceAbbonamento, Boolean valido){
        AbbonamentoDao abbonamentoDao = new AbbonamentoDao();
        abbonamentoDao.aggiunta_abbonamentoProcedure(codiceAbbonamento, valido);
    }

    public void associaCorsaVeicolo(int numeroTratta, LocalTime orario, String matricolaVeicolo){
        CorsaDao corsaDao = new CorsaDao();
        corsaDao.corsa_veicoloProcedure(numeroTratta, orario, matricolaVeicolo);

    }

    public void associaCorsaConducente(int numeroTratta, LocalTime orario, String codiceFiscaleConducente){
        CorsaDao corsaDao = new CorsaDao();
        corsaDao.corsa_conducenteProcedure(numeroTratta, orario, codiceFiscaleConducente);
    }
}
