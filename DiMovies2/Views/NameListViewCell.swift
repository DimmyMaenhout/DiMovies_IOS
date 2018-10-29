import UIKit

class NameListViewCell : UITableViewCell{
    
    @IBOutlet weak var nameList: UILabel!
    
    var listName: String! {
        didSet {
            nameList.text = listName
        }
    }
}
