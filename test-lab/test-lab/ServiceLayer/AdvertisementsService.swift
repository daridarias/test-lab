//
//  AdvertisementsService.swift
//  test-lab
//
//  Created by Дарья Сотникова on 29.08.2023.
//

import Foundation

final class AdvertisementsService {
    enum Errors: Error {
        case brokenURL
    }
    let productsURL = "https://www.avito.st/s/interns-ios/main-page.json"
    let urlStringItem = "https://www.avito.st/s/interns-ios/details/"
    
    func fetchProductList() async throws -> ProductListData {
        guard let url = URL(string: productsURL) else { throw Errors.brokenURL }
        
        let (data, _) = try await URLSession(configuration: .default).data(for: URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(ProductListData.self, from: data)
        return decodedData
    }
    
    func fetchItem(itemId: String) async throws -> ProductPageData {
        let urlString = "\(urlStringItem)\(itemId).json"
        guard let url = URL(string: urlString) else { throw Errors.brokenURL }
        
        let (data, _) = try await URLSession(configuration: .default).data(for: URLRequest(url: url))
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(ProductPageData.self, from: data)
        return decodedData
    }
}
