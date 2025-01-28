package model.dao.veicolo;

public class Veicolo {
    private String matricola;
    private int distanzaInFermate;

    public Veicolo(String matricola, int distanzaInFermate) {
        this.matricola = matricola;
        this.distanzaInFermate = distanzaInFermate;
    }

    public String getMatricola() {
        return matricola;
    }

    public void setMatricola(String matricola) {
        this.matricola = matricola;
    }

    public int getDistanzaInFermate() {
        return distanzaInFermate;
    }

    public void setDistanzaInFermate(int distanzaInFermate) {
        this.distanzaInFermate = distanzaInFermate;
    }

}
