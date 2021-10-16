//
//  ViewController.swift
//  DiffableDataSource
//
//  Created by Esraa Eid on 15/10/2021.
//

import UIKit
import SafariServices


//. Understanding how does Generics are used to simplify the API design

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //Instance Properties
    
    let apiKey = "4435399e0203452ba983391f629f3ed6"
    
    private var viewModels = [NewsCollectionViewCellViewModel]()
    private var articles = [Article]()
    private lazy var dataSource = makeDataSource()

    
    enum Section {
      case main
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Article>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Article>

    
    private var searchController = UISearchController(searchResultsController: nil)

    
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionHeadersPinToVisibleBounds = false
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundColor = .white
        return collectionView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"

        setupCollectionView()
        getStories()
        configureSearchController()
        applySnapshot(animatingDifferences: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func makeDataSource() -> DataSource {
      // 1
      let dataSource = DataSource(
        collectionView: collectionView,
        cellProvider: { (collectionView, indexPath, article) ->
          UICollectionViewCell? in
          // 2
          let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NewsCollectionViewCell.identifier,
            for: indexPath) as? NewsCollectionViewCell
            cell?.configure(with: .init(title: article.title,
                                        subtitle: article.description ??  "NO Description",
                                        imageURL: URL(string: article.urlToImage ?? "")))
          return cell
      })
      return dataSource
    }
    
    // 1
    func applySnapshot(animatingDifferences: Bool = true) {
      // 2
      var snapshot = Snapshot()
      // 3
      snapshot.appendSections([.main])
      // 4
      snapshot.appendItems(articles)
      // 5
      dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }


    
    func setupCollectionView(){
        collectionView.delegate = self
        
        
           collectionView.register(NewsCollectionViewCell.self,
                                   forCellWithReuseIdentifier: NewsCollectionViewCell.identifier)
        view.addSubview(collectionView)
    }
    
    func getStories(){
        APICaller.shared.getTopStories { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsCollectionViewCellViewModel(title: $0.title,
                                               subtitle: $0.description ?? "NO Description",
                                               imageURL: URL(string: $0.urlToImage ?? ""))
                })
                DispatchQueue.main.async {
                    self?.applySnapshot()

                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
 
    
    
    //MARK:- CollectionView Delegate and DataSource Methods
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let article = dataSource.itemIdentifier(for: indexPath) else {
          return
        }

        
        guard let url = URL(string: article.url ?? "" ) else { return }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
    
}

// MARK: - UISearchResultsUpdating Delegate
extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    articles = filteredArticles(for: searchController.searchBar.text)
    applySnapshot()
  }
  
  func filteredArticles(for queryOrNil: String?) -> [Article] {
    let articles = articles
    guard
      let query = queryOrNil,
      !query.isEmpty
      else {
        return articles
    }
    return articles.filter {
      return $0.title.lowercased().contains(query.lowercased())
    }
  }
  
  func configureSearchController() {
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Articles"
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
}
