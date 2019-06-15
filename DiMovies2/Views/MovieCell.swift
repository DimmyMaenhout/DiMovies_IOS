import UIKit

class MovieCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var score: UILabel!
    
    var movie : Movie! {
        
        didSet {
            title.text = movie.title
            overview.text = movie.overview
            score.text = String(describing: movie.vote_average)
        }
    }
}
