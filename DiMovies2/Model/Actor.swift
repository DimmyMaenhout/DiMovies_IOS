//
//  Actor.swift
//  DiMovies2
//
//  Created by Dimmy Maenhout on 24/12/2017.
//  Copyright © 2017 Dimmy Maenhout. All rights reserved.
//

import Foundation
class Actor {
    var id : Int
    var photo = ""
    //var imdb_id : Int?
    var name = ""
    var birthYear = ""
    var deathDay = ""
    var biography = ""
    var gender : Int //0 = not set, 1 = female, 2 = male
    var placeOfBirth = ""
    var photoFilePath = ""
    var profilePath = ""
    //var also_known_as: [String] = []
    
    init(id: Int, name: String, birthyear: String, deathday: String, biography: String, gender: Int, placeOfBirth: String /*, alsoKnowsAs: [String]*/, photoFilePath : String, profilePath: String){
        self.id = id
        self.name = name
        self.birthYear = birthyear
        self.deathDay = deathday
        self.biography = biography
        self.gender = gender
        self.placeOfBirth = placeOfBirth
        //self.also_known_as  = alsoKnowsAs
        self.photoFilePath = photoFilePath
        self.profilePath = profilePath
    }
    
}
enum gender : Int {
    case undefined = 0, female, male
}
