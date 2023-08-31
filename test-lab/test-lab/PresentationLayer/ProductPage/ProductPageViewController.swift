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
        case loading
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
    var viewModel: ProductPageViewModel
    
    // MARK: - Lifecycle
    
    init(advertisementsService: AdvertisementsService, imageService: ImageService) {
        self.advertisementsService = advertisementsService
        self.imageService = imageService
        self.viewModel = .loading
        
        super.init(nibName: nil, bundle: nil)
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case let .image(model):
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
                cell.selectionStyle = .none
                guard let castedCell = cell as? ImageCell else { return cell }
                castedCell.configure(model: model)
                return cell
            case let .text(model):
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
                cell.selectionStyle = .none
                guard let castedCell = cell as? TextCell else { return cell }
                castedCell.configure(model: model)
                return cell
            case .loading:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
                cell.selectionStyle = .none
                return cell
            }
            
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: "ImageCell")
        tableView.register(TextCell.self, forCellReuseIdentifier: "TextCell")
        tableView.register(ActivityCellProductPage.self, forCellReuseIdentifier: "ActivityCell")
        
        tableView.separatorColor = .clear
        updatePage()
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
 
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Something wrong", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] action in
            self?.viewModel = .loading
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configure(id: String) {
        Task {
            do {
                let productData = try await advertisementsService.fetchItem(itemId: id)
                viewModel = .data(advertisements: productData, image: nil)
                updatePage()
                guard let url = productData.image_url else { return }
                let data = try await imageService.loadImage(by: url)
                let image = UIImage(data: data)
                viewModel = .data(advertisements: productData, image: image)
                updatePage(animated: false)
            } catch {
                viewModel = .error(error)
                updatePage()
                
                showErrorAlert()
                
            }
        }
    }
    

    @MainActor func updatePage(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<ProductPageSection, ProductPageCell>()
        snapshot.appendSections([ProductPageSection.main])
        
        switch viewModel {
        case .loading:
            snapshot.appendItems([.loading])
        case .error:
            snapshot.appendItems([])
        case .data(let advertisements, let image):
            guard let productData = advertisements else { return }
            
            if let placeholderImage = UIImage(systemName: "photo.on.rectangle.angled") {
                snapshot.appendItems([.image(model: ImageCellModel(image: image ?? placeholderImage))])
            }
            
            snapshot.appendItems([
                .text(model: TextCellModel(text: productData.title, font: .systemFont(ofSize: 22), textColor: .black)),
                .text(model: TextCellModel(text: productData.price, font: .boldSystemFont(ofSize: 22), textColor: .black)),
                .text(model: TextCellModel(text: productData.location, font: .systemFont(ofSize: 18), textColor: .gray)),
                .text(model: TextCellModel(text: productData.address, font: .systemFont(ofSize: 18), textColor: .gray)),
                .text(model: TextCellModel(text: productData.created_date, font: .systemFont(ofSize: 16), textColor: .gray)),
                .text(model: TextCellModel(text: productData.description, font: .systemFont(ofSize: 20), textColor: .black)),
                .text(model: TextCellModel(text: productData.email, font: .systemFont(ofSize: 18), textColor: .black)),
                .text(model: TextCellModel(text: productData.phone_number, font: .boldSystemFont(ofSize: 20), textColor: .black))
            ])
        }
       
        dataSource?.apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
