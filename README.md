# Zaq
A CLI installer for Linux

## Build and run

```console
# clone the repo
$ git clone https://github.com/ZaqInstaller/Zaq.git

# change the working directory to Zaq
$ cd Zaq

# install the requirements
$ nimble install cligen

# build
$ nim c -d:ssl zaq.nim

# run
$ ./zaq install godot-4
```

## Examples

```console
$ zaq install godot-4
.: Welcome in zaq :.
Downloading godot-4 v4.0.2...
Download complete.
Checking hash...
Check complete.
Extracting godot-4...
Extraction complete.
Done!

$ zaq search lmms
.: Welcome in zaq :.
Searching lmms...
Found: lmms
```

## How it works


## Acknowledgements
[cligen](https://github.com/c-blake/cligen)

[Nim](https://github.com/nim-lang/Nim)
