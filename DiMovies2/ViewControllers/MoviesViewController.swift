//
//  MoviesViewController.swift
//  DiMovies2
//
//  Created by Dimmy Maenhout on 24/12/2017.
//  Copyright © 2017 Dimmy Maenhout. All rights reserved.
//

import Foundation
import UIKit

class MoviesViewController : UIViewController {
    
    let apiKey = "fba7c35c2680c39c8829a17d5e902b97"
    let baseURL_TMDB = "https://api.themoviedb.org/3"
    //voor poster
    let baseUrlPoster = "https://image.tmdb.org/t/p/"
    let sizePoster = "w92"
    var moviesTBMD : [Dictionary<String, Any>?] = []
    var movies: [Movie] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        getMoviesPlaying()
    }
    
    func getMoviesPlaying() {
        
        let postData = NSData(data:"{}".data(using: String.Encoding.utf8)!)
        var request = URLRequest(
            url: NSURL(string: "\(baseURL_TMDB)/movie/now_playing?page=1&language=en-US&api_key=\(apiKey)")! as URL,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data{
                if let responsed = try! JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any>{
                    //gebruikt om te kijken of er data ontvangen werd
                    //print("response from TMDB: \(responsed)")
                    self.moviesTBMD = responsed["results"] as! [Dictionary<String, Any>]
                    
                    DispatchQueue.main.async {
                        var movies : [Movie] = []
                        for i in 0 ... self.moviesTBMD.count - 1{
                            var genre_ids : [Int] = self.moviesTBMD[i]!["genre_ids"] as! [Int]
                            var movie = Movie(movie_id: self.moviesTBMD[i]!["id"] as! Int,
                                              imdb_id: "",
                                              title: self.moviesTBMD[i]!["title"] as! String,
                                              overview: self.moviesTBMD[i]!["overview"] as! String,
                                              duration: "",
                                              budget: 0.0,
                                              //genre: "",
                                              popularity: self.moviesTBMD[i]!["popularity"] as! Double,
                                              releaseDate: self.moviesTBMD[i]!["release_date"] as! String,
                                              revenue: 0.0,
                                              status: "",
                                              tagline: "",
                                              video: self.moviesTBMD[i]!["video"] as! Bool,
                                              vote_average: self.moviesTBMD[i]!["vote_average"] as! Double,
                                              votecount: self.moviesTBMD[i]!["vote_count"] as! Int,
                                              writer: "",
                                              director: "",
                                              stars: "",
                                              //genre_ids: genre_ids,
                                              genres: [],
                                              poster_path: self.moviesTBMD[i]!["poster_path"] as! String)
                            movies.append(movie)
                            
                        }
                        self.movies = movies
                       /* for i in movies{
                            print("movie:")
                            print(i.title)
                        }*/
                        self.tableView.reloadData()
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "selectedMovie" else {
            fatalError("Unknown segue")
        }
        let movieSelectionViewController = segue.destination as! MovieSelectionViewController
        movieSelectionViewController.movie = movies[tableView.indexPathForSelectedRow!.row]
        
    }
}

extension MoviesViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesTBMD.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        
        cell.title.text = movie.title
        var punten : String = String(format: "%.1F",movie.vote_average!)
        cell.score.text = punten
        cell.overview.text = movie.overview
        
        //voor image bestaat de url uit 3 delen = base_url, full_size and the file path
        let imageURL = movie.poster_path
        let moviePosterURL = URL(string: baseUrlPoster + sizePoster + imageURL)!
        let data = try! Data.init(contentsOf: moviePosterURL)
        cell.poster.image =  UIImage(data: data)
        
        return cell
    }
}

extension MoviesViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // performSegue(withIdentifier: "selectedMovie", sender: self)
    }
    
}
