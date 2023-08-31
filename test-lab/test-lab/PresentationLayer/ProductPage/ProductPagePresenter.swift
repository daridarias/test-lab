//
//  ProductPagePresenter.swift
//  test-lab
//
//  Created by Дарья Сотникова on 31.08.2023.
//

import Foundation
import UIKit

protocol ProductPageModuleInput: AnyObject {
    var output: ProductPageModuleOutput? { get set }
    
    func configure(identifier: String)
}

protocol ProductPageModuleOutput: AnyObject {
}

final class ProductPagePresenter {
    var output: ProductPageModuleOutput?
    
    let advertisementsService: AdvertisementsService
    let imageService: ImageService
    var viewModel: ProductPageViewModel
    var viewInput: ProductPageViewInput?
    var id: String?
    
    init(advertisementsService: AdvertisementsService,
         imageService: ImageService) {
        self.advertisementsService = advertisementsService
        self.imageService = imageService
        self.viewModel = .loading
    }
    
    func obtainData(id: String) {
        Task {
            do {
                let productData = try await advertisementsService.fetchItem(itemId: id)
                viewModel = .data(advertisements: productData, image: nil)
                viewInput?.updateView(viewModel: viewModel, animated: true)
                guard let url = productData.image_url else { return }
                let data = try await imageService.loadImage(by: url)
                let image = UIImage(data: data)
                viewModel = .data(advertisements: productData, image: image)
                viewInput?.updateView(viewModel: viewModel, animated: false)
            } catch {
                viewModel = .error(error)
                viewInput?.updateView(viewModel: viewModel, animated: false)
            }
        }
    }
}

extension ProductPagePresenter: ProductPageModuleInput {
    func configure(identifier: String) {
        self.id = identifier
        obtainData(id: identifier)
    }
}

extension ProductPagePresenter: ProductPageViewOutput {
    func productPageViewDidLoad(_ input: ProductPageViewInput) {}
    
    func productPageViewDidTapRetryLoad(_ input: ProductPageViewInput) {
        guard let id else { return }
        obtainData(id: id)
    }
}
