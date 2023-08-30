//
//  MainViewModel.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import Foundation

class MainViewModel {
    //MARK: - Properties
    weak var coordinator: AppCoordinator?
    private let movies: [Movie]?
    private let movieService: MovieService?
    
    //MARK: - Init
    init(movies: [Movie], movieService: MovieService) {
        self.movies = movies
        self.movieService = movieService
        
        print(movies)
    }
    
    //MARK: - Methods
    
    //MARK: - Private Methods
}
