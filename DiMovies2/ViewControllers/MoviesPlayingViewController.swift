import Foundation
import UIKit
import RealmSwift
import SDWebImage
import Reachability

//MARK: Shows movies in cinema
class MoviesPlayingViewController : UIViewController {
    
    private var movies: [Movie] = []
    private var moviesTask: URLSessionTask?
    private var sv = UIView()
    private var currentPage = 1
    private var isFetchInProgress = false
    
    @IBOutlet private weak var tableView: UITableView!
    //MARK: Spinner is called here (to center it to the view)
    override func viewWillAppear(_ animated: Bool) {
        //MARK: indien we anders terug komen (bv van search) blijft de spinner op de pagina
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

            guard let movies = $0 else { return }
            self.movies = movies
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        moviesTask!.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.selectedMovieSegue else {
            fatalError(Constants.unknownSegue)
        }
        let movieDetailsViewController = segue.destination as! MovieDetailsViewController
        movieDetailsViewController.movie = movies[tableView.indexPathForSelectedRow!.row]
    }
}

extension MoviesPlayingViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.movieCellIdentifier, for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        cell.title.text = movie.title
        let punten : String = String(format: "%.1F",movie.vote_average)//!
        cell.score.text = punten
        if movie.overview.isEmpty {
            movie.overview = Constants.notAvailableString
        }
        cell.overview.text = movie.overview
        
        if !movie.poster_path.isEmpty {
            //MARK: The image url exists of 3 pieces: base_url, full_size and the file path
            let imageURL = movie.poster_path
            let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePosterW92 + imageURL)!
            cell.poster.sd_setImage(with: moviePosterURL)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = movies.count - 1
        if indexPath.row == lastItem {
            //MARK: Load more data (next page)
            fetchMoreMoviesPlaying()
        }
    }
    //MARK: Gets the next page with movies playing
    func fetchMoreMoviesPlaying() {
        
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        currentPage += 1
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
        
        //MARK: Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
