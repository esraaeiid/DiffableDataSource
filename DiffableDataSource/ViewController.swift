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
        configureLayout()
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
        
        
        // 1
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
          // 2
          guard kind == UICollectionView.elementKindSectionHeader else {
            return nil
          }
          // 3
          let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier,
            for: indexPath) as? SectionHeaderReusableView
          // 4
          let section = self.dataSource.snapshot()
            .sectionIdentifiers[indexPath.section]
          view?.titleLabel.text = section.title
          return view
        }
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

// MARK: - Layout Handling
extension ViewController {
  private func configureLayout() {
    collectionView.register(
      SectionHeaderReusableView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier
    )
    
    collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.phone
      let size = NSCollectionLayoutSize(
        widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
        heightDimension: NSCollectionLayoutDimension.absolute(isPhone ? 280 : 250)
      )
      let itemCount = isPhone ? 1 : 3
      let item = NSCollectionLayoutItem(layoutSize: size)
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
      section.interGroupSpacing = 10
        
        
        // Supplementary header view setup
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(20)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
      return section
    })
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { context in
      self.collectionView.collectionViewLayout.invalidateLayout()
    }, completion: nil)
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
