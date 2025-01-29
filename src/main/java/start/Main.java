package start;

import controller.MainController;

public class Main {
    public static void main(String[] args) {
        MainController controller = MainController.getInstance();
        controller.start();
    }
}


/*
* esempio conducente
*           CF: LNSRDS88T09N725V
*           VEICOLO: 0008
*           CAPOLINEA: 00067
*
*           esso ha associate le corse delle 07:50:00 tratta 3
*                                            18:10:00 tratta 4
*                                            18:30:00 tratta 6
*                                            23:20:00 tratta 5
*
* */


/*
 * esempio passeggero
 *          aspettare circa 20 secondi, poi inserire codice fermata 00052 (vedi file resources/schema_traccia_simulazione.png)
 * */
