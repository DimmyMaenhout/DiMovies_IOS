import Foundation
//import Alamofire

enum TmdbAPIService {
    
    private static let session = URLSession(configuration: .ephemeral)
    private static let apiKey = "fba7c35c2680c39c8829a17d5e902b97"
    private static let baseURL_TMDB = "https://api.themoviedb.org/3"
    //voor poster
    private static let baseUrlPoster = "https://image.tmdb.org/t/p/"
    private static let sizePoster = "w92"
    //size poster actor
    private static let sizeProfilePhoto = "w45"
    
    /*
        Ophalen films die momenteel in de cinema spelen
    */
    static func getMoviesPlaying(completion: @escaping ([Movie]?) -> Void) -> URLSessionTask {
        let url = URL(string: "\(baseURL_TMDB)/movie/now_playing?page=1&language=en-US&api_key=\(apiKey)")!
        
        return session.dataTask(with: url) {
            data, response, error in
            let completion: ([Movie]?) -> Void = {
                movies in
                DispatchQueue.main.async {
//                    verwijst naar completion als parameter in func
                    completion(movies)
                }
            }
//             print("Tmbd API Service line 26, got till here")
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    completion(nil)
                    return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let json = result!["results"] as? [[String: Any]] else {
//                    print("Tmbd API Service line 40, result or json is nil")
                    completion(nil)
                    return
            }
//            print("Tmbd API Service line 43, result: \(String(describing: result))")
            var movies : [Movie] = []
            for i in 0 ... json.count - 1 {
                let movie = json[i]
                movies.append(Movie(movie_id: movie["id"] as! Int,
                                   imdb_id: "",
                                   title: movie["title"] as! String,
                                   overview: movie["overview"] as! String,
                                   duration: 0,
                                   budget: 0.0,
                                   popularity: movie["popularity"] as! Double,
                                   releaseDate: movie["release_date"] as! String,
                                   revenue: 0.0,
                                   status: "",
                                   tagline: "",
                                   video: movie["video"] as! Bool,
                                   vote_average: movie["vote_average"] as! Double,
                                   votecount: movie["vote_count"] as! Int,
                                   stars: "",
                                   genres: [],
                                   poster_path: movie["poster_path"] as? String ?? "",
                                   trailerUrl: ""))
                
            }
            completion(movies)
        }
    }
    /* Details van elke film ophalen */
    static func getMovieDetails(for movieID: Int, completion: @escaping (Movie?) -> Void) -> URLSessionTask {
//        Nog checken of er null waarden in de json zitten, bv bij 
        let url = URL(string: "\(baseURL_TMDB)/movie/\(movieID)?language=en-US&api_key=\(apiKey)")!
        print("Tmbd API Service line 73, movieID: \(movieID)")
        return session.dataTask(with: url) {
            data, response, error in
            print("Tmbd API Service line 76, got here")
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
            
            print("Tmdb API Service line 94, result: \(result)")
            print("Tmdb API Service line 95, json: \(json)")
            let film = Movie(movie_id: json["id"] as! Int,
                             imdb_id: "",
                             title: json["title"] as! String,
                             overview: json["overview"] as! String,
                             duration: json["runtime"] as? Int ?? 0,
                             budget: json["budget"] as! Double,
                             popularity: json["popularity"] as! Double,
                             releaseDate: json["release_date"] as! String,
                             revenue: json["revenue"] as! Double,
                             status: json["status"] as! String,
                             tagline: json["tagline"] as! String,
                             video: json["video"] as! Bool,
                             vote_average: json["vote_average"] as! Double,
                             votecount: json["vote_count"] as! Int,
                             stars: "",
                             genres: [""],
                             poster_path: json["poster_path"] as! String,
                             trailerUrl: "")
            
            completion(film)
        }
    }
    
    /*
     Ophalen cast (acteurs) die hebben meegespeeld in de film
    */
    static func getCast(for movieID: Int, completion: @escaping ([Actor]?) -> Void) -> URLSessionTask {
        let url = URL(string: "\(baseURL_TMDB)/movie/\(movieID)/credits?api_key=\(apiKey)")!
        
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
            //print("Tmbd API Service line 113, getCast response: \(response)")
            //print("Tmbd API Service line 115, getCast data: \(data)")
            guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let json = result!["cast"] as? [[String: Any]] else {
                    print("Tmdb API Service line 146, result is nil")
                    completion(nil)
                    return
            }
//            print("Tmbd API Service line 124, getCast result: \(String(describing: result))")
            print("Tmbd API Service line 151, getCast json: \(json)")
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
//                print("Tmdb API Service line 139, actor \(i): \(actor)")
            }
            for i in 0 ... cast.count - 1 {
                let actor = cast[i]
                print("actor \(i): \(actor.name)\n \(actor.id)")
            }
            completion(cast)
        }
    }
    
    static func getActorInfo(for actorID: Int, completion: @escaping (Actor?) -> Void) -> URLSessionTask {
        
        let url = URL(string: "\(baseURL_TMDB)/person/\(actorID)?api_key=\(apiKey)&append_to_response=images")! //\(actorID)
        print("TMDB API Service line 177, url: \(url)")
        return session.dataTask(with: url){
            data, response, error in
            let completion: (Actor?) -> Void = {
                actor in
                DispatchQueue.main.async {
                    completion(actor)
                }
            }
            print("Tmdb API Service line 186, data: \(String(describing: data))")
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
            print("Tmdb API Service line 203, images: \(String(describing: images)) \n images[profiles]\(String(describing: images["profiles"]))")
            print("Tmdb API Service line 204, result: \(String(describing: result))")
            guard let profiles = images["profiles"],
                let lastImageObject = profiles.last as! [String: Any]?,
                let imagePath = lastImageObject["file_path"] as! String?else {
                completion(nil)
                return
            }
            print("Tmdb API Service line 211, lastImageObject: \(String(describing: lastImageObject))")
            print("Tmdb API Service line 212, imagePath: \(String(describing: imagePath))")

            let actor = Actor(id: result!["id"] as! Int,
                              name: result!["name"] as! String,
                              birthyear: result!["birthday"] as? String ?? "N/A",
                              deathday: "", //result!["deathday"] as! String,
                              biography: result!["biography"] as? String ?? "N/A",
                              gender: result!["gender"] as! Int,
                              placeOfBirth: result!["place_of_birth"] as? String ?? "N/A",
                              photoFilePath: imagePath,
                              profilePath: result!["profile_path"] as! String)
            print("TMDB API Service line 226, actor biography: \(actor.biography)")
            completion(actor)
        }
    }
    
    /*
     Ophalen van de youtube key voor de film
    */
    static func getTrailerUrlKey(for movieID: Int, completion: @escaping (String?) -> Void) -> URLSessionTask {
        //http://api.themoviedb.org/3/movie/400/videos?api_key=fba7c35c2680c39c8829a17d5e902b97
        let url = URL(string: "\(baseURL_TMDB)/movie/\(movieID)/videos?api_key=\(apiKey)")!
        
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
            print("TMDB API Service line 257, result: \(String(describing: result))")
            print("TMDB API Service line 258, json: \(json)")
            
            var youtubeKey = ""
            if json.count > 0 {
                print("TMDB API Service line 262, json[0][key]: \(describing: json[0]["key"])")
                
                youtubeKey = json[0]["key"]! as! String
            }
            print("TMDB API Service line 266, youtubeKey: \(youtubeKey)")
            
            completion(youtubeKey)
        }
    }
    
    /*
        vb werkende url adhv titel
        https://api.themoviedb.org/3/search/movie?api_key=fba7c35c2680c39c8829a17d5e902b97&query=the+fast+and+the+furious
        baseURL_TMDB/search/movie?api_key=apiKey&query=the+fast+and+the+furious
    */
    static func getMovieByName(for movieName: String, completion: @escaping ([Movie]?) -> Void) -> URLSessionTask {
//        https://api.themoviedb.org/3/search/movie?api_key=fba7c35c2680c39c8829a17d5e902b97&language=en-US&query=the%20best%20of%20me&page=1&include_adult=false
        let movie = movieName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        print("TMDB API service line 275, \(String(describing: movie!))")
        
        let url = URL(string: "\(baseURL_TMDB)/search/movie?api_key=\(apiKey)&language=en-US&query=\(movie!)&include_adult=false")!
        
        print("TMDB API Service line 279, url: \(url)")
        return session.dataTask(with: url) {
            data, response, error in
            let completion: ([Movie]?) -> Void = {
                movies in
                DispatchQueue.main.async {
                    //                    verwijst naar completion als parameter in func
                    completion(movies)
                }
            }

            print("TDMB API Service line 290, error: \(String(describing: error))")
//            print("TMDB API Service line 244, got till here")
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    completion(nil)
                    return
            }
            guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let json = result!["results"] as? [[String: Any]] else {
                    //                    print("Tmbd API Service line 40, result or json is nil")
                    completion(nil)
                    return
            }
            print("Tmbd API Service line 304, getMovieByName json: \(json)")
//            print("Tmbd API Service line 253, getMovieByName response: \(response)")
//            guard let poster = movie!["poster_path"] else {
//                completion nil
//                return
//            }
            guard let posters = json.first as! [String: Any]? else {
                completion(nil)
                return
            }
            print("Tmbd API Service line 314, getMovieByName posters: \(posters)")
            var movies : [Movie] = []
            for i in 0 ... json.count - 1 {
                let movie = json[i]
                print("Tmbd API Service line 318, getMovieByName poster_path: \(String(describing: movie["poster_path"]))")
                movies.append(Movie(movie_id: movie["id"] as! Int,
                                    imdb_id: "",
                                    title: movie["title"] as! String,
                                    overview: movie["overview"] as! String,
                                    duration: 0,
                                    budget: 0.0,
                                    popularity: movie["popularity"] as! Double,
                                    releaseDate: movie["release_date"] as! String,
                                    revenue: 0.0,
                                    status: "",
                                    tagline: "",
                                    video: movie["video"] as! Bool,
                                    vote_average: movie["vote_average"] as! Double,
                                    votecount: movie["vote_count"] as! Int,
                                    stars: "",
                                    genres: [],
                                    poster_path: movie["poster_path"]as? String ?? "",
                                    trailerUrl: ""))
                
            }
            print("TMDB API Service line 339, movies.count = \(movies.count)")
            
            completion(movies)
        }
    }
}
