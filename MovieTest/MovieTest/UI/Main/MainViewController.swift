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
                case .reloadData:
                    self?.tableView.reloadData()
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
        viewModel.didSelectTab(segment: selectedTab)
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
        return viewModel.moviesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as? MovieTableViewCell else { return UITableViewCell() }
        
        let title = viewModel.getMovieTitle(indexPath: indexPath.row)
        let imagePath = viewModel.getMovieImagePath(indexPath: indexPath.row)
        let releaseDate = viewModel.getMovieReleaseDate(indexPath: indexPath.row)
        let averageVote = viewModel.getMovieAvgVoteScore(indexPath: indexPath.row)
        let isFav = viewModel.currentMovies[indexPath.row].isFav
        
        cell.configureCell(title: title, releaseDate: releaseDate, averageVote: averageVote, imagePath: imagePath, isFav: isFav)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = viewModel.currentMovies[indexPath.row]
        navigateToDetailsScreen(with: selectedMovie)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isNearEndOfList = indexPath.row == viewModel.moviesCount - 5
        
        if isNearEndOfList, let selectedTab = SegementTab(rawValue: segmentedControl.selectedSegmentIndex) {
            if selectedTab == .popular || selectedTab == .nowPlaying {
                if let currentPage = viewModel.currentPage[selectedTab],
                   let totalPages = viewModel.totalPages[selectedTab] {
                    // Check if the current page is less than the total pages
                    if currentPage < totalPages {
                        viewModel.fetchNextPage(for: selectedTab, page: currentPage)
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
