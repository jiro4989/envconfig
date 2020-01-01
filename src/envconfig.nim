## envconfig provides binding prefix of environment variables to object.
##
## Usage
## -----
##

runnableExamples:
  import os
  import envconfig

  type
    MyApp = ref object
      name, version, dir: string
      port: int
      dev: bool

  putEnv("MYAPP_NAME", "envconfig")
  putEnv("MYAPP_VERSION", "v1.0.0")
  putEnv("MYAPP_DIR", "/opt/envconfig")
  putEnv("MYAPP_PORT", "1234")
  putEnv("MYAPP_DEV", "true")

  let obj = getEnvObject[MyApp]()
  echo "MYAPP_NAME: " & obj.name
  echo "MYAPP_VERSION: " & obj.name
  echo "MYAPP_DIR: " & obj.name
  echo "MYAPP_PORT: " & $obj.name
  echo "MYAPP_DEV: " & $obj.name

import typeinfo
import strutils
from os import getEnv

proc camelCaseToUpperSnakeCase(s: string): string =
  for ch in s:
    if ch.isUpperAscii:
      result.add("_")
    result.add(ch.toUpperAscii)

proc getEnvObject*(T: typedesc, prefix = ""): T =
  # 1. Get object name and type name
  let envPrefix =
    if prefix != "": prefix
    else: ($T).toUpperAscii

  # 2. Get object field names and type names
  var obj = T()
  var objAny = obj.toAny
  for name, value in obj.fieldPairs:
    # 3. Lookup envaironment variables
    let envName = envPrefix & "_" & name.camelCaseToUpperSnakeCase
    let envValue = getEnv(envName)

    # NOTE: can not early return
    if envValue != "":
      # 4. Set value to object
      var v = envValue
      let vType = $value.type
      case vType
      of "string":
        var vAny = v.toAny
        objAny[name] = vAny
      of "bool":
        var v = parseBool(v)
        var vAny = v.toAny
        objAny[name] = vAny
      of "int":
        var v = parseInt(v)
        var vAny = v.toAny
        objAny[name] = vAny
      of "float":
        var v = parseFloat(v)
        var vAny = v.toAny
        objAny[name] = vAny
      else:
        raiseAssert "not supported types: " & vType
  return obj
