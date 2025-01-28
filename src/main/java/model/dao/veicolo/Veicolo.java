package model.dao.veicolo;

public class Veicolo {
    private String matricola;
    private String distanzaInFermate;

    public Veicolo(String matricola, String distanzaInFermate) {
        this.matricola = matricola;
    }

    public String getMatricola() {
        return matricola;
    }

    public void setMatricola(String matricola) {
        this.matricola = matricola;
    }

    public String getDistanzaInFermate() {
        return distanzaInFermate;
    }

    public void setDistanzaInFermate(String distanzaInFermate) {
        this.distanzaInFermate = distanzaInFermate;
    }

}
