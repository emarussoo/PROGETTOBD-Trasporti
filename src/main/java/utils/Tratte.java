package utils;

public enum Tratte {
    TRATTA1("00054", "00095", "00099", "00052", "00031"),
    TRATTA2("00055", "00068", "00075", "00099", "00080"),
    TRATTA3("00067", "00060", "00052", "00056", "00089");

    private final String[] fermate;

    Tratte(String... fermate) {
        this.fermate = fermate;
    }

    public String getFermata(int i) {
        return fermate[i];
    }
}
