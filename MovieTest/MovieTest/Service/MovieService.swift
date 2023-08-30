//
//  MovieService.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import Foundation

class MovieService {
    
    private let networkingService: NetworkingService
    
    init(baseURL: String) {
        networkingService = NetworkingService(baseURL: baseURL)
    }
    
    func fetchPopularMovies(completion: @escaping (Result<MovieResult, NetworkError>) -> Void) {
        networkingService.fetchData(for: .popularMovies, method: .get, completion: completion)
    }
}
