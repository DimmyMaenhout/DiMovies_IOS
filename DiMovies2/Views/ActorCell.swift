//
//  ActorCell.swift
//  DiMovies2
//
//  Created by Dimmy Maenhout on 24/12/2017.
//  Copyright © 2017 Dimmy Maenhout. All rights reserved.
//

import Foundation
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
