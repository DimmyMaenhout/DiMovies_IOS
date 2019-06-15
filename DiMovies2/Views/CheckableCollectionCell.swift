import UIKit

class CheckableCollectionCell: UITableViewCell {
    
    @IBOutlet weak var collectionName: UILabel!
    @IBOutlet weak var collectionMovieCount: UILabel!
    @IBOutlet weak var addToCollectionSwitch: UISwitch!
    
    var collection: Collection! {
        didSet {
            collectionName.text = collection.name
            collectionMovieCount.text = "\(collection.movies.count)"
        }
    }
}
