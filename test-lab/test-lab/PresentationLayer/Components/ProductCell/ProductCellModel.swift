//
//  ProductCellModel.swift
//  test-lab
//
//  Created by Дарья Сотникова on 29.08.2023.
//

import UIKit

struct ProductCellModel: Hashable, Equatable {
    let title: String?
    let price: String?
    let location: String?
    let image: URL?
    let date: String?
}
