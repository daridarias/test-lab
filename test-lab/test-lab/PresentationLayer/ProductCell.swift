//
//  ProductCell.swift
//  test-lab
//
//  Created by Дарья Сотникова on 29.08.2023.
//

import UIKit

final class ProductCell: UICollectionViewCell {
    
    lazy var itemContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 25
        return view
    }()
    
    lazy var productImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "paperplane")
        
        return image
    }()
    
    lazy var itemTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 22)
        label.numberOfLines = 2
        return label
    }()
    
    lazy var itemPrice: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var itemLocation: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 1
        
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(itemContainer)
        itemContainer.addSubview(productImage)
        itemContainer.addSubview(itemTitle)
        itemContainer.addSubview(itemPrice)
        itemContainer.addSubview(itemLocation)
        itemContainer.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            itemContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            itemContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            itemContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -4),
            itemContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            productImage.topAnchor.constraint(equalTo: itemContainer.topAnchor, constant: 8),
            productImage.leadingAnchor.constraint(equalTo: itemContainer.leadingAnchor, constant: 8),
            productImage.trailingAnchor.constraint(equalTo: itemContainer.trailingAnchor, constant: -8),
            
            itemTitle.topAnchor.constraint(equalTo: productImage.bottomAnchor, constant: 8),
            itemTitle.leadingAnchor.constraint(equalTo: itemContainer.leadingAnchor, constant: 8),
            itemTitle.trailingAnchor.constraint(equalTo: itemContainer.trailingAnchor, constant: -8),
            
            itemPrice.topAnchor.constraint(equalTo: itemTitle.bottomAnchor, constant: 8),
            itemPrice.leadingAnchor.constraint(equalTo: itemContainer.leadingAnchor, constant: 8),
            itemPrice.trailingAnchor.constraint(equalTo: itemContainer.trailingAnchor, constant: -8),
            
            itemLocation.topAnchor.constraint(equalTo: itemPrice.bottomAnchor, constant: 8),
            itemLocation.leadingAnchor.constraint(equalTo: itemContainer.leadingAnchor, constant: 8),
            itemLocation.trailingAnchor.constraint(equalTo: itemContainer.trailingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: itemLocation.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: itemContainer.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: itemContainer.trailingAnchor, constant: -8)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: ProductCellModel) {
//        productImage.image = model.image
        itemTitle.text = model.title
        itemPrice.text = model.price
        itemLocation.text = model.location
        dateLabel.text = model.date
    }
}
