# Package

version       = "1.1.0"
author        = "jiro4989"
description   = "envconfig provides a function to get config objects from environment variables."
license       = "MIT"
srcDir        = "src"



# Dependencies

requires "nim >= 1.0.0"
requires "regex >= 0.13.0"

task docs, "Generate API documents":
  exec "nimble doc -Y --index:on --project --out:docs --hints:off src/envconfig.nim"
