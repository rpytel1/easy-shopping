package com.wpam.repository;

import com.wpam.model.ListEntry;
import com.wpam.model.User;
import org.hibernate.Session;
import org.hibernate.SessionFactory;

import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import org.hibernate.query.Query;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;

@Repository
public class LoginRepository {
    private SessionFactory factory;


    public boolean loginUser(User person) {
        System.out.println(person.getLogin());
        boolean canLogin;
        factory = new Configuration()
                .configure()
                .addAnnotatedClass(User.class)
                .buildSessionFactory();

        Session session = factory.openSession();
        User userInDB = session.get(User.class, person.getLogin());

        canLogin = userInDB != null && (userInDB.getPassword().equals(person.getPassword()));

        if (userInDB != null)
            System.out.println(userInDB.getLogin());
        else
            System.out.println("User doesn't exists");

        session.close();
        return canLogin;
    }

    public List<String> getAllUsers() {
        factory = new Configuration()
                .configure()
                .addAnnotatedClass(User.class)
                .buildSessionFactory();

        Session session = factory.openSession();
        Transaction transaction = session.beginTransaction();

        String sqlQuery = "FROM User ";
        Query query = session.createQuery(sqlQuery);

        List resultList = query.list();
        transaction.commit();
        session.close();

        List<String> newList = new ArrayList<>();
        for (Object object : resultList) {
            newList.add(((User) object).getLogin());
        }
        return newList;
    }


}
