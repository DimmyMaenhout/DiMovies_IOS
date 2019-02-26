import Foundation
import UIKit
import RealmSwift

class AddMovieToCollectionViewController: UIViewController {

    var user: User?
    // film die we (eventueel) gaan opslaan, doorgekregen door vorige viewController
    var movie: Movie!
    let realm = try! Realm()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        user = try! Realm().objects(User.self)[0]
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.allowsMultipleSelection = true
        
        //collections += (user?.collections)!
        print("Add movie to collection view controller line 29, #collections: \(user!.collections.count)")
    }
    
    @IBAction func checkboxTapped (_ sender: UIButton) {
        
        /*if sender.isSelected {
            
            sender.isSelected = false
        }
        else {
            
            sender.isSelected = true
        }*/
    }
}

extension AddMovieToCollectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  user?.collections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectCollectionToAddMovieCell", for: indexPath) as! CheckableCollectionCell
        
        
        cell.collectionName.text = user!.collections[indexPath.row].name
        cell.collectionMovieCount.text = "\(String(describing: user!.collections[indexPath.row].movies.count))"
        
        // If the collections are loaded in the tableView there must be checked if the movie is already in a collection or not to in order to give the checkbox the right value
        if checkIfMovieAlreadyInDb(for: user!.collections[indexPath.row]) {
            
            cell.checkBtn.isSelected = true
        }
        else {
            
            cell.checkBtn.isSelected = false
        }
        
        return cell
    }
    /*  Show checkmark if user did select collection to save movie to   */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
 
        // film zit nog niet in collectie
        if checkIfMovieAlreadyInDb(for: user!.collections[indexPath.row]) == false {
            
            /*
                TODO nog nakijken of de film niet in 'Seen' zit of in 'Want to watch', indien in 1 van de 2 moet eerste de film verwijderd worden uit de 1ne collectie ('Seen' of 'Want to watch')
                alvorens de film toe te voegen aan de andere collectie ('Seen' of 'Want to watch')
             */
            try! realm.write {
                
                doneBarButton.isEnabled = true
                
                var header = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as! CheckableCollectionCell
                header.checkBtn.isSelected = true
                
                addMovieToCollection(collection: (user!.collections[indexPath.row]))
                
                let message = "\(movie.title) is added to  '\(user!.collections[indexPath.row].name)'"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.present(alert, animated: true)
                
                // duration in seconds
                let duration: Double = 2
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    alert.dismiss(animated: true)
                    tableView.reloadData()
                }
            }
        }
        // film aan collectie toevoegen
        else {
            
            try! realm.write {
                
                doneBarButton.isEnabled = true
                
                var header = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as! CheckableCollectionCell
                header.checkBtn.isSelected = false
                
                let deleteMovieFromCollection = user!.collections.filter("id == \(user!.collections[indexPath.row].id)").first!.movies.filter("id == \(movie.id)").first!
                let deleteIndex = user!.collections.filter("id == \(user!.collections[indexPath.row].id)").first!.movies.index(of: deleteMovieFromCollection)
                user!.collections[indexPath.row].movies.remove(at: deleteIndex!)
                
                let message = "\(movie.title) is removed from  '\(user!.collections[indexPath.row].name)'"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.present(alert, animated: true)
                
                // duration in seconds
                let duration: Double = 2
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    alert.dismiss(animated: true)
                    tableView.reloadData()
                }
            }
        }
        print("Added movie to collection: \(user!.collections[indexPath.row].name)")
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
    }
    
    func addMovieToCollection(collection: Collection) {
        
        print("collection \(collection.name) #movies before adding movie: \(collection.movies.count)")
        user?.collections.filter("id == \(collection.id)").first?.movies.append(movie)
        print("collection \(collection.name) #movies after adding movie: \(collection.movies.count)")
    }
    
    func checkIfMovieAlreadyInDb(for collection: Collection) -> Bool {
        
        var containsMovie = false
        
        for m in collection.movies {
            if m.id == movie.id {
                containsMovie = true
            }
        }
        return containsMovie
    }
    
}

extension AddMovieToCollectionViewController: UITableViewDelegate {
    
}
