//
//  MoviesCategory.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import Foundation

struct MoviesCategory: Codable {
    
    var popularMovies: [Movie]?
    var nowPlayingMovies: [Movie]?
    
    init(popularMovies: [Movie]? = nil, nowPlayingMovies: [Movie]? = nil) {
        self.popularMovies = popularMovies
        self.nowPlayingMovies = nowPlayingMovies
    }
}
