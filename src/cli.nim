import rdstdin
import terminal
import parseopt
import ./commands
import ./common

var optParser = initOptParser(shortNoVal = {'h', 'v'}, longNoVal = @["help",
    "version", "json", "plain", "no-input"])

var firstArg: string
var outputKind = OutputFormatted
var noInput = false

block parser:
  for kind, key, _ in optParser.getopt():
    case kind
    of cmdEnd: doAssert false
    of cmdShortOption, cmdLongOption:
      case key
      of "help", "h":
        writeHelp(QuitSuccess)
      of "version", "v":
        writeVersion()
      of "json":
        outputKind = OutputJson
      of "plain":
        outputKind = OutputPlain
      of "no-input":
        noInput = true
    of cmdArgument:
      firstArg = key
      break parser

let args = optParser.remainingArgs()
let shouldBeInteractive = (not noInput) and (not stdin.isatty())

case firstArg
of "stats":
  case args.len
  of 0:
    if shouldBeInteractive:
      readLineFromStdin("").writeStats(outputKind)
    else:
      # Use total stats
      writeStats(outputKind)
  of 1:
    # Use provided URL stats
    args[0].writeStats(outputKind)
  else: discard
of "shorten":
  case args.len
  of 0:
    if shouldBeInteractive:
      readLineFromStdin("").writeShortenUrl(outputKind)
  of 1:
    # Shorten provided URL
    args[0].writeShortenUrl(outputKind)
  else: discard
of "config":
  writeSerializedConfig(outputKind)
of "":
  # No arguments were provided
  if shouldBeInteractive:
    readLineFromStdin("").writeShortenUrl(outputKind)
else:
  # Some arguments were provided
  if args.len == 0:
    # First argument was a URL, no others were provided
    firstArg.writeShortenUrl(outputKind)

# All commands terminate the program, so default behavior is to print help exit with failure
writeHelp(QuitFailure)
