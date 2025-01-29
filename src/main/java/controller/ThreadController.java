package controller;

import threads.ThreadVeicolo;

public class ThreadController {
    public void start(){
        ThreadVeicolo veicolo1 = new ThreadVeicolo(0, "0000");
        ThreadVeicolo veicolo2 = new ThreadVeicolo(1, "0004");
        ThreadVeicolo veicolo3 = new ThreadVeicolo(2, "0008");
        veicolo1.start();
        veicolo2.start();
        veicolo3.start();
    }
}
