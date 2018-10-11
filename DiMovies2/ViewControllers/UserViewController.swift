import Foundation
import UIKit

class UserViewController: UIViewController {
    
    var lists = ["Movies seen", "Movies to watch"]
    var selectedCell = ""
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let userMoviesOverViewController = segue.destination as! UserMoviesOverviewController
        userMoviesOverViewController.selectedList = lists[(tableView.indexPathForSelectedRow!.row)]
        print("UserViewController line 22, selectedList: \(userMoviesOverViewController.selectedList)")
    }
}
extension UserViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //        Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
        print("UserViewController line 34, selectedList: \(selectedCell)")
    }
}

extension UserViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //momenteel enkel keuze tussen "movies seen" & "movies to watch"
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserlistCell", for: indexPath) as! NameListViewCell
//        nodig om de juiste lijst te tonen in volgende controller (UserMoviesOverviewController)
        
        selectedCell = lists[indexPath.row]
        cell.listName = lists[indexPath.row]
        print("UserViewController line 54, lists[indexPath.row]: \(lists[indexPath.row]) \n selectedCell: \(selectedCell)")
        return cell
    }
}
