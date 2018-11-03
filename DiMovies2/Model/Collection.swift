import Foundation
import RealmSwift

class Collection: Object {
    
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""
    
    let movies = List<Movie>()
    
    convenience init(name: String, id: Int){
        self.init()
        self.name = name
        self.id = id
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
        self.id = incrementCollectionID()
    }
}

extension Collection  {
    func incrementCollectionID() -> Int {
        
        let realm = try! Realm()
        return (realm.objects(Collection.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
//    Geeft de collectie met overeenkomstig id terug
    static func getCollection(with id: Int) -> Collection {
        
        let realm = try! Realm()
        return realm.objects(Collection.self).filter("id == \(id)").first!
    }
}
