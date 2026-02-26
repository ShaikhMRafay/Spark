import UIKit
import SkeletonView

@MainActor
class RosterViewController: UIViewController {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var roosterbtn: UIButton!
    @IBOutlet weak var setting: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let viewModel = RosterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
        setupTableView()
        bindViewModel()
        
        viewModel.loadCacheData()
        Task { await viewModel.fetchRosters() }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchbar.layer.cornerRadius = searchbar.frame.height / 4
        roosterbtn.layer.cornerRadius = roosterbtn.frame.height / 4
        setting.layer.cornerRadius = setting.frame.height / 4
        
        searchbar.clipsToBounds = true
        roosterbtn.clipsToBounds = true
        setting.clipsToBounds = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isSkeletonable = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(
            UINib(nibName: "RosterTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RosterTableViewCell"
        )
        
        // Pull to Refresh
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = .systemGray
        refreshControl.attributedTitle = NSAttributedString(
            string: "Refreshing Rosters...",
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]
        )
    }
    
    @objc private func handleRefresh() {
        Task {
            await viewModel.fetchRosters(forceRefresh: true)
        }
    }
    
    private func bindViewModel() {
        
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            guard let self = self else { return }
            
            if isLoading {
                if !self.refreshControl.isRefreshing {
                    let gradient = SkeletonGradient(baseColor: .systemGray5)
                    self.tableView.showAnimatedGradientSkeleton(usingGradient: gradient)
                }
            } else {
                self.tableView.hideSkeleton()
                self.refreshControl.endRefreshing()
            }
        }
        
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            self?.showToast(message: errorMessage, backgroundColor: .systemRed)
        }
    }
    
}

extension RosterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.filteredRosters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RosterTableViewCell", for: indexPath) as? RosterTableViewCell else {
            return UITableViewCell()
        }
        let roster = viewModel.filteredRosters[indexPath.section]
        cell.configure(with: roster)
        return cell
    }
}

extension RosterViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
}

extension RosterViewController: SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView,
                                cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "RosterTableViewCell"
    }
}

extension RosterViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterRosters(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.filterRosters(searchText: "")
        searchBar.resignFirstResponder()
    }
}
