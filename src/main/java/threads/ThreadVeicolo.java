package threads;

import model.dao.veicolo.VeicoloDao;
import utils.ConnHandlerMezzo;
import utils.Tratte;

import java.io.*;
import java.sql.Connection;

public class ThreadVeicolo extends Thread {
    int numeroTratta;
    String matricolaVeicolo;
    Connection connection;
    static PrintStream fileOut = null;
    PrintStream console = System.out;

    static{
        try {
            fileOut = new PrintStream(new FileOutputStream("src/main/resources/output_veicolo.txt"));
        } catch (FileNotFoundException ex) {
            throw new RuntimeException(ex);
        }
    }

    public ThreadVeicolo(int numeroTratta, String matricolaVeicolo) {
        this.numeroTratta = numeroTratta;
        this.matricolaVeicolo = matricolaVeicolo;
    }

    public void run(){
        ConnHandlerMezzo connHandler = new ConnHandlerMezzo();
        connection = connHandler.getConnection();
        System.setOut(fileOut);
        System.out.println("Veicolo " + matricolaVeicolo +" partito per la tratta "+ numeroTratta);
        System.setOut(console);

        while(true){
            for(int i=0; i<3; i++){
                try{
                    VeicoloDao veicoloDao = new VeicoloDao();
                    veicoloDao.aggiorna_posizione(matricolaVeicolo, Tratte.values()[numeroTratta].getFermata(i), connection);

                    System.setOut(fileOut);
                    System.out.println("Veicolo "+ matricolaVeicolo+ " avanza alla fermata "+ Tratte.values()[numeroTratta].getFermata(i));
                    System.setOut(console);

                    sleep(20000);

                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }
        }
    }
}
