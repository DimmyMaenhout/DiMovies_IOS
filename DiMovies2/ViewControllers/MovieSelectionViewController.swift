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
    
    var youtubeTrailerKey = ""
    @IBOutlet weak var tableView: UITableView!
    
    //Voor de cast van de film te krijgen gebruik maken van:
    //                                                          get/movie/{movie_id}/credits
    
    //eens we de persoon id hebben (acteur) kunnen we gebruik maken van 1 van de 3 methoden:
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
            print("Movie Selection View Controlelr line 47, movieID is nil")
            return
        }
        print("Movie selection view controller line 51, movieID: \(String(describing: movieID))")
        
        movieTask?.cancel()
        print("Movie selection view controller line 54, movieTask: \(String(describing: movieTask))")
        movieTask = TmdbAPIService.getMovieDetails(for: movieID){
            self.movie = $0!
            print("MovieSelectionViewController line 57, \(self.movie)")
            self.tableView.reloadData()
        }

        movieTask!.resume()
        movieTask = TmdbAPIService.getCast(for: movieID) {
            print("Movie selection view controller line 63, movieID: \(movieID)")
            self.actors = $0!
            print("Movie selection view controller line 65, # actors: \(self.actors.count)")
            self.tableView.reloadData()
        }
        
//        movieTask?.cancel()
        
        movieTask!.resume()
        while actors.count != 0{
            
            for actor in actors {
                movieTask = TmdbAPIService.getActorInfo(for: actor.id  /* 500 */ ) {
                    print("Movie selection view controller line 73, actorId: \(actor.id)")
                    
                    self.actors.append($0!)
                    print("Movie selection view controller line 76, # actors: \(self.actors.count)")
                    self.tableView.reloadData()
                }
                
                //            movieTask!.resume()
            }
        }
        
        
        movieTask!.resume()
        movieTask = TmdbAPIService.getTrailerUrlKey(for: movieID) {
            self.youtubeTrailerKey = $0!
            print("Movie selection view controller line 85, youtubeTrailerKey = \(self.youtubeTrailerKey)")
        }
        
        movieTask!.resume()
//        self.tableView.reloadData()
    }
}

extension MovieSelectionViewController : UITableViewDelegate{

    
}

extension MovieSelectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        + 2 voor movieHeader en trailerCell
        print("Movie Selection view controller line 107, nr of rows: \(actors.count + 2)")
        return actors.count + 2

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
            
        case 0:
            print("MovieSelectionViewController line 106, movie director: \(movie.director)")
            let movieHeaderCell = tableView.dequeueReusableCell(withIdentifier: "movieHeaderCell", for: indexPath) as! MovieHeaderCell

            movieHeaderCell.nameDirector.text = movie.director
            movieHeaderCell.nameWriter.text = movie.writer
            print("Movie selection view controller line 116, writer: \(movie.writer)")
            movieHeaderCell.duration.text = "\(String(describing: movie.duration!))"
            movieHeaderCell.genre.text = movie.genres.joined(separator: ",")
            movieHeaderCell.starsInMovie.text = movie.stars
            print("Movie selection view controller line 118, movie stars: \(movie.stars)")
            movieHeaderCell.overview.text = movie.overview
            print("Movie selection view controller line 120, movie overview: \(movie.overview)")
            let punten : String = String(format: "%.1F",movie.vote_average!)
            movieHeaderCell.score.text = punten
            movieHeaderCell.title.text = movie.title
           
//            Poster for movie
            let posterUrl = URL(string: baseUrl + sizePoster + movie.poster_path)
            let data = try! Data.init(contentsOf: posterUrl!)
            movieHeaderCell.poster.image = UIImage(data: data)
            
            return movieHeaderCell

        case 1:
            let trailerCell = tableView.dequeueReusableCell(withIdentifier: "trailerCell", for: indexPath) as! TrailerCell
            
            let embedUrl = URL(string: "https://www.youtube.com/embed/\(youtubeTrailerKey)")
            let trailerRequest = URLRequest(url: embedUrl! /*URL(string: movie.trailerUrl)!*/)
            trailerCell.webView.load(trailerRequest)
            
            return trailerCell

        default:
            let actorCell = tableView.dequeueReusableCell(withIdentifier: "actorCell", for: indexPath) as! ActorCell
            print("Movie Selection view controller line 151, got here (actor cell), indexPath: \(indexPath)")
            print("Movie Selection view controller line 152, got here (actor cell), actorsindexPath: \(indexPath)")
            print("Movie Selection view controller line 153, got here (actor cell), actors[indexPath.row].biography: \(actors[indexPath.row - 2].biography)")
            actorCell.bio.text = actors[indexPath.row - 2].biography
            actorCell.name.text = actors[indexPath.row - 2].name
            
            if (actors[indexPath.row - 2].photoFilePath != "") {
                //            image can be displayed with \(baseUrl) + \(sizeProfilePhoto) + imageURL
                let imageURL = actors[indexPath.row - 2].photoFilePath
                let photoURL = URL(string: baseUrl + "original"/* sizeProfilePhoto */+ imageURL)!
                print("Movie Selection view controller line 166, photoUrl: \(photoURL)")
                let data = try! Data.init(contentsOf: photoURL)
                actorCell.photo.image = UIImage(data: data)
            }

            
            return actorCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        switch indexPath.row {
            
            case 0:
                return 475// UITableViewAutomaticDimension
            
            case 1:
                return 250
            
            case 2:
                return 86
            
            default:
                return 86
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
            
            case 0:
                return UITableViewAutomaticDimension
            
            case 2:
                return 86
            
            default:
                return 86
        }
    }
}
