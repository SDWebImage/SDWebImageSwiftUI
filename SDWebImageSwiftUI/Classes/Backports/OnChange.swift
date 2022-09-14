import SwiftUI
import Combine

@available(iOS, deprecated: 14.0)
@available(macOS, deprecated: 11.0)
@available(tvOS, deprecated: 14.0)
@available(watchOS, deprecated: 7.0)
public extension Backport where Wrapped: View {

    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// `onChange` is called on the main thread. Avoid performing long-running
    /// tasks on the main thread. If you need to perform a long-running task in
    /// response to `value` changing, you should dispatch to a background queue.
    ///
    /// The new value is passed into the closure.
    ///
    /// - Parameters:
    ///   - value: The value to observe for changes
    ///   - action: A closure to run when the value changes.
    ///   - newValue: The new value that changed
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    @ViewBuilder
    func onChange<Value: Equatable>(of value: Value, perform action: @escaping (Value) -> Void) -> some View {
        content.modifier(ChangeModifier(value: value, action: action))
    }

}

private struct ChangeModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let action: (Value) -> Void

    @State var oldValue: Value?

    init(value: Value, action: @escaping (Value) -> Void) {
        self.value = value
        self.action = action
        _oldValue = .init(initialValue: value)
    }

    func body(content: Content) -> some View {
        content
            .onReceive(Just(value)) { newValue in
                guard newValue != oldValue else { return }
                action(newValue)
                oldValue = newValue
            }
    }
}
