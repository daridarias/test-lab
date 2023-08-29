//
//  ProductPageViewController.swift
//  test-lab
//
//  Created by Дарья Сотникова on 29.08.2023.
//

import UIKit

final class ProductPageViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    let advertisementsService: AdvertisementsService
    
    init(advertisementsService: AdvertisementsService) {
        self.advertisementsService = advertisementsService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
    }
    
    func configure(id: String) {
        Task {
            do {
                let productData = try await advertisementsService.fetchItem(itemId: id)
                print(productData)
//                updateList(productData: productData)
            } catch {
                print(error)
            }
        }
        
    }
}
