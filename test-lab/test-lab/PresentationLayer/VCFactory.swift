//
//  VCFactory.swift
//  test-lab
//
//  Created by Дарья Сотникова on 31.08.2023.
//

import UIKit

protocol VCFactory {
    func createProductList() -> (UIViewController, ProductListModuleInput)
    func createProductPage() -> (UIViewController, ProductPageModuleInput)
}

final class DefaultVCFactory: VCFactory {
    let advertisementsService: AdvertisementsService
    let imageService: ImageService
    
    init(advertisementsService: AdvertisementsService, imageService: ImageService) {
        self.advertisementsService = advertisementsService
        self.imageService = imageService
    }
    
    func createProductList() -> (UIViewController, ProductListModuleInput) {
        let viewController = ProductsListViewController()
        let presenter = ProductListPresenter(advertisementsService: advertisementsService, imageService: imageService)
        
        presenter.viewInput = viewController
        viewController.output = presenter
        
        return (viewController, presenter)
    }
    
    func createProductPage() -> (UIViewController, ProductPageModuleInput) {
        let viewController = ProductPageViewController()
        let presenter = ProductPagePresenter(advertisementsService: advertisementsService, imageService: imageService)
        
        presenter.viewInput = viewController
        viewController.output = presenter
        
        return (viewController, presenter)
    }
}
