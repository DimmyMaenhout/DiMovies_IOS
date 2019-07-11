//
//  MoviesPlayingViewModel.swift
//  DiMovies2
//
//  Created by Philippe Asselbergh on 11/07/2019.
//  Copyright © 2019 Dimmy Maenhout. All rights reserved.
//

import Foundation

protocol MoviesPlayingViewModelDelegate: class {
    func refresh()
}
class MoviesPlayingViewModel {
    // MARK: - Delegate
    weak var delegate: MoviesPlayingViewModelDelegate?

    // MARK: - Variables
    private var movies: [Movie] = []
    private var moviesTask: URLSessionTask?
    private var currentPage = 1
    var isFetchInProgress = false

    var hasMovies: Bool {
        return !movies.isEmpty
    }

    var movieCount: Int {
        return movies.count
    }

    func movie(for index: Int) -> Movie {
        return movies[index]
    }

    func fetchMovies() {
        isFetchInProgress = true
        currentPage += 1
        moviesTask?.cancel()
        moviesTask = TmdbAPIService.getMoviesPlaying(with: currentPage) { [weak self] moviesPlaying in
            self?.isFetchInProgress = false
            if let moviesPlaying = moviesPlaying, let movies = self?.movies {
                self?.movies.insert(contentsOf: moviesPlaying, at: movies.count)
            }
            self?.delegate?.refresh()
        }
        moviesTask!.resume()
    }

}
