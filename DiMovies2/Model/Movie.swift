
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
    var duration = ""
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
    var director = ""
    var writer = ""
    var stars = ""
    var genres : [String] = []            //film heeft een array waarin id's (int) en name (string) zit dus gaan we name ophalen
    //    var poster : UIImage = nil
    
    
    convenience init(movie_id: Int, imdb_id: String, title: String, overview: String, duration: String, budget: Double, popularity: Double, releaseDate: String, revenue: Double, status: String, tagline: String, video: Bool, vote_average: Double, votecount: Int, writer : String, director :  String, stars: String, genres : [String], poster_path: String) {
        
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
        self.director = director
        self.writer = writer
        self.stars = stars
        self.genres = genres
        self.poster_path = poster_path
    }
    
}
