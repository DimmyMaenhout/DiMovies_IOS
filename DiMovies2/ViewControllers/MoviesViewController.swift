import Foundation
import UIKit
/*
 *  Shows movies in cinema
 */
class MoviesViewController : UIViewController {
    
    let apiKey = "fba7c35c2680c39c8829a17d5e902b97"
    let baseURL_TMDB = "https://api.themoviedb.org/3"
    //voor poster
    let baseUrlPoster = "https://image.tmdb.org/t/p/"
    let sizePoster = "original" //"w92"
    var moviesTBMD : [Dictionary<String, Any>?] = []
    var movies: [Movie] = []
    var moviesTask: URLSessionTask?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        moviesTask?.cancel()
        moviesTask = TmdbAPIService.getMoviesPlaying(){
            self.movies = $0!
            self.tableView.reloadData()
        }
        moviesTask!.resume()
        
    }
    
    //                          TODO
    //finding movies by title:
    //vb werkende url adhv titel
    //https://api.themoviedb.org/3/search/movie?api_key=fba7c35c2680c39c8829a17d5e902b97&query=the+fast+and+the+furious
    //baseURL_TMDB/search/movie?api_key=apiKey&query=the+fast+and+the+furious
    /*  func getMovieByName(name: String){
    
    }   */

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
//        print("Movies view controller line 74, #movies: ", movies.count, indexPath.row)
        let movie = movies[indexPath.row]
//        print("Movies view controller line 76, \(movies[indexPath.row]): \(movie.title)")
        cell.title.text = movie.title
        let punten : String = String(format: "%.1F",movie.vote_average!)
        cell.score.text = punten
        cell.overview.text = movie.overview
        
        //voor image bestaat de url uit 3 delen = base_url, full_size and the file path
        let imageURL = movie.poster_path
        let moviePosterURL = URL(string: baseUrlPoster + sizePoster + imageURL)!
        let data = try! Data.init(contentsOf: moviePosterURL)
        cell.poster.image =  UIImage(data: data)
        
        return cell
    }
}

extension MoviesViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension MoviesViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchKeywords = searchBar.text else {
            print("Movies view controller line 93, searchKeywords is nil")
            return
        }
        print("Movie view controller line 96, searchKeywords: \(searchKeywords)")
        moviesTask?.cancel()
        moviesTask = TmdbAPIService.getMovieByName(for: searchKeywords) {
            self.movies.removeAll()
            self.movies = $0!
            self.tableView.reloadData()
            
        }
        moviesTask?.resume()
        self.view.endEditing(true)
    }
}



