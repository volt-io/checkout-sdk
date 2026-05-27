//
// VoltToastViewModifier.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 26/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltToastViewModifier: ViewModifier {
    @Binding package var isPresented: Bool
    package let title: String
    package let message: String?

    private func close() {
        withAnimation {
            $isPresented.wrappedValue = false
        }
    }

    package func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: .voltPadding3) {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(title)
                            .font(.voltSubheadline)
                            .fontWeight(.medium)
                            .lineSpacing(.voltLineSpacing)
                            .alignmentGuide(.firstTextBaseline) { context in
                                context[.firstTextBaseline] + .voltPadding1 + .voltPadding2
                            }
                        Spacer()
                        Button(action: close) {
                            Label {
                                Text("Close")
                            } icon: {
                                Image.voltCloseIcon
                            }
                            .labelStyle(.iconOnly)
                        }
                    }
                    if let message {
                        Text(message)
                            .font(.voltCaption)
                            .lineSpacing(.voltLineSpacing)
                    }
                }
                .padding([.top, .trailing], .voltPadding5)
                .padding([.leading, .bottom], .voltPadding6)
                .background(in: RoundedRectangle(cornerRadius: .voltRadius2))
                .backgroundStyle(Color.voltMutedNavyColor)
            }
            .tint(.white)
            .foregroundStyle(.white)
            .padding(.voltPadding5)
            .opacity($isPresented.wrappedValue ? 1.0 : 0.0)
        }
    }
}

extension View {
    package func voltPopoverToast(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil
    ) -> some View {
        modifier(VoltToastViewModifier(
            isPresented: isPresented,
            title: title,
            message: message
        ))
    }
}
