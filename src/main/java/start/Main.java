package start;

import controller.MainController;

public class Main {
    public static void main(String[] args) {
        MainController controller = MainController.getInstance();
        controller.start();
    }
}

/*
* credenziali gestore
*                      user123456
*                      pwA1B2C3D4
* credenziali passeggero
*                       user234567
*                       pwE5F6G7H8I
* credenziali autista
*                       user345678
*                       pwJ9K0L1M2N
*/


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
