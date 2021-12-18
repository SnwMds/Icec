proc writeStderr*(s: string, exitCode: int = -1): void =
    stderr.write(s & "\n")
    
    if exitCode >= 0:
        quit(exitCode)

proc writeStdout*(s: string, exitCode: int = -1): void =
    stdout.write(s & "\n")
    
    if exitCode >= 0:
        quit(exitCode)

proc getPrefixedArgument*(s: string): string =
    result = if len(s) > 1: "--" & s else: "-" & s
