package com.wpam.model;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
@Entity
@Table(name = "user")
public class User {
    @Id
    @NotNull
    @Column(name = "login")
    private String login;

    @NotNull
    @Column(name = "password")
    private String password;


    public User() {

    }

    public User(String login, String password) {
        this.login = login;
        this.password = password;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin (String login) {
        this.login = login;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword (String password) {
        this.password = password;
    }


}
