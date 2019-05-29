import Foundation
import UIKit
import RealmSwift

class AddMovieToCollectionViewController: UIViewController {

    var user: User!
    // film die we (eventueel) gaan opslaan, doorgekregen door vorige viewController (movie detail vc)
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
    }
}

extension AddMovieToCollectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  user.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectCollectionToAddMovieCell", for: indexPath) as! CheckableCollectionCell
        
        cell.collectionName.text = user.collections[indexPath.row].name
        cell.collectionMovieCount.text = "\(String(describing: user.collections[indexPath.row].movies.count))"
        cell.addToCollectionSwitch.tag = user.collections[indexPath.row].id
        // If the collections are loaded in the tableView there must be checked if the movie is already in a collection or not to in order to give the switch the right value
        if checkIfMovieAlreadyInDb(for: user.collections[indexPath.row]) {
            
            cell.addToCollectionSwitch.isOn = true
        }
        else {
            
            cell.addToCollectionSwitch.isOn = false
        }
        cell.addToCollectionSwitch.addTarget(self, action: #selector((switchTapped(_:))), for: .valueChanged)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Zorgt ervoor dat de table cell niet meer geselecteerd is als we terug komen
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
    }
    
    @objc func switchTapped(_ sender: UISwitch) {
        //sender.tag is the id of the collection
        
        // movie is in collection, so delete movie
        if sender.isOn == true{
            let selectedCollection = user.collections.filter("id == \(sender.tag)").first!
            addMovieToCollection(collection: selectedCollection)
        }
            // movie not in collection, add movie
        else {
            let selectedCollection = user.collections.filter("id == \(sender.tag)").first!
            deleteMovieFromCollection(collection: selectedCollection)
        }
        
    }
    
    func addMovieToCollection(collection: Collection) {
        try! realm.write {
            user.collections.filter("id == \(collection.id)").first!.movies.append(movie)
            
            let message = "\(movie.title) is added to  '\(user.collections.filter("id == \(collection.id)").first!.name)'"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)
            
            // duration in seconds
            let duration: Double = 1.5
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteMovieFromCollection(collection: Collection) {
        let deleteMovieFromCollection = user.collections.filter("id == \(collection.id)").first!.movies.filter("id == \(movie.id)").first!
        
        let deleteIndex = user.collections.filter("id == \(collection.id)").first!.movies.index(of: deleteMovieFromCollection)
        
        try! realm.write {
            user.collections.filter("id == \(collection.id)").first!.movies.remove(at: deleteIndex!)
            
            let message = "\(movie.title) is removed from  '\(user.collections.filter("id == \(collection.id)").first!.name)'"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)
            
            // duration in seconds
            let duration: Double = 1.5
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
                self.tableView.reloadData()
            }
        }
        
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
