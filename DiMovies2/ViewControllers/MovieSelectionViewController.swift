import Foundation
import UIKit

class MovieSelectionViewController : UIViewController {
    
    var movieTask: URLSessionTask?
    let session = URLSession(configuration: .ephemeral)
    let apiKey = "fba7c35c2680c39c8829a17d5e902b97"
    let baseURL_TMDB = "https://api.themoviedb.org/3"
    //for actor photo
    let baseUrl = "https://image.tmdb.org/t/p/"
    let sizePoster = "w92"
    let sizeProfilePhoto = "w45"
    //film die we krijgen van MovieViewController
    var movie : Movie!
    var movieDetails : [String : Any] = [:]
    var actor : Actor!
    /* voor headercell en actor cells */
    var movieData : [ Int : [Actor]] = [:]
    //gaan we opvullen met actors die we hebben opgehaald (eerst converteren van JSON naar object!)
    var actors : [Actor] = [
                            /*Actor(id: 1, name: "Vin Diesel", birthyear: "1984", deathday: "31", biography: "Actor from the Riddick & Fast and Furious seris", gender: 2, placeOfBirth: "USA", photo_file_path: "photo Vin Diesel" ),
                            Actor(id: 2, name: "Angelina Jolie", birthyear: "1970", deathday: "20", biography: "Actress from Lara Croft", gender: 1, placeOfBirth: "USA", photo_file_path: "photo Angelina Jolie" ),
                            Actor(id: 3, name: "Paul Walker", birthyear: "1964", deathday: "31", biography: "Actor from Fast and Furious 1, 2, 4, 5, 6, 7", gender: 2, placeOfBirth: "USA", photo_file_path: "photo Paul Walker" )*/
                           ]
    var cast : [Dictionary<String, Any>?] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //Voor de cast van de film te krijgen gebruik maken van:
    //                                                          get/movie/{movie_id}/credits
    
    //eens we de persoon id hebben (acteur) kunnen we gebruik amken van 1 van de 3 methoden:
    /*
     http://api.themoviedb.org/3/person/62/movie_credits?api_key=###
     http://api.themoviedb.org/3/person/62/tv_credits?api_key=###
     http://api.themoviedb.org/3/person/62/combined_credits?api_key=###
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let movieID = movie.id else {
            print("Movie Selection View Controlelr line 51, movieID is nil")
            return
        }

        //getMovieDetails(for: movieID)
        movieTask?.cancel()
        print("Movie selection view controller line 57, movieTask: \(String(describing: movieTask))")
        movieTask = TmdbAPIService.getMovieDetails(for: movieID){
            self.movie = $0!
            
        }
        movieTask!.resume()
        movieTask = TmdbAPIService.getCast(for: movieID){
            print("Movie selection view controller line 57, movieID: \(movieID)")
            self.actors = $0!
            self.tableView.reloadData()
        }
        movieTask!.resume()
        for actor in actors {
            movieTask = TmdbAPIService.getActorInfo(for: actor.id){
                print("Movie selection view controller line 57, movieID: \(movieID)")
                self.actors.append($0!) 
                self.tableView.reloadData()
            }
            movieTask!.resume()
        }
        
        
        //getCast(movieID: movie.id!)
        //getActorInfo()
        /*toont film details + de cellen met alle actor cellen*/
        //movieData = [0 : actors]
    }
    
    /*
        ophalen film adhv id
     */
    /*func getMovieDetails(for movieId : Int){
        /* request is based on TMDB api example code (is adapted to what I need)*/
        let postData = NSData(data: "{}".data(using: String.Encoding.utf8)!)
        var request = URLRequest(url: NSURL(string: "\(baseURL_TMDB)/movie/\(movieId)?language=en-US&api_key=\(apiKey)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        print("request lijn 68: \(request)" )
        request.httpMethod = "GET"
        request.httpBody = postData as Data
        
        //let session = URLSession.shared
        print("lijn 75")
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            print("lijn 77")
            if let data = data{
                print("lijn 79")
                if let responsed = try! JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    print("response from TMDB movieDetails: \(responsed)")
                    self.movieDetails = responsed
                    
                    DispatchQueue.main.async {
                        //var genres_names : [String] = self.movieDetails["genres"]!["name"] as! [String]
                        var movie = Movie(movie_id: self.movieDetails["id"] as! Int,
                                          imdb_id: self.movieDetails["imdb_id"] as! String,
                                          title: self.movieDetails["title"] as! String,
                                          overview: self.movieDetails["overview"] as! String,
                                          duration: self.movieDetails["runtime"] as! String,
                                          budget: self.movieDetails["budget"] as! Double,
                                          popularity: self.movieDetails["popularity"] as! Double,
                                          releaseDate: self.movieDetails["release_date"] as! String,//dit is toegevoegd!
                                          revenue: self.movieDetails["revenue"] as! Double,
                                          status: self.movieDetails["status"] as! String,
                                          tagline: self.movieDetails["tagline"] as! String,
                                          video: self.movieDetails["video"] as! Bool,
                                          vote_average: self.movieDetails["vote_average"] as! Double,
                                          votecount: self.movieDetails["vote_count"] as! Int,
                                          writer: "",
                                          director: "",
                                          stars: "",
                                          genres: [self.movieDetails["genres"] as! String],
                                          poster_path: self.movieDetails["poster_path"] as! String)
                        
                    }
                }
                self.tableView.reloadData()
            }
        })
        dataTask.resume()
    }
 */
    
    /*
     ophalen Cast film adhv movie id
     */
    
    //func getCast(movieID : Int){
       
        /*let postData = NSData(data: "{}".data(using: String.Encoding.utf8)!)
        var request = URLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/\(movieId)/credits?api_key=\(apiKey)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data{
                if let responsed = try! JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> {
                    self.cast = responsed["cast"] as! [ Dictionary<String, Any> ]
                    
                    DispatchQueue.main.async {
                        var castActors : [Actor] = []
                        for i in 0 ... self.cast.count - 1{
                            var actor = Actor(
                                               id: self.cast[i]!["id"] as! Int,
                                               name: self.cast[i]!["name"] as! String,
                                               birthyear: "",
                                               deathday: "",
                                               biography: "",
                                               gender: self.cast[i]!["gender"] as! Int,
                                               placeOfBirth: "",
                                               photo_file_path: ""
                                               )
                            castActors.append(actor)
                        }
                        self.actors = castActors
                        for i in castActors{
                            print("Actor: ", i.name)
                        }
                    }
                    
                }
                self.tableView.reloadData()
            }
        })
        
        dataTask.resume()*/
        //TmdbAPIService.getCast(for: movieID)
    //}
    
    /*
     Ophalen info actor adhv id
     */
    /*func getActorInfo(){
        //for photo we need file_path
        //link to get actor account is \(baseURL_TMDB)/person/id/images?\(apiKey)
        
        for i in 0 ... actors.count - 1 {
            let postData = NSData(data: "{}".data(using: String.Encoding.utf8)!) 
            var request = URLRequest(url: NSURL(string: "\(baseURL_TMDB)/person/\(actors[i].id)?api_key=\(apiKey)&append_to_response=images")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
            print("request lijn 163 \(request)")
            request.httpMethod = "GET"
            request.httpBody = postData as Data
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                
                if let data = data{ //vanaf hier terug opzoeken!
                    print("lijn 171 data: \(data)")
                    if let responsed = try! JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> {
                        print("lijn 173 response from TMDB")
                        self.cast = responsed["cast"] as! [ Dictionary<String, Any> ]
                        
                        DispatchQueue.main.async {
                            var castActors : [Actor] = []
                            for i in 0 ... self.cast.count - 1{
                                var actor = Actor( id: self.cast[i]!["id"] as! Int, //opzoeken "Actor has no subscript members"
                                                   name: self.cast[i]!["name"] as! String,
                                                   birthyear: "",
                                                   deathday: "",
                                                   biography: "",
                                                   gender: self.cast[i]!["gender"] as! Int,
                                                   placeOfBirth: "",
                                                   photo_file_path: "" as! String) //nog kijken naar volledige pad,
                                castActors.append(actor)
                            }
                            self.actors = castActors
                            for i in castActors{
                                print("Actor: ", i.name)
                            }
                        }
                        
                    }
                    self.tableView.reloadData()
                }
            })
            dataTask.resume()
        } //end for
    }*/
    
}

extension MovieSelectionViewController : UITableViewDelegate{
    
    /*func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
     
     }*/
}

extension MovieSelectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actors.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row){
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "movieHeaderCell", for: indexPath) as! MovieHeaderCell
            
            cell.nameDirector.text = movie.director
            //cell.duration.text = movie.duration
            cell.genre.text = movie.genres.joined(separator: ",")
            cell.starsInMovie.text = movie.stars
            cell.overview.text = movie.overview
            let punten : String = String(format: "%.1F",movie.vote_average!)
            cell.score.text = punten
            cell.title.text = movie.title
            cell.nameWriter.text = movie.writer
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "actorCell", for: indexPath) as! ActorCell
            
            cell.bio.text = actors[indexPath.row].biography
            cell.name.text = actors[indexPath.row].name
            
            //image can be displayed with \(baseUrl) + \(sizeProfilePhoto) + imageURL
            let imageURL = actors[indexPath.row].photoFilePath
            let photoURL = URL(string: baseUrl + sizeProfilePhoto + imageURL )!
//            let data = try! Data.init(contentsOf: photoURL)
//            cell.photo.image = UIImage(data: data)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row != 0 {
            
            return 86
        }
        else {
            return 450
        }
    }
}
