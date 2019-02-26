import Foundation
import UIKit
import RealmSwift

class MovieDetailsViewController : UIViewController {
    
    var movieTask: URLSessionTask?
    //Movie selected from MovieViewController
    var movie : Movie!
    //gaan we opvullen met actors die we hebben opgehaald (eerst converteren van JSON naar object!)
    var actors : [Actor] = []
    var actorsWithDetails : [Actor] = []
    var stars: [String] = []
    var youtubeTrailerKey = ""
    
    let dispatchGroup = DispatchGroup()
    var sv = UIView()
    var user: User!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        user = try! Realm().objects(User.self)[0]
        
        getMovieDetails(for: movie.id)
        getYoutubeTrailerKey(for: movie.id)
        getCast(for: movie.id)
        
//        De code in de dispatchGroup.notifiy zou pas moeten uitgevoerd worden als de andere calls klaar zijn
        dispatchGroup.notify(queue: .global()){
            print("Movie selection view controller line 34, # actors: \(self.actors.count) actors: \(self.actors)")
            for actor in self.actors {

                self.getActorDetails(for: actor.id)
            }
        }
//        Updaten van de UI (moet op de main thread gebeuren)
        dispatchGroup.notify(queue: .main){
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if actors.count == 0 {
             sv = UIViewController.displaySpinner(onView: self.tableView)
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
            print("Movie selection view controller line 79, # actors: \(actors.count)")
            self.dispatchGroup.leave()
        })
        movieTask!.resume()
    }
    
    func getActorDetails(for actorID: Int) {
        dispatchGroup.enter()
        movieTask = TmdbAPIService.getActorInfo(for: actorID, completion: { (actorDetails) in
            UIViewController.removeSpinner(spinner: self.sv)
            guard let actor = actorDetails else {
                return
            }
            self.actorsWithDetails.append(actor)
            self.tableView.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        + 2 voor movieHeader en trailerCell
        print("Movie Selection view controller line 114, nr of rows: \(actorsWithDetails.count + 2)")
        return actorsWithDetails.count + 2
    }

    @objc func wantToWatchTriggered(_ sender: AnyObject){

        let realm = try! Realm()
        let header = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! MovieHeaderCell
        
        if header.wantToWatchMovie.isOn {
            
            if header.seenMovie.isOn {
                
                header.seenMovie.isOn = false
                
                try! realm.write {

                    let deleteMovieFromCollection = user.collections.filter("id == 1").first!.movies.filter("id == \(movie.id)").first!
                    let deleteIndex = user.collections.filter("id == 0").first!.movies.index(of: deleteMovieFromCollection)
                    
                    let message = "\(deleteMovieFromCollection.title) is removed from 'Movies seen'"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    self.present(alert, animated: true)
                    
                    // duration in seconds
                    let duration: Double = 2
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                        alert.dismiss(animated: true)
                    }
                    user.collections.filter("id == 0").first!.movies.remove(at: deleteIndex!)
                }
            }
            
            try! realm.write {
                let message = "\(movie.title) is added to 'Movies to watch'"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.present(alert, animated: true)
                
                // duration in seconds
                let duration: Double = 2
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    alert.dismiss(animated: true)
                }
                user.collections.filter("id == 1").first!.movies.append(movie)
                print("Movie selection view controller line 140, # movies to watch: \(user.collections.filter("id == 1").first!.movies.count)")
            }
        }
//        switch staat uit dus film mag ook niet in "want to watch" lijst zitten
        else {
            if checkIfMovieAlreadyInDb(for: user!.moviesToWatch) == true {
                try! realm.write {
                    
                    let deleteMovieFromCollection = user.collections.filter("id == 1").first!.movies.filter("id == \(movie.id)").first
                    let deleteIndex = user.moviesToWatch.index(of: deleteMovieFromCollection!)
                    
                    let message = "\(deleteMovieFromCollection!.title) is removed from 'Movies to watch'"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    self.present(alert, animated: true)
                    
                    // duration in seconds
                    let duration: Double = 2
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                        alert.dismiss(animated: true)
                    }
                    user.collections.filter("id == 1").first!.movies.remove(at: deleteIndex!)
                }
            }
        }
    }
    
   @objc func seenTriggered(_ sender: AnyObject){
    
        let realm = try! Realm()
        let header = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! MovieHeaderCell
    
        if header.seenMovie.isOn {
            
            if header.wantToWatchMovie.isOn {
                
                header.wantToWatchMovie.isOn = false
                
                try! realm.write {

                    let deleteMovieFromCollection = user.collections.filter("id == 1").first!.movies.filter("id == \(movie.id)").first
                    let deleteIndex = user.collections.filter("id == 1").first!.movies.index(of: deleteMovieFromCollection!)

                    let message = "\(deleteMovieFromCollection!.title) is removed from 'Movies to watch'"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    self.present(alert, animated: true)
                    
                    // duration in seconds
                    let duration: Double = 2
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                        alert.dismiss(animated: true)
                    }
                    
                    user.collections.filter("id == 1").first!.movies.remove(at: deleteIndex!)
                }
            }
            
            try! realm.write {
                let message = "\(movie.title) is added to 'Movies seen'"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.present(alert, animated: true)
                
                // duration in seconds
                let duration: Double = 2
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    alert.dismiss(animated: true)
                }
                user.collections.filter("id == 0").first!.movies.append(movie)
                print("Movie selection view controller line 237, # movies seen: \( user.collections.filter("id == 0").first!.movies.count)")

            }
        }
//        Movies seen (id == 0) switch staat uit dus film mag niet in lijst zitten
        else {
            if checkIfMovieAlreadyInDb(for: user.collections.filter("id == 0").first!.movies) == true {
                try! realm.write {
                    let deleteMovieFromCollection =  user.collections.filter("id == 0").first!.movies.filter("id == \(movie.id)").first!
                    let deleteIndex = user.collections.filter("id == 0").first!.movies.index(of: deleteMovieFromCollection)
                    
                    let message = "\(deleteMovieFromCollection.title) is removed from 'Movies seen'"
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    self.present(alert, animated: true)
                    
                    // duration in seconds
                    let duration: Double = 2
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                        alert.dismiss(animated: true)
                    }
                    user.collections.filter("id == 0").first!.movies.remove(at: deleteIndex!)
                }
            }
        }
    }
    
    func checkIfMovieAlreadyInDb(for list: List<Movie>) -> Bool {
  
        var containsMovie = false
//        var inList = ""
        
        for m in list {
            if m.id == movie.id {
                containsMovie = true
            }
        }
        return containsMovie
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
            
        case 0:
            let movieHeaderCell = tableView.dequeueReusableCell(withIdentifier: "movieHeaderCell", for: indexPath) as! MovieHeaderCell
            
            movieHeaderCell.duration.text = "\(String(describing: movie.duration))"
//            movieHeaderCell.genre.text = movie.genres.joined(separator: ",")

            print("Movie selection view controller line 196, actorsWithDetails.prefix(8): \(actorsWithDetails.prefix(8))")
//            get first 8 cast members
            if stars.isEmpty || stars.count != 8 {
                stars.removeAll()
                for i in actorsWithDetails.prefix(8) {
                    let actor = i
                    stars.append(actor.name)
                }
            }

            let namesStars = stars.joined(separator: ", ")
            movieHeaderCell.starsInMovie.text = namesStars
            movieHeaderCell.overview.text = movie.overview
            
            let punten : String = String(format: "%.1F",movie.vote_average)
            movieHeaderCell.score.text = punten
            movieHeaderCell.title.text = movie.title
           
//            Poster for movie, gets the original size of the poster
            if movie.poster_path != "" {
                let posterUrl = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePoster + movie.poster_path)
                let data = try! Data.init(contentsOf: posterUrl!)
                movieHeaderCell.poster.image = UIImage(data: data)
            }

//            toevoegen van film aan de gepaste lijst, indien film al in db zet switch op true
//            Film zit al in moviesSeen
            if checkIfMovieAlreadyInDb(for: user.collections.filter("id == 0").first!.movies) == true {
                movieHeaderCell.seenMovie.isOn = true
            }
//                film zit nog niet in moviesSeen
//            else {
                movieHeaderCell.seenMovie.addTarget(self, action: #selector((seenTriggered(_:))), for: .valueChanged)
//            }
//            film zit al in movies to watch
            if checkIfMovieAlreadyInDb(for: user.collections.filter("id == 1").first!.movies) == true {
                movieHeaderCell.wantToWatchMovie.isOn = true
            }
                movieHeaderCell.wantToWatchMovie.addTarget(self, action: #selector((wantToWatchTriggered(_:))), for: .valueChanged)
            
            return movieHeaderCell

        case 1:
            let trailerCell = tableView.dequeueReusableCell(withIdentifier: "trailerCell", for: indexPath) as! TrailerCell
            
            let embedUrl = URL(string: "https://www.youtube.com/embed/\(youtubeTrailerKey)")
            let trailerRequest = URLRequest(url: embedUrl!)
            trailerCell.webView.load(trailerRequest)
            
            return trailerCell

        default:
            let actorCell = tableView.dequeueReusableCell(withIdentifier: "actorCell", for: indexPath) as! ActorCell
            
            print("Movie Selection view controller line 252, got here (actor cell), actors[indexPath.row].biography: \(actors[indexPath.row - 2].biography)")
            
            if actorsWithDetails[indexPath.row - 2].biography.isEmpty {
                actorsWithDetails[indexPath.row - 2].biography = "N/A"
            }
            actorCell.bio.text = actorsWithDetails[indexPath.row - 2].biography
            actorCell.name.text = actorsWithDetails[indexPath.row - 2].name
            
            
            if actorsWithDetails[indexPath.row - 2].profilePath != ""  {
                //            image can be displayed with \(baseUrl) + \(sizeProfilePhoto) + imageURL
                let imageURL = actorsWithDetails[indexPath.row - 2].photoFilePath
                let photoURL = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePoster + imageURL)!
                print("Movie Selection view controller line 265, photoUrl: \(photoURL)")
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

// To show the spinner I used this tutorial: http://brainwashinc.com/2017/07/21/loading-activity-indicator-ios-swift/
extension UIViewController {
    
    class func displaySpinner(onView: UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    class func removeSpinner(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
