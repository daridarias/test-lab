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
        case loading
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
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        
        return indicator
    }()
    
    let advertisementsService: AdvertisementsService
    let imageService: ImageService
    var viewModel: ProductsListViewModel
    
    // MARK: - Lifecycle
    init(advertisementsService: AdvertisementsService, imageService: ImageService) {
        self.advertisementsService = advertisementsService
        self.imageService = imageService
        self.viewModel = .loading
        
        super.init(nibName: nil, bundle: nil)
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case let .item(_, viewModel):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath)
                guard let castedCell = cell as? ProductCell else { return cell }
                castedCell.configure(model: viewModel)
                return cell
                
            case .loading:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCellProductList", for: indexPath)
                return cell
            }
            
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func obtainData() {
        Task {
            do {
                let productData = try await advertisementsService.fetchProductList()
                viewModel = .data(advertisements: productData.advertisements, images: [:])
                updateList()
                var images: [URL?: UIImage] = [:]
                for item in productData.advertisements {
                    guard let url = item.image_url else { continue }
                    Task {
                        do {
                            let data = try await imageService.loadImage(by: url)
                            let image = UIImage(data: data)
                            images[url] = image
                            viewModel = .data(advertisements: productData.advertisements, images: images)
                            updateList()
                        } catch {
                            print(error)
                        }
                    }
                }
            } catch {
                viewModel = .error(error)
                updateList()
                showErrorAlert()

            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if case .loading = viewModel {
            activityIndicator.isHidden = false
            view.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            activityIndicator.startAnimating()
        }
        
        updateList()
        obtainData()
        collectionView.delegate = self
        
        self.title = "Объявления"
        collectionView.dataSource = dataSource
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "productCell")
        
    
        
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
    }

    @MainActor func updateList() {
        var snapshot = NSDiffableDataSourceSnapshot<ProductsListSection, ProductListCell>()
        snapshot.appendSections([ProductsListSection.product])
        
        switch viewModel {
        case .loading:
            snapshot.appendItems([.loading])
            return
        case .error:
            snapshot.appendItems([])
        case .data(let advertisements, let images):
            view.bringSubviewToFront(collectionView)
            activityIndicator.stopAnimating()
            for element in advertisements {
                guard let id = element.id else { continue }
                snapshot.appendItems([.item(id: id, viewModel: .init(
                    title: element.title,
                    price: element.price,
                    location: element.location,
                    image: images[element.image_url],
                    date: element.created_date
                ))], toSection: .product)
            }
        }
        
        dataSource?.apply(snapshot)
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Something wrong", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.viewModel = .loading
            self?.updateList()
            self?.obtainData()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        switch itemIdentifier {
        case .item(let id, _):
            let productPageVC = ProductPageViewController(advertisementsService: advertisementsService, imageService: imageService)
            productPageVC.configure(id: id)
            navigationController?.pushViewController(productPageVC, animated: true)
        case .loading:
            return
        }
    }
}

