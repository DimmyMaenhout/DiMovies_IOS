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
    
    static func getMoviesPlaying(completion: @escaping ([Movie]?) -> Void) -> URLSessionTask {
        let url = URL(string: "\(baseURL_TMDB)/movie/now_playing?page=1&language=en-US&api_key=\(apiKey)")!
        
        return session.dataTask(with: url) {
            data, response, error in
            let completion: ([Movie]?) -> Void = {
                movies in
                DispatchQueue.main.async {
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
            var movies : [Movie] = []
            for i in 0 ... json.count - 1 {
                let movie = json[i]
                movies.append(Movie(movie_id: movie["id"] as! Int,
                                   imdb_id: "",
                                   title: movie["title"] as! String,
                                   overview: movie["overview"] as! String,
                                   duration: "",
                                   budget: 0.0,
                                   popularity: movie["popularity"] as! Double,
                                   releaseDate: movie["release_date"] as! String,
                                   revenue: 0.0,
                                   status: "",
                                   tagline: "",
                                   video: movie["video"] as! Bool,
                                   vote_average: movie["vote_average"] as! Double,
                                   votecount: movie["vote_count"] as! Int,
                                   writer: "",
                                   director: "",
                                   stars: "",
                                   genres: [],
                                   poster_path: movie["poster_path"] as! String))
            }
            completion(movies)
        }
    }
    
    static func getMovieDetails(for movieID: Int, completion: @escaping (Movie?) -> Void) -> URLSessionTask {
        let url = URL(string: "\(baseURL_TMDB)/movie/\(movieID)?language=en-US&api_key=\(apiKey)")!
        print("Tmbd API Service line 76, movieID: \(movieID)")
        return session.dataTask(with: url) {
            data, response, error in
            print("Tmbd API Service line 71, got here")
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
            print("Tmdb API Service line 89, result: \(result)")
        }
    }
 /*
     data, response, error in
     print("Tmbd API Service line 71, response: \(response)")
     print("Tmbd API Service line 72, error: \(error)")
     let completion: (Movie?) -> Void = {
     movie in
     DispatchQueue.main.async {
     print("Tmbd API Service line 82, got till here")
     completion(movie)
     }
     }
     print("Tmbd API Service line 85, got till here")
     guard let response = response as? HTTPURLResponse,
     response.statusCode == 200,
     let data = data else {
     print("Tmbd API Service line 85, response/data is nil")
     completion(nil)
     return
     }
     guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any]//,
     /*let json = result![]]*/ else {
     completion(nil)
     return
     }
     print("Tmdb API Service line 96, result: \(result)")
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
                    print("Tmdb API Service line 112, response or data is nil")
                    completion(nil)
                    return
            }
            //print("Tmbd API Service line 113, getCast response: \(response)")
            //print("Tmbd API Service line 114, getCast response.statusCode: \(response.statusCode)")
            //print("Tmbd API Service line 115, getCast data: \(data)")
            guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let json = result!["cast"] as? [[String: Any]] else {
                    print("Tmdb API Service line 118, result is nil")
                    completion(nil)
                    return
            }
//            print("Tmbd API Service line 124, getCast result: \(String(describing: result))")
            print("Tmbd API Service line 123, getCast json: \(json)")
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
            completion(cast)
        }
    }
    static func getActorInfo(for actorID: Int, completion: @escaping (Actor?) -> Void) -> URLSessionTask {

            let url = URL(string: "\(baseURL_TMDB)/person/\(actorID)?api_key=\(apiKey)&append_to_response=images")!
            
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
                        print("Tmdb API Service line 160, response/data is nil")
                        completion(nil)
                        return
                }
                guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Tmdb API Service line 165, result is nil")
                    completion(nil)
                    return
                }
                print("Tmdb API Service line 169, result: \(String(describing: result))")
                //completion(actor)
            }
            
        //}
        //return completion(actors)
        //return
    }
}
