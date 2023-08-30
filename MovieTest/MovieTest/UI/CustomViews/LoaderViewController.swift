//
//  LoaderViewController.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit

class LoaderViewController: UIViewController {

    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    let loadingLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the UI
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = .white

        // Add the UI elements to the view
        view.addSubview(activityIndicatorView)
        view.addSubview(loadingLabel)

        // Position the UI elements
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingLabel.topAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor, constant: 16),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        // Start the activity indicator animation
        activityIndicatorView.startAnimating()
    }
}

class Loadable: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var greyView: UIView?
    let loadingLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func activityIndicatorBegin() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        activityIndicator.style = .large
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        greyView = UIView()
        greyView?.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        greyView?.backgroundColor = UIColor.black
        greyView?.alpha = 0.5
        self.view.addSubview(greyView ?? UIView())
    }

    func activityIndicatorEnd() {
        self.activityIndicator.stopAnimating()
        self.greyView?.removeFromSuperview()
    }
}

