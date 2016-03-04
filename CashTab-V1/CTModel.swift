//
//  CTModel.swift
//  CashTab-V1
//
//  Created by Kevin Tsui on 2/23/16.
//  Copyright © 2016 Kevin Tsui. All rights reserved.
//

//import CoreData
import Foundation

class Transaction {
    // MARK: Transaction Properties
    
    var title: String
    var cost: String
    
    init(title: String, cost: String) {
        self.title  = title
        self.cost   = cost
    }
}