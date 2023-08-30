//
//  MainViewController.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    //MARK: - Properties
    private var viewModel: MainViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    //MARK: - IBOutlets
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        addObservers()
    }
    
    //MARK: - Initializer
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //MARK: - Methods
    
    
    //MARK: - Private Methods
    private func addObservers() {
        viewModel.uiEventsPublisher
            .sink { [weak self] event in
                switch event {
                case .movieAddToFav(title: let title),
                     .movieAlreadyExistInFav(title: let title):
                    self?.showAlert(title: title)
                case .navigateBackFromDetailScreen:
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.movieTableViewCell, bundle: nil), forCellReuseIdentifier: MovieTableViewCell.identifier)
    }
    
    //MARK: - IBActions
    @IBAction func segementedControllPressed(_ sender: UISegmentedControl) {
        guard let selectedTab = SegementTab(rawValue: sender.selectedSegmentIndex) else { return }
        viewModel.didSelectTab(segment: selectedTab) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func navigateToDetailsScreen(with selectedMovie: Movie) {
        let viewModel = DetailViewModel(selectedMovie: selectedMovie)
        let viewController = DetailsViewController(viewModel: viewModel)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate , UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as? MovieTableViewCell else { return UITableViewCell() }
        
        let title = viewModel.currentMovies[indexPath.row].title ?? ""
        let imagePath = viewModel.currentMovies[indexPath.row].posterPath ?? ""
        let releaseYear = viewModel.currentMovies[indexPath.row].releaseDate ?? ""
        let averageVote = viewModel.currentMovies[indexPath.row].voteAverage ?? 0.0
        
        cell.configureCell(title: title, releaseYear: releaseYear, averageVote: averageVote, imagePath: imagePath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = viewModel.currentMovies[indexPath.row]
        navigateToDetailsScreen(with: selectedMovie)
    }
}

//MARK: - DetailsViewControllerDelegate
extension MainViewController: DetailsViewControllerDelegate {
    func didAddMovieToFavorites(selectedMovie: Movie) {
        viewModel.notifyNavigationBackToMainScreen()
        viewModel.appendFavoriteMovieToDataSource(selectedMovie: selectedMovie)
    }
}
