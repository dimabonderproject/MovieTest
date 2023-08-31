//
//  AppCoordinator.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
}

class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Initializer
    init(navController: UINavigationController) {
        self.navigationController = navController
        
        setupNavigationAppearence()
    }
    
    
    //MARK: - Private
    private func setupNavigationAppearence() {
        let backButtonImage = UIImage(systemName: "chevron.backward")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        navigationController.navigationBar.topItem?.title = ""
        navigationController.navigationBar.backIndicatorImage = backButtonImage
        navigationController.navigationBar.backIndicatorTransitionMaskImage = backButtonImage
    }
    
    //MARK: - Public Methods
    func start() {
        let movieService = MovieService(baseURL: Constants.baseURL)
        let viewModel = SplashViewModel(movieService: movieService)
        viewModel.coordinator = self
        let viewController = SplashViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func loadMainScreen(movieService: MovieService, movies: MoviesCategory,totalPages: [SegementTab: Int]) {
        let viewModel = MainViewModel(movies: movies, movieService: movieService, totalPages: totalPages)
        viewModel.coordinator = self
        let viewController = MainViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
