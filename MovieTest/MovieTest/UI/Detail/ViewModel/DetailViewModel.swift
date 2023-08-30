//
//  DetailViewModel.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import Foundation

class DetailViewModel {
    
    //MARK: - Properties
    weak var coordinator: AppCoordinator?
    let selectedMovie: Movie?
    
    //MARK: - Init
    init(selectedMovie: Movie) {
        self.selectedMovie = selectedMovie
    }
}
