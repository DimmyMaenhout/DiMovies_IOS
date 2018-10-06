import Foundation
import UIKit

class MovieSelectionViewController : UIViewController {
    
    var movieTask: URLSessionTask?
    let session = URLSession(configuration: .ephemeral)
    let apiKey = "fba7c35c2680c39c8829a17d5e902b97"
    let baseURL_TMDB = "https://api.themoviedb.org/3"
    //for actor photo
    let baseUrl = "https://image.tmdb.org/t/p/"
    let originalPosterSize = "original"
    //Movie selected from MovieViewController
    var movie : Movie!
//    var movieDetails : [String : Any] = [:]
//    var actor : Actor!
    //gaan we opvullen met actors die we hebben opgehaald (eerst converteren van JSON naar object!)
    var actors : [Actor] = []
    var actorsWithDetails : [Actor] = []
    var cast: [[String : Actor]] = [[:]]
    var stars: [String] = []
    var youtubeTrailerKey = ""
    
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let movieID = movie.id else {
            print("Movie Selection View Controlelr line 34, movieID is nil")
            return
        }
        print("Movie selection view controller line 38, movieID = \(movieID)")
        getMovieDetails(for: movieID)
        getYoutubeTrailerKey(for: movieID)
        getCast(for: movieID)
//        De code in de dispatchGrupo.notifiy zou pas moeten uitgevoerd worden als de andere calls klaar zijn
        dispatchGroup.notify(queue: .global()){
            print("Movie selection view controller line 44, # actors: \(self.actors.count) actors: \(self.actors)")
            for actor in self.actors {
                print("Movie selection view controller line 46,\(actor) actorID: \(actor.id)")
                self.getActorDetails(for: actor.id)
            }
            print("Movie selection view controller line 49, # cast \(self.cast.count) cast: \(self.cast)")
            print("Movie selection view controller line 50, # actorsWithDetails \(self.actorsWithDetails.count) cast: \(self.actorsWithDetails)")
        }

        print("Movie selection view controller line 53, # cast: \(cast.count)\t # actors: \(actors.count)")
//        Updaten van de UI (moet op de main thread gebeuren)
        dispatchGroup.notify(queue: .main){
            self.tableView.reloadData()
        }
    }
    
    func getMovieDetails(for movieID: Int) {
        movieTask = TmdbAPIService.getMovieDetails(for: movieID, completion: { (movieDetails) in
            guard let movieDetails = movieDetails else {
                return
            }
            self.movie = movieDetails
        })
        movieTask!.resume()
    }
    
    func getYoutubeTrailerKey(for movieID: Int) {
        movieTask = TmdbAPIService.getTrailerUrlKey(for: movieID, completion: { (urlKey) in
            guard let urlKey = urlKey else {
                return
            }
            self.youtubeTrailerKey = urlKey
        })
        movieTask!.resume()
    }
    
    func getCast(for movieID: Int) {
        dispatchGroup.enter()
        movieTask = TmdbAPIService.getCast(for: movieID, completion: { (actors) in
            guard let actors = actors else {
                return
            }
            self.actors = actors
            print("Movie selection view controller line 87, # actors: \(actors.count)")
            self.dispatchGroup.leave()
        })
        movieTask!.resume()
        
    }
    
    func getActorDetails(for actorID: Int) {
        dispatchGroup.enter()
        movieTask = TmdbAPIService.getActorInfo(for: actorID, completion: { (actorDetails) in
            guard let actor = actorDetails else {
                return
            }
            self.cast.append([actor.name : actor])
            self.actorsWithDetails.append(actor)
            print("Movie selection view controller line 102, actor: \(actor.biography)")
            print("Movie selection view controller line 103, cast: \(self.cast.count) \t # actors: \(self.actors.count) \t # actorsWithDetails: \(self.actorsWithDetails.count)")
            self.tableView.reloadData()
            self.dispatchGroup.leave()
        })
        print("Movie selection view controller line 107, cast: \(self.cast.count) \t # actors: \(self.actors.count)")
        movieTask!.resume()
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
        print("Movie Selection view controller line 126, nr of rows: \(actorsWithDetails.count + 2)")
        return actorsWithDetails.count + 2//actors.count + 2

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
            
        case 0:
            let movieHeaderCell = tableView.dequeueReusableCell(withIdentifier: "movieHeaderCell", for: indexPath) as! MovieHeaderCell
            
            movieHeaderCell.duration.text = "\(String(describing: movie.duration!))"
            movieHeaderCell.genre.text = movie.genres.joined(separator: ",")

            print("Movie selection view controller line 141, actorsWithDetails.prefix(8): \(actorsWithDetails.prefix(8))")
//            get first 8 cast members
            for i in actorsWithDetails.prefix(8) {
                let actor = i
                stars.append(actor.name)
            }

            let namesStars = stars.joined(separator: ", ")
            movieHeaderCell.starsInMovie.text = namesStars
            print("Movie selection view controller line 150, movie stars: \(movie.stars)")
            movieHeaderCell.overview.text = movie.overview
            print("Movie selection view controller line 152, movie overview: \(movie.overview)")
            let punten : String = String(format: "%.1F",movie.vote_average!)
            movieHeaderCell.score.text = punten
            movieHeaderCell.title.text = movie.title
           
//            Poster for movie, gets the original size of the poster
            let posterUrl = URL(string: baseUrl + originalPosterSize + movie.poster_path)
            let data = try! Data.init(contentsOf: posterUrl!)
            movieHeaderCell.poster.image = UIImage(data: data)
            
            return movieHeaderCell

        case 1:
            let trailerCell = tableView.dequeueReusableCell(withIdentifier: "trailerCell", for: indexPath) as! TrailerCell
            
            let embedUrl = URL(string: "https://www.youtube.com/embed/\(youtubeTrailerKey)")
            let trailerRequest = URLRequest(url: embedUrl!)
            trailerCell.webView.load(trailerRequest)
            
            return trailerCell

        default:
            let actorCell = tableView.dequeueReusableCell(withIdentifier: "actorCell", for: indexPath) as! ActorCell
            
            print("Movie Selection view controller line 176, got here (actor cell), actors[indexPath.row].biography: \(actors[indexPath.row - 2].biography)")
            
            if actorsWithDetails[indexPath.row - 2].biography.isEmpty {
                actorsWithDetails[indexPath.row - 2].biography = "N/A"
            }
            actorCell.bio.text = actorsWithDetails[indexPath.row - 2].biography
            actorCell.name.text = actorsWithDetails[indexPath.row - 2].name
            
            
            if actorsWithDetails[indexPath.row - 2].profilePath != ""  {
                //            image can be displayed with \(baseUrl) + \(sizeProfilePhoto) + imageURL
                let imageURL = actorsWithDetails[indexPath.row - 2].photoFilePath
                let photoURL = URL(string: baseUrl + "original"/* sizeProfilePhoto */+ imageURL)!
                print("Movie Selection view controller line 186, photoUrl: \(photoURL)")
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
