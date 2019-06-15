import Foundation
import UIKit
import RealmSwift
import SDWebImage

class MovieDetailsViewController : UIViewController {
    
    private var movieTask: URLSessionTask?
    //MARK: Movie selected from MovieViewController
    var movie : Movie!
    private var actors : [Actor] = []
    private var actorsWithDetails : [Actor] = []
    private var stars: [String] = []
    private var youtubeTrailerKey = ""
    private var sv = UIView()
    private var user: User!
    private let dispatchGroup = DispatchGroup()
    
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        user = try! Realm().objects(User.self)[0]
        
        getMovieDetails(for: movie.id)
        getYoutubeTrailerKey(for: movie.id)
        getCast(for: movie.id)
        
        //MARK: De code in de dispatchGroup.notifiy zou pas moeten uitgevoerd worden als de getCast call klaar is
        dispatchGroup.notify(queue: .global()){
            for actor in self.actors {
                self.getActorDetails(for: actor.id)
            }
        }
        //MARK: Updaten van de UI (moet op de main thread gebeuren)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if actors.count == 0 {
             sv = self.displaySpinner(onView: self.tableView)
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
            self.dispatchGroup.leave()
        })
        movieTask!.resume()
    }
    
    func getActorDetails(for actorID: Int) {
        dispatchGroup.enter()
        movieTask = TmdbAPIService.getActorInfo(for: actorID, completion: { (actorDetails) in
            self.removeSpinner(spinner: self.sv)
            guard let actor = actorDetails else {
                return
            }
            
            self.actorsWithDetails.append(actor)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            self.dispatchGroup.leave()
        })
        movieTask!.resume()
    }
}

extension MovieDetailsViewController : UITableViewDelegate{

    
}

extension MovieDetailsViewController: UITableViewDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let addMovieToCollectionViewController = segue.destination as! AddMovieToCollectionViewController
        addMovieToCollectionViewController.movie = movie
    }
    
    @IBAction func unwindToMovieDetail(_ sender: UIStoryboardSegue) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //MARK: + 2 voor movieHeader en trailerCell
        return actorsWithDetails.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
            
        case 0:
            let movieHeaderCell = tableView.dequeueReusableCell(withIdentifier: Constants.movieHeaderCellIdentifier, for: indexPath) as! MovieHeaderCell
            
            movieHeaderCell.duration.text = "\(String(describing: movie.duration))"
//            movieHeaderCell.genre.text = movie.genres.joined(separator: ",")

            //MARK: get first 8 cast members
            if stars.isEmpty || stars.count != 8 {
                stars.removeAll()
                for i in actorsWithDetails.prefix(8) {
                    let actor = i
                    stars.append(actor.name)
                }
            }
            movieHeaderCell.releaseDate.text = movie.release_date
            let namesStars = stars.joined(separator: ", ")
            movieHeaderCell.starsInMovie.text = namesStars
            movieHeaderCell.overview.text = movie.overview
            
            let punten : String = String(format: "%.1F",movie.vote_average)
            movieHeaderCell.score.text = punten
            movieHeaderCell.title.text = movie.title
           
            // MARK: Poster for movie, gets the (small) size of the poster
            if !movie.poster_path.isEmpty {
                let posterUrl = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePosterW342 + movie.poster_path)
                movieHeaderCell.poster.sd_setImage(with: posterUrl)
            }
            return movieHeaderCell

        case 1:
            let trailerCell = tableView.dequeueReusableCell(withIdentifier: Constants.trailerCellIdentifier, for: indexPath) as! TrailerCell
            let embedUrl = URL(string: "\(Constants.youtubeEmbedURL)\(youtubeTrailerKey)")
            let trailerRequest = URLRequest(url: embedUrl!)
            trailerCell.webView.load(trailerRequest)
            
            return trailerCell

        default:
            let actorCell = tableView.dequeueReusableCell(withIdentifier: Constants.actorCellIdentifier, for: indexPath) as! ActorCell
            
            if actorsWithDetails[indexPath.row - 2].biography.isEmpty {
                actorsWithDetails[indexPath.row - 2].biography = Constants.notAvailableString
            }
            actorCell.bio.text = actorsWithDetails[indexPath.row - 2].biography
            actorCell.name.text = actorsWithDetails[indexPath.row - 2].name
            
            
            if !actorsWithDetails[indexPath.row - 2].profilePath.isEmpty  {
                //MARK: image can be displayed with \(baseUrl) + \(sizeProfilePhoto) + imageURL
                let imageURL = actorsWithDetails[indexPath.row - 2].photoFilePath
                let photoURL = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePosterW92 + imageURL)!
                actorCell.photo.sd_setImage(with: photoURL)
            }
            return actorCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
            
            case 0:
                return 475
            
            case 1:
                return 250
            
            default:
                return 120
        }
    }
}
