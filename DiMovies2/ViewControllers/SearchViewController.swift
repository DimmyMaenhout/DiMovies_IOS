import Foundation
import UIKit

class SearchViewController : UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
//    combined results (movies & series) with type (int) as key
//    var searchResults : [Int: [Any]] = [:]
    var movieResults : [Movie] = []
//    var serieResults : [Movie] = [] //type gaat nog veranderd moeten worden
    var searchTask : URLSessionTask?

    //voor poster
    let baseUrlPoster = "https://image.tmdb.org/t/p/"
    let sizePoster = "original"
    let sections = [Type.Movies/*"Movies"*//*, "Series"*/]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searchBar.returnKeyType = UIReturnKeyType.done
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "selectedSearchMovie" else {
            fatalError("Unknown segue")
        }
        
        let movieSelectionViewController = segue.destination as! MovieSelectionViewController
        movieSelectionViewController.movie = movieResults[tableView.indexPathForSelectedRow!.row]
    }
}

extension SearchViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchKeywords = searchBar.text else {
            print("Search view controller line 43, searchKeywords is nil")
            return
        }
        print("Search view controller line 46, searchKeywords: \(searchKeywords)")
        searchTask?.cancel()
        searchTask = TmdbAPIService.getMovieByName(for: searchKeywords) {
            self.movieResults.removeAll()
            self.movieResults = $0!
            self.tableView.reloadData()
            
        }
        searchTask?.resume()
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        if there is text in searchbar, clear text
        if searchBar.text != "" {
            searchBar.text = ""
        }
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchSectionheaderCell") as! SearchSectionHeaderCell
        
        switch section {
        case 0:
            cell.sectionTitle.text = "Movies"
        case 1:
            cell.sectionTitle.text = "Series"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchedMovieCell"/*"movieCell"*/, for: indexPath) as! MovieCell
        //        print("Search view controller line 74, #movies: ", movies.count, indexPath.row)
        let movie = movieResults[indexPath.row]
        //        print("Search view controller line 76, \(movies[indexPath.row]): \(movie.title)")
        cell.title.text = movie.title
        let punten : String = String(format: "%.1F",movie.vote_average!)
        cell.score.text = punten
        cell.overview.text = movie.overview
        
        if movie.poster_path != "" {
            
            //voor image bestaat de url uit 3 delen = base_url, full_size and the file path
            let imageURL = movie.poster_path
            let moviePosterURL = URL(string: baseUrlPoster + sizePoster + imageURL)!
            let data = try! Data.init(contentsOf: moviePosterURL)
            cell.poster.image =  UIImage(data: data)
        }
        
        return cell
    }
}
