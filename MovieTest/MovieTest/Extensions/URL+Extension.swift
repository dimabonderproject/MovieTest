//
//  URL+Extension.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 31/08/2023.
//

import Foundation

extension URL {
    static func createMovieImageURL(withImagePath imagePath: String) -> URL? {
        let movieCompleteUrl = Constants.imageBaseURL + imagePath
        return URL(string: movieCompleteUrl)
    }
}
