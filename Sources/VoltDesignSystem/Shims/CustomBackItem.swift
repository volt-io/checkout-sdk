//
// CustomBackItem.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 24/06/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI
import UIKit

struct CustomBackItemModifier: ViewModifier {
    let image: UIImage?
    var imageInsets: UIEdgeInsets = .zero
    var displayMode: UINavigationItem.BackButtonDisplayMode = .default

    func body(content: Content) -> some View {
        content.background(
            CustomBackItem(image: image, imageInsets: imageInsets, displayMode: displayMode)
        )
    }
}

struct CustomBackItem: UIViewControllerRepresentable {
    let image: UIImage?
    let imageInsets: UIEdgeInsets
    let displayMode: UINavigationItem.BackButtonDisplayMode

    func makeUIViewController(context _: Context) -> CustomBackItemViewController {
        let controller = CustomBackItemViewController()
        controller.backIndicatorImage = image
        controller.backIndicatorImageInsets = imageInsets
        controller.backButtonDisplayMode = displayMode
        return controller
    }

    func updateUIViewController(_: CustomBackItemViewController, context _: Context) {
        // no-op
    }
}

class CustomBackItemViewController: UIViewController {
    var backIndicatorImage: UIImage?
    var backIndicatorImageInsets: UIEdgeInsets = .zero
    var backButtonDisplayMode: UINavigationItem.BackButtonDisplayMode = .default

    init() {
        super.init(nibName: nil, bundle: .module)
    }

    required init?(coder _: NSCoder) {
        nil
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        guard let navigationController = parent?.navigationController else { return }

        let insetImage = backIndicatorImage?.withAlignmentRectInsets(backIndicatorImageInsets)
        let appearance = UINavigationBarAppearance()

        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = .init(style: .light)
        appearance.setBackIndicatorImage(insetImage, transitionMaskImage: insetImage)

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance

        navigationController.navigationBar.items?.forEach { item in
            item.backButtonDisplayMode = backButtonDisplayMode
        }
    }
}
