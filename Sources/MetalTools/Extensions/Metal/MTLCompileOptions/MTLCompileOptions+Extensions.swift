import Metal

public extension MTLCompileOptions {
    /// Enumeration of compiler arguments that can be passed to the Metal compiler.
    enum CompilerArgument: String {
        /// Omits warnings about unused variables.
        case omitUnusedWariablesWarning = "-Wno-unused-variable"
        /// Omits warnings about unused functions.
        case omitUnusedFunctionsWarning = "-Wno-unused-function"
    }

    /// Sets additional compiler arguments for Metal shader compilation.
    ///
    /// This method allows you to pass specific compiler flags to the Metal shader compiler.
    /// It uses the private API `setAdditionalCompilerArguments:` if available.
    ///
    /// - Parameter arguments: A variadic list of `CompilerArgument` cases to be applied.
    ///
    /// - Note: This method uses Objective-C runtime features to call a private API.
    ///         Its behavior may change in future versions of Metal.
    func setCompilerArguments(_ arguments: CompilerArgument...) {
        let setAdditionalCompilerArgumentsSelector = NSSelectorFromString("setAdditionalCompilerArguments:")

        let argumentsSet = Set(arguments)
        var argumentsString = ""
        argumentsSet.enumerated().forEach {
            argumentsString += $0.element.rawValue
            if $0.offset < argumentsSet.count {
                argumentsString += " "
            }
        }

        if responds(to: setAdditionalCompilerArgumentsSelector) {
            perform(
                setAdditionalCompilerArgumentsSelector,
                with: argumentsString as NSString
            )
        }
    }
}
