//
//  CarouselView.swift
//  CarouselZoomUIKit
//
//  Created by Subhronil Test on 07/11/24.
//

import UIKit

class CarouselView: UIView {
    private let viewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    private let indicatorViewContainerView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 5
        view.alignment = .center
        view.distribution = .fill
        return view
    }()
    private let indicatorViewContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 5
        view.alignment = .center
        view.distribution = .fill
        return view
    }()
    
    var carouselItems: [CarouselViewItem] = []
    var indicatorViews: [UIView] = []
    private var lastLeadingConstraintOfViewContainer: CGFloat?
    private var leadingConstraintOfViewContainer: NSLayoutConstraint?
    private var initialLeadingOffset: CGFloat? = 0
    private var maxWidthOfContainer: CGFloat = 0
    private var focusedIndex: Int = 1
    var isScalingDown: Bool = false
    var lastScrollDirection: ScrollDirection?
    
    // Item UI sizes
    private var itemSize = CGSize(width: 150, height: 150)
    private let interItemSpacing: CGFloat = 10
    private let itemCornerRadius: CGFloat = 16
    private let sectionInsets: CGFloat = 10
    private let scaleFactorMax: CGFloat = 1.5
    private let scaleFactorMin: CGFloat = 1.0
    let screenWidth = UIScreen.main.bounds.width
    
    var haptic: UIImpactFeedbackGenerator?
    
    // Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        self.haptic = UIImpactFeedbackGenerator(style: .soft, view: self)
        createViews()
        addDragGesture()
    }
    
    // Create UI
    private func createViews() {
        addCarouselItems()
        self.addSubview(viewContainer)
        indicatorViewContainerView.addArrangedSubview(indicatorViewContainer)
        self.addSubview(indicatorViewContainerView)
        let leadingConstraintOfViewContainer = viewContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        NSLayoutConstraint.activate([
            viewContainer.topAnchor.constraint(equalTo: self.topAnchor),
            viewContainer.bottomAnchor.constraint(equalTo: indicatorViewContainer.topAnchor),
            leadingConstraintOfViewContainer,
            indicatorViewContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            indicatorViewContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            indicatorViewContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            indicatorViewContainerView.heightAnchor.constraint(equalToConstant: 20),
            indicatorViewContainer.heightAnchor.constraint(equalToConstant: 20)
        ])
        self.leadingConstraintOfViewContainer = leadingConstraintOfViewContainer
    }
    private func addCarouselItems(data: [PicsumAPIListItemModel] = []) {
        carouselItems.removeAll()
        viewContainer.subviews.forEach { $0.removeFromSuperview() }
        let totalSectionSpacing = 2.0 * sectionInsets
        let totalItemWidth = CGFloat(data.count) * itemSize.width
        let totalInteritemSpacing = CGFloat(data.count - 1) * interItemSpacing
        maxWidthOfContainer =  totalSectionSpacing + totalItemWidth + totalInteritemSpacing
        for i in 0..<data.count {
            let itemView = createCard(data: data[i])
            viewContainer.addSubview(itemView)
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalToConstant: itemSize.height),
                itemView.widthAnchor.constraint(equalToConstant: itemSize.width),
                itemView.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor)
            ])
            if let lastItem = carouselItems.last {
                NSLayoutConstraint.activate([
                    itemView.leadingAnchor.constraint(equalTo: lastItem.view.trailingAnchor, constant: interItemSpacing)
                ])
            } else {
                NSLayoutConstraint.activate([
                    itemView.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: sectionInsets)
                ])
            }
            if i == (data.count - 1) {
                NSLayoutConstraint.activate([
                    itemView.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -sectionInsets)
                ])
            }
            let carouselElem = CarouselViewItem(view: itemView)
            self.carouselItems.append(carouselElem)
        }
    }
    private func createCard(data: PicsumAPIListItemModel) -> UIImageView {
        let itemView = UIImageView()
        itemView.translatesAutoresizingMaskIntoConstraints = false
        itemView.layer.cornerRadius = itemCornerRadius
        itemView.backgroundColor = getRandomUniqueColor()
        itemView.layer.borderWidth = 1.0
        itemView.layer.borderColor = UIColor.black.cgColor
        itemView.clipsToBounds = true
        itemView.downloaded(from: data.download_url, contentMode: .scaleAspectFill)
        return itemView
    }
    private func getRandomUniqueColor() -> UIColor {
        let colors: [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemTeal, .systemPink, .systemPurple, .systemBlue, .systemCyan, .systemMint]
        return colors[.random(in: 0..<colors.count)]
    }
    private func addIndicatorItems(data: [PicsumAPIListItemModel]) {
        indicatorViews.removeAll()
        indicatorViewContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for _ in data {
            let indicator = createIndicatorView()
            indicatorViewContainer.addArrangedSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.heightAnchor.constraint(equalToConstant: 5),
                indicator.widthAnchor.constraint(equalToConstant: 5)
            ])
            indicatorViews.append(indicator)
        }
    }
    private func createIndicatorView() -> UIView {
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.layer.cornerRadius = 2.5
        indicator.backgroundColor = .lightGray
        return indicator
    }
    private func updateIndicatorViews() {
        for (index, _) in indicatorViews.enumerated() {
            if index == focusedIndex {
                indicatorViews[index].backgroundColor = .black
            } else {
                indicatorViews[index].backgroundColor = .lightGray
            }
        }
    }
    
    // Update data
    func updateData(data: [PicsumAPIListItemModel], carouselHeight: CGFloat = 250) {
        let itemDimensions = carouselHeight / scaleFactorMax - 30.0
        self.itemSize = CGSize(width: itemDimensions, height: itemDimensions)
        addCarouselItems(data: data)
        addIndicatorItems(data: data)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
            self?.snapToFocusedItem()
            self?.updateIndicatorViews()
        }
    }
}

// MARK: Drag/Scroll Gestures
extension CarouselView {
    private func addDragGesture() {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(dragGestureHandler))
        viewContainer.addGestureRecognizer(gesture)
        viewContainer.isUserInteractionEnabled = true
    }
    @objc func dragGestureHandler(_ gesture: UIPanGestureRecognizer?) {
        switch gesture?.state {
        case .began: break
        case .changed:
            let translation = gesture?.translation(in: viewContainer)
            let newOffset = (initialLeadingOffset ?? 0) + (translation?.x ?? 0)
            let scrollDirection =  getScrollDirection(newLeadingOffset: newOffset,
                                                      oldLeadingOffset: leadingConstraintOfViewContainer?.constant ?? 0)
            if scrollDirection == .left && focusedIndex == carouselItems.count - 1 && isScalingDown {
                return
            } else if scrollDirection == .right && focusedIndex == 0 && isScalingDown {
                return
            } else {
                lastLeadingConstraintOfViewContainer = leadingConstraintOfViewContainer?.constant
                leadingConstraintOfViewContainer?.constant = (initialLeadingOffset ?? 0) + (translation?.x ?? 0)
                resizeItemsWhileScrolling()
            }
        case .ended:
            snapToFocusedItem() // Snaps to selected index
        default: break
        }
    }
    private func snapToFocusedItem() {
        let newOffset = CGFloat(focusedIndex) * (itemSize.width + interItemSpacing)
        let emptySpaceOnEitherSide = screenWidth - (itemSize.width + interItemSpacing)
        self.initialLeadingOffset = -newOffset + (emptySpaceOnEitherSide / 2.0)
        UIView.animate(withDuration: 0.4) {
            self.leadingConstraintOfViewContainer?.constant = self.initialLeadingOffset ?? 0
            for index in 0..<self.carouselItems.count {
                if index == self.focusedIndex {
                    self.carouselItems[index].scaleFactor = self.scaleFactorMax
                    self.isScalingDown = true
                    self.carouselItems[index].view.transform = CGAffineTransform(scaleX: self.scaleFactorMax, y: self.scaleFactorMax)
                    self.viewContainer.bringSubviewToFront(self.carouselItems[index].view)
                } else {
                    self.carouselItems[index].scaleFactor = self.scaleFactorMin
                    self.isScalingDown = false
                    self.carouselItems[index].view.transform = .identity
                    self.viewContainer.sendSubviewToBack(self.carouselItems[index].view)
                }
            }
            self.layoutIfNeeded()
        }
    }
    private func resizeItemsWhileScrolling() {
        let maxTraversal = itemSize.width + (4.0 * interItemSpacing)
        let scrollDirection = getScrollDirection(newLeadingOffset: leadingConstraintOfViewContainer?.constant ?? 0,
                                                 oldLeadingOffset: lastLeadingConstraintOfViewContainer ?? 0)
        switch scrollDirection {
        case .left: // Scrolled left
            if focusedIndex == carouselItems.count - 1 && !isScalingDown { return }
            let diff = (leadingConstraintOfViewContainer?.constant ?? 0) - (lastLeadingConstraintOfViewContainer ?? 0)
            scaleUpDownWhileScroll(diff: diff, maxTraversal: maxTraversal, scrollDirection: .left)
            lastScrollDirection = .left
        case .right: // Scrolled right
            if focusedIndex == 0 && isScalingDown { return }
            let diff = (leadingConstraintOfViewContainer?.constant ?? 0) - (lastLeadingConstraintOfViewContainer ?? 0)
            scaleUpDownWhileScroll(diff: diff, maxTraversal: maxTraversal, scrollDirection: .right)
            lastScrollDirection = .right
        }
    }
    private func getScrollDirection(newLeadingOffset: CGFloat?, oldLeadingOffset: CGFloat?) -> ScrollDirection {
        if (oldLeadingOffset ?? 0) > (newLeadingOffset ?? 0) { return .left }
        return .right
    }
    private func scaleUpDownWhileScroll(diff: CGFloat, maxTraversal: CGFloat, scrollDirection: ScrollDirection) {
        if !carouselItems.indices.contains(focusedIndex) { return }
        if let lastScrollDirection, scrollDirection != lastScrollDirection {
            isScalingDown.toggle()
        }
        if isScalingDown { // Scaling down
            if carouselItems[focusedIndex].scaleFactor > scaleFactorMin
                && carouselItems[focusedIndex].scaleFactor <= scaleFactorMax {
                carouselItems[focusedIndex].scaleFactor -= (abs(diff / maxTraversal) * scaleFactorMax)
                carouselItems[focusedIndex].view.transform = CGAffineTransform(scaleX: carouselItems[focusedIndex].scaleFactor,
                                                                               y: carouselItems[focusedIndex].scaleFactor)
            } else {
                carouselItems[focusedIndex].scaleFactor = scaleFactorMin
                switch scrollDirection {
                case .left:
                    let rightIndex = focusedIndex + 1
                    if rightIndex < carouselItems.count {
                        focusedIndex = rightIndex
                        isScalingDown = false
                        updateIndicatorViews()
                    }
                case .right:
                    let leftIndex = focusedIndex - 1
                    if leftIndex >= 0 {
                        focusedIndex = leftIndex
                        isScalingDown = false
                        updateIndicatorViews()
                    }
                }
                haptic?.impactOccurred()
            }
        } else { // Scaling up
            if carouselItems[focusedIndex].scaleFactor < scaleFactorMax {
                carouselItems[focusedIndex].scaleFactor += (abs(diff / maxTraversal) * scaleFactorMax)
                carouselItems[focusedIndex].view.transform = CGAffineTransform(scaleX: carouselItems[focusedIndex].scaleFactor,
                                                                               y: carouselItems[focusedIndex].scaleFactor)
                viewContainer.bringSubviewToFront(carouselItems[focusedIndex].view)
            } else if carouselItems[focusedIndex].scaleFactor >= scaleFactorMax {
                carouselItems[focusedIndex].scaleFactor = scaleFactorMax
                isScalingDown = true
            }
        }
    }
}
