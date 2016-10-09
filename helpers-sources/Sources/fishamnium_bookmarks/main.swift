import Foundation
let bookmarkFile = "\(NSHomeDirectory())/.fishamnium_bookmarks.json"
let shortBookmarkFile = "~/.fishamnium_bookmarks.json"

enum RuntimeError: Error {
  case invalidJSON
  case permissionError
}

func fail(_ reason: String?) {
  if reason != nil {
    print("\u{001b}[31m\(reason!)\u{001b}[39m")
  }

  exit(1)
}

func sanitizeDestination(_ destination: String) -> String{
  // Properly escape $HOME
  return destination.replacingOccurrences(of: "$HOME", with: NSHomeDirectory())
}

func load() -> [String: String]?{
  do {
    // Read the file
    guard let data = FileManager.default.contents(atPath: bookmarkFile) else { throw RuntimeError.invalidJSON }

    // Deserialize
    return (try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: String])
  } catch {
    fail("Cannot parse JSON file \(shortBookmarkFile)")
    exit(1)
  }
}

func save(_ bookmarks: Any){
  do {
    // Serialize
    let data = try JSONSerialization.data(withJSONObject: bookmarks, options: .prettyPrinted)

    // Write the destination
    guard FileManager.default.createFile(atPath: bookmarkFile, contents: data) else { throw RuntimeError.permissionError }
  } catch {
    print(error)
    fail("Cannot serialize to JSON file \(shortBookmarkFile)")
    exit(1)
  }
}

func list(_ namesOnly: Bool){
  // Load the bookmarks
  guard let bookmarks = load() else { return }
  let names = bookmarks.keys.sorted()
  let home = NSHomeDirectory()

  if namesOnly { // Show names only, simply print the keys
    print(names.joined(separator: "\n"))
  } else {
    // Find the lenght to align results
    let maxLength = bookmarks.keys.map { $0.characters.count }.max()! + 1

    for name in names {
      // Colorize destinations
      let destination = bookmarks[name]!
        .replacingOccurrences(of: home, with: "\u{001b}[33m$HOME\u{001b}[39m")
        .replacingOccurrences(of: "$HOME", with: "\u{001b}[33m$HOME\u{001b}[39m")

      // Print
      print("\u{001b}[32m\(name.padding(toLength: maxLength, withPad: " ", startingAt: 0))\u{001b}[39m\u{2192} \u{001b}[1m\(destination)\u{001b}[22m");
    }
  }
}

func create(_ nameParam: String?){
  // Validate the name
  guard nameParam != nil else { return fail("Please provide a bookmark name.") }
  let name = nameParam!

  // Validate that name is not already taken
  guard var bookmarks = load() else { return }
  guard bookmarks[name] == nil else { return fail("The bookmark \"\(name)\" already exist.") }

  bookmarks[name] = sanitizeDestination(FileManager.default.currentDirectoryPath)
  save(bookmarks)
}

func show(_ nameParam: String?){
  // Validate the name
  guard nameParam != nil else { return fail("Please provide a bookmark name.") }
  let name = nameParam!

  // Validate that name exists
  guard let bookmarks = load() else { return }
  guard let destination = bookmarks[name] else { return fail("The bookmark \"\(name)\" does not exist.") }

  print(sanitizeDestination(destination))
}

func delete(_ nameParam: String?){
  // Validate the name
  guard nameParam != nil else { return fail("Please provide a bookmark name.") }
  let name = nameParam!

  // Validate that name exists
  guard var bookmarks = load() else { return }
  guard bookmarks[name] != nil else { return fail("The bookmark \"\(name)\" does not exist.") }

  bookmarks[name] = nil
  save(bookmarks)
}

func main(){
  let name: String? = CommandLine.argc > 2 ? CommandLine.arguments[2] : nil

  // Perform the action
  switch CommandLine.argc > 1 ? CommandLine.arguments[1] : "" {
    case "g", "get", "show", "load", "read":
      show(name)
    case "s", "set", "save", "write":
      create(name);
    case "d", "delete", "erase", "remove":
      delete(name)
    case "l", "list":
      list(name == "--names-only")
    default:
      print("Usage: \(CommandLine.arguments[0]) s|d|l|get|set|delete|list|load|save|erase|read|write|remove [NAME]")
  }
}

main()
