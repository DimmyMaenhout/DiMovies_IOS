import RealmSwift

class User : Object {

    @objc dynamic var username : String = ""
    
    let moviesSeen = List<Movie>()
    let moviesToWatch = List<Movie>()
    
    convenience init(username: String) {
        self.init()
        self.username = username
    }
    
}
