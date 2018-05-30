package com.wpam.model;

import javax.persistence.*;
import javax.validation.constraints.NotNull;

@Entity
@Table(name = "listentry")
public class ListEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private long id;

    @NotNull
    @Column(name = "product")
    private String product;

    @NotNull
    @Column(name = "quantity")
    private String quantity;


    @NotNull
    @Column(name = "owner")
    private String owner;

    public ListEntry() {
    }

    public ListEntry(String product, String quantity, String owner) {
        this.product = product;
        this.quantity = quantity;
        this.owner = owner;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getProduct() {
        return product;
    }

    public void setProduct(String product) {
        this.product = product;
    }

    public String getQuantity() {
        return quantity;
    }

    public void setQuantity(String quantity) {
        this.quantity = quantity;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

}
