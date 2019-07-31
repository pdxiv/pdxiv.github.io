## adventshark

Adventshark is a free and open source cross-platform interactive fiction authoring tool that allows the creation of "Scott Adams compatible" files.

### Download

[Windows version v0.1.0](https://github.com/pdxiv/adventshark/releases/download/v0.1.0/adventshark_windows_v0.1.0.zip)

[Linux version v0.1.0](https://github.com/pdxiv/adventshark/releases/download/v0.1.0/adventshark_linux_v0.1.0.zip)

MacOSX version currently unavailable due to GUI bugs 🤒

For more details and to build the files yourself please refer to the [GitHub repository](https://github.com/pdxiv/adventshark).

### How to convert .dat files to .json

Since adventshark currently doesn't have file import functionality, old "Scott Adams" data files from TRS-80 will first need to be converted to adventshark's `.json` format with an included Perl script: [scott2json.pl](scott2json.pl).

#### Basic scott2json usage example (Linux/MacOSX)

```bash
./scott2json.pl adv01.dat > adv01.json
```

#### Usage example with many files at once (Linux/MacOSX)

This example assumes that the `rename` utility is installed. It will convert all the `.dat` files in the directory at once to `.json` format.

```bash
ls -1 *.dat | xargs -i bash -c "./scott2json.pl {} | python -m json.tool > {}.json" ; rename -f 's/.dat.json$/.json/' *.dat.json
```

### Support or Contact

Having trouble with adventshark? Check out the [GitHub repository](https://github.com/pdxiv/adventshark) and create an issue if you don't find what you need.