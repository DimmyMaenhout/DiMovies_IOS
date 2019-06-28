import Foundation
import UIKit
import SDWebImage

class SearchViewController : UIViewController {

    private var movieResults : [Movie] = []
    private var searchTask : URLSessionTask?
    private let sections = [Type.Movies]
    private var sv = UIView()
    private var isFetchInProgress = false
    private var currentPage = 1
    //MARK: name of movie / serie searched
    private var searchString = ""
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
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
        guard segue.identifier == Constants.selectedSearchMovieSegue else {
            fatalError(Constants.unknownSegue)
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
            //MARK: Necessary for pagination
            searchString = searchKeywords
            
            searchTask?.cancel()
            searchTask = TmdbAPIService.getMovieByName(for: searchKeywords, page: currentPage) {
                self.removeSpinner(spinner: self.sv)
                self.movieResults.removeAll()
                self.movieResults = $0!
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            searchTask?.resume()
            sv = self.displaySpinner(onView: self.view)
            self.view.endEditing(true)
        } else {
            searchTask?.cancel()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //MARK: If there is text in searchbar, clear text
        if searchBar.text != "" {
            searchBar.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //MARK: Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.searchSectionHeaderCellIdentifier) as! SearchSectionHeaderCell
        
        switch section {
        case 0:
            cell.sectionTitle.text = Constants.moviesSectionHeader
        case 1:
            cell.sectionTitle.text = Constants.seriesSectionHeader
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.searchedMovieCellIdentifier, for: indexPath) as! MovieCell
        let movie = movieResults[indexPath.row]
        cell.title.text = movie.title
        let punten : String = String(format: "%.1F",movie.vote_average)
        cell.score.text = punten
        
        if movie.overview.isEmpty {
            movie.overview = Constants.notAvailableString
        }
        cell.overview.text = movie.overview
        
        if !movie.poster_path.isEmpty {
            
            //MARK: For the image, the url exists of 3 pieces: base_url, full_size and the file path
            let imageURL = movie.poster_path
            let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePosterW92 + imageURL)!
            cell.poster.sd_setImage(with: moviePosterURL)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = movieResults.count - 1
        if indexPath.row == lastItem {
            //MARK: Load more data (next page)
            fetchMoreMovies()
        }
    }
    //MARK: Gets the next page with searched movies
    func fetchMoreMovies() {
        //MARK: If fetch is already in progress, don't fetch again
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        currentPage += 1
        searchTask?.cancel()
        searchTask = TmdbAPIService.getMovieByName(for: searchString, page: currentPage, completion: { (searchResults) in
            self.removeSpinner(spinner: self.sv)
            self.isFetchInProgress = false
            guard let searchResults = searchResults else {
                print("searchResults was nil")
                return
            }
            self.movieResults.insert(contentsOf:searchResults, at: self.movieResults.count)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        searchTask!.resume()
        sv = self.displaySpinner(onView: self.view)
    }
}
