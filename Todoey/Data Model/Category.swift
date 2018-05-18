//
//  Category.swift
//  Todoey_Realm
//
//  Created by Morris on 2018/4/24.
//  Copyright © 2018年 Morris. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
