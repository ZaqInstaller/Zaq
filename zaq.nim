import os, osproc, sequtils, cligen, json, httpclient, uri, strformat, strutils

let main_dir: string = getHomeDir() & "zaq"
let dl_dir: string = getHomeDir() & "zaq/dl/"
let json_dir: string = getHomeDir() & "zaq/json/"
let json_dir_main: string = getHomeDir() & "zaq/json/Main/"
let shims: string = getHomeDir() & "zaq/shims/"
let jsons_list = toSeq(walkDir(fmt"{main_dir}/json/Main", relative = true))
let http = newHttpClient()


proc setup(program: string) =
  echo ".: Welcome in zaq :."
  if not existsOrCreateDir(main_dir):
    echo "Creating main directory in ~/zaq..."
    echo fmt"Creating download directory in {dl_dir}..."
    createDir(mainDir & "/dl")
    echo fmt"Creating json directory in {json_dir}..."
    createDir(main_dir & "/json")

    # todo: check if git is installed
    echo "Cloning Main repo inside ~/zaq/json..."
    let clone_main_repo = execProcess(fmt"git -C {json_dir} clone https://github.com/ZaqInstaller/Main")
    echo clone_main_repo
  

proc content(program: string): JsonNode =
  let file = open(fmt"{json_dir}{program}.json", fmRead)
  let content = parseJson(file.readAll())
  defer: file.close()
  return content


proc hash(file: string, hash: string): bool =
  let hash: string = strip(hash, chars={'\"'})
  let result_hash: string = execProcess(fmt"sha512sum {file}") # todo: add custom hash algorithm
  if hash == strip(result_hash.split(' ')[0]):
    true
  else:
    false


proc executable(program: string, ext: string) =
  if execShellCmd(fmt"chmod +x {dl_dir}{program}{ext}") == 0:
    echo fmt"Making {program} executable..."
  echo "Done!"


proc symlink(program: string, ext: string) =
  # echo "Creating symlink..."
  # createSymlink(fmt"{dl_dir}{program}{ext}", "/usr/local/bin/")
  # echo "Done!"
  echo "To do symlink"


proc install(program: string): void =
  echo fmt"Pulling Main repo..."
  let pull_main_repo = execProcess(fmt"git -C {json_dir}Main/ pull")
  for json in jsons_list:
    if program & ".json" in json.path:
      let file = open(fmt"{json_dir}/Main/{program}.json", fmRead)
      let content = parseJson(file.readAll())
      defer: file.close()
      let link: string = strip($content["extension"]["AppImage"]["url"],
          chars = {'\"'})
      let version: string = strip($content["version"], chars = {'\"'})
      let hash : string = $content["extension"]["AppImage"]["hash"]
      let ext: string = link.splitFile().ext
      echo fmt"Downloading {program} v{version}..."
      let dir: string = fmt"{dl_dir}{program}{ext}"
      http.downloadFile(link, strip(dir))
      echo fmt"Download complete."
      echo fmt"Checking hash..."
      if not hash(fmt"{dl_dir}{program}{ext}", hash):
        echo "Check failed. The hash values doesn't correspond or the field is empty."
        return
      echo fmt"Check complete."

      # echo "Linking (create .desktop, create shim) -> to do" 
      # to do repair
      

      case ext.toLower():
        of ".appimage":
          executable(program, ext)
          symlink(program, ext)

        of ".zip":
          if execShellCmd(fmt"gunzip -S '.zip' {dl_dir}{program}{ext}") == 0:
            echo fmt"Extracting {program}..."
          echo "Extraction complete."

        of ".gz", ".xz":
          if execShellCmd(fmt"tar -xf {dl_dir}{program}{ext} -C {dl_dir} --remove-files") == 0:
            echo fmt"Extracting {program}..."
          echo "Extraction complete."

      echo "Done!"


proc search(program: string): void =
  echo fmt"Searching {program}..."
  var programs: seq[string]
  case program:
    of "*":
      for json in jsons_list:
        programs.add(splitFile(json.path).name)
      echo "Found: " & join(programs, ", ")
      return
    else:
      for json in jsons_list:
        if program in json.path:
          programs.add(splitFile(json.path).name)
      echo "Found: " & join(programs, ", ")


proc create(program: string): void =
  echo "-v version -d description -h homepage -l license -u appimage-url -s hash"


proc remove(program: string): void =
  return


proc repair(): void =
  return


proc site(program: string): void =
  for p in jsons_list:
    if program & ".json" in p.path:
      let json: JsonNode = content(program)
      let homepage: string = strip($json["homepage"],
          chars = {'\"'})
      echo fmt"{program} homepage is {homepage}"
    return


proc version(program: string): void =
  for p in jsons_list:
    if program & ".json" in p.path:
      let json: JsonNode = content(program)
      let version: string = strip($json["version"],
          chars = {'\"'})
      echo fmt"{program} version is {version}"
    else:
      echo fmt"Can't find the program {program}"
    return


# document commands
proc zaq(args: seq[string]): void =
  try:
    var operation = args[0]
    var program = args[1]

    setup(program)

    case operation:
      of "install":
        install(program)

      of "search":
        search(program)

      of "create":
        create(program)

      of "remove":
        remove(program)

      of "site":
        site(program)

      of "version":
        version(program)

      else:
        echo fmt"""
No operation corresponds to: {operation}. 
Try: install, search, create, remove, site, version
  """
  except:
    echo "Catched error: " & getCurrentExceptionMsg()


dispatch zaq, help = {"args": "The arguments"
# {
# "install": "Install a program",
# "create": "Create a program json",
# "remove": "Remove a program",
# "site": "Open the program site",
# "version": "Display the program version",
# "search": "Search a program",}
}