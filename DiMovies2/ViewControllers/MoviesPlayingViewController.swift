import Foundation
import UIKit
import RealmSwift
import SDWebImage
/*
 *  Shows movies in cinema
 */
class MoviesPlayingViewController : UIViewController {
    
    var moviesTBMD : [Dictionary<String, Any>?] = []
    var movies: [Movie] = []
    var moviesTask: URLSessionTask?
    var sv = UIView()
    var currentPage = 1
    var isFetchInProgress = false
    
    @IBOutlet weak var tableView: UITableView!
    //    Spinner is called here (to center it to the view)
    override func viewWillAppear(_ animated: Bool) {
//        indien we anders terug komen (bv van search) blijft de spinner op de pagina
        if movies.count == 0 {
            sv = self.displaySpinner(onView: self.view)
        }
    }
    override func viewDidLoad() {
       super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let realm = try! Realm()
        if(realm.isEmpty){
            DataRepo()
        }
        
        moviesTask?.cancel()
        moviesTask = TmdbAPIService.getMoviesPlaying(with: currentPage){
            self.removeSpinner(spinner: self.sv)
            print("movies playing controller line 39, movies: \($0)")
            guard let movies = $0 else { return }
            self.movies = movies//$0!
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        moviesTask!.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "selectedMovie" else {
            fatalError("Unknown segue")
        }
        
        let movieDetailsViewController = segue.destination as! MovieDetailsViewController
        movieDetailsViewController.movie = movies[tableView.indexPathForSelectedRow!.row]
    }
}

extension MoviesPlayingViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        print("Movies view controller line 74, nr of cell: \(indexPath.row) #movies: ", movies.count, indexPath.row)
        let movie = movies[indexPath.row]
        cell.title.text = movie.title
        let punten : String = String(format: "%.1F",movie.vote_average)//!
        cell.score.text = punten
        if movie.overview.isEmpty {
            movie.overview = "N/A"
        }
        cell.overview.text = movie.overview
        
        if movie.poster_path != "" {

            // The image url exists of 3 pieces: base_url, full_size and the file path
            let imageURL = movie.poster_path
            let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePosterW92 + imageURL)!
            //let data = try! Data.init(contentsOf: moviePosterURL)
            cell.poster.sd_setImage(with: moviePosterURL)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = movies.count - 1
        if indexPath.row == lastItem {
//            load more data (next page)
            fetchMoreMoviesPlaying()
        }
    }
//    gets the next page with movies playing
    func fetchMoreMoviesPlaying() {
        
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        currentPage += 1
        print("Movies view controller line 107, currentPage: \(String(currentPage))")
        moviesTask?.cancel()
        moviesTask = TmdbAPIService.getMoviesPlaying(with: currentPage) { moviesPlaying in

            self.removeSpinner(spinner: self.sv)
            self.isFetchInProgress = false
            self.movies.insert(contentsOf: moviesPlaying!, at: self.movies.count)
            DispatchQueue.main.async {

                self.tableView.reloadData()
            }
        }
        moviesTask!.resume()
        sv = self.displaySpinner(onView: self.view)
    }
}

extension MoviesPlayingViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
