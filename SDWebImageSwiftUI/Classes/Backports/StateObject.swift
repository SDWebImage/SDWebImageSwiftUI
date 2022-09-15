import Combine
import SwiftUI

@available(iOS, deprecated: 14.0)
@available(macOS, deprecated: 11.0)
@available(tvOS, deprecated: 14.0)
@available(watchOS, deprecated: 7.0)
public extension Backport where Wrapped: ObservableObject {

    /// A property wrapper type that instantiates an observable object.
    ///
    /// Create a state object in a ``SwiftUI/View``, ``SwiftUI/App``, or
    /// ``SwiftUI/Scene`` by applying the `@Backport.StateObject` attribute to a property
    /// declaration and providing an initial value that conforms to the
    /// <doc://com.apple.documentation/documentation/Combine/ObservableObject>
    /// protocol:
    ///
    ///     @Backport.StateObject var model = DataModel()
    ///
    /// SwiftUI creates a new instance of the object only once for each instance of
    /// the structure that declares the object. When published properties of the
    /// observable object change, SwiftUI updates the parts of any view that depend
    /// on those properties:
    ///
    ///     Text(model.title) // Updates the view any time `title` changes.
    ///
    /// You can pass the state object into a property that has the
    /// ``SwiftUI/ObservedObject`` attribute. You can alternatively add the object
    /// to the environment of a view hierarchy by applying the
    /// ``SwiftUI/View/environmentObject(_:)`` modifier:
    ///
    ///     ContentView()
    ///         .environmentObject(model)
    ///
    /// If you create an environment object as shown in the code above, you can
    /// read the object inside `ContentView` or any of its descendants
    /// using the ``SwiftUI/EnvironmentObject`` attribute:
    ///
    ///     @EnvironmentObject var model: DataModel
    ///
    /// Get a ``SwiftUI/Binding`` to one of the state object's properties using the
    /// `$` operator. Use a binding when you want to create a two-way connection to
    /// one of the object's properties. For example, you can let a
    /// ``SwiftUI/Toggle`` control a Boolean value called `isEnabled` stored in the
    /// model:
    ///
    ///     Toggle("Enabled", isOn: $model.isEnabled)
    @propertyWrapper struct StateObject: DynamicProperty {
        private final class Wrapper: ObservableObject {
            private var subject = PassthroughSubject<Void, Never>()

            var value: Wrapped? {
                didSet {
                    cancellable = nil
                    cancellable = value?.objectWillChange
                        .sink { [subject] _ in subject.send() }
                }
            }

            private var cancellable: AnyCancellable?

            var objectWillChange: AnyPublisher<Void, Never> {
                subject.eraseToAnyPublisher()
            }
        }

        @State private var state = Wrapper()

        @ObservedObject private var observedObject = Wrapper()

        private var thunk: () -> Wrapped

        /// The underlying value referenced by the state object.
        ///
        /// The wrapped value property provides primary access to the value's data.
        /// However, you don't access `wrappedValue` directly. Instead, use the
        /// property variable created with the `@Backport.StateObject` attribute:
        ///
        ///     @Backport.StateObject var contact = Contact()
        ///
        ///     var body: some View {
        ///         Text(contact.name) // Accesses contact's wrapped value.
        ///     }
        ///
        /// When you change a property of the wrapped value, you can access the new
        /// value immediately. However, SwiftUI updates views displaying the value
        /// asynchronously, so the user interface might not update immediately.
        public var wrappedValue: Wrapped {
            if let object = state.value {
                return object
            } else {
                let object = thunk()
                state.value = object
                return object
            }
        }

        /// A projection of the state object that creates bindings to its
        /// properties.
        ///
        /// Use the projected value to pass a binding value down a view hierarchy.
        /// To get the projected value, prefix the property variable with `$`. For
        /// example, you can get a binding to a model's `isEnabled` Boolean so that
        /// a ``SwiftUI/Toggle`` view can control the value:
        ///
        ///     struct MyView: View {
        ///         @Backport.StateObject var model = DataModel()
        ///
        ///         var body: some View {
        ///             Toggle("Enabled", isOn: $model.isEnabled)
        ///         }
        ///     }
        public var projectedValue: ObservedObject<Wrapped>.Wrapper {
            ObservedObject(wrappedValue: wrappedValue).projectedValue
        }

        /// Creates a new state object with an initial wrapped value.
        ///
        /// You don’t call this initializer directly. Instead, declare a property
        /// with the `@Backport.StateObject` attribute in a ``SwiftUI/View``,
        /// ``SwiftUI/App``, or ``SwiftUI/Scene``, and provide an initial value:
        ///
        ///     struct MyView: View {
        ///         @Backport.StateObject var model = DataModel()
        ///
        ///         // ...
        ///     }
        ///
        /// SwiftUI creates only one instance of the state object for each
        /// container instance that you declare. In the code above, SwiftUI
        /// creates `model` only the first time it initializes a particular instance
        /// of `MyView`. On the other hand, each different instance of `MyView`
        /// receives a distinct copy of the data model.
        ///
        /// - Parameter thunk: An initial value for the state object.
        public init(wrappedValue thunk: @autoclosure @escaping () -> Wrapped) {
            self.thunk = thunk
        }

        public mutating func update() {
            if state.value == nil {
                state.value = thunk()
            }
            if observedObject.value !== state.value {
                observedObject.value = state.value
            }
        }
    }
    
}

