//
//  MainViewController.swift
//  MovieTest
//
//  Created by Dmitri Bondartchev on 30/08/2023.
//

import UIKit

class MainViewController: UIViewController {
    //MARK: - Properties
    private var viewModel: MainViewModel
    
    
    //MARK: - IBOutlets
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - Initializer
    init(viewModel: MainViewModel ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //MARK: - Methods
    
    
    //MARK: - Private Methods
    private func setupUI() {
        navigationItem.hidesBackButton = true
    }
    
    private func setupTableView() {
        
    }
    
    //MARK: - IBActions
    @IBAction func segementedControllPressed(_ sender: UISegmentedControl) {
        
    }
    
}
