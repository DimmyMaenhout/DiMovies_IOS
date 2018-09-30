import Foundation
import UIKit
import WebKit

class TrailerCell : UITableViewCell {
    
    @IBOutlet weak var webView: WKWebView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
