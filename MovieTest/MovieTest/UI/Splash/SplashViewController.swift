//
//  SplashViewController.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit
import Combine

class SplashViewController: UIViewController {
    
    //MARK: - Properties
    private var viewModel: SplashViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    //MARK: - IBOutlets
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initApp()
        addObservers()
    }
    
    //MARK: - Initializer
    init(viewModel: SplashViewModel ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //MARK: - Private Methods
    private func initApp() {
        indicatorView.startAnimating()
        viewModel.preFetchMoviesByCategories { [weak self] in
            //Disclaimer * just added the delay in order to accomplish the effect of the loader in the splash :) *
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.indicatorView.stopAnimating()
                self?.navigateToMainApp()
            }
        }
    }
    
    private func addObservers() {
        viewModel.uiEventsPublisher
            .sink { [weak self] event in
                switch event {
                case .showErrorAlert(title: let title, message: let message):
                    self?.showAlert(title: title, message: message)
                }
            }
            .store(in: &cancellables)
    }
    
    private func navigateToMainApp() {
        viewModel.handleNavigationToMainApp()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
