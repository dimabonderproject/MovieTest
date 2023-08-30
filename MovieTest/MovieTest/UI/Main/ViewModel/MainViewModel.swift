//
//  MainViewModel.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import Foundation
import Combine

enum SegementTab: Int {
    case popular = 0
    case nowPlaying = 1
    case favorites = 2
}

enum MainViewModelUIEvents {
    case navigateBackFromDetailScreen
    case movieAddToFav(title: String)
    case movieAlreadyExistInFav(title: String)
}

class MainViewModel {
    
    //MARK: - Properties
    weak var coordinator: AppCoordinator?
    private let movieService: MovieService?
    private(set) var movies: MoviesCategory?
    private(set) var selectedTab: SegementTab = .popular
    private(set) var favoriteMovies: [Movie] = []
    private(set) var dataSoruceDict: [SegementTab: [Movie]] = [:]
    private(set) var uiEventsPublisher = PassthroughSubject<MainViewModelUIEvents,Never>()
    
    var currentMovies: [Movie] {
        dataSoruceDict[selectedTab] ?? []
    }
    
    //MARK: - Init
    init(movies: MoviesCategory, movieService: MovieService) {
        self.movies = movies
        self.movieService = movieService
        
        setDataSource()
    }
    
    //MARK: - Methods
    
    /// Selects a specific tab and triggers a completion block.
       /// - Parameters:
       ///   - segment: The SegementTab to be selected.
       ///   - completion: A completion block to be executed after the tab is selected.
    func didSelectTab(segment: SegementTab, completion: @escaping () -> Void) {
        selectedTab = segment
        completion()
    }
    
    /// Appends a movie to the favorite movies data source if it doesn't exist, otherwise notifies that the movie already exists.
       /// - Parameter selectedMovie: The selected movie to be added to favorites.
    func appendFavoriteMovieToDataSource(selectedMovie: Movie) {
        if !favoriteMovies.contains(where: { $0.title == selectedMovie.title }) {
            favoriteMovies.append(selectedMovie)
            notifyMovieHaveBeenAddedToFav()
            dataSoruceDict[.favorites] = favoriteMovies
        } else {
            notifyMovieAlreadyExistsInFav()
            dataSoruceDict[.favorites] = favoriteMovies
        }
    }
    
    func notifyNavigationBackToMainScreen() {
        uiEventsPublisher.send(.navigateBackFromDetailScreen)
    }
    
    //MARK: - Private Methods
    private func setDataSource() {
        dataSoruceDict[.popular] = movies?.popularMovies ?? []
        dataSoruceDict[.nowPlaying] = movies?.nowPlayingMovies ?? []
    }
    
    private func notifyMovieHaveBeenAddedToFav() {
        uiEventsPublisher.send(.movieAddToFav(title: Constants.addToFavTitle))
    }
    
    private func notifyMovieAlreadyExistsInFav() {
        uiEventsPublisher.send(.movieAddToFav(title: Constants.existInFavTitle))
    }

}
