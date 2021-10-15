//
//  NewsCollectionViewCell.swift
//  DiffableDataSource
//
//  Created by Esraa Eid on 15/10/2021.
//

import UIKit

class NewsCollectionViewCellViewModel {
    let title: String
    let subtitle: String
    let imageURL: URL?
    var imageData: Data? = nil
    
    init(title: String, subtitle: String, imageURL: URL?) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
    }
}

class NewsCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "NewsCollectionViewCell"
    
    override init(frame: CGRect) {
          super.init(frame: frame)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(subtitleTitleLabel)
        contentView.addSubview(newsImageView)
      }

      required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    
    
    private let newsTitleLabel : UILabel = {
      let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let subtitleTitleLabel : UILabel = {
      let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .light)
        return label
    }()
    
    private let newsImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .secondarySystemBackground
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    
    override func layoutSubviews() {
        super.layoutSubviews()
        newsTitleLabel.frame = CGRect(x: 10, y: 0,
                                      width: contentView.frame.size.width - 170,
                                      height: 70)
        
        subtitleTitleLabel.frame = CGRect(x: 10, y: 70,
                                      width: contentView.frame.size.width - 170,
                                      height: contentView.frame.size.height / 2)
        
        newsImageView.frame = CGRect(x: contentView.frame.size.width - 150, y: 5,
                                      width: 140,
                                      height: contentView.frame.size.height - 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
        newsTitleLabel.text = nil
        subtitleTitleLabel.text = nil
    }
    
    func configure(with viewModel: NewsCollectionViewCellViewModel){
        newsTitleLabel.text = viewModel.title
        subtitleTitleLabel.text = viewModel.subtitle
        if let data = viewModel.imageData {
        newsImageView.image = UIImage(data: data)
        }
        else  if let url = viewModel.imageURL{
            //fetch image
            URLSession.shared.dataTask(with: url) { [weak self](data, _, error) in
                guard let data = data, error == nil else{
                    return
                }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}

