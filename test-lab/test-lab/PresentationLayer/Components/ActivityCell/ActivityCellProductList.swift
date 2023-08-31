//
//  ActivityCellProductList.swift
//  test-lab
//
//  Created by Дарья Сотникова on 31.08.2023.
//

import UIKit

final class ActivityCellProductList: UICollectionViewCell {
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        
        return indicator
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.activityIndicator = activityIndicator
        
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
