package controller;

import model.domain.Credentials;
import views.LoginView;

public class MainController {
    private static MainController instance = null;
    protected MainController(){
    }

    public static MainController getInstance(){
        if(instance == null){
            instance = new MainController();
        }
        return instance;
    }

    public void start(){
        LoginView loginView = new LoginView();
        Credentials cred = loginView.getCredentials();
        LoginController loginController = new LoginController();
        String role = loginController.auth(cred.getUsername(), cred.getPassword());
        if(role == null){
            throw new RuntimeException("credenziali non corrette");
        }

        switch(role){
            case "gestore":
                GestoreController gestore = new GestoreController();
                gestore.start();
                break;
            case "passeggero":
                PasseggeroController passeggero = new PasseggeroController();
                passeggero.start();
                break;
            case "autista":
                AutistaController autista = new AutistaController();
                autista.start();
                break;
                default:
                    break;

        }

    }
}
