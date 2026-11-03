import Observation

/// Unidirectional (MVI-style) contract every feature view model follows.
///
/// Views render `state` and report user actions through `send(_:)`. All mutations
/// happen inside the view model, which keeps screens dumb and logic unit-testable.
@MainActor
protocol ViewModel: AnyObject, Observable {
    associatedtype State: Equatable
    associatedtype Intent

    var state: State { get }
    func send(_ intent: Intent)
}
