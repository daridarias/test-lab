//
//  ProductData.swift
//  test-lab
//
//  Created by Дарья Сотникова on 29.08.2023.
//

import Foundation

struct ProductListData: Decodable,
                    Hashable,
                    Equatable {
    let advertisements: [Advertisements]
}

struct Advertisements: Decodable,
                       Identifiable,
                       Hashable,
                       Equatable {
    let id: String?
    let title: String?
    let price: String?
    let location: String?
    let image_url: URL?
    let created_date: String?
}
