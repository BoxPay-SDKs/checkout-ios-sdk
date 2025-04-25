////
////  TimerManager.swift
////  boxpay-ios-checkout
////
////  Created by ankush on 23/01/25.
////
//
//import Foundation
//
//class TimerManager: ObservableObject {
//    static let shared = TimerManager()
//    @Published var remainingTime: TimeInterval = 0 // Remaining time in seconds
//    @Published var hasExpired: Bool = false
//    private var timer: Timer?
//    private var isTimerRunning = false
//
//    private init() {}
//
//    /// Starts the timer with the provided duration in seconds.
//    func startTimer(duration: TimeInterval) {
//        stopTimer() // Ensure any existing timer is stopped
//        remainingTime = duration
//        isTimerRunning = true
//
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            self.remainingTime -= 1
//            if self.remainingTime <= 0 {
//                self.stopTimer()
//                self.hasExpired = true
//            }
//        }
//    }
//
//    /// Stops the timer and resets the state.
//    func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//        isTimerRunning = false
//        remainingTime = 0
//    }
//}
