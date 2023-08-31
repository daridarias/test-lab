//
//  ProductListPresenter.swift
//  test-lab
//
//  Created by Дарья Сотникова on 31.08.2023.
//

import Foundation
import UIKit

protocol ProductListModuleInput: AnyObject {
    var output: ProductListModuleOutput? { get set }
    
    func configure()
}

protocol ProductListModuleOutput: AnyObject {
    func productList(_ input: ProductListModuleInput, didTapOpenProductWithId identifier: String)
}

final class ProductListPresenter {
    let advertisementsService: AdvertisementsService
    let imageService: ImageService
    var viewModel: ProductsListViewModel
    
    var output: ProductListModuleOutput?
    weak var viewInput: ProductListViewInput?
    
    init(advertisementsService: AdvertisementsService, imageService: ImageService) {
        self.advertisementsService = advertisementsService
        self.imageService = imageService
        self.viewModel = .loading
    }
    
    @MainActor func obtainData() {
        Task {
            do {
                let productData = try await advertisementsService.fetchProductList()
                viewModel = .data(advertisements: productData.advertisements, images: [:])
                viewInput?.updateView(viewModel: viewModel)
                var images: [URL?: UIImage] = [:]
                for item in productData.advertisements {
                    guard let url = item.image_url else { continue }
                    Task {
                        do {
                            let data = try await imageService.loadImage(by: url)
                            let image = UIImage(data: data)
                            images[url] = image
                            viewModel = .data(advertisements: productData.advertisements, images: images)
                            viewInput?.updateView(viewModel: viewModel)
                        } catch {
                            print(error)
                        }
                    }
                }
            } catch {
                viewModel = .error(error)
                viewInput?.updateView(viewModel: viewModel)
            }
        }
    }
}

extension ProductListPresenter: ProductListModuleInput {
    func configure() { }
}

extension ProductListPresenter: ProductListViewOutput {
    func productListView(_ input: ProductListViewInput, didTapOnCellWithId identifier: String) {
        output?.productList(self, didTapOpenProductWithId: identifier)
    }
    
    @MainActor func productListViewDidLoad(_ input: ProductListViewInput) {
        viewModel = .loading
        input.updateView(viewModel: viewModel)
        obtainData()
    }
    
    @MainActor func productListViewDidTapRetryLoad(_ input: ProductListViewInput) {
        viewModel = .loading
        input.updateView(viewModel: viewModel)
        obtainData()
    }
}
