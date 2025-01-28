package views;

import controller.AutistaController;
import controller.PasseggeroController;
import model.dao.veicolo.Veicolo;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.List;

public class PasseggeroView {
    public static void showMenu(){
        int choice;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        while(true){
            System.out.println("--------------Menu passeggero--------------");
            System.out.println("1. Visualizza veicoli in arrivo ad una fermata e la loro distanza");

            try {
                choice = Integer.parseInt(br.readLine());
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

            switch(choice){
                case 1:
                    veicoliInArrivo();
                    break;
                default:
                    System.out.println("Scelta non valida");
                    break;
            }
        }
    }

    public static void veicoliInArrivo(){
        String codiceFermata;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("Inserisci codice fermata");
        try {
            codiceFermata = br.readLine();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        PasseggeroController passeggero = new PasseggeroController();
        List<Veicolo> veicoli = passeggero.veicoliInArrivo(codiceFermata);
        for(Veicolo veicolo : veicoli){
            System.out.println(veicolo.getMatricola() +", "+ veicolo.getDistanzaInFermate());
        }
    }
}
