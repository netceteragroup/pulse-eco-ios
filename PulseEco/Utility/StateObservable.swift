import Foundation
import Combine

/// The generic protocol of the state observable. This abstraction is to be exposed to the upper layers, while `MutableStateObservable` is to be used from
/// the clients. This way only clients can modify the state, while other layers can still (and only) access the value/observable.

protocol StateObservable<State> {
    associatedtype State
    
    /// The value of the state observable.
    var value: State { get }
    
    /// Used to subscribe to value changes.
    /// - Returns: The Publisher with the `State` as the value.
    func observe() -> AnyPublisher<State, Never>
}

/// The default implementation of `StateObservable`. This is to be used from the clients, while the abstraction `StateObservable`is to be exposed to the
/// other upper layers. This way only clients can modify the state, while other layers can still (and only) access the value/observable.
public final class MutableStateObservable<State>: StateObservable {
    private let subscriptionCounter = SubscriptionCounter()
    private var _currentValue: State
    private let queue = DispatchQueue(label: "currentValueQueue")
    
    private var currentValue: State {
        get { queue.sync { _currentValue } }
        set { queue.sync { _currentValue = newValue } }
    }
    
    private var onSubscribe: (() -> Void)?
    private var onCancel: (() -> Void)?
    
    private lazy var currentValueSubject: CurrentValueSubject<State, Never> = {
        return CurrentValueSubject<State, Never>(currentValue)
    }()
    
    var value: State {
        return currentValue
    }
    
    init(initialValue: State) {
        self._currentValue = initialValue
    }
    
    func observe() -> AnyPublisher<State, Never> {
        currentValueSubject
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.subscriptionCounter.increase(onFirstSubscriber: { [weak self] in self?.onSubscribe?() })
                },
                receiveCompletion: { [weak self] _ in
                    self?.subscriptionCounter.decrease(onNoSubscribers: { [weak self] in self?.onCancel?() })
                },
                receiveCancel: { [weak self] in
                    self?.subscriptionCounter.decrease(onNoSubscribers: { [weak self] in self?.onCancel?() })
                }
            )
            .eraseToAnyPublisher()
    }
    
    func activeSubscriptions() -> Int {
        subscriptionCounter.activeSubscriptionsCount()
    }
    
    func setSubscribeAction(_ action: @escaping () -> Void) {
        onSubscribe = action
    }
    
    func setCancelAction(_ action: @escaping () -> Void) {
        onCancel = action
    }
    
    func setNewValue(_ newValue: State) {
        currentValue = newValue
        currentValueSubject.send(currentValue)
    }
}

private class SubscriptionCounter {
    private var subscriptionCount = 0
    
    func increase(onFirstSubscriber: () -> Void) {
        if subscriptionCount == 0 {
            onFirstSubscriber()
        }
        
        subscriptionCount += 1
        
    }
    
    func decrease(onNoSubscribers: () -> Void) {
        guard subscriptionCount > 0 else {
            return
        }
        
        subscriptionCount -= 1
        
        if subscriptionCount == 0 {
            onNoSubscribers()
        }
    }
    
    func activeSubscriptionsCount() -> Int {
        subscriptionCount
    }
}
