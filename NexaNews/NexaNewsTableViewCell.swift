//
//  NexaNewsTableViewCell.swift
//  NexaNews
//
//  Created by Jesse Hough on 11/3/23.
//

import UIKit

class NexaNewsTableViewModel {
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


class NexaNewsTableViewCell: UITableViewCell {
    static let identifier = "NexaNewsTableViewCell"
    
    private let NexaNewsTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()

    private let NexaNewsSubtitleTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()

    private let NexaNewsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(NexaNewsTitleLabel)
        contentView.addSubview(NexaNewsSubtitleTitleLabel)
        contentView.addSubview(NexaNewsImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NexaNewsTitleLabel.frame = CGRect(x: 10, y: 0, width: contentView.frame.size.width - 170, height: 70)
        
        NexaNewsSubtitleTitleLabel.frame = CGRect(x: 10, y: 70, width: contentView.frame.size.width - 170, height: contentView.frame.size.height/2)
        
        NexaNewsImageView.frame = CGRect(x: contentView.frame.size.width-150, y: 5, width: 140, height: contentView.frame.size.height - 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        NexaNewsTitleLabel.text = nil
        NexaNewsSubtitleTitleLabel.text = nil
        NexaNewsImageView.image = nil
    }
    
    func configure(with viewModel: NexaNewsTableViewModel) {
        NexaNewsTitleLabel.text = viewModel.title
        NexaNewsSubtitleTitleLabel.text = viewModel.subtitle
        
        //Image
        if let data = viewModel.imageData {
            NexaNewsImageView.image = UIImage(data: data)
        }
        else if let url = viewModel.imageURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.NexaNewsImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
    
}
