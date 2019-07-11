import Foundation
import UIKit
import RealmSwift
import SDWebImage

//MARK: Shows movies in cinema
class MoviesPlayingViewController : UIViewController {
    // MARK: - Variables
    private var sv = UIView()
    private var currentPage = 1

    private var viewModel = MoviesPlayingViewModel()

    // MARK: - Outlet
    @IBOutlet private var tableView: UITableView!

    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //indien we anders terug komen (bv van search) blijft de spinner op de pagina
        if viewModel.hasMovies {
            sv = self.displaySpinner(onView: self.view)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.selectedMovieSegue else {
            fatalError(Constants.unknownSegue)
        }
        let movieDetailsViewController = segue.destination as! MovieDetailsViewController
        movieDetailsViewController.movie = viewModel.movie(for: tableView.indexPathForSelectedRow!.row)
    }
}
//MARK: UITableViewDataSource
extension MoviesPlayingViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movieCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return movieCell(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.movieCount - 1 {
            // Load more data (next page)
            fetchMoreMoviesPlaying()
        }
    }
}

//MARK: UITableViewDelegate
extension MoviesPlayingViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //MARK: Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: Private Functions
private extension MoviesPlayingViewController {
    func movieCell(for indexPath: IndexPath) -> MovieCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.movieCellIdentifier, for: indexPath) as! MovieCell
        let movie = viewModel.movie(for: indexPath.row)
        cell.bind(movie: movie)
        return cell
    }

    func setupView() {
        viewModel.delegate = self
        setupTableView()
        setupRealm()
        viewModel.fetchMovies()
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    func setupRealm() {
        let realm = try! Realm()
        if(realm.isEmpty){
            DataRepo()
        }
    }

    // Gets the next page with movies playing
    func fetchMoreMoviesPlaying() {
        guard !viewModel.isFetchInProgress else {
            return
        }
        viewModel.fetchMovies()
        sv = self.displaySpinner(onView: self.view)
    }
}

//MARK: UITableViewDelegate
extension MoviesPlayingViewController : MoviesPlayingViewModelDelegate {

    func refresh() {
        if !viewModel.isFetchInProgress {
            removeSpinner(spinner: sv)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
