import Metal

public extension MTLCompileOptions {
    enum CompilerArgument: String {
        case omitUnusedWariablesWarning = "-Wno-unused-variable"
        case omitUnusedFunctionsWarning = "-Wno-unused-function"
    }

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
