//
//  SplashViewController.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit

class SplashViewController: Loadable {
    
    //MARK: - Properties
    private var viewModel: SplashViewModel
    
    
    //MARK: - IBOutlets
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initApp()
    }
    
    //MARK: - Initializer
    init(viewModel: SplashViewModel ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    //MARK: - Methods
    
    
    //MARK: - Private Methods
    private func initApp() {
        self.activityIndicatorBegin()
        viewModel.preFetchPopularMovies(completion: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.activityIndicatorEnd()
                self?.navigateToMainApp()
            }
        })
    }
    
    private func navigateToMainApp() {
        viewModel.handleNavigationToMainApp()
    }
    
    //MARK: - IBActions


}
