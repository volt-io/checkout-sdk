//
// CustomSearchBar.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 31/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI
import UIKit

struct CustomSearchBarModifier: ViewModifier {
    let icons: [CustomSearchBar.SearchBarIcon: UIImage]?
    let tintColors: [CustomSearchBar.ControlType: UIColor]?
    let backgroundImages: [CustomSearchBar.ControlType: UIImage]?
    let backgroundColor: UIColor?
    let selectedBorder: CustomSearchBar.Border?
    let border: CustomSearchBar.Border?
    let corner: CustomSearchBar.Corner?

    func body(content: Content) -> some View {
        content.background(
            CustomSearchBar(
                icons: icons,
                tintColors: tintColors,
                backgroundImages: backgroundImages,
                backgroundColor: backgroundColor,
                selectedBorder: selectedBorder,
                border: border,
                corner: corner
            )
        )
    }
}

struct CustomSearchBar: UIViewControllerRepresentable {
    let icons: [SearchBarIcon: UIImage]?
    let tintColors: [ControlType: UIColor]?
    let backgroundImages: [ControlType: UIImage]?
    let backgroundColor: UIColor?
    let selectedBorder: Border?
    let border: Border?
    let corner: Corner?

    func makeUIViewController(context _: Context) -> some UIViewController {
        let controller = CustomSearchBarViewController()
        controller.icons = icons?.reduce(into: [:]) { $0[$1.key.asUISearchBarIcon] = $1.value }
        controller.searchFieldBackgroundImage = backgroundImages?[.field]
        controller.searchBarBackgroundImage = backgroundImages?[.bar]
        controller.searchFieldBackgroundColor = backgroundColor
        controller.searchBarTint = tintColors?[.bar]
        controller.searchFieldTint = tintColors?[.field]
        controller.searchFieldPromptTint = tintColors?[.prompt]
        controller.searchFieldBorderWidth = border?.width
        controller.searchFieldBorderColor = border?.color
        controller.searchFieldSelectedBorderWidth = selectedBorder?.width
        controller.searchFieldSelectedBorderColor = selectedBorder?.color
        controller.searchFieldCornerRadius = corner?.radius
        controller.searchFieldCornerCurve = corner?.curve
        return controller
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {
        // no-op
    }
}

extension CustomSearchBar {
    enum ControlType {
        case bar, field, prompt
    }

    enum ControlState {
        case normal, focused, disabled
    }

    enum SearchBarIcon {
        case search, clear

        var asUISearchBarIcon: UISearchBar.Icon {
            switch self {
            case .search:
                return .search
            case .clear:
                return .clear
            }
        }
    }

    struct Border {
        let color: UIColor
        let width: CGFloat
    }

    struct Corner {
        let radius: CGFloat
        let curve: CALayerCornerCurve
    }
}

class CustomSearchBarViewController: UIViewController {
    var icons: [UISearchBar.Icon: UIImage]?
    var searchBarBackgroundImage: UIImage?
    var searchFieldBackgroundImage: UIImage?
    var searchFieldBackgroundColor: UIColor?
    var searchBarTint: UIColor?
    var searchFieldTint: UIColor?
    var searchFieldPromptTint: UIColor?
    var searchFieldBorderWidth: CGFloat?
    var searchFieldBorderColor: UIColor?
    var searchFieldSelectedBorderWidth: CGFloat?
    var searchFieldSelectedBorderColor: UIColor?
    var searchFieldCornerRadius: CGFloat?
    var searchFieldCornerCurve: CALayerCornerCurve?

    init() {
        super.init(nibName: nil, bundle: .module)
    }

    required init?(coder _: NSCoder) {
        nil
    }

    // swiftlint:disable cyclomatic_complexity
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        guard let navigationController = parent?.navigationController,
              let searchBar = navigationController.navigationBar.lastSubview(ofType: UISearchBar.self),
              let searchTextField = searchBar.firstSubview(ofType: UISearchTextField.self) else { return }

        if let icons {
            for (iconType, iconImage) in icons {
                searchBar.setImage(iconImage, for: iconType, state: .normal)
            }
        }
        if let searchFieldBackgroundImage {
            searchBar.setSearchFieldBackgroundImage(searchFieldBackgroundImage, for: .normal)
        }
        if let searchBarBackgroundImage {
            searchBar.setBackgroundImage(searchBarBackgroundImage, for: .any, barMetrics: .default)
        }
        if let searchFieldBackgroundColor {
            searchTextField.backgroundColor = searchFieldBackgroundColor
            searchTextField.clipsToBounds = true
        }
        if let searchBarTint {
            searchBar.tintColor = searchBarTint
        }
        if let searchFieldTint {
            searchTextField.tintColor = searchFieldTint
            searchTextField.textColor = searchFieldTint
        }
        if let searchFieldPromptTint, let searchFieldPrompt = searchTextField.placeholder {
            searchTextField.attributedPlaceholder = NSAttributedString(
                string: searchFieldPrompt,
                attributes: [.foregroundColor: searchFieldPromptTint]
            )
        }
        if let searchFieldCornerRadius {
            searchTextField.layer.cornerRadius = searchFieldCornerRadius
        }
        if let searchFieldCornerCurve {
            searchTextField.layer.cornerCurve = searchFieldCornerCurve
        }
    }
    // swiftlint:enable cyclomatic_complexity

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let navigationController = parent?.navigationController,
              let searchBar = navigationController.navigationBar.lastSubview(ofType: UISearchBar.self),
              let searchTextField = searchBar.firstSubview(ofType: UISearchTextField.self) else { return }

        if let searchFieldBorderColor {
            searchTextField.layer.borderColor = searchFieldBorderColor.cgColor
        }
        if let searchFieldBorderWidth {
            searchTextField.layer.borderWidth = searchFieldBorderWidth
        }
        if searchBar.isFirstResponder {
            if let searchFieldSelectedBorderColor {
                searchTextField.layer.borderColor = searchFieldSelectedBorderColor.cgColor
            }
            if let searchFieldSelectedBorderWidth {
                searchTextField.layer.borderWidth = searchFieldSelectedBorderWidth
            }
        }
    }
}
