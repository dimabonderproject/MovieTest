//
//  NetworkingService.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit

enum HTTPMethod: String {
    case get = "GET"
}

enum Endpoint {
    case popularMovies
    case nowPlaying
    
    var path: String {
        switch self {
        case .popularMovies:
            return "/3/movie/popular"
        case .nowPlaying:
            return "/3/movie/now_playing"
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

class NetworkingService {
    private let baseURL: String?
    private let token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiZDZhZTdlNzJkNjY0MTgxMzEwOTJjYTJiYjA5YTFiNSIsInN1YiI6IjYxMWU1NWFlODVjMGEyMDAyYTUxOTQzMyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.bk54icHGkw9DL1EhISdUdUgLc78an6ZaNWcwRLyw_Rw"
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    private func makeRequest(endpoint: Endpoint, method: HTTPMethod, page: Int? = nil, body: Data? = nil, headers: [String: String]? = nil) -> URLRequest? {
        
        guard let baseURL = URL(string: baseURL ?? "") else { return nil}
        
        var queryItems: [URLQueryItem] = []

        if let page = page {
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
        }

        let urlType = baseURL.appendingPathComponent(endpoint.path)
        
        var components = URLComponents(url: urlType, resolvingAgainstBaseURL: true)
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        var allHeaders = headers ?? [:]
        allHeaders["Authorization"] = "Bearer \(token)"
        allHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    func fetchData<T: Codable>(for endpoint: Endpoint, method: HTTPMethod, page: Int? = nil,body: Data? = nil, headers: [String: String]? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let request = makeRequest(endpoint: endpoint, method: method, page: page, body: body, headers: headers) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }
        task.resume()
    }
}

