package views;

import controller.AutistaController;
import controller.PasseggeroController;
import model.dao.veicolo.Veicolo;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.time.LocalTime;
import java.util.List;

public class AutistaView {
    public static void showMenu(){
        int choice;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        while(true){
            System.out.println("--------------Menu autista--------------");
            System.out.println("1. Visualizza prossimo orario di partenza in base a CF, veicolo e capolinea");
            System.out.println("2. exit");

            try {
                choice = Integer.parseInt(br.readLine());
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

            switch(choice){
                case 1:
                    prossimaPartenza();
                    break;
                case 2:
                    System.exit(0);
                    break;
                default:
                    System.out.println("Scelta non valida");
                    break;
            }
        }
    }

    public static void prossimaPartenza(){
        String codiceFiscale;
        String matricolaVeicolo;
        String codiceCapolinea;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        try {
            System.out.println("Inserisci codice fiscale");
            codiceFiscale = br.readLine();
            System.out.println("Inserisci matricola veicolo");
            matricolaVeicolo = br.readLine();
            System.out.println("Inserisci codice capolinea");
            codiceCapolinea = br.readLine();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        AutistaController autista = new AutistaController();
        LocalTime orarioProssimaPartenza = autista.prossimaPartenza(codiceFiscale, matricolaVeicolo, codiceCapolinea);
        System.out.println("La prossima partenza prevista è per l'ora: " + orarioProssimaPartenza);
    }
}
