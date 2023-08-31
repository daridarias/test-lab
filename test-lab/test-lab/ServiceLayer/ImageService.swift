//
//  ImageService.swift
//  test-lab
//
//  Created by Дарья Сотникова on 30.08.2023.
//

import Foundation

final class ImageService {
    enum Errors: Error {
        case nilImageData
    }
    
    let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func loadImage(by url: URL) async throws -> Data {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        let (data, _) = try await urlSession.data(for: request)
        return data
    }
}
