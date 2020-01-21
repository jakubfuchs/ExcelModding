# ExcelModding

**Basic handling of xls via R**

The coding is adjusted for RStudio based work-flow.

The work-flow consists of:
- `DataSlurp.R` - Main methods for slurping files from data folder, by default based on `settings.json` file.

- `settings.json` minimal required example (the file is not in repo):
```bash
{
  "dirData": "//network/User/dataDir,
  "sheet": "export_data",
  "outOfScope": ["~",
                 "_testcases",
                 "_Dev",
                 "_Archive",
                 "johny"]
}
```


Note: see the 'DEV BLOCK' function at the bottom of the file to get an idea of intended usage and development logic (the dev block includes lines that are meant to be evaluated inside a repl).
