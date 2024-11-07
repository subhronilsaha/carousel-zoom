//
//  CarouselModel.swift
//  CarouselZoomUIKit
//
//  Created by Subhronil Test on 08/11/24.
//

import UIKit

/// Enum for Scroll direction
enum ScrollDirection {
    case left
    case right
}

/// Carousel Item View
struct CarouselViewItem {
    var view: UIView // Card view
    var scaleFactor: CGFloat = 1.0 // Scale-factor of the card
}

// MARK: API Models
struct PicsumAPIListItemModel: Codable {
    var download_url: String
}
