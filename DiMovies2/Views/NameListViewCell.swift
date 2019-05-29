import UIKit

class NameListViewCell : UITableViewCell{
    
    @IBOutlet weak var nameList: UILabel!
    @IBOutlet weak var nrOfMovies: UILabel!
    
    var collection: Collection! {
        didSet {
            nameList.text = collection.name
            nrOfMovies.text = "\(collection.movies.count)"
        }
    }
}
