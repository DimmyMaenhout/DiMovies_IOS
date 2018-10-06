import Foundation
import RealmSwift

class Movie : Object {
    @objc dynamic var id : Int = 0
    @objc dynamic var poster_path : String = ""
    @objc dynamic var original_language : String = ""
    @objc dynamic var original_title : String = ""
    @objc dynamic var backdrop_path : String = ""
    @objc dynamic var adult : String = ""
    @objc dynamic var release_date : String = ""
    @objc dynamic var imdb_id : String = ""
    @objc dynamic var title : String = ""
    @objc dynamic var overview : String = ""
    @objc dynamic var duration : Int = 0
    @objc dynamic var budget : Double = 0.0
    @objc dynamic var popularity : Double = 0.0
    //var production_countries : [String] = []
    //var production_companies : []
    @objc dynamic var revenue : Double = 0.0
    @objc dynamic var status : String = ""
    @objc dynamic var tagline : String = ""
    @objc dynamic var video : Bool = false
    @objc dynamic var vote_average : Double = 0.0
    @objc dynamic var vote_count : Int = 0
    @objc dynamic var stars : String = ""
    //film heeft een array waarin id's (int) en name (string) zit dus gaan we name ophalen
    @objc dynamic var genres : [String] = []
    @objc dynamic var trailerUrl : String = ""
    
    
    convenience init(movie_id: Int, imdb_id: String, title: String, overview: String, duration: Int, budget: Double, popularity: Double, releaseDate: String, revenue: Double, status: String, tagline: String, video: Bool, vote_average: Double, votecount: Int, stars: String, genres : [String], poster_path: String, trailerUrl: String) {
        
        self.init()
        self.id = movie_id
        self.imdb_id = imdb_id
        self.title = title
        self.overview = overview
        self.duration = duration
        self.budget = budget
        self.popularity = popularity
        self.release_date = releaseDate
        self.revenue = revenue
        self.status = status
        self.tagline = tagline
        self.video = video
        self.vote_average = vote_average
        self.vote_count = votecount
        self.stars = stars
        self.genres = genres
        self.poster_path = poster_path
        self.trailerUrl = trailerUrl
    }
}

enum Type: Int {
    case Movies = 0, Series
}
