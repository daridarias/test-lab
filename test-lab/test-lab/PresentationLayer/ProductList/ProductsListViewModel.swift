//
//  ProductsListViewModel.swift
//  test-lab
//
//  Created by Дарья Сотникова on 30.08.2023.
//

import UIKit

enum ProductsListViewModel {
    case loading
    case error(Error)
    case data(advertisements: [Advertisements], images: [URL?: UIImage])
}
