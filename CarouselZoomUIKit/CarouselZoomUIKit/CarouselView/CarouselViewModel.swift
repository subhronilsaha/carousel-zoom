//
//  CarouselViewModel.swift
//  CarouselZoomUIKit
//
//  Created by Subhronil Test on 08/11/24.
//

import Foundation

class CarouselViewModel {
    // Get images from API for carousel
    func getData(completionHandler: @escaping (Result<[PicsumAPIListItemModel], Error>) -> Void) {
        let limit = Int.random(in: 3...30)
        if let url = URL(string: "https://picsum.photos/v2/list?limit=\(limit)") {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { data, resp, err in
                if let err {
                    completionHandler(.failure(err))
                    return
                }
                if let data {
                    do {
                        let response = try JSONDecoder().decode([PicsumAPIListItemModel].self, from: data)
                        completionHandler(.success(response))
                    } catch {
                        print("Error: \(error)")
                        completionHandler(.failure(error))
                    }
                }
            }.resume()
        }
    }
}
