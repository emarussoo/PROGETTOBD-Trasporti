package start;

import controller.MainController;

public class Main {
    public static void main(String[] args) {
        MainController controller = MainController.getInstance();
        controller.start();
    }
}