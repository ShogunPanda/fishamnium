import Foundation
let pwd = FileManager.default.currentDirectoryPath
let defaultBranch = ProcessInfo().environment["GIT_DEFAULT_BRANCH"] ?? "development"
let defaultRemote = ProcessInfo().environment["GIT_DEFAULT_REMOTE"] ?? "origin"
let quiet = ProcessInfo().environment["QUIET"] != nil
let useDebug = ProcessInfo().environment["DEBUG"] != nil
let commands = [
  "is_repository", "remotes", "full_branch_name", "branch_name", "full_sha", "sha", "task", "commit_with_task", "reset", "cleanup", "delete", "list-commands",
  "start", "refresh", "finish", "full_finish", "fast_commit", "release", "import",
  "start_from_release", "refresh_from_release", "finish_to_release", "full_finish_to_release", "import_release", "delete_release"
  //"fbn", "bn", "t", "ct", "cat", "d", "s", "r", "f", "ff", "fc", "rt", "i", "rs", "rr", "rf", "rff", "ri", "rd"
]

func showExit(_ result: Int32) {
  if !quiet {
    if result != 0 {
      print("\u{001b}[31m\u{2717} Operation failed with code \(result).\u{001b}[39m")
    } else {
      print("\u{001b}[32m\u{2713} Operation completed successfully!\u{001b}[39m")
    }
  }

  exit(result)
}

func fail(_ reason: String?) {
  if reason != nil {
    print("\u{001b}[1m\u{001b}[31m\(reason!)\u{001b}[22m\u{001b}[39m")
  }

  exit(1)
}

func isEmptyString(_ subject: String?) -> Bool {
  return subject == nil || subject!.trimmingCharacters(in: CharacterSet.whitespaces.union(CharacterSet.newlines)).isEmpty
}

func showHelp(_ requiredArguments: [String], _ optionalArguments: [String] = []) {
  var args: [String] = []

  // Add usage line
  for arg in requiredArguments {
    args.append(arg.uppercased())
  }
  for arg in optionalArguments {
    args.append("[\(arg.uppercased())]")
  }

  print("Usage: \(CommandLine.arguments[0].components(separatedBy: "/").last!) \(CommandLine.arguments[1]) \(args.joined(separator: " "))")

  if optionalArguments.index(of: "base") != nil || optionalArguments.index(of: "destination") != nil {
    print("  Default BASE/DESTINATION is the value of GIT_DEFAULT_BRANCH environment variable or \"development\".")
  }

  if optionalArguments.index(of: "remote") != nil {
    print("  Default REMOTE is the value of GIT_DEFAULT_REMOTE environment variable or \"origin\".")
  }
}

func parseArguments(_ arguments: [String], _ requiredArguments: [String], _ optionalArguments: [String] = []) -> [String: String] {
  var args = arguments
  var parsed: [String: String] = [:]

  // Check if only help is needed
  if ["-h", "-u", "--help", "--usage", "-?"].index(of: arguments.first ?? "") != nil {
    showHelp(requiredArguments, optionalArguments)
    showExit(0)
  }

  // Parse required arguments
  for required in requiredArguments {
    let value: String? = args.isEmpty ? nil : args.remove(at: 0)

    guard !isEmptyString(value) else {
      fail("Please provide the \(required.uppercased()) argument. Re-run with \"-h\" as the only argument for more information.")
      return parsed
    }

    parsed[required] = value
  }

  // Parse optional arguments, with defaults
  for optional in optionalArguments {
    let value: String? = args.isEmpty ? nil : args.remove(at: 0)

    if !isEmptyString(value) {
      parsed[optional] = value
    } else if optional == "base" || optional == "destination" {
      parsed[optional] = defaultBranch
    } else if optional == "remote" {
      parsed[optional] = defaultRemote
    }
  }

  return parsed;
}

func git(_ arguments: [String], _ pipe: Bool = true, _ fatalMessage: String? = nil) -> Process {
  let task = Process()

  // Set arguments
  task.launchPath = "/usr/bin/git"
  task.arguments = arguments

  if pipe {
    task.standardError = Pipe()
    task.standardOutput = Pipe()
  } else {
    // Show command that is being executed
    let formattedArguments = arguments.map { $0.contains(" ") ? "\"\($0)\"" : $0}.joined(separator: " ")

    print("\u{001b}[33m\u{22EF} Executing: git \(formattedArguments)\u{001b}[39m")
  }

  // Launch the task and wait to exit
  task.launch()
  task.waitUntilExit()

  if !pipe && useDebug {
    if task.terminationStatus != 0 {
      print("\u{001b}[31m\u{2717} Exited with status \(task.terminationStatus)\u{001b}[39m")
    } else {
      print("\u{001b}[32m\u{2713} Exited with status \(task.terminationStatus)\u{001b}[39m")
    }
  }

  if task.terminationStatus != 0 && fatalMessage != nil {
    fail(fatalMessage!)
  }

  return task
}

func gitChain(_ steps: [[String]]) {
  for step in steps {
    let result = git(step, false)

    if result.terminationStatus != 0 {
      showExit(result.terminationStatus)
    }
  }
}

func taskOutput(_ task: Process) -> String{
  // Read stdout
  let outputData = (task.standardOutput as! Pipe).fileHandleForReading.readDataToEndOfFile()

  // Trim whitespaces and newlines
  return String(data: outputData, encoding: String.Encoding.utf8)!.trimmingCharacters(in: CharacterSet.whitespaces.union(CharacterSet.newlines))
}

func isRepository(_ quiet: Bool = false){
  // Execute git
  guard git(["rev-parse", "--is-inside-work-tree"]).terminationStatus != 0 else { return }

  // Not a repo
  fail(quiet ? nil : "You're not inside a git repository.")
}

func showRemotes(){
  // Execute git
  let output = taskOutput(git(["remote", "-v"]))

  var remotes = output.components(separatedBy: "\n").reduce([String: Any]()) {
    tAccu, remote in
    var accu = tAccu as! [String: [String: String]]

    // Split output
    let tokens = remote.components(separatedBy: CharacterSet.whitespaces).filter { $0.isEmpty == false }
    let name = tokens[0], url = tokens[1], type = tokens[2].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")

    // Assign new type
    if accu[name] == nil {
      accu[name] = [:]
    }

    accu[name]![type] = url

    // Reduce
    return accu
  }

  for (name, _) in remotes { // Simplify output by merging identical fetch and push
    let fetch = (remotes[name] as! [String: String])["fetch"]
    if fetch == (remotes[name] as! [String: String])["push"] {
      remotes[name] = fetch
    }
  }

  // Serialize as JSON, which will be more human readable
  let json = String(data: try! JSONSerialization.data(withJSONObject: remotes, options: .prettyPrinted), encoding: String.Encoding.utf8)!

  // Print
  print(json.replacingOccurrences(of: "\\/", with: "/"))
}

func getFullBranchName() -> String{
  // Execute git
  var execution = git(["symbolic-ref", "HEAD"])

  if execution.terminationStatus != 0 {
    execution = git(["rev-parse", "--short", "HEAD"])
  }

  // Verify a command succeded then print its output
  guard execution.terminationStatus == 0 else { fail("Cannot get git branch name."); return "" }
  return taskOutput(execution)
}

func getBranchName() -> String {
  return getFullBranchName().replacingOccurrences(of: "refs/heads/", with: "")
}

func getSha(_ short: Bool = false) -> String{
  // Execute git
  var arguments = ["rev-parse", "HEAD"]

  if short {
    arguments.insert("--short", at: 1)
  }

  let execution = git(arguments, true, "Cannot get git SHA.")

  // Verify a command succeded then print its output
  return taskOutput(execution)
}

func getTaskID() -> String {
  var task = ""

  // Parse the branch name
  let branch = getFullBranchName().components(separatedBy: "/").last!
  let regex = try! NSRegularExpression(pattern: "^((([a-z]+-)?\\d+-+)?.+?(-+([a-z]+-)?\\d+)?)$", options: .caseInsensitive)

  // There is match
  if let matches = regex.firstMatch(in: branch, options: [], range: NSRange(location: 0, length: branch.utf8.count)) {
    // Find which portion holds the task, they might both be empty in case of false positive
    let rangeIndex = [2, 4].first { matches.rangeAt($0).length != 0 }

    // Assign the task
    if rangeIndex != nil {
      task = (branch as NSString).substring(with: matches.rangeAt(rangeIndex!)).trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
  }

  return task
}

func commitWithTask(_ internalMessage: String?, _ task: String?, _ inputArgs: [String]){
  var args = inputArgs
  guard internalMessage != nil || !args.isEmpty else { return fail("Please provide a commit message.") }

  // If the message is missing, get it from the args
  var message = internalMessage ?? args.remove(at: 0)

  // If there is a task, add it
  if task == nil || !task!.isEmpty {
    if ProcessInfo().environment["GIT_TASK_PREPEND"] != nil {
      message = "[#\(task!)] " + message
    } else {
      message += " [#\(task!)]"
    }
  }

  // Manipulate arguments
  args.insert("commit", at: 0)
  args.append("-m")
  args.append("\(message)")

  // Execute and return
  let termination = git(args, false).terminationStatus

  if termination != 0 || internalMessage == nil {
    showExit(termination)
  }
}

func hardReset(){
  // Reset
  var execution = git(["reset", "--hard"], false)

  if execution.terminationStatus == 0 {
    // Cleanup
    execution = git(["clean", "-f"], false)
  }

  showExit(execution.terminationStatus)
}

func cleanup(){
  // Get the list of branches
  let execution = git(["branch", "--merged"], true, "Cannot get branches.")

  // Detect deletable branches
  let filteredBranches = ["master", defaultBranch]
  var args = taskOutput(execution)
    .components(separatedBy: "\n")
    .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
    .filter { !$0.hasPrefix("*") }
    .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
    .filter { filteredBranches.index(of: $0) == nil }

  // Perform deletion
  if !args.isEmpty {
    args = ["branch", "-D"] + args
    let _ = git(args, false)
    showExit(0)
  }
}

func delete(_ otherArgs: [String]){
  var branches = otherArgs

  // Check if help is needed
  if branches.isEmpty {
    return fail("Please provide the BRANCH argument. Re-run with \"-h\" as the only argument for more information.")
  }

  if ["-h", "-u", "--help", "--usage", "-?"].index(of: branches.first ?? "") != nil {
    showHelp(["branch"], ["branch...", "remote"])
    print("  When more than a branch is given, the last argument is considered to always be REMOTE.")
    showExit(0)
  }

  // Delete branches
  let remote: String = branches.count < 2 ? defaultRemote : branches.popLast()!

  for branch in branches {
    let _ = git(["branch", "-D", branch], false)
    let _ = git(["push", remote, ":\(branch)"], false)
  }
}

func workflowDebugStep(_ step: String) {
  print("\u{001b}[33m\u{22EF} Workflow: \(step)\u{001b}[39m")
}

func workflowStart(_ otherArgs: [String]) {
  // Parse args
  let args : [String: String] = parseArguments(otherArgs, ["name"], ["base", "remote"])
  workflowDebugStep("Creating a new branch \"\(args["name"]!)\" out of branch \"\(args["remote"]!)/\(args["base"]!)\" ...")

  // Execute the chain
  gitChain([
    ["fetch"],
    ["checkout", args["base"]!],
    ["pull", args["remote"]!, args["base"]!],
    ["checkout", "-b", args["name"]!]
  ])
}

func workflowRefresh(_ otherArgs: [String], _ currentBranch: String? = nil) {
  let current = currentBranch ?? getBranchName()

  // Parse args
  let args: [String: String] = parseArguments(otherArgs, [], ["base", "remote"])
  workflowDebugStep("Refreshing branch \"\(current)\" on branch \"\(args["remote"]!)/\(args["base"]!)\" ...")

  // Execute the chain
  gitChain([
    ["fetch"],
    ["checkout", args["base"]!],
    ["pull", args["remote"]!, args["base"]!],
    ["checkout", current],
    ["rebase", args["base"]!]
  ])
}

func workflowFinish(_ otherArgs: [String], _ deleteAfter: Bool = false, _ currentBranch: String? = nil) {
  let current = currentBranch ?? getBranchName()

  workflowRefresh(otherArgs, current)

  // Parse args
  let args: [String: String] = parseArguments(otherArgs, [], ["base", "remote"])
  workflowDebugStep("Merging branch \"\(current) to branch \"\(args["remote"]!)/\(args["base"]!)\" ...")

  // Execute the chain
  gitChain([
    ["checkout", args["base"]!],
    ["merge", "--no-ff", "-m", "Merge branch '\(current)' into '\(args["base"]!)'", current],
    ["push", args["remote"]!, args["base"]!],
  ])

  if deleteAfter {
    workflowDebugStep("Deleting local branch \"\(current)\" ...")
    let _ = git(["branch", "-D", current], false)
  }
}

func workflowFastCommit(_ otherArgs: [String]) {
  // Parse args
  let args: [String: String] = parseArguments(otherArgs, ["name", "message"], ["base", "remote"])

  // Execute the flow
  workflowStart([args["name"]!, args["base"]!, args["remote"]!])
  workflowDebugStep("Commiting with message: \"\(args["message"]!)\" ...")
  commitWithTask(args["message"], getTaskID(), ["-a"])
  workflowFinish([args["base"]!, args["remote"]!], true, args["name"]!)
}

func workflowRelease(_ otherArgs: [String]){
  // Parse args
  let args: [String: String] = parseArguments(otherArgs, ["version"], ["base", "remote"])
  let current = getBranchName()
  let release = "release-\(args["version"]!)"

  // Execute the flow
  let _ = git(["branch", "-D", release], false)
  workflowDebugStep("Creating release \"\(release)\" ...")
  workflowStart([release, args["base"]!, args["remote"]!])
  workflowDebugStep("Pushing release \"\(release)\" ...")
  gitChain([
    ["push", "-f", args["remote"]!, release],
    ["checkout", current],
    ["branch", "-D", release],
  ])
}

func workflowImport(_ otherArgs: [String]){
  // Parse args
  var args: [String: String] = parseArguments(otherArgs, ["source"], ["destination", "remote", "temporary"])

  if args["temporary"] == nil {
    args["temporary"] = "import-\(args["source"]!)"
  }

  delete([args["temporary"]!, args["remote"]!])
  workflowStart([args["temporary"]!, args["source"]!, args["remote"]!])
  workflowFinish([args["destination"]!, args["remote"]!], true)
}

func workflowStartFromRelease(_ otherArgs: [String]){
  var args: [String: String] = parseArguments(otherArgs, ["name", "version"], ["remote"])
  workflowStart([args["name"]!, "release-\(args["version"]!)", args["remote"]!])
}

func workflowRefreshFromRelease(_ otherArgs: [String]){
  var args: [String: String] = parseArguments(otherArgs, ["version"], ["remote"])
  workflowRefresh(["release-\(args["version"]!)", args["remote"]!])
}

func workflowFinishToRelease(_ otherArgs: [String], _ deleteAfter: Bool = false){
  var args: [String: String] = parseArguments(otherArgs, ["version"], ["remote"])
  workflowFinish(["release-\(args["version"]!)", args["remote"]!], deleteAfter)
}

func workflowImportRelease(_ otherArgs: [String]){
  var args: [String: String] = parseArguments(otherArgs, ["version"], ["destination", "remote", "temporary"])
  let release = "release-\(args["version"]!)"

  if args["temporary"] == nil {
    args["temporary"] = "import-\(release)"
  }

  workflowImport([release, args["destination"]!, args["remote"]!, args["temporary"]!])
}

func workflowDeleteRelease(_ otherArgs: [String]){
  var args: [String: String] = parseArguments(otherArgs, ["version"], ["remote"])
  delete(["release-\(args["version"]!)", args["remote"]!])
}

func main(){
  let otherArgs = CommandLine.argc > 2 ? Array(CommandLine.arguments[2 ..< CommandLine.arguments.endIndex]) : []

  // Perform the action
  switch CommandLine.argc > 1 ? CommandLine.arguments[1] : "" {
    // Base
    case "is_repository":
      isRepository(true)
    case "remotes":
      isRepository()
      showRemotes()
    case "full_branch_name", "fbn":
      isRepository()
      print(getFullBranchName())
    case "branch_name", "bn":
      isRepository()
      print(getBranchName())
    case "full_sha":
      isRepository()
      print(getSha())
    case "sha":
      isRepository()
      print(getSha(true))
    case "task", "t":
      isRepository()
      let task = getTaskID()

      if !task.isEmpty {
        print(task)
      }
    case "commit_with_task", "ct", "cat":
      isRepository()
      commitWithTask(nil, getTaskID(), otherArgs)
    case "reset":
      isRepository()
      hardReset()
    case "cleanup":
      isRepository()
      cleanup()
    case "delete", "d":
      isRepository()
      delete(otherArgs)
    // Workflow
    case "start", "s":
      isRepository()
      workflowStart(otherArgs)
    case "refresh", "r":
      isRepository()
      workflowRefresh(otherArgs)
    case "finish", "f":
      isRepository()
      workflowFinish(otherArgs)
    case "full_finish", "ff":
      isRepository()
      workflowFinish(otherArgs, true)
    case "fast_commit", "fc":
      isRepository()
      workflowFastCommit(otherArgs)

    case "release", "rt":
      isRepository()
      workflowRelease(otherArgs)
    case "import", "i":
      isRepository()
      workflowImport(otherArgs)
    case "start_from_release", "rs":
      isRepository()
      workflowStartFromRelease(otherArgs)
    case "refresh_from_release", "rr":
      isRepository()
      workflowRefreshFromRelease(otherArgs)
    case "finish_to_release", "rf":
      isRepository()
      workflowFinishToRelease(otherArgs)
    case "full_finish_to_release", "rff":
      isRepository()
      workflowFinishToRelease(otherArgs, true)
    case "import_release", "ri":
      isRepository()
      workflowImportRelease(otherArgs)
    case "delete_release", "rd":
      isRepository()
      workflowDeleteRelease(otherArgs)
    case "list-commands":
      for c in commands {
        print(c)
      }
    default:
      print("Usage: \(CommandLine.arguments[0]) COMMAND [ARGS...]")
  }
}

main()
