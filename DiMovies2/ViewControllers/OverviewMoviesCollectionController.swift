import UIKit
import RealmSwift

// Toont alle films van een collectie
class OverviewMoviesColletionController : UIViewController {
    
    var user : User!
    var selectedListId: Int?
    var collection: Collection!
    @IBOutlet weak var tableView: UITableView!
    
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
        //        indien user film heeft bekeken kan hij deze op de "seen" lijst zetten of verwijderen
//        1 = want to watch
        if selectedListId == 1 {
            seenAction = UIContextualAction(style: .normal, title: "Seen") {
                (action, view, completionHandler) in
                
                movie = self.user.collections.filter("id == 1").first!.movies[indexPath.row]// self.user!.moviesToWatch[indexPath.row]
                
                let realm = try! Realm()
                try! realm.write {
                    //                adding movie to other collection and deleting it from current
//                    self.user!.moviesSeen.append(movie!)
                    self.user.collections.filter("id == 0").first!.movies.append(movie!)
//                    self.user!.moviesToWatch.remove(at: indexPath.row)
                    self.user.collections.filter("id == 1").first!.movies.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
            seenAction!.backgroundColor = UIColor.orange
            
            deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
                (action, view, completionHandler) in
                
                if self.selectedListId == 0/*self.selectedList == "Movies seen"*/ {
                    movie = self.user.collections.filter("id == 0").first!.movies[indexPath.row] // self.user!.moviesSeen[indexPath.row]
                } else if self.selectedListId == 1 {
                    movie = self.user.collections.filter("id == 1").first!.movies[indexPath.row] // self.user!.moviesToWatch[indexPath.row]
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
            //            alle collections hebben de mogelijkheid om films te verwijderen, enkel bij "Want to watch" is er ook nog de optie "Seen"
        else {
            deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
                (action, view, completionHandler) in
                
                if self.selectedListId == 0/*"Movies seen"*/ {
                    movie = self.user.collections.filter("id == 0").first!.movies[indexPath.row] // self.user!.moviesSeen[indexPath.row]
                } else if self.selectedListId == 1 {
                    movie = self.user.collections.filter("id == 1").first!.movies[indexPath.row] // self.user!.moviesToWatch[indexPath.row]
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
        print("Overview movies collection controller line 94, collection.movies.count: \(collection.movies.count)")
        return collection.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        
        let movie = collection.movies[indexPath.row]//user!.moviesSeen[indexPath.row]
        cell.title.text = movie.title
        cell.overview.text = movie.overview
        let punten : String = String(format: "%.1F",movie.vote_average) //!
        cell.score.text = punten
        print("Overview movies collection controller line 107, movie.name: \(movie.title)")
        if movie.poster_path != "" {
            
            //voor image bestaat de url uit 3 delen = base_url, full_size and the file path
            let imageURL = movie.poster_path
            let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + "original" + imageURL)!
            let data = try! Data.init(contentsOf: moviePosterURL)
            cell.poster.image =  UIImage(data: data)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
