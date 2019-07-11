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

    func bind(movie: Movie) {
        self.movie = movie
        title.text = movie.title
        score.text = String(format: "%.1F",movie.vote_average)
        if movie.overview.isEmpty {
            movie.overview = Constants.notAvailableString
        }
        overview.text = movie.overview

        if !movie.poster_path.isEmpty {
            //The image url exists of 3 pieces: base_url, full_size and the file path
            let imageURL = movie.poster_path
            let moviePosterURL = URL(string: TmdbApiData.baseUrlPoster + TmdbApiData.sizePosterW92 + imageURL)!
            poster.sd_setImage(with: moviePosterURL)
        }
    }
}
