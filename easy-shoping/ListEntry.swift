//
//  ListEntry.swift
//  easy-shoping
//
//  Created by Rafał Pytel on 29.05.2018.
//  Copyright © 2018 Rafał Pytel. All rights reserved.
//

import Foundation
public class ListEntry{
    public var id : CLong
    public var product : String
    public var quantity : String
    init(product: String, quantity : String, id: CLong){
        self.product = product
        self.quantity = quantity
        self.id = id
    }
}
