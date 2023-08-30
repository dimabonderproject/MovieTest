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
    private(set) var movies: MoviesCategory? = MoviesCategory()
    
    //MARK: - Init
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    //MARK: - Methods
    func preFetchMoviesByCategories(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        preFetchPopularMovies {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        preFetchNowPlayingMovies {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
           completion()
        }
    }
    
    //MARK: - Private Methods
    private func preFetchNowPlayingMovies(completion: @escaping () -> Void) {
        movieService?.fetchNowPlayingMovies { [weak self] result in
            switch result {
            case .success(let moviesResponse):
                self?.movies?.nowPlayingMovies = moviesResponse.results
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    private func preFetchPopularMovies(completion: @escaping () -> Void ) {
        movieService?.fetchPopularMovies { [weak self] result in
            switch result {
            case .success(let moviesResponse):
                self?.movies?.popularMovies = moviesResponse.results
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    func handleNavigationToMainApp() {
        guard let movieService = movieService else { return }
        guard let movieCategory = movies else { return }
        coordinator?.loadMainScreen(movieService: movieService, movies: movieCategory)
    }
}
