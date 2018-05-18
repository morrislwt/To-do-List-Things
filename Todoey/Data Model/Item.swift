//
//  Item.swift
//  Todoey_Realm
//
//  Created by Morris on 2018/4/24.
//  Copyright © 2018年 Morris. All rights reserved.
//

import Foundation
import RealmSwift

class Item:Object {
    @objc dynamic var title:String = ""
    @objc dynamic var done:Bool = false
    @objc dynamic var dateCreated:Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    ///items 是 Category這個Data Model裡 main的 property
    
}
