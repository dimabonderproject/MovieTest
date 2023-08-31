//
//  SplashViewModel.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import Foundation
import Combine

enum SplashViewModelUIEvents {
    case showErrorAlert(title: String, message: String)
}

class SplashViewModel {
    
    //MARK: - Properties
    weak var coordinator: AppCoordinator?
    private let movieService: MovieService?
    private(set) var totalPages: [SegementTab: Int] = [:]
    private(set) var movies: MoviesCategory? = MoviesCategory()
    private(set) var uiEventsPublisher = PassthroughSubject<SplashViewModelUIEvents,Never>()
    
    //MARK: - Init
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    //MARK: - Public Methods
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
        movieService?.fetchNowPlayingMovies(page: 1) { [weak self] result in
            switch result {
            case .success(let moviesResponse):
                self?.totalPages[.nowPlaying] = moviesResponse.totalPages
                self?.movies?.nowPlayingMovies = moviesResponse.results
            case .failure(let error):
                print("Self logged error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.uiEventsPublisher.send(.showErrorAlert(title: Constants.errorTitle, message: Constants.errorMessage))
                }
            }
            completion()
        }
    }
    
    private func preFetchPopularMovies(completion: @escaping () -> Void ) {
        movieService?.fetchPopularMovies(page: 1) { [weak self] result in
            switch result {
            case .success(let moviesResponse):
                self?.totalPages[.popular] = moviesResponse.totalPages
                self?.movies?.popularMovies = moviesResponse.results
            case .failure(let error):
                print("Self logged error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.uiEventsPublisher.send(.showErrorAlert(title: Constants.errorTitle, message: Constants.errorMessage))
                }
            }
            completion()
        }
    }
    
    func handleNavigationToMainApp() {
        guard let movieService = movieService else { return }
        guard let movieCategory = movies else { return }
        coordinator?.loadMainScreen(movieService: movieService, movies: movieCategory, totalPages: totalPages)
    }
}
