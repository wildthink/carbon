import SwiftUI

public protocol Action {
    func callAsFunction<A>(_ value: A, in: EnvironmentValues?) -> Bool
}


struct ActionTrampoline<T>: Action, DynamicProperty {
    
//    @Environment(\.self) var _viewEnvironment
    var parameterType: T.Type
    var action: (T, EnvironmentValues?) -> Void
//    var env: EnvironmentValues? = nil
            
    /// The update function is only called in the View update cycle.
    /// We rely on this to
    mutating public func update() {
//        env = _viewEnvironment
    }

//        public static var defaultValue: SegueDispatcher = .system
    
    init(action: @escaping (T, EnvironmentValues?) -> Void) {
        self.parameterType = T.self
        self.action = action
    }
    
    func callAsFunction<A>(_ value: A, in env: EnvironmentValues?) -> Bool {
        guard let value = value as? T else { return false }
        action(value, env)
        return true
    }
}

public struct Dispatch<Value>: DynamicProperty {
    var actions: [Action] = []

    public func callAsFunction(_ value: Value, in env: EnvironmentValues?) {
        _ = actions.reversed().first { $0(value, in: env) }
    }
}

extension Dispatch {
    static var warning: Self {
        .init(actions: [
            ActionTrampoline { (a: Any, e) in
                print(String(describing: a))
            }
        ])
    }
}

struct DispatchKey<Value>: EnvironmentKey {
    static var defaultValue: Dispatch<Value> { .warning }
}

public extension EnvironmentValues {
    var dispatch: Dispatch<Any> {
        get { self[DispatchKey<Any>.self] }
        set { self[DispatchKey<Any>.self] = newValue }
    }
}

public extension View {
    func onDispatch<A>(
        for type: A.Type = A.self,
        call: @escaping (A, EnvironmentValues?) -> Void)
    -> some View {
        let at = ActionTrampoline(action: call)
        return self
            .transformEnvironment(\.dispatch) {
                $0.actions.append(at)
            }
    }
}

// MARK: Helper Views
struct ActionTap<Value>: ViewModifier {
    @Environment(\.self) var env
    var action: Value
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                env.dispatch(action, in: env)
            }
    }
}

public extension View {
    func onTap<Value>(dispatch value: Value) -> some View {
        modifier(ActionTap(action: value))
    }
}

public struct ActionButton<Value, Content: View> : View {
    @Environment(\.self) var env
    let content : () -> Content
    let value: Value
    
    public init(dispatch: Value, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.value = dispatch
    }
    
    public var body: some View {
        Button(action: { env.dispatch(value, in: env) }) {
            content()
        }
    }
}

public struct WithDispatcher<Content: View>: View {
    @Environment(\.dispatch) var dispatch
    @ViewBuilder var content: (Dispatch<Any>) -> Content
    
    public init(@ViewBuilder content: @escaping (Dispatch<Any>) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(dispatch)
    }
}

#Preview {
    ZStack {
        Color.yellow
        ActionButton(dispatch: "Hello world") {
            Text("Say Hello")
                .font(.largeTitle)
                .padding()
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .buttonBorderShape(.capsule)
        .padding()
    }
}
