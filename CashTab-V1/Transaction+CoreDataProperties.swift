//
//  Transaction+CoreDataProperties.swift
//  CashTab-V1
//
//  Created by Grant Campanelli on 2/18/16.
//  Copyright © 2016 Kevin Tsui. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Transaction {

    @NSManaged public var date: NSDate?
    @NSManaged public var desc: String?
    @NSManaged public var location: String?
    @NSManaged public var moneySpent: NSNumber?
    @NSManaged public var moneyType: String?
    @NSManaged public var tags: NSObject?
    @NSManaged public var transactionName: String?
    @NSManaged public var vendorName: String?

}
