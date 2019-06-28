import UIKit

class ActorCell : UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    var actor : Actor! {
        didSet{
            name.text = actor.name
            bio.text = actor.biography
        }
    }
}
