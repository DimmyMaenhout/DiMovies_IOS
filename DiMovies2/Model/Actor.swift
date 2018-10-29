import Foundation
import RealmSwift

class Actor : Object {
    @objc dynamic var id : Int = 0
    @objc dynamic var photo : String = ""
    //var imdb_id : Int?
    @objc dynamic var name : String = ""
    @objc dynamic var birthYear : String = ""
    @objc dynamic var deathDay : String = ""
    @objc dynamic var biography : String = ""
    @objc dynamic var gender : Int = 0//0 = not set, 1 = female, 2 = male
    @objc dynamic var placeOfBirth : String = ""
    @objc dynamic var photoFilePath : String = ""
    @objc dynamic var profilePath : String = ""
    //var also_known_as: [String] = []
    
    convenience init(id: Int, name: String, birthyear: String, deathday: String, biography: String, gender: Int, placeOfBirth: String /*, alsoKnowsAs: [String]*/, photoFilePath : String, profilePath: String){
        self.init()
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
