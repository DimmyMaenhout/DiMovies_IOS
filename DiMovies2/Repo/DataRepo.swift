//
//  DataRepo.swift
//  DiMovies2
//
//  Created by Dimmy Maenhout on 09/10/2018.
//  Copyright © 2018 Dimmy Maenhout. All rights reserved.
//

import Foundation
import RealmSwift
class DataRepo {
    
    init() {
        let user = User(username: "User")
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(user)
        }
    }
}
