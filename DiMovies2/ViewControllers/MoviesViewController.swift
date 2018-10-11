import Foundation
import UIKit
import RealmSwift
/*
 *  Shows movies in cinema
 */
class MoviesViewController : UIViewController {
    
    var moviesTBMD : [Dictionary<String, Any>?] = []
    var movies: [Movie] = []
    var moviesTask: URLSessionTask?
    var sv = UIView()
    var currentPage = 1
    var isFetchInProgress = false
    @IBOutlet weak var tableView: UITableView!

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
            UIViewController.removeSpinner(spinner: self.sv)
            self.movies = $0!
//            self.tableView.reloadData()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        moviesTask!.resume()
        sv.center = self.view.center
        sv = UIViewController.displaySpinner(onView: self.view)
//        tableView.ind
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "selectedMovie" else {
            fatalError("Unknown segue")
        }
        
        let movieSelectionViewController = segue.destination as! MovieSelectionViewController
        movieSelectionViewController.movie = movies[tableView.indexPathForSelectedRow!.row]
    }
}

extension MoviesViewController : UITableViewDataSource {
    
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
//        print("Movies view controller line 76, \(movies[indexPath.row]): \(movie.title)")
        cell.title.text = movie.title
        let punten : String = String(format: "%.1F",movie.vote_average)//!
        cell.score.text = punten
        if movie.overview.isEmpty {
            movie.overview = "N/A"
        }
        cell.overview.text = movie.overview
        
        if movie.poster_path != "" {
        
            //voor image bestaat de url uit 3 delen = base_url, full_size and the file path
            let imageURL = movie.poster_path
            let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePoster + imageURL)!
            let data = try! Data.init(contentsOf: moviePosterURL)
            cell.poster.image =  UIImage(data: data)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = movies.count - 1
        if indexPath.row == lastItem {
//            load more data (next page)
            fetchMoreMoviesPlaying()
//            sv = UIViewController.displaySpinner(onView: self.view)
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

            UIViewController.removeSpinner(spinner: self.sv)
            self.isFetchInProgress = false
            self.movies.insert(contentsOf: moviesPlaying!, at: self.movies.count)
            DispatchQueue.main.async {

                self.tableView.reloadData()
            }
        }
        moviesTask!.resume()
        sv = UIViewController.displaySpinner(onView: self.view)
    }
    
//    private func calculateIndexPathsToReload(from newMoviesPlaying: [Movie]) -> [IndexPath]
//    {
//        let startIndex = movies.count - newMoviesPlaying.count
//        let endIndex = startIndex + newMoviesPlaying.count
//        return (startIndex ..< endIndex).map { IndexPath(row: $0, section: 0)}
//    }
}

extension MoviesViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
