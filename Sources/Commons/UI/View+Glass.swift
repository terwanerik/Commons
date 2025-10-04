//
//  View+Glass.swift
//  MapDraw
//
//  Created by Erik Terwan on 29/09/2025.
//

import SwiftUI

extension View {

	@ViewBuilder
	public func glassy<Fallback: Shape>(fallback: Fallback) -> some View {
		#if os(iOS)
		if #available(iOS 26.0, *) {
			self.glassEffect().background {
				fallback.fill(.black.opacity(0.0001))
			}
		} else {
			self.background {
				fallback.fill(.regularMaterial)
			}
		}
		#elseif os(macOS)
		if #available(macOS 26.0, *) {
			self.glassEffect().background {
				fallback.fill(.black.opacity(0.0001))
			}
		} else {
			self.background {
				fallback.fill(.regularMaterial)
			}
		}
		#else
		self.background {
			fallback.fill(.regularMaterial)
		}
		#endif
	}

	@ViewBuilder
	public func glassButtonStyle(prominent: Bool) -> some View {
		#if os(iOS)
		if #available(iOS 26.0, *) {
			if prominent {
				self.buttonStyle(.glassProminent)
			} else {
				self.buttonStyle(.glass)
			}
		} else {
			if prominent {
				self.buttonStyle(.borderedProminent)
			} else {
				self.buttonStyle(.bordered)
			}
		}
		#else
		if #available(macOS 26.0, *) {
			if prominent {
				self.buttonStyle(.glassProminent)
			} else {
				self.buttonStyle(.glass)
			}
		} else {
			if prominent {
				self.buttonStyle(.borderedProminent)
			} else {
				self.buttonStyle(.bordered)
			}
		}
		#endif
	}
}
