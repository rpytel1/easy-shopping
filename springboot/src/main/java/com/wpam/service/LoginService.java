package com.wpam.service;

import com.wpam.model.User;
import com.wpam.repository.LoginRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LoginService {
    @Autowired
    private LoginRepository loginRepository;

    public boolean loginUser(User userToLogin) {
        return loginRepository.loginUser(userToLogin);
    }

    public List<String> getAllUsers() {
        return loginRepository.getAllUsers();
    }

}
