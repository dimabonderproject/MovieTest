//
//  DetailsViewController.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit
import Kingfisher

protocol DetailsViewControllerDelegate: AnyObject {
    func didAddMovieToFavorites(selectedMovie: Movie)
}

class DetailsViewController: UIViewController {
    
    //MARK: - Properties
    private var viewModel: DetailViewModel
    weak var delegate: DetailsViewControllerDelegate?
    
    //MARK: - IBOutlets
    @IBOutlet private weak var addToFavButton: UIButton!
    @IBOutlet private weak var movieTitleLabel: UILabel!
    @IBOutlet private weak var movieDescription: UILabel!
    @IBOutlet private weak var movieReleaseDate: UILabel!
    @IBOutlet private weak var movieImageView: UIImageView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupUIForNavigationBar()
    }
    
    //MARK: - Initializer
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    //MARK: - Private Methods
    private func setupUIForNavigationBar() {
        navigationItem.hidesBackButton = false
        navigationController?.navigationBar.isHidden = false
    }
    
    func setupUI() {
        movieTitleLabel.text = viewModel.getMovieTitle()
        movieDescription.text = viewModel.getMovieOverview()
        movieReleaseDate.text = "Release date: \(viewModel.getMovieReleaseDate())"
        
        guard let requestDownloadURL = URL.createMovieImageURL(withImagePath: viewModel.getMovieImagePath()) else {
            return
        }
        movieImageView.kf.setImage(with: requestDownloadURL)
    }
    
    //MARK: - IBActions
    @IBAction func addMovieButtonPressed(_ sender: UIButton) {
        guard let selectedMovie = viewModel.selectedMovie else { return }
        delegate?.didAddMovieToFavorites(selectedMovie: selectedMovie)
    }
}
