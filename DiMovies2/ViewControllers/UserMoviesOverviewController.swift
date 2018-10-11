import UIKit
import RealmSwift

class UserMoviesOverviewController : UIViewController {
    
    var user : User?
    var selectedList = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        print("UserMoviesOverviewController line 17, selectedList: \(selectedList)")
        let realm = try! Realm()
        user = try! realm.objects(User.self)[0]
        self.navigationController?.topViewController?.title = selectedList
    }
}

extension UserMoviesOverviewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var movie : Movie?
        var seenAction : UIContextualAction?
        var deleteAction : UIContextualAction?
//        indien user film heeft bekeken kan hij deze op de "seen" lijst zetten
        if selectedList == "Movies to watch" {
            seenAction = UIContextualAction(style: .normal, title: "Seen") {
                (action, view, completionHandler) in
                
                movie = self.user!.moviesToWatch[indexPath.row]
                
                
                let realm = try! Realm()
                try! realm.write {
                    //                adding movie to other collection and deleting it from current
                    self.user!.moviesSeen.append(movie!)
                    self.user!.moviesToWatch.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
            seenAction!.backgroundColor = UIColor.green
            
            deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
                (action, view, completionHandler) in
                
                if self.selectedList == "Movies seen" {
                    movie = self.user!.moviesSeen[indexPath.row]
                } else {
                    movie = self.user!.moviesToWatch[indexPath.row]
                }
                //            let project = self.user!.moviesSeen[indexPath.row]
                let realm = try! Realm()
                try! realm.write {
                    //                project.tasks.forEach(realm.delete(_:))
                    realm.delete(movie!)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction!, seenAction!])
        }
        else {
            deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
                (action, view, completionHandler) in
                
                //            var movie: Movie?
                if self.selectedList == "Movies seen" {
                    /*var*/ movie = self.user!.moviesSeen[indexPath.row]
                } else {
                    /*var*/ movie = self.user!.moviesToWatch[indexPath.row]
                }
                //            let project = self.user!.moviesSeen[indexPath.row]
                let realm = try! Realm()
                try! realm.write {
                    //                project.tasks.forEach(realm.delete(_:))
                    realm.delete(movie!)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction!])
        }
    }
}

extension UserMoviesOverviewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("UserMoviesOverviewController line 29, selectedList: \(selectedList)")
        switch selectedList {
        case "Movies seen":
            print("User movies overview controller line 32, user!.moviesSeen.count: \(user!.moviesSeen.count)")
            return user!.moviesSeen.count
            
        case "Movies to watch":
            print("User movies overview controller line 37, user!.moviesToWatch.count: \(String(describing: user!.moviesToWatch.count))")
            return user!.moviesToWatch.count
            
        default:
            print("User movies overview controller line 42, default: geretourneerde waarde voor number of rows in section is 0")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        print("User movies overview controller line 49, selectedList: \(selectedList)")
        switch selectedList {
        case "Movies seen":
            let movie = user!.moviesSeen[indexPath.row]
            cell.title.text = movie.title
            cell.overview.text = movie.overview
            let punten : String = String(format: "%.1F",movie.vote_average) //!
            cell.score.text = punten
            
            if movie.poster_path != "" {
                
                //voor image bestaat de url uit 3 delen = base_url, full_size and the file path
                let imageURL = movie.poster_path
                let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + "original" + imageURL)!
                let data = try! Data.init(contentsOf: moviePosterURL)
                cell.poster.image =  UIImage(data: data)
            }
            return cell
        case "Movies to watch":
            let movie = user!.moviesToWatch[indexPath.row]
            cell.title.text = movie.title
            cell.overview.text = movie.overview
            let punten : String = String(format: "%.1F",movie.vote_average)
            cell.score.text = punten
            
            if user!.moviesToWatch[indexPath.row].poster_path != "" {
                //voor image bestaat de url uit 3 delen = base_url, full_size and the file path
                let imageURL = movie.poster_path
                let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + "original" + imageURL)!
                let data = try! Data.init(contentsOf: moviePosterURL)
                cell.poster.image =  UIImage(data: data)
            }
            return cell
            
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
