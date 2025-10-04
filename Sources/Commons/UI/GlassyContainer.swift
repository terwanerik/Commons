//
//  GlassyContainer.swift
//  Pacer
//
//  Created by Erik Terwan on 29/09/2025.
//

import SwiftUI

public struct GlassyContainer<Content: View>: View {

	private let spacing: CGFloat?
	private let content: () -> Content

	public init(spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
		self.spacing = spacing
		self.content = content
	}

	public var body: some View {
		#if os(iOS)
		if #available(iOS 26.0, *) {
			GlassEffectContainer(spacing: spacing) {
				content()
			}
		} else {
			content()
		}
		#elseif os(macOS)
		if #available(macOS 26.0, *) {
			GlassEffectContainer(spacing: spacing) {
				content()
			}
		} else {
			content()
		}
		#else
		content()
		#endif
	}
}
