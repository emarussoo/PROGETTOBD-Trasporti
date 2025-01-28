package controller;

import model.dao.login.LoginDao;

public class LoginController {
    public String auth(String username, String password) {
        LoginDao loginDAO = new LoginDao();
        return loginDAO.loginProcedure(username, password);
    }
}
