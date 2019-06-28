import RealmSwift

class DataRepo {
    
    init() {
        let user = User(username: "User")
        
        let moviesSeen = Collection(name: "Seen", id: 0)
        let wantToWatchMovies = Collection(name: "Want to watch", id: 1)
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(user)
            
            user.collections.append(moviesSeen)
            user.collections.append(wantToWatchMovies)
        }
    }
}
