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
    
    var path: String {
        switch self {
        case .popularMovies:
            return "/3/movie/popular"
        }
    }
    
//    var queryItems: [URLQueryItem]? {
//        switch self {
//        case .popularMovies:
//            return [URLQueryItem(name: "", value: "")]
//        }
//    }
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
    
    private func makeRequest(endpoint: Endpoint, method: HTTPMethod, body: Data? = nil, headers: [String: String]? = nil) -> URLRequest? {
        
        guard let baseURL = URL(string: baseURL ?? "") else { return nil}
        
        let urlType = baseURL.appendingPathComponent(endpoint.path)
        
        var components = URLComponents(url: urlType, resolvingAgainstBaseURL: true)
        
//        if let queryItems = endpoint.queryItems {
//            components?.queryItems = queryItems
//        }
        
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
    
    func fetchData<T: Codable>(for endpoint: Endpoint, method: HTTPMethod, body: Data? = nil, headers: [String: String]? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        guard let request = makeRequest(endpoint: endpoint, method: method, body: body, headers: headers) else {
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
    
    static func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }
    
}

