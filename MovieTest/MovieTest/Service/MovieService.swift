//
//  MovieService.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import Foundation

class MovieService {
    
    private let networkingService: NetworkingService
    
    /// Initializes the MovieService with a base URL.
    /// - Parameter baseURL: The base URL for API requests.
    init(baseURL: String) {
        networkingService = NetworkingService(baseURL: baseURL)
    }
    
    /// Fetches a list of popular movies.
    /// - Parameter completion: A closure to be called when the fetch is complete. The closure takes a `Result` containing a `MovieResult` or a `NetworkError`.
    func fetchPopularMovies(page: Int , completion: @escaping (Result<MovieResult, NetworkError>) -> Void) {
        networkingService.fetchData(for: .popularMovies, method: .get, page: page, completion: completion)
    }
    
    /// Fetches a list of now playing movies.
    /// - Parameter completion: A closure to be called when the fetch is complete. The closure takes a `Result` containing a `MovieResult` or a `NetworkError`.
    func fetchNowPlayingMovies(page: Int ,completion: @escaping (Result<MovieResult, NetworkError>) -> Void) {
        networkingService.fetchData(for: .nowPlaying, method: .get, page: page, completion: completion)
    }
    
    /// Fetches the next page of movies for a specific segment tab.
    /// - Parameters:
    ///   - tab: The segment tab for which to fetch the next page of movies.
    ///   - page: The current page number of the movies to be fetched.
    ///   - completion: A closure to be called when the fetch is complete. The closure takes a `Result` containing a `MovieResult` or a `NetworkError`.
    func fetchNextPage(for tab: SegementTab, page: Int, completion: @escaping (Result<MovieResult, NetworkError>) -> Void) {
        switch tab {
        case .popular:
            fetchPopularMovies(page: page + 1, completion: completion)
        case .nowPlaying:
            fetchNowPlayingMovies(page: page + 1, completion: completion)
        default:
            break
        }
    }
}
