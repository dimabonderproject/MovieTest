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
    
    @IBOutlet private weak var heartImageView: UIImageView!
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
    
    //MARK: - Public Method
    ///Configure cell with title , release year , vote and image path.
    func configureCell(title: String, releaseDate: String, averageVote: Double, imagePath: String, isFav: Bool) {
        
        updateHeartImage(isFav: isFav)
        
        indicatorView.startAnimating()
        titleLabel.text = title
        releaseDateLabel.text = releaseDate
        averageVoteLabel.text = String((averageVote))
        
        //Download Image using imagePath and Kingfisher
        guard let requestDownloadURL = URL.createMovieImageURL(withImagePath: imagePath) else {
            return
        }
        
        movieImageView.kf.setImage(with: requestDownloadURL) { [weak self] result in
            self?.indicatorView.stopAnimating()
        }
    }
    
    //MARK: - Private Method
    //Disclaimer - * added just for cool slicky ui :) *
    private func updateHeartImage(isFav: Bool) {
        heartImageView.image = isFav ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
     
        // Apply animation to heart image changes
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.heartImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.2) {
                self?.heartImageView.transform = .identity
            }
        }
    }
}
