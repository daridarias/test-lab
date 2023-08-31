//
//  ActivityCell.swift
//  test-lab
//
//  Created by Дарья Сотникова on 31.08.2023.
//

import UIKit

final class ActivityCellProductPage: UITableViewCell {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "ActivityCell")
        
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
//            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height),
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
