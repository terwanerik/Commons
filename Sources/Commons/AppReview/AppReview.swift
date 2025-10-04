//
//  AppReview.swift
//  MapDraw
//
//  Created by Erik Terwan on 04/10/2025.
//

import StoreKit
import SwiftUI

@MainActor
public final class AppReview: ObservableObject {

	private static let ACTIONS_COMPLETED_KEY = "REVIEW_ACTIONS_COMPLETED"
	private static let ACTIONS_REQUIRED_MULTIPLIER_KEY = "ACTIONS_REQUIRED_MULTIPLIER"
	private static let FIRST_LAUNCH_KEY = "FIRST_LAUNCH"

	@Published
	private var actionsCompleted: Int {
		didSet {
			UserDefaults.standard.set(actionsCompleted, forKey: Self.ACTIONS_COMPLETED_KEY)
		}
	}

	private var actionsRequiredMultiplier: Int {
		didSet {
			UserDefaults.standard.set(actionsRequiredMultiplier, forKey: Self.ACTIONS_REQUIRED_MULTIPLIER_KEY)
		}
	}

	private var isNotFirstLaunch: Bool {
		didSet {
			UserDefaults.standard.set(isNotFirstLaunch, forKey: Self.FIRST_LAUNCH_KEY)
		}
	}

	private var currentVersion: String {
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
	}

	private let actionsRequired: Int
	private let multiplierMaximum: Int

	fileprivate init(actionsRequired: Int, multiplierMaximum: Int = 5) {
		self.actionsRequired = actionsRequired
		self.actionsCompleted = UserDefaults.standard.integer(forKey: Self.ACTIONS_COMPLETED_KEY)
		self.actionsRequiredMultiplier = UserDefaults.standard.integer(forKey: Self.ACTIONS_REQUIRED_MULTIPLIER_KEY)
		self.isNotFirstLaunch = UserDefaults.standard.bool(forKey: Self.FIRST_LAUNCH_KEY)
		self.multiplierMaximum = multiplierMaximum
		self.attachListeners()
	}

	private func attachListeners() {

		#if os(macOS)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(willTerminate),
			name: NSApplication.willTerminateNotification,
			object: nil
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(willMoveToBackground),
			name: NSApplication.willHideNotification,
			object: nil
		)
		#else
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(willTerminate),
			name: UIApplication.willTerminateNotification,
			object: nil
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(willMoveToBackground),
			name: UIApplication.didEnterBackgroundNotification,
			object: nil
		)
		#endif
	}

	public func completedAction(weight: Int = 1) {

		actionsCompleted += weight

		let required = actionsRequired * (actionsRequiredMultiplier + 1)

		guard actionsCompleted >= required, isNotFirstLaunch else {
			return
		}

		guard let askForReview else {
			assertionFailure()
			return
		}

		askForReview()

		actionsRequiredMultiplier = min(actionsRequiredMultiplier + 1, multiplierMaximum)
		actionsCompleted = 0
	}

	private var actionDebounceTimer: Timer? {
		didSet {
			oldValue?.invalidate()
		}
	}

	public func debouncedCompletedAction(weight: Int = 1, interval: TimeInterval = 2) {

		actionDebounceTimer = Timer.scheduledTimer(
			timeInterval: interval,
			target: self,
			selector: #selector(handleDebouncedTimer),
			userInfo: NSNumber(value: weight),
			repeats: false
		)
	}

	@objc private func handleDebouncedTimer(_ timer: Timer) {
		completedAction(weight: {
			guard case let weightNumber as NSNumber = timer.userInfo else {
				assertionFailure()
				return 1
			}
			return weightNumber.intValue
		}())
	}

	private var askForReview: (() -> Void)?

	fileprivate func attach(askForReview: @escaping () -> Void) {
		self.askForReview = askForReview
	}

	fileprivate func onDisappear() {
		isNotFirstLaunch = true
	}

	@objc private func willMoveToBackground() {
		isNotFirstLaunch = true
	}

	@objc private func willTerminate() {
		isNotFirstLaunch = true
	}
}

private struct AppReviewViewModifier: ViewModifier {

	@Environment(\.requestReview)
	private var requestReview

	@StateObject
	private var appReview: AppReview

	public init(actionsRequired: Int) {
		_appReview = .init(wrappedValue: AppReview(actionsRequired: actionsRequired))
	}

	public func body(content: Content) -> some View {
		content
			.onDisappear {
				appReview.onDisappear()
			}
			.environmentObject(appReview)
			.task {
				appReview.attach {
					Task {
						try await Task.sleep(for: .seconds(2))
						requestReview()
					}
				}
			}
	}
}

extension View {

	@ViewBuilder
	public func appReview(actionsRequired: Int) -> some View {
		modifier(AppReviewViewModifier(actionsRequired: actionsRequired))
	}
}
