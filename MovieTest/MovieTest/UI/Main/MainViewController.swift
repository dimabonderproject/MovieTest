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
    private var fetchNextPageDelayWorkItem: DispatchWorkItem?

    //MARK: - IBOutlets
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
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
                    self?.showAlert(title: title, message: "")
                case .navigateBackFromDetailScreen:
                    self?.navigationController?.popViewController(animated: true)
                case .reloadData:
                    self?.tableView.reloadData()
                case .stopAnimate:
                    self?.stopIndicatorAnimation()
                case .showErrorAlert(title: let title, message: let message):
                    self?.showAlert(title: title, message: message)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = true
        indicatorView.hidesWhenStopped = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.movieTableViewCell, bundle: nil), forCellReuseIdentifier: MovieTableViewCell.identifier)
    }
    
    private func navigateToDetailsScreen(with selectedMovie: Movie) {
        let viewModel = DetailViewModel(selectedMovie: selectedMovie)
        let viewController = DetailsViewController(viewModel: viewModel)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func startIndicatorAnimation() {
        DispatchQueue.main.async { [weak self] in
            self?.indicatorView.startAnimating()
        }
    }
    
    private func stopIndicatorAnimation() {
        DispatchQueue.main.async { [weak self] in
            self?.indicatorView.hidesWhenStopped = true
            self?.indicatorView.stopAnimating()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - IBActions
    @IBAction func segementedControllPressed(_ sender: UISegmentedControl) {
        guard let selectedTab = SegementTab(rawValue: sender.selectedSegmentIndex) else { return }
        viewModel.didSelectTab(segment: selectedTab)
    }
}

//MARK: - UITableViewDelegate , UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.moviesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as? MovieTableViewCell else { return UITableViewCell() }
        
        if let movie = viewModel.currentMovies[safe: indexPath.row] {
            let title = viewModel.getMovieTitle(indexPath: indexPath.row)
            let imagePath = viewModel.getMovieImagePath(indexPath: indexPath.row)
            let releaseDate = viewModel.getMovieReleaseDate(indexPath: indexPath.row)
            let averageVote = viewModel.getMovieAvgVoteScore(indexPath: indexPath.row)
            let isFav = movie?.isFav ?? false
            
            cell.configureCell(title: title, releaseDate: releaseDate, averageVote: averageVote, imagePath: imagePath, isFav: isFav)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedMovie = viewModel.currentMovies[indexPath.row] else { return  }
        navigateToDetailsScreen(with: selectedMovie)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isNearEndOfList = indexPath.row >= 3 && indexPath.row == viewModel.moviesCount - 3
        
        if isNearEndOfList, let selectedTab = SegementTab(rawValue: segmentedControl.selectedSegmentIndex) {
            if selectedTab == .popular || selectedTab == .nowPlaying {
                if let currentPage = viewModel.currentPage[selectedTab],
                   let totalPages = viewModel.totalPages[selectedTab] {
                    if currentPage < totalPages {
                        
                        // Cancel any previously scheduled work item to prevent multiple API calls
                        fetchNextPageDelayWorkItem?.cancel()
                        
                        // Start indicator animation to show loading progress
                        startIndicatorAnimation()
                        
                        // Create a new debounce work item
                        fetchNextPageDelayWorkItem = DispatchWorkItem { [weak self] in
                            // Fetch the next page of data
                            self?.viewModel.fetchNextPage(for: selectedTab, page: currentPage)
                        }
                        
                        // Schedule the work item after a delay of 1 second to avoid rapid swiping
                        if let fetchNextPageDelayWorkItem = fetchNextPageDelayWorkItem {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: fetchNextPageDelayWorkItem)
                        }
                    }
                }
            }
        }
    }
}

//MARK: - DetailsViewControllerDelegate
extension MainViewController: DetailsViewControllerDelegate {
    func didAddMovieToFavorites(selectedMovie: Movie) {
        viewModel.notifyNavigationBackToMainScreen()
        viewModel.appendFavoriteMovieToDataSource(selectedMovie: selectedMovie)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
