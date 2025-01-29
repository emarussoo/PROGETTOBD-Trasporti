package utils;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class ConnHandlerMezzo {
    Connection connection = null;
    {
        try (
        InputStream input = new FileInputStream("src/main/resources/database.properties")) {
            Properties properties = new Properties();
            properties.load(input);

            String connection_url = properties.getProperty("URL");
            String user = properties.getProperty("mezzo_USER");
            String pass = properties.getProperty("mezzo_PASS");

            connection = DriverManager.getConnection(connection_url, user, pass);
        } catch (IOException | SQLException e) {
        e.printStackTrace();
        }
    }

    public Connection getConnection() {
        return connection;
    }
}
