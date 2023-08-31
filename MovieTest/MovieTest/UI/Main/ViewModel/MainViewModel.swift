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
    case reloadData
}

class MainViewModel {
    
    //MARK: - Properties
    weak var coordinator: AppCoordinator?
    private let movieService: MovieService?
    private(set) var movies: MoviesCategory?
    private(set) var selectedTab: SegementTab = .popular
    private(set) var favoriteMovies: [Movie] = []
    private(set) var dataSoruceDict: [SegementTab: [Movie]] = [:]
    private(set) var currentPage: [SegementTab: Int] = [.popular: 1, .nowPlaying: 1, .favorites: 1]
    private(set) var totalPages: [SegementTab: Int] = [:]
    private(set) var uiEventsPublisher = PassthroughSubject<MainViewModelUIEvents,Never>()
    
    var currentMovies: [Movie] {
        dataSoruceDict[selectedTab] ?? []
    }
    
    //MARK: - Init
    init(movies: MoviesCategory, movieService: MovieService,totalPages: [SegementTab: Int]) {
        self.movies = movies
        self.movieService = movieService
        self.totalPages = totalPages
        
        setDataSource()
    }
    
    //MARK: - Public Methods
    /// Selects a specific tab and triggers a completion block.
    /// - Parameters:
    ///   - segment: The SegementTab to be selected.
    func didSelectTab(segment: SegementTab) {
        selectedTab = segment
        uiEventsPublisher.send(.reloadData)
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
        
        if let index = dataSoruceDict[.popular]?.firstIndex(where: { $0.title == selectedMovie.title }) {
            dataSoruceDict[.popular]?[index].isFav = true
            uiEventsPublisher.send(.reloadData) // Reload the table view
        }
        
        if let index = dataSoruceDict[.nowPlaying]?.firstIndex(where: { $0.title == selectedMovie.title }) {
            dataSoruceDict[.nowPlaying]?[index].isFav = true
            uiEventsPublisher.send(.reloadData) // Reload the table view
        }
    }
    
    func fetchNextPage(for tab: SegementTab, page: Int) {
        movieService?.fetchNextPage(for: tab, page: page) { [weak self] result in
            switch result {
            case .success(let moviesResponse):
                if !moviesResponse.results.isEmpty {
                    self?.totalPages[tab] = moviesResponse.totalPages 
                    self?.currentPage[tab] = page + 1
                    self?.dataSoruceDict[tab]?.append(contentsOf: moviesResponse.results)
                    DispatchQueue.main.async { [weak self] in
                        self?.uiEventsPublisher.send(.reloadData)
                    }
                } else {
                    print("Next Page is Empty")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func notifyNavigationBackToMainScreen() {
        uiEventsPublisher.send(.navigateBackFromDetailScreen)
    }
    
    func getMovieTitle(indexPath: Int) -> String {
        return currentMovies[indexPath].title ?? ""
    }
    
    func getMovieImagePath(indexPath: Int) -> String {
        return currentMovies[indexPath].posterPath ?? ""
    }
    
    func getMovieReleaseDate(indexPath: Int) -> String {
        return currentMovies[indexPath].releaseDate ?? ""
    }
    
    func getMovieAvgVoteScore(indexPath: Int) -> Double {
        return currentMovies[indexPath].voteAverage ?? 0.0
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

//MARK: - Extenion for convience
extension MainViewModel {
    var moviesCount: Int {
        return currentMovies.count
    }
}
