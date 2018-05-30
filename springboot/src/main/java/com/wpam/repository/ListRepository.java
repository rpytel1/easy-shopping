package com.wpam.repository;

import com.wpam.model.ListEntry;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import org.hibernate.query.Query;
import org.springframework.stereotype.Repository;

import javax.persistence.EntityManager;
import java.util.ArrayList;
import java.util.List;

@Repository
public class ListRepository {
    private SessionFactory factory;

    public ListRepository() {
        factory = new Configuration()
                .configure()
                .addAnnotatedClass(ListEntry.class)
                .buildSessionFactory();
    }

    public ListEntry addProduct(ListEntry listEntry) {
        Session session = factory.openSession();
        Transaction transaction = session.beginTransaction();
        Long id = (Long) session.save(listEntry);
        transaction.commit();
        session.close();

        return listEntry;
    }

    public ListEntry deleteProduct(ListEntry listEntry) {
        Session session = factory.openSession();
        Transaction transaction = session.beginTransaction();
        session.delete(listEntry);
        transaction.commit();
        session.close();

        return listEntry;
    }

    public List<ListEntry> getWholeList(String owner) {

        Session session = factory.openSession();
        Transaction transaction = session.beginTransaction();
        String sqlQuery = "FROM ListEntry where owner='" + owner + "'";
        Query query = session.createQuery(sqlQuery);
        List resultList = query.list();
        transaction.commit();
        session.close();

        List<ListEntry> newList = new ArrayList<>();
        for (Object object : resultList) {
            newList.add((ListEntry) object);
        }
        return newList;
    }

    public boolean sendList(String sender, String receiver) {
        Session session = factory.openSession();
        Transaction transaction = session.beginTransaction();
        String sqlQuery = "FROM ListEntry where owner='" + sender + "'";
        Query query = session.createQuery(sqlQuery);
        List resultList = query.list();
        List<ListEntry> newList = new ArrayList<>();
        for (Object object : resultList) {
            ListEntry element = (ListEntry) object;
            element.setOwner(receiver);
        }
        transaction.commit();
        session.close();
        return true;
    }


}
