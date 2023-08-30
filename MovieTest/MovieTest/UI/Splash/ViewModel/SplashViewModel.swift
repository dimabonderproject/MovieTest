//
//  SplashViewModel.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import Foundation

class SplashViewModel {
    
    //MARK: - Properties
    weak var coordinator: AppCoordinator?
    private let movieService: MovieService?
    private var movies: [Movie] = []
    
    //MARK: - Init
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    //MARK: - Methods
    
    //MARK: - Private Methods
    func preFetchPopularMovies(completion: @escaping () -> Void ) {
        movieService?.fetchPopularMovies(completion: { [weak self] result in
            switch result {
            case .success(let moviesResponse):
                self?.movies = moviesResponse.results
                completion()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func handleNavigationToMainApp() {
        guard let movieService = movieService else { return }
        coordinator?.loadMainScreen(movieService: movieService, movies: movies)
    }
}
