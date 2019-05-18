import Foundation
import UIKit
import SDWebImage

class SearchViewController : UIViewController {
    
//    combined results (movies & series) with type (int) as key
//    var searchResults : [Int: [Any]] = [:]
    var movieResults : [Movie] = []
//    var serieResults : [Movie] = [] //type gaat nog veranderd moeten worden
    var searchTask : URLSessionTask?
    let sections = [Type.Movies/*"Movies"*//*, "Series"*/]
    var sv = UIView()
    var isFetchInProgress = false
    var currentPage = 1
//    name of movie / serie searched
    var searchString = ""
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searchBar.returnKeyType = UIReturnKeyType.done
        //tapping closes the keyboard
        self.hideKeyBoardOnTap()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "selectedSearchMovie" else {
            fatalError("Unknown segue")
        }
        
        let movieDetailsViewController = segue.destination as! MovieDetailsViewController
        movieDetailsViewController.movie = movieResults[tableView.indexPathForSelectedRow!.row]
    }
}

extension SearchViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchKeywords = searchBar.text else {
            print("Search view controller line 43, searchKeywords is nil")
            return
        }
        
        if !searchKeywords.isEmpty {
            
            //        nodig voor pagination
            searchString = searchKeywords
            
            print("Search view controller line 46, searchKeywords: \(searchKeywords)")
            searchTask?.cancel()
            searchTask = TmdbAPIService.getMovieByName(for: searchKeywords, page: currentPage) {
                UIViewController.removeSpinner(spinner: self.sv)
                self.movieResults.removeAll()
                self.movieResults = $0!
                self.tableView.reloadData()
                
            }
            searchTask?.resume()
            sv = UIViewController.displaySpinner(onView: self.view)
            self.view.endEditing(true)
        } else {
            searchTask?.cancel()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        if there is text in searchbar, clear text
        if searchBar.text != "" {
            searchBar.text = ""
        }
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchedMovieCell", for: indexPath) as! MovieCell
        //        print("Search view controller line 74, #movies: ", movies.count, indexPath.row)
        let movie = movieResults[indexPath.row]
        //        print("Search view controller line 76, \(movies[indexPath.row]): \(movie.title)")
        cell.title.text = movie.title
        let punten : String = String(format: "%.1F",movie.vote_average) //!
        cell.score.text = punten
        
        if movie.overview.isEmpty {
            movie.overview = "N/A"
        }
        cell.overview.text = movie.overview
        
        if movie.poster_path != "" {
            
            //For the image the url exists of 3 pieces: base_url, full_size and the file path
            let imageURL = movie.poster_path
            let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePosterW92 + imageURL)!
            let data = try! Data.init(contentsOf: moviePosterURL)
            cell.poster.image =  UIImage(data: data)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = movieResults.count - 1
        if indexPath.row == lastItem {
            //            load more data (next page)
            fetchMoreMovies()
        }
    }
    //    gets the next page with searched movies
    func fetchMoreMovies() {
//        if fetch is already in progress don't fetch again
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        currentPage += 1
        print("Search view controller line 155, searchString: \(searchString), currentPage: \(String(currentPage))")
        searchTask?.cancel()
        searchTask = TmdbAPIService.getMovieByName(for: searchString, page: currentPage, completion: { (searchResults) in
            
            UIViewController.removeSpinner(spinner: self.sv)

            self.isFetchInProgress = false
            guard let searchResults = searchResults else {
                print("searchResults was nil")
                return
            }
            self.movieResults.insert(contentsOf:searchResults, at: self.movieResults.count)
            print("Search view controller line 163, movieResults.count: \(self.movieResults.count)")
            DispatchQueue.main.async {

                self.tableView.reloadData()
            }
        })
            searchTask!.resume()
            sv = UIViewController.displaySpinner(onView: self.view)
    }
}
