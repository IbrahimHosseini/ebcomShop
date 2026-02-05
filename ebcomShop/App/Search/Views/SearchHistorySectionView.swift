//
//  SearchHistorySectionView.swift
//  ebcomShop
//
//  Created by Ibrahim on 2026-02-05.
//

import SwiftUI

/// Section showing recent search terms as tappable chips with a delete-all header.
struct SearchHistorySectionView: View {
    let history: [String]
    let onDelete: () -> Void
    let onSelectTerm: (String) -> Void

    var body: some View {
        if !history.isEmpty {
            HStack {
                Text("جستجو های اخیر")
                    .typography(.subtitle)
                    .foregroundStyle(Color.grayBold)

                Spacer()

                Button(action: onDelete) {
                    Image(.delete)
                        .renderingMode(.template)
                        .foregroundStyle(.gray400)
                }
                .buttonStyle(.plain)
            }
            .padding(16)

            FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(history, id: \.self) { term in
                    HistoryChipView(term: term) { onSelectTerm(term) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Flow Layout (wraps to next row when row is full)

private struct FlowLayout: Layout {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, point) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + verticalSpacing
                totalHeight = y + size.height
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + horizontalSpacing
            totalHeight = max(totalHeight, y + rowHeight)
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
