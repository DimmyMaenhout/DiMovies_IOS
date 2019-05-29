import Foundation
import UIKit
import RealmSwift

class CollectionsViewController: UIViewController {
    
    var selectedCell = ""
    var selectedCellId: Int?
    var user: User?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        user = try! Realm().objects(User.self)[0]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        case "addCollection":
            break
        case "showMovies":
            let overviewMoviesColletionController = segue.destination as! OverviewMoviesColletionController
            //        we sturen het id van collectie mee
            overviewMoviesColletionController.selectedListId = user!.collections[(tableView.indexPathForSelectedRow!.row)].id
        default:
            fatalError("Unknown segue")
        }
    }
    
    @IBAction func unwindFromAddCollection(_ segue: UIStoryboardSegue) {
        switch segue.identifier {
        case "didAddCollection"?:
            let addProjectViewController = segue.source as! AddCollectionViewController
            
            let realm = try! Realm()
            try! realm.write {
                
                user!.collections.append(addProjectViewController.collection!)
            }
            tableView.insertRows(at: [IndexPath(row: user!.collections.count - 1, section: 0)], with: .automatic)
        default:
            fatalError("Unkown segue")
        }
    }
}
extension CollectionsViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //  Deselects the tableViewCell when we return
        tableView.deselectRow(at: indexPath, animated: true)
        print("UserViewController line 34, selectedList: \(String(describing: selectedCellId))")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        var deleteAction: UIContextualAction?
        
        switch user!.collections[indexPath.row].id {
//            There are 2 collections that can't be deleted, the standard collections 'Seen' and 'Want to watch'
            
        case 0 ..< 2:
            
            deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in

                let alert = UIAlertController(title: "", message: "This collection can't be removed", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
                completionHandler(false)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction!])
        default:
            
            deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
                
                let collection = self.user!.collections[indexPath.row]
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(collection)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction!])
        }
    }
}

extension CollectionsViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

           return user?.collections.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserlistCell", for: indexPath) as! NameListViewCell
//        nodig om de juiste lijst te tonen in volgende controller (UserMoviesOverviewController)
        selectedCellId = user!.collections[indexPath.row].id
        cell.nameList.text = user!.collections[indexPath.row].name
        cell.nrOfMovies.text = "\(user!.collections[indexPath.row].movies.count)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
    }
}
