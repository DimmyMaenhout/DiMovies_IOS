import UIKit

class MovieHeaderCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var starsInMovie: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var releaseDate: UILabel!
    
    var movie : Movie! {
        
        didSet{
            title.text = movie.title
            score.text = "\(String(describing: movie.vote_average))"
            duration.text = "\(String(describing: movie.duration))"
            //genre.text = movie.genre
            starsInMovie.text = movie.stars
            overview.text = movie.overview
            releaseDate.text = movie.release_date
        }
    }
}
