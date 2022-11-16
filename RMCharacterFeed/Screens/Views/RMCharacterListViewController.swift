//
//  ViewController.swift
//  RMCharacterFeed
//
//  Created by Joe Thomas on 2022-11-13.
//

import UIKit

class RMCharacterListViewController: UIViewController {
   
    @IBOutlet weak var rmCharacterListTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    let activityView = UIActivityIndicatorView(style: .large)
    var characters: [RMCharacter] = []
    var filteredCharacters: [RMCharacter] = []
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        let filterBool = searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
        viewModel.isFiltering = filterBool
        return filterBool
    }
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    lazy var viewModel = {
        RMCharctersListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initViewModel()
        showActivityIndicatory()
        makeSearchField()
        customiseNavigationControl()
    }
    
    fileprivate func customiseNavigationControl() {
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.blue]
        } else {
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.blue]
        }
        navigationController?.navigationBar.backgroundColor = .white
        definesPresentationContext = true
    }
    
    fileprivate func makeSearchField() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Characters"
        searchController.searchBar.backgroundColor = .white
        navigationItem.searchController = searchController
    }
    
   
    
    func showActivityIndicatory() {
        activityView.center = self.view.center
        activityView.hidesWhenStopped = true
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    func initView() {
        rmCharacterListTableView.delegate = self
        rmCharacterListTableView.dataSource = self
        rmCharacterListTableView.backgroundColor = .white
        rmCharacterListTableView.separatorColor = .white
        rmCharacterListTableView.separatorStyle = .singleLine
        rmCharacterListTableView.tableFooterView = UIView()
        rmCharacterListTableView.allowsSelection = true
        rmCharacterListTableView.register(RMCharacterTableViewCell.nib, forCellReuseIdentifier: RMCharacterTableViewCell.identifier)
    }
    
    func initViewModel() {
        // Get character data
        viewModel.getRMCharacters()
        
        // Reload TableView closure
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.activityView.stopAnimating()
                self?.rmCharacterListTableView.reloadData()
            }
        }
    }
    
    func filterContentForSearchText(_ searchText: String) {
        viewModel.filteerCellViewModels(for: searchText)
        rmCharacterListTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension RMCharacterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let nextVC = sb.instantiateViewController(withIdentifier: "RMCharacterDetailsViewController") as? RMCharacterDetailsViewController
        guard let vc = nextVC else {
            return
        }
        vc.selecetedCharacter = viewModel.getDetailsViewModel(at: indexPath)
        self.navigationController?.show(vc, sender: self)
    }
}

// MARK: - UITableViewDataSource

extension RMCharacterListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return viewModel.rmFilteredCharcatersCellViewModels.count
        }
        return viewModel.rmCharcatersCellViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RMCharacterTableViewCell.identifier, for: indexPath) as? RMCharacterTableViewCell else { fatalError("xib does not exists") }
        let cellVM = viewModel.getCellViewModel(at: indexPath)
        cell.cellViewModel = cellVM
        return cell
    }
}

extension RMCharacterListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
      let searchBar = searchController.searchBar
      filterContentForSearchText(searchBar.text!)
  }
}
