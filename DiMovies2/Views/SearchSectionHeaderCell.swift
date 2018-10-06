import Foundation
import UIKit

class SearchSectionHeaderCell: UITableViewCell {
    @IBOutlet weak var sectionTitle: UILabel!
    
    var title: String! {
        didSet{
            sectionTitle.text = title
        }
    }
}
