
import Foundation

class Movie {
    var id : Int?
    var poster_path = ""
    var original_language = ""
    var original_title = ""
    var backdrop_path = ""
    var adult = ""
    var release_date = ""
    var imdb_id = ""
    var title = ""
    var overview = ""
    var duration : Int?
    var budget : Double?
    
    var popularity : Double?
    //var production_countries : [String] = []
    //var production_companies : []
    var revenue : Double?
    var status = ""
    var tagline = ""
    var video = false
    var vote_average : Double?
    var vote_count : Int?
    var stars = ""
    var genres : [String] = []            //film heeft een array waarin id's (int) en name (string) zit dus gaan we name ophalen
    //    var poster : UIImage = nil
    var trailerUrl = ""
    
    
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
