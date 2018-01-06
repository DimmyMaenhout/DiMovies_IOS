//
//  MovieHeaderCell.swift
//  DiMovies2
//
//  Created by Dimmy Maenhout on 24/12/2017.
//  Copyright © 2017 Dimmy Maenhout. All rights reserved.
//

import Foundation
import UIKit
class MovieHeaderCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var seenMovie: UIButton!
    
    @IBOutlet weak var wantToSeeMovie: UIButton!
    
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var duration: UILabel!
    
    @IBOutlet weak var nameDirector: UILabel!
    
    @IBOutlet weak var nameWriter: UILabel!
    
    @IBOutlet weak var genre: UILabel!
    
    @IBOutlet weak var starsInMovie: UILabel!
    
    @IBOutlet weak var overview: UILabel!
    
    @IBOutlet weak var trailerMovie: UIView!
    
    var movie : Movie! {
        
        didSet{
            title.text = movie.title
            score.text = "\(movie.vote_average)"
            duration.text = movie.duration
            nameDirector.text = movie.director
            nameWriter.text = movie.writer
            //genre.text = movie.genre
            starsInMovie.text = movie.stars
            overview.text = movie.overview
            
        }
    }
}
