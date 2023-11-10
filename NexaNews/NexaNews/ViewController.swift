import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NexaNewsTableViewCell.self, forCellReuseIdentifier: NexaNewsTableViewCell.identifier)
        return table
    }()

    private let searchVC = UISearchController(searchResultsController: nil)

    private var viewModels = [NexaNewsTableViewModel]()
    private var articles = [Article]()
    private var currentView = "Top Stories"

    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        // Set a black background color
        toolbar.barTintColor = .black
        return toolbar
    }()

    private let technologyButton: UIBarButtonItem = {
        let buttonSize: CGFloat = 30.0
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        button.setImage(UIImage(systemName: "laptopcomputer", withConfiguration: UIImage.SymbolConfiguration(pointSize: buttonSize, weight: .regular)), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(technologyButtonTapped), for: .touchUpInside)

        let label = UILabel()
        label.text = "Tech"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14.0)

        let stackView = UIStackView(arrangedSubviews: [button, label])
        stackView.axis = .vertical
        stackView.alignment = .center

        let barButton = UIBarButtonItem(customView: stackView)
        return barButton
    }()
    
    private let sportsButton: UIBarButtonItem = {
        let buttonSize: CGFloat = 30.0
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        button.setImage(UIImage(systemName: "sportscourt", withConfiguration: UIImage.SymbolConfiguration(pointSize: buttonSize, weight: .regular)), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(sportsButtonTapped), for: .touchUpInside)

        let label = UILabel()
        label.text = "Sports"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14.0)

        let stackView = UIStackView(arrangedSubviews: [button, label])
        stackView.axis = .vertical
        stackView.alignment = .center

        let barButton = UIBarButtonItem(customView: stackView)
        return barButton
    }()
    
    private let scienceButton: UIBarButtonItem = {
        let buttonSize: CGFloat = 30.0
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        button.setImage(UIImage(systemName: "flask", withConfiguration: UIImage.SymbolConfiguration(pointSize: buttonSize, weight: .regular)), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(scienceButtonTapped), for: .touchUpInside)

        let label = UILabel()
        label.text = "Science"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14.0)

        let stackView = UIStackView(arrangedSubviews: [button, label])
        stackView.axis = .vertical
        stackView.alignment = .center

        let barButton = UIBarButtonItem(customView: stackView)
        return barButton
    }()


    // Add this property to store the original title
        private let originalTitle = "NexaNews"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = originalTitle // Set the initial title
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground

        // Add the "Home" button to the toolbar
        let homeButtonStack = createHomeButtonStack()
        let homeButtonBarItem = UIBarButtonItem(customView: homeButtonStack)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [homeButtonBarItem, flexibleSpace, sportsButton, flexibleSpace, technologyButton, flexibleSpace, scienceButton] // Add the technology button to the toolbar

        // Set the height of the bottom toolbar here
        let toolbarHeight: CGFloat = 100.0 // Adjust this value as needed
        toolbar.frame = CGRect(x: 0, y: view.frame.height - toolbarHeight, width: view.frame.width, height: toolbarHeight)

        // Add the bottom toolbar to the view
        view.addSubview(toolbar)
        
        // Refresh Controller
        configureRefreshControl()

        createSearchBar()
        getTopStories()
        
        currentView = "Top Stories"
    }
    
    private func resetTitle() {
            title = originalTitle
        }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }

    private func getTopStories() {
        APICaller.shared.getTopStories { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NexaNewsTableViewModel(title: $0.title, subtitle: $0.description ?? "No Description", imageURL: URL(string: $0.urlToImage ?? ""))
                })

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    // Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NexaNewsTableViewCell.identifier, for: indexPath) as? NexaNewsTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]

        guard let url = URL(string: article.url ?? "") else {
            return
        }

        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    // Search

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }

        APICaller.shared.search(with: text) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NexaNewsTableViewModel(title: $0.title, subtitle: $0.description ?? "No Description", imageURL: URL(string: $0.urlToImage ?? ""))
                })

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.searchVC.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    // Create a custom stack view for the "Home" button
    private func createHomeButtonStack() -> UIStackView {
        let homeButtonSize: CGFloat = 30.0 // Adjust icon size as needed
        let homeButton = UIButton(type: .system)
        homeButton.frame = CGRect(x: 0, y: 0, width: homeButtonSize, height: homeButtonSize)
        homeButton.setImage(UIImage(systemName: "house", withConfiguration: UIImage.SymbolConfiguration(pointSize: homeButtonSize, weight: .regular)), for: .normal)
        homeButton.tintColor = .white // Set icon color to white
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)

        let homeLabel = UILabel()
        homeLabel.text = "Home"
        homeLabel.textColor = .white
        homeLabel.font = .systemFont(ofSize: 14.0) // Adjust label font size as needed

        let stackView = UIStackView(arrangedSubviews: [homeButton, homeLabel])
        stackView.axis = .vertical
        stackView.alignment = .center

        return stackView
    }
    
    
    // Refresh Controller to reload selected view
    func configureRefreshControl(){
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        // Update content
        refreshView()
        
        // Dismiss refresh control
        DispatchQueue.main.async{
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    
    // Reload source when table view is refreshed
    func refreshView(){
        
        switch currentView {
            
        case "Technology News":
            fetchTechnologyNews()
        case "Sports News":
            fetchSportsNews()
        case "Science News":
            fetchScienceNews()
            
            
        default:
            getTopStories()
        }
    }

    // Add this method to reset the view
    @objc private func homeButtonTapped() {
            resetTitle()
            resetView()
        }

    // Add this method to reset the view
    private func resetView() {
        getTopStories()
    }

    // Add this function to fetch technology news
    @objc private func technologyButtonTapped() {
        fetchTechnologyNews()
        title = "Technology" // Set the title to "Technology" when the button is tapped
        }
    @objc private func sportsButtonTapped() {
        fetchSportsNews()
        title = "Sports" // Set the title to "Sports" when the button is tapped
    }
    
    @objc private func scienceButtonTapped() {
        fetchScienceNews()
        title = "Science" // Set the title to "Science" when the button is tapped
    }

    // Add this function to fetch technology news
    private func fetchTechnologyNews() {
        APICaller.shared.getTechnologyNews { [weak self] result in
            switch result {
            case .success(let articles):
                self?.currentView = "Technology News"
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NexaNewsTableViewModel(title: $0.title, subtitle: $0.description ?? "No Description", imageURL: URL(string: $0.urlToImage ?? ""))
                })

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchSportsNews() {
        APICaller.shared.getSportsNews { [weak self] result in
            switch result {
            case .success(let articles):
                self?.currentView = "Sports News"
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NexaNewsTableViewModel(title: $0.title, subtitle: $0.description ?? "No Description", imageURL: URL(string: $0.urlToImage ?? ""))
                })

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchScienceNews() {
        APICaller.shared.getScienceNews { [weak self] result in
            switch result {
            case .success(let articles):
                self?.currentView = "Science News"
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NexaNewsTableViewModel(title: $0.title, subtitle: $0.description ?? "No Description", imageURL: URL(string: $0.urlToImage ?? ""))
                })

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
