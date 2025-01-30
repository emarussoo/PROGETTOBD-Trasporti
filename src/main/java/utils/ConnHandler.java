package utils;


import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class ConnHandler {
    private static Connection connection;
    static {
        try (InputStream input = new FileInputStream("src/main/resources/database.properties")) {
            Properties properties = new Properties();
            properties.load(input);

            String connection_url = properties.getProperty("URL");
            String user = properties.getProperty("login_USER");
            String pass = properties.getProperty("login_PASS");

            connection = DriverManager.getConnection(connection_url, user, pass);
        } catch (IOException | SQLException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return connection;
    }

    public static void changeRole(String role) throws SQLException {
        connection.close();

        try (InputStream input = new FileInputStream("src/main/resources/database.properties")) {
            Properties properties = new Properties();
            properties.load(input);

            String connection_url = properties.getProperty("URL");
            String user = properties.getProperty(role + "_USER");
            String pass = properties.getProperty(role + "_PASS");

            connection = DriverManager.getConnection(connection_url, user, pass);
        } catch (IOException | SQLException e) {
            e.printStackTrace();
        }
    }
}
