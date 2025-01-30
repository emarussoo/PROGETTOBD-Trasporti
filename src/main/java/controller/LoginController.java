package controller;

import exceptions.GenericDaoException;
import model.dao.login.LoginDao;

public class LoginController {
    public String auth(String username, String password) {
        LoginDao loginDAO = new LoginDao();
        try{
            return loginDAO.loginProcedure(username, password);
        }catch(GenericDaoException e){
            throw new RuntimeException(e);
        }
    }
}
