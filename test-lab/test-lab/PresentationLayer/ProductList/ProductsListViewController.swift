//
//  ProductsListViewController.swift
//  test-lab
//
//  Created by Дарья Сотникова on 28.08.2023.
//

import UIKit

final class ProductsListViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - Private
    
    private enum ProductsListSection: Hashable {
        case product
    }
    
    private enum ProductListCell: Hashable {
        case item(id: String, viewModel: ProductCellModel)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<ProductsListSection, ProductListCell>?
 
    // MARK: - Properties
    
    lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.33))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        
        return collectionView
    }()
    
    let advertisementsService: AdvertisementsService
    let imageService: ImageService
    var viewModel: ProductsListViewModel
    
    // MARK: - Lifecycle
    init(advertisementsService: AdvertisementsService, imageService: ImageService) {
        self.advertisementsService = advertisementsService
        self.imageService = imageService
        self.viewModel = ProductsListViewModel(advertisements: [], images: [:])
        
        super.init(nibName: nil, bundle: nil)
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath)
            switch itemIdentifier {
            case let .item(_, viewModel):
                guard let castedCell = cell as? ProductCell else { break }
                castedCell.configure(model: viewModel)
                
            }
            return cell
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)
        
        collectionView.dataSource = dataSource
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "productCell")
        
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        Task {
            do {
                let productData = try await advertisementsService.fetchProductList()
                viewModel.advertisements = productData.advertisements
                updateList()
                for item in productData.advertisements {
                    guard let url = item.image_url else { continue }
                    Task {
                        do {
                            let data = try await imageService.loadImage(by: url)
                            let image = UIImage(data: data)
                            viewModel.images[url] = image
                            updateList()
                        } catch {
                            print(error)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    @MainActor func updateList() {
        var snapshot = NSDiffableDataSourceSnapshot<ProductsListSection, ProductListCell>()
        snapshot.appendSections([ProductsListSection.product])
        
        for element in viewModel.advertisements {
            guard let id = element.id else { continue }
            snapshot.appendItems([.item(id: id, viewModel: .init(
                title: element.title,
                price: element.price,
                location: element.location,
                image: viewModel.images[element.image_url],
                date: element.created_date
            ))], toSection: .product)
        }
        
        dataSource?.apply(snapshot)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        switch itemIdentifier {
        case .item(let id, _):
            let productPageVC = ProductPageViewController(advertisementsService: advertisementsService, imageService: imageService)
            productPageVC.configure(id: id)
            present(productPageVC, animated: true)
        }
    }
}

