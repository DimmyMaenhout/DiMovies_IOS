import UIKit
import RealmSwift

//MARK: Shows all movies from a collection
class OverviewMoviesColletionController : UIViewController {
    
    private var user : User!
    var selectedListId: Int?
    private var collection: Collection!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let realm = try! Realm()
        user = try! realm.objects(User.self)[0]
        collection = Collection.getCollection(with: selectedListId!)
        self.navigationController?.topViewController?.title = collection.name
    }
}

extension OverviewMoviesColletionController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var movie : Movie?
        var seenAction : UIContextualAction?
        var deleteAction : UIContextualAction?
        //Mark: When the user has seen the movie, he can place it in the 'seen' collection or remove it from the collection
        //MARK: 1 = 'Want to watch' collection, 0 = 'Seen' collection
        if selectedListId == 1 {
            seenAction = UIContextualAction(style: .normal, title: "Seen") {
                (action, view, completionHandler) in
                
                movie = self.user.collections.filter("\(Constants.idString) == \(Constants.seenCollectionId)").first!.movies[indexPath.row]
                
                let realm = try! Realm()
                try! realm.write {
                    // Mark: Adding movie to 'Seen' collection and deleting it from 'Want to watch'
                    self.user.collections.filter("\(Constants.idString) == \(Constants.wantToWatchCollectionId)").first!.movies.append(movie!)
                    self.user.collections.filter("\(Constants.idString) == \(Constants.seenCollectionId)").first!.movies.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
            seenAction!.backgroundColor = UIColor.orange
            
            deleteAction = UIContextualAction(style: .destructive, title: Constants.deleteString) {
                (action, view, completionHandler) in
                
                if self.selectedListId == Constants.wantToWatchCollectionId {
                    
                    movie = self.user.collections.filter("\(Constants.idString) == \(Constants.wantToWatchCollectionId)").first!.movies[indexPath.row]
                }
                else if self.selectedListId == Constants.seenCollectionId {
                    
                    movie = self.user.collections.filter("\(Constants.idString) == \(Constants.seenCollectionId)").first!.movies[indexPath.row]
                }
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(movie!)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction!, seenAction!])
        }
            //Mark: All collections have the possibility to delete movies, only 'Want to watch' has the option 'Seen'
        else {
            deleteAction = UIContextualAction(style: .destructive, title: Constants.deleteString) {
                (action, view, completionHandler) in
                // MARK: 0 = 'Seen' Collection, 1 = 'Want to watch' collection
                if self.selectedListId == 0 {
                    movie = self.user.collections.filter("\(Constants.idString) == \(Constants.wantToWatchCollectionId)").first!.movies[indexPath.row]
                } else if self.selectedListId == 1 {
                    movie = self.user.collections.filter("\(Constants.idString) == \(Constants.seenCollectionId)").first!.movies[indexPath.row]
                }
                
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(movie!)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction!])
        }
    }
}

extension OverviewMoviesColletionController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.movieCellIdentifier) as! MovieCell
        let movie = collection.movies[indexPath.row]
        cell.title.text = movie.title
        cell.overview.text = movie.overview
        let punten : String = String(format: "%.1F",movie.vote_average)
        cell.score.text = punten

        if !movie.poster_path.isEmpty {
            
            //Mark: Image URL exists of 3 pieces: base_url, full_size and the file path
            let imageURL = movie.poster_path
            let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePosterW92 + imageURL)!
            let data = try! Data.init(contentsOf: moviePosterURL)
            cell.poster.image =  UIImage(data: data)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
