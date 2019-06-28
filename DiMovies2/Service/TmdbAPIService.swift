import Foundation

enum TmdbAPIService {
    
    private static let session = URLSession(configuration: .ephemeral)
    
    //MARK: Ophalen films die momenteel in de cinema spelen
    static func getMoviesPlaying(with page: Int, completion: @escaping ([Movie]?) -> Void) -> URLSessionTask {
        let url = URL(string: "\(TmdbApiData.baseURL_TMDB)\(TmdbApiData.moviesPlayingURL)page=\(page)&language=en-US&api_key=\(TmdbApiPrivateData.apiKey)")!
        
        return session.dataTask(with: url) {
            data, response, error in
            let completion: ([Movie]?) -> Void = {
                movies in
                DispatchQueue.main.async {
                    //MARK: Points to the completion as parameter in func
                    completion(movies)
                }
            }
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    completion(nil)
                    return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let json = result!["results"] as? [[String: Any]] else {
                    completion(nil)
                    return
            }

            var movies : [Movie] = []
            for i in 0 ... json.count - 1 {
                let movie = json[i]
                movies.append(Movie(movie_id: movie["id"] as! Int,
                                    imdb_id: "",
                                    title: movie["title"] as! String,
                                    overview: movie["overview"] as! String,
                                    duration: 0,
                                    popularity: movie["popularity"] as! Double,
                                    releaseDate: movie["release_date"] as! String,
                                    status: "",
                                    tagline: "",
                                    vote_average: movie["vote_average"] as! Double,
                                    votecount: movie["vote_count"] as! Int,
                                    stars: "",
                                    //                                   genres: [],
                    poster_path: movie["poster_path"] as? String ?? "",
                    trailerUrl: ""))
            }
            completion(movies)
        }
    }
    
    //Mark: Get details for every movie
    static func getMovieDetails(for movieID: Int, completion: @escaping (Movie?) -> Void) -> URLSessionTask {
        
        let url = URL(string: "\(TmdbApiData.baseURL_TMDB)/movie/\(movieID)?language=en-US&api_key=\(TmdbApiPrivateData.apiKey)")!
        
        return session.dataTask(with: url) {
            data, response, error in
            
            let completion: (Movie?) -> Void = {
                movie in
                DispatchQueue.main.async {
                    completion(movie)
                }
            }
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    completion(nil)
                    return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data),
                let json = result as? [String: Any] else {
                    completion(nil)
                    return
            }
            print("Tmdb API Service line 80, json: \(json)")
            let film = Movie(movie_id: json["id"] as! Int,
                             imdb_id: "",
                             title: json["title"] as! String,
                             overview: json["overview"] as! String,
                             duration: json["runtime"] as? Int ?? 0,
                             popularity: json["popularity"] as! Double,
                             releaseDate: json["release_date"] as! String,
                             status: json["status"] as! String,
                             tagline: json["tagline"] as! String,
                             vote_average: json["vote_average"] as! Double,
                             votecount: json["vote_count"] as! Int,
                             stars: "",
                             poster_path: json["poster_path"] as? String ?? "",
                             trailerUrl: "")
            
            completion(film)
        }
    }
    
    //Mark: Get cast (actors) who played in the movie
    static func getCast(for movieID: Int, completion: @escaping ([Actor]?) -> Void) -> URLSessionTask {
        let url = URL(string: "\(TmdbApiData.baseURL_TMDB)/movie/\(movieID)/credits?api_key=\(TmdbApiPrivateData.apiKey)")!
        
        return session.dataTask(with: url) {
            data, response, error in
            let completion: ([Actor]?) -> Void = {
                actors in
                DispatchQueue.main.async {
                    completion(actors)
                }
            }
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    print("Tmdb API Service line 138, response or data is nil")
                    completion(nil)
                    return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let json = result!["cast"] as? [[String: Any]] else {
                    print("Tmdb API Service line 146, result is nil")
                    completion(nil)
                    return
            }
            
            var cast : [Actor] = []
            for i in 0 ... json.count - 1 {
                let actor = json[i]
                cast.append(Actor(id: actor["id"] as! Int,
                                  name: actor["name"] as! String,
                                  birthyear: "",
                                  deathday: "",
                                  biography: "",
                                  gender: actor["gender"] as! Int,
                                  placeOfBirth: "",
                                  photoFilePath: "",
                                  profilePath: ""))
            }
//            for i in 0 ... cast.count - 1 {
//                let actor = cast[i]
//            }
            completion(cast)
        }
    }
    
    static func getActorInfo(for actorID: Int, completion: @escaping (Actor?) -> Void) -> URLSessionTask {
        
        let url = URL(string: "\(TmdbApiData.baseURL_TMDB)/person/\(actorID)?api_key=\(TmdbApiPrivateData.apiKey)&append_to_response=images")!
        
        return session.dataTask(with: url){
            data, response, error in
            let completion: (Actor?) -> Void = {
                actor in
                DispatchQueue.main.async {
                    completion(actor)
                }
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    print("Tmdb API Service line 190, response/data is nil, for actorID: \(actorID)")
                    completion(nil)
                    return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Tmdb API Service line 195, result is nil")
                completion(nil)
                return
            }
            guard let images = result!["images"] as! [String: [Any]]? else {
                completion(nil)
                return
            }
            
            guard let profiles = images["profiles"],
                let lastImageObject = profiles.last as! [String: Any]?,
                let imagePath = lastImageObject["file_path"] as! String?else {
                    completion(nil)
                    return
            }
            
            let actor = Actor(id: result!["id"] as! Int,
                              name: result!["name"] as! String,
                              birthyear: result!["birthday"] as? String ?? "N/A",
                              deathday: "", //result!["deathday"] as! String,
                biography: result!["biography"] as? String ?? "N/A",
                gender: result!["gender"] as! Int,
                placeOfBirth: result!["place_of_birth"] as? String ?? "N/A",
                photoFilePath: imagePath,
                profilePath: result!["profile_path"] as! String)
            //print("TMDB API Service line 226, actor biography: \(actor.biography)")
            completion(actor)
        }
    }
    
    //MARK: Get youtube key for trailer
    static func getTrailerUrlKey(for movieID: Int, completion: @escaping (String?) -> Void) -> URLSessionTask {
        //http://api.themoviedb.org/3/movie/400/videos?api_key=apiKey
        let url = URL(string: "\(TmdbApiData.baseURL_TMDB)/movie/\(movieID)/videos?api_key=\(TmdbApiPrivateData.apiKey)")!
        
        return session.dataTask(with: url) {
            data, response, error in
            let completion: (String?) -> Void = {
                youtubeKey in
                DispatchQueue.main.async {
                    completion(youtubeKey)
                }
            }
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    completion(nil)
                    return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let json = result!["results"] as? [[String: Any]] else {
                    completion(nil)
                    return
            }
            
            var youtubeKey = ""
            if json.count > 0 {
                youtubeKey = json[0]["key"]! as! String
            }
            
            completion(youtubeKey)
        }
    }
    
    //MARK: Get movie by name
    static func getMovieByName(for movieName: String, page: Int, completion: @escaping ([Movie]?) -> Void) -> URLSessionTask {
        let movie = movieName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let url = URL(string: "\(TmdbApiData.baseURL_TMDB)/search/movie?api_key=\(TmdbApiPrivateData.apiKey)&language=en-US&query=\(movie!)&page=\(page)&include_adult=false")!
        
        return session.dataTask(with: url) {
            data, response, error in
            let completion: ([Movie]?) -> Void = {
                movies in
                DispatchQueue.main.async {
                    //MARK: Points to completion as paramter in func
                    completion(movies)
                }
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    completion(nil)
                    return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let json = result!["results"] as? [[String: Any]] else {
                    print("Tmbd API Service line 40, result or json is nil")
                    completion(nil)
                    return
            }
            guard let posters = json.first else {
                completion(nil)
                return
            }
            
            var movies : [Movie] = []
            for i in 0 ... json.count - 1 {
                let movie = json[i]
                
                movies.append(Movie(movie_id: movie["id"] as! Int,
                                    imdb_id: "",
                                    title: movie["title"] as! String,
                                    overview: movie["overview"] as! String,
                                    duration: 0,
                                    popularity: movie["popularity"] as! Double,
                                    releaseDate: movie["release_date"] as! String,
                                    status: "",
                                    tagline: "",
                                    vote_average: movie["vote_average"] as! Double,
                                    votecount: movie["vote_count"] as! Int,
                                    stars: "",
                                    // genres: [],
                                    poster_path: movie["poster_path"]as? String ?? "",
                                    trailerUrl: ""))
                
            }
            
            completion(movies)
        }
    }
}
