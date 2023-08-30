//
//  MovieTableViewCell.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit
import Kingfisher

class MovieTableViewCell: UITableViewCell {
    
    //MARK: - Cell identifier
    static let identifier: String = "MovieCell"
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var averageVoteLabel: UILabel!
    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    ///Configure cell with title , release year , vote and image path.
    func configureCell(title: String, releaseYear: String, averageVote: Double, imagePath: String) {
        indicatorView.startAnimating()
        
        titleLabel.text = title
        releaseDateLabel.text = releaseYear
        averageVoteLabel.text = String((averageVote))
        
        //Download Image using imagePath and Kingfisher
        let movieCompleteUrl = Constants.imageBaseURL + imagePath
        guard let requestDownloadURL = URL(string: movieCompleteUrl) else { return }
        
        movieImageView.kf.setImage(with: requestDownloadURL) { [weak self] result in
             self?.indicatorView.stopAnimating()
         }
    }
}
