import std/parseopt
import std/strformat
import std/strutils
import std/parsecfg

import ./utils

const
    helpMessage: string = staticRead(filename = "../external/help_message.txt")
    repository: string = staticExec(command = "git config --get remote.origin.url")
    commit: string = staticExec(command = "git rev-parse --short HEAD")
    versionInfo: string = &"Icec v0.1 ({repository}@{commit})\n" &
        &"Compiled for {hostOS} ({hostCPU}) using Nim {NimVersion} " &
        &"({CompileDate}, {CompileTime})\n"

setControlCHook(
    hook = proc(): void {.noconv.} =
        quit(0)
)

var parser: OptParser = initOptParser()

var
    address: string = "127.0.0.1"
    port: int = 8000
    mountPoint: string = "/stream"
    username: string = "source"
    password: string = "hackme"
    ypPolicy: int = -1
    name: string = "Generic name"
    description: string = "Generic description"
    url: string = "http://<generic-address>:<generic-port>/<generic-path>"
    genre: string = "Generic genre"
    bitrate: int = -1
    audioInfo: string = "Generic audio info"
    contentType: string = "audio/mpeg"
    shuffle: bool = false
    repeat: bool = false
    repeatMax: int = -1

var mediaFiles: seq[string] = newSeq[string]()

while true:
    parser.next()

    case parser.kind
    of cmdEnd:
        break
    of cmdShortOption, cmdLongOption:
        case parser.key
        of "version", "v":
            writeStdout(s = versionInfo, exitCode = 0)
        of "help", "h":
            writeStdout(s = helpMessage, exitCode = 0)
        of "address":
            address = parser.val
            
            if parser.val.isEmptyOrWhitespace():
                writeStderr(
                    s = &"icec: fatal: missing required value for argument: --address",
                    exitCode = 1
                )
        of "port":
            try:
                port = parser.val.parseInt()
            except ValueError:
                writeStderr(
                    s = &"icec: fatal: bad value for argument: --port",
                    exitCode = 1
                )
        of "mount-point", "path":
            mountPoint = parser.val
            
            if mountPoint.isEmptyOrWhitespace():
                writeStderr(
                    s = &"icec: fatal: missing required value for argument: --mount-point",
                    exitCode = 1
                )
        of "username":
            username = parser.val
            
            if username.isEmptyOrWhitespace():
                writeStderr(
                    s = &"icec: fatal: missing required value for argument: --username",
                    exitCode = 1
                )
        of "password":
            password = parser.val
            
            if password.isEmptyOrWhitespace():
                writeStderr(
                    s = &"icec: fatal: missing required value for argument: --password",
                    exitCode = 1
                )
        of "yp-policy":
            if parser.val notin ["-1", "0", "1"]:
                writeStderr(
                    s = &"icec: fatal: bad value for argument: --yp-policy",
                    exitCode = 1
                )
            
            ypPolicy = parser.val.parseInt()
        of "name":
            name = parser.val
        of "description":
            description = parser.val
        of "url":
            url = parser.val
        of "genre":
            genre = parser.val
        of "bitrate":
            try:
                bitrate = parser.val.parseInt()
            except ValueError:
                writeStderr(
                    s = &"icec: fatal: bad value for argument: --bitrate",
                    exitCode = 1
                )
        of "audio-info":
            audioInfo = parser.val
        of "content-type":
            contentType = parser.val
        of "config-file":
            let config: Config = loadConfig(filename = parser.val)
            
            # Server
            address = config.getSectionValue(section = "Server", key = "address", defaultVal = "127.0.0.1")
            
            if address.isEmptyOrWhitespace():
                writeStderr(
                    s = &"icec: fatal: missing required value for key: address",
                    exitCode = 1
                )
            
            try:
                port = config.getSectionValue(section = "Server", key = "port", defaultVal = "8000").parseInt()
            except ValueError:
                writeStderr(
                    s = &"icec: fatal: bad value for key: port",
                    exitCode = 1
                )
            
            mountPoint = config.getSectionValue(section = "Server", key = "mount-point", defaultVal = "/stream")
            
            if mountPoint.isEmptyOrWhitespace():
                writeStderr(
                    s = &"icec: fatal: missing required value for key: mountPoint",
                    exitCode = 1
                )
            
            # Authentication
            username = config.getSectionValue(section = "Authentication", key = "username", defaultVal = "source")
            
            if username.isEmptyOrWhitespace():
                writeStderr(
                    s = &"icec: fatal: missing required value for key: username",
                    exitCode = 1
                )
            
            password = config.getSectionValue(section = "Authentication", key = "username", defaultVal = "source")
            
            if password.isEmptyOrWhitespace():
                writeStderr(
                    s = &"icec: fatal: missing required value for key: password",
                    exitCode = 1
                )
            
            # Stream
            let value: string = config.getSectionValue(section = "Stream", key = "yp-policy", defaultVal = "-1")
            
            if value notin ["-1", "0", "1"]:
                writeStderr(
                    s = &"icec: fatal: bad value for key: yp-policy",
                    exitCode = 1
                )
            
            ypPolicy = value.parseInt()
            name = config.getSectionValue(section = "Stream", key = "name", defaultVal = "Generic name")
            description = config.getSectionValue(section = "Stream", key = "description", defaultVal = "Generic description")
            url = config.getSectionValue(section = "Stream", key = "url", defaultVal = "http://<generic-address>:<generic-port>/<generic-path>")
            genre = config.getSectionValue(section = "Stream", key = "genre", defaultVal = "Generic genre")
            
            try:
                bitrate = config.getSectionValue(section = "Stream", key = "bitrate", defaultVal = "-1").parseInt()
            except ValueError:
                writeStderr(
                    s = &"icec: fatal: bad value for key: bitrate",
                    exitCode = 1
                )
            
            audioInfo = config.getSectionValue(section = "Stream", key = "audio-info", defaultVal = "Generic audio info")
            contentType = config.getSectionValue(section = "Stream", key = "content-type", defaultVal = "audio/mpeg")
            
            shuffle = if config.getSectionValue(section = "Stream", key = "shuffle", defaultVal = "false") == "false": false else: true
            repeat = if config.getSectionValue(section = "Stream", key = "repeat", defaultVal = "false") == "false": false else: true
            if repeat:
                try:
                    repeatMax = config.getSectionValue(section = "Stream", key = "repeat-max", defaultVal = "-1").parseInt()
                except ValueError:
                    writeStderr(
                        s = &"icec: fatal: bad value for key: repeat-max",
                        exitCode = 1
                    )

            break
        of "shuffle":
            shuffle = true
        of "repeat":
            repeat = true
        of "repeat-max":
            try:
                repeatMax = parser.val.parseInt()
            except ValueError:
                writeStderr(
                    s = &"icec: fatal: bad value for argument: --repeat-max",
                    exitCode = 1
                )
        else:
            writeStderr(
                s = &"icec: faltal: unrecognized argument: " & getPrefixedArgument(parser.key),
                exitCode = 1
            )
    of cmdArgument:
        mediaFiles.add(parser.key)
        
echo mediaFiles
