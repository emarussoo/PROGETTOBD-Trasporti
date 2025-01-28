package views;

import model.domain.Credentials;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class LoginView {
    public Credentials getCredentials(){
        String username;
        String password;
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        try {
            System.out.print("Inserisci username: ");
            username = br.readLine();
            System.out.print("Inserisci password: ");
            password = br.readLine();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        return new Credentials(username, password);

    }
}
