//
//  ProductPageViewModel.swift
//  test-lab
//
//  Created by Дарья Сотникова on 30.08.2023.
//

import UIKit

enum ProductPageViewModel {
    case loading
    case error(Error)
    case data(advertisements: ProductPageData?, image: UIImage?)
}
