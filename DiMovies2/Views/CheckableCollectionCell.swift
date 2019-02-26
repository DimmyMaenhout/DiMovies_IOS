import Foundation
import UIKit

class CheckableCollectionCell: UITableViewCell {
    
    @IBOutlet weak var collectionName: UILabel!
    @IBOutlet weak var collectionMovieCount: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    
    var collection: Collection! {
        didSet {
            
            collectionName.text = collection.name
            
            collectionMovieCount.text = "\(collection.movies.count)"
            
            //checkBtn.isSelected = false
        }
    }
    
}
