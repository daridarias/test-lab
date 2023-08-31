//
//  ProductsListViewController.swift
//  test-lab
//
//  Created by Дарья Сотникова on 28.08.2023.
//

import UIKit

protocol ProductListViewInput: AnyObject {
    var output: ProductListViewOutput? { get set }
    
    func updateView(viewModel: ProductsListViewModel)
}

protocol ProductListViewOutput: AnyObject {
    func productListViewDidLoad(_ input: ProductListViewInput)
    func productListViewDidTapRetryLoad(_ input: ProductListViewInput)
    func productListView(_ input: ProductListViewInput, didTapOnCellWithId: String)
}

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
    
    var output: ProductListViewOutput?
    
    // MARK: - Lifecycle
    init() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        output?.productListViewDidLoad(self)
    }

    @MainActor func updateList(viewModel: ProductsListViewModel) {
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
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        switch itemIdentifier {
        case .item(let id, _):
            output?.productListView(self, didTapOnCellWithId: id)
        case .loading:
            return
        }
    }
}

extension ProductsListViewController: ProductListViewInput {
    func updateView(viewModel: ProductsListViewModel) {
        switch viewModel {
        case .loading:
            activityIndicator.isHidden = false
            view.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            activityIndicator.startAnimating()
        case .error:
            let alert = UIAlertController(title: "Error", message: "Something wrong", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
                guard let self else { return }
                self.output?.productListViewDidTapRetryLoad(self)
            }))
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            
        case .data:
            break
        }
        
        updateList(viewModel: viewModel)
    }
}
