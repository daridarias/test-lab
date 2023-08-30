//
//  ProductPageViewController.swift
//  test-lab
//
//  Created by Дарья Сотникова on 29.08.2023.
//

import UIKit

final class ProductPageViewController: UIViewController, UITableViewDelegate {
    
//MARK: - Private
    
    private enum ProductPageSection: Hashable, Equatable {
        case main
    }
    
    private enum ProductPageCell: Hashable, Equatable {
        case image(model: ImageCellModel)
        case text(model: TextCellModel)
    }
    
    private var dataSource: UITableViewDiffableDataSource<ProductPageSection, ProductPageCell>?

// MARK: - Properties
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    let advertisementsService: AdvertisementsService
    let imageService: ImageService
    
    // MARK: - Lifecycle
    
    init(advertisementsService: AdvertisementsService, imageService: ImageService) {
        self.advertisementsService = advertisementsService
        self.imageService = imageService
        super.init(nibName: nil, bundle: nil)
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "productPageCell", for: indexPath)
            
            switch itemIdentifier {
            case let .image(model):
                guard let castedCell = cell as? ImageCell else { break }
                castedCell.configure(model: model)
                if let imageURLString = model.imageURL {
                    
                }
            case let .text(model):
                guard let castedCell = cell as? TextCell else { break }
                castedCell.configure(model: model)
            }
            return cell
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: "productPageCell")
        tableView.register(TextCell.self, forCellReuseIdentifier: "productPageCell")
        tableView.separatorColor = .clear
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
 
    
    func configure(id: String) {
        Task {
            do {
                let productData = try await advertisementsService.fetchItem(itemId: id)
                updatePage(productData: productData)
            } catch {
                print(error)
            }
        }
    }
    
    func updatePage(productData: ProductPageData) {
        var snapshot = NSDiffableDataSourceSnapshot<ProductPageSection, ProductPageCell>()
        snapshot.appendSections([ProductPageSection.main])
        snapshot.appendItems([
            .image(model: ImageCellModel(imageURL: productData.image_url)),
            .text(model: TextCellModel(text: productData.title, font: .systemFont(ofSize: 22), textColor: .black)),
            .text(model: TextCellModel(text: productData.price, font: .boldSystemFont(ofSize: 22), textColor: .black)),
            .text(model: TextCellModel(text: productData.location, font: .systemFont(ofSize: 20), textColor: .gray)),
            .text(model: TextCellModel(text: productData.address, font: .systemFont(ofSize: 20), textColor: .gray)),
            .text(model: TextCellModel(text: productData.created_date, font: .systemFont(ofSize: 16), textColor: .gray)),
            .text(model: TextCellModel(text: productData.description, font: .systemFont(ofSize: 22), textColor: .black)),
            .text(model: TextCellModel(text: productData.email, font: .systemFont(ofSize: 22), textColor: .black)),
            .text(model: TextCellModel(text: productData.phone_number, font: .boldSystemFont(ofSize: 22), textColor: .black))
        ])
        dataSource?.apply(snapshot)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
