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
    
    
    private var sections = Section.allSections
    private lazy var dataSource = makeDataSource()


    typealias DataSource = UICollectionViewDiffableDataSource<Section, Video>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Video>

    
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
                                        subtitle: "\(article.lessonCount)",
                                        image: article.thumbnail ?? nil))
          return cell
      })
      return dataSource
    }
    
    // 1
    func applySnapshot(animatingDifferences: Bool = true) {
      // 2
      var snapshot = Snapshot()
        // 3
        snapshot.appendSections(sections)
        sections.forEach { section in
          snapshot.appendItems(section.videos, toSection: section)
        }

      // 5
      dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }


    
    func setupCollectionView(){
        collectionView.delegate = self
        
        
           collectionView.register(NewsCollectionViewCell.self,
                                   forCellWithReuseIdentifier: NewsCollectionViewCell.identifier)
        view.addSubview(collectionView)
    }
    
    
 
    
    
    //MARK:- CollectionView Delegate and DataSource Methods
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
   
        
        guard let video = dataSource.itemIdentifier(for: indexPath) else {
          return
        }
        guard let link = video.link else {
          print("Invalid link")
          return
        }

        let vc = SFSafariViewController(url: link)
        present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
    
}

// MARK: - UISearchResultsUpdating Delegate
extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    sections = filteredSections(for: searchController.searchBar.text)
    applySnapshot()
  }
  
    func filteredSections(for queryOrNil: String?) -> [Section] {
      let sections = Section.allSections

      guard
        let query = queryOrNil,
        !query.isEmpty
        else {
          return sections
      }
        
      return sections.filter { section in
        var matches = section.title.lowercased().contains(query.lowercased())
        for video in section.videos {
          if video.title.lowercased().contains(query.lowercased()) {
            matches = true
            break
          }
        }
        return matches
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
