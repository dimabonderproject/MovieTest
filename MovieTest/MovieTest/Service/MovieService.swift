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
    func fetchPopularMovies(completion: @escaping (Result<MovieResult, NetworkError>) -> Void) {
        networkingService.fetchData(for: .popularMovies, method: .get, completion: completion)
    }
    
    /// Fetches a list of now playing movies.
    /// - Parameter completion: A closure to be called when the fetch is complete. The closure takes a `Result` containing a `MovieResult` or a `NetworkError`.
    func fetchNowPlayingMovies(completion: @escaping (Result<MovieResult, NetworkError>) -> Void) {
        networkingService.fetchData(for: .nowPlaying, method: .get, completion: completion)
    }
}
