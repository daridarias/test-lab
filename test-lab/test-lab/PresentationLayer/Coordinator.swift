//
//  Coordinator.swift
//  test-lab
//
//  Created by Дарья Сотникова on 31.08.2023.
//

import Foundation
import UIKit

final class Coordinator {
    var router: UINavigationController
    var vcFactory: VCFactory
    
    init(router: UINavigationController, vcFactory: VCFactory) {
        self.router = router
        self.vcFactory = vcFactory
    }
    
    func start() {
        showProductList()
    }
    
    // MARK: - show
    
    func showProductList() {
        let (viewController, moduleInput) = vcFactory.createProductList()
        moduleInput.output = self
        moduleInput.configure()
        router.setViewControllers([viewController], animated: false)
    }
    
    func showProductPage(identifier: String) {
        let (viewController, moduleInput) = vcFactory.createProductPage()
        moduleInput.output = self
        moduleInput.configure(identifier: identifier)
        router.pushViewController(viewController, animated: true)
    }
}

extension Coordinator: ProductListModuleOutput {
    func productList(_ input: ProductListModuleInput, didTapOpenProductWithId identifier: String) {
        showProductPage(identifier: identifier)
    }
}

extension Coordinator: ProductPageModuleOutput {}
