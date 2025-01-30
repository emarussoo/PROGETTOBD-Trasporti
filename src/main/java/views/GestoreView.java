package views;

import controller.GestoreController;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.time.LocalTime;

public class GestoreView {
    public static void showMenu(){
        int choice;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        while(true){
            System.out.println("--------------Menu gestore--------------");
            System.out.println("1. Aggiungi biglietto");
            System.out.println("2. Aggiungi abbonamento");
            System.out.println("3. Aggiungi associazione corsa-conducente");
            System.out.println("4. Aggiungi associazione corsa-veicolo");
            System.out.println("5. exit");

            try {
                choice = Integer.parseInt(br.readLine());
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

            switch(choice){
                case 1:
                    aggiungiBiglietto();
                    break;
                case 2:
                    aggiungiAbbonamento();
                    break;
                case 3:
                    aggiungiAssociazioneCorsaConducente();
                    break;
                case 4:
                    aggiungiAssociazioneCorsaVeicolo();
                    break;
                case 5:
                    System.exit(0);
                    break;
                default:
                    System.out.println("Scelta non valida");
                    break;
            }
        }
    }

    public static void aggiungiBiglietto(){
        String codiceBiglietto;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("Inserisci codice biglietto");
        try {
            codiceBiglietto = br.readLine();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        GestoreController gestore = new GestoreController();
        gestore.aggiungiBiglietto(codiceBiglietto);
    }

    public static void aggiungiAbbonamento(){
        String codiceAbbonamento;
        int validoChoice;
        Boolean valido = false;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        try {
            System.out.println("Inserisci codice abbonamento");
            codiceAbbonamento = br.readLine();
            System.out.println("Inserisci 1 se è valido, 0 altrimenti");
            validoChoice = Integer.parseInt(br.readLine());
            if(validoChoice == 0){
                valido = false;
            }else if(validoChoice == 1){
                valido = true;
            };
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        GestoreController gestore = new GestoreController();
        gestore.aggiungiAbbonamento(codiceAbbonamento, valido);

    }

    public static void aggiungiAssociazioneCorsaConducente(){
        int numeroTratta;
        LocalTime orario;
        String codiceFiscaleConducente;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        try {
            System.out.println("Inserisci numero tratta");
            numeroTratta = Integer.parseInt(br.readLine());
            System.out.println("Inserisci orario, nella forma HH:mm:ss");
            orario = LocalTime.parse(br.readLine());
            System.out.println("Inserisci codice fiscale del conducente");
            codiceFiscaleConducente = br.readLine();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        GestoreController gestore = new GestoreController();
        gestore.associaCorsaConducente(numeroTratta, orario, codiceFiscaleConducente);
    }

    public static void aggiungiAssociazioneCorsaVeicolo(){
        int numeroTratta;
        LocalTime orario;
        String matricolaVeicolo;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        try {
            System.out.println("Inserisci numero tratta");
            numeroTratta = Integer.parseInt(br.readLine());
            System.out.println("Inserisci orario, nella forma HH:mm:ss");
            orario = LocalTime.parse(br.readLine());
            System.out.println("Inserisci matricola del veicolo");
            matricolaVeicolo = br.readLine();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        GestoreController gestore = new GestoreController();
        gestore.associaCorsaVeicolo(numeroTratta, orario, matricolaVeicolo);
    }
}
