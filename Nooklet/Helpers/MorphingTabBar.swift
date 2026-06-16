//
//  MorphingTabBar.swift
//  Nooklet
//
//  Created by Tu on 15/6/26.
//

import SwiftUI

protocol MorphingTabBarProtocol: CaseIterable, Hashable {
    var symbolImage: String { get }
}

struct MorphingTabBar<Tab: MorphingTabBarProtocol, ExpandedContent: View>: View
{
    @Binding var activeTab: Tab
    @Binding var isExpanded: Bool

    @ViewBuilder var expandedContent: ExpandedContent
    var body: some View {
        ZStack {
            let symbols = Array(Tab.allCases).compactMap({ $0.symbolImage })
            let selectedIndex = Binding {
                return symbols.firstIndex(of: activeTab.symbolImage) ?? 0
            } set: { index in
                activeTab = Array(Tab.allCases)[index]
            }

            CustomTabBar(symbols: symbols, index: selectedIndex) {
                image in
                let font = UIFont.systemFont(ofSize: 19)
                let configuration = UIImage.SymbolConfiguration(font: font)

                return UIImage(
                    systemName: image,
                    withConfiguration: configuration
                )
            }
            .frame(height: 48)

        }
    }
}

private struct CustomTabBar: UIViewRepresentable {
    var tint: Color = .gray.opacity(0.15)
    var symbols: [String]
    @Binding var index: Int
    var image: (String) -> UIImage?

    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        if uiView.selectedSegmentIndex != index {
            uiView.selectedSegmentIndex = index
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject {
        var parent: CustomTabBar
        init(parent: CustomTabBar) {
            self.parent = parent
        }

        @objc
        func didSelect(_ control: UISegmentedControl) {
            parent.index = control.selectedSegmentIndex
        }
    }

    func makeUIView(context: Context) -> UISegmentedControl {
        let control = UISegmentedControl(items: symbols)
        control.selectedSegmentIndex = index
        control.selectedSegmentTintColor = UIColor(tint)
        for (index, symbol) in symbols.enumerated() {
            control.setImage(image(symbol), forSegmentAt: index)
        }

        control.addTarget(
            context.coordinator,
            action: #selector(context.coordinator.didSelect(_:)),
            for: .valueChanged
        )
        DispatchQueue.main.async {
            for view in control.subviews.dropLast() {
                if view is UIImageView {
                    view.alpha = 0
                }
            }
        }

        return control

    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UISegmentedControl,
        context: Context
    ) -> CGSize? {
        return proposal.replacingUnspecifiedDimensions()
    }

}
