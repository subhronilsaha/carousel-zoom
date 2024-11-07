//
//  ViewController.swift
//  CarouselZoomUIKit
//
//  Created by Subhronil Test on 07/11/24.
//

import UIKit

class ViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private let carouselView: CarouselView = {
        let view = CarouselView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let labelDesc: UILabel = {
        let label = UILabel()
        label.text = "- This is a dynamically sized carousel view with centered zoom enabled.\n- The images are being fetched from an API\n- If the height of the container updates, the cards will resize to accommodate the change in its parent's size\n- No UICollectionView or UIScrollView has been used"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let refreshAPIButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Refresh API", for: .normal)
        button.configuration = .filled()
        return button
    }()
    var carouselHeightConstraint: NSLayoutConstraint?
    
    let viewModel = CarouselViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Carousel View"
        createViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }

    private func createViews() {
        self.view.addSubview(stackView)
        stackView.addArrangedSubview(labelDesc)
        stackView.addArrangedSubview(carouselView)
        stackView.addArrangedSubview(spacerView)
        stackView.addArrangedSubview(refreshAPIButton)
        let carouselHeightConstraint = carouselView.heightAnchor.constraint(equalToConstant: 250)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            carouselHeightConstraint,
            labelDesc.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            labelDesc.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
            refreshAPIButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
            refreshAPIButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
            refreshAPIButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        self.carouselHeightConstraint = carouselHeightConstraint
        refreshAPIButton.addTarget(self, action: #selector(callAPI), for: .touchUpInside)
    }
    @objc func callAPI() {
        viewModel.getData { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
//                    self?.carouselHeightConstraint?.constant = 250 // MARK: You can change height here and check, every item height is dynamic
                    self?.carouselView.updateData(data: data, carouselHeight: self?.carouselHeightConstraint?.constant ?? 0)
                }
            case .failure(let error):
                dump(error)
            }
        }
    }
}

