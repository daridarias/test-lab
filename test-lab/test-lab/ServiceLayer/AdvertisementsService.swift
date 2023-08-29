//
//  AdvertisementsService.swift
//  test-lab
//
//  Created by Дарья Сотникова on 29.08.2023.
//

import Foundation

class AdvertisementsService {
    enum Errors: Error {
        case brokenURL
    }
    let productsURL = "https://www.avito.st/s/interns-ios/main-page.json"
    let urlStringItem = "https://www.avito.st/s/interns-ios/details/"
    
    func fetchProductList() async throws -> ProductData {
        guard let url = URL(string: productsURL) else { throw Errors.brokenURL }
        
        let (data, _) = try await URLSession(configuration: .default).data(for: URLRequest(url: url))
        return try await self.parseJSON(productData: data)
    }
    
    func fetchItem(itemId: String) {
        let urlString = "\(urlStringItem)\(itemId).json"
//        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) async throws {
        
    }
    
    func parseJSON(productData: Data) async throws -> ProductData {
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(ProductData.self, from: productData)
        return decodedData
    }
}
