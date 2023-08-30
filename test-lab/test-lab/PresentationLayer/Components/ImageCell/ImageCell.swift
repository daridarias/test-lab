//
//  ImageCell.swift
//  test-lab
//
//  Created by Дарья Сотникова on 29.08.2023.
//

import UIKit

final class ImageCell: UITableViewCell {
    
    lazy var vImage: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 25
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        
        return image
    }()
    
    var imageHeightContraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(vImage)
        
        NSLayoutConstraint.activate([
            vImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            vImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: vImage.trailingAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: vImage.bottomAnchor, constant: 16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: ImageCellModel) {
        vImage.image = model.image
//        imageHeightContraint?.isActive = false
        imageHeightContraint = vImage.heightAnchor.constraint(equalTo: vImage.widthAnchor, multiplier: model.image.size.height / model.image.size.width)
        imageHeightContraint?.isActive = true
    }
}
