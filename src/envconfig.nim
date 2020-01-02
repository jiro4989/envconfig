## envconfig provides binding prefix of environment variables to object.
##
## Usage
## -----
##

runnableExamples:
  from os import putEnv
  import envconfig

  type
    MyApp = object
      name, version, dir: string
      port: int
      dev: bool

  putEnv("MYAPP_NAME", "envconfig")
  putEnv("MYAPP_VERSION", "v1.0.0")
  putEnv("MYAPP_DIR", "/opt/envconfig")
  putEnv("MYAPP_PORT", "1234")
  putEnv("MYAPP_DEV", "true")

  let config = getEnvConfig(MyApp)
  doAssert config.name == "envconfig"
  doAssert config.version == "v1.0.0"
  doAssert config.dir == "/opt/envconfig"
  doAssert config.port == 1234
  doAssert config.dev == true

import typeinfo
import strutils
from os import getEnv, existsEnv
from sequtils import mapIt

import regex
export regex

type
  ValidationError* = object of Defect

proc camelCaseToUpperSnakeCase(s: string): string =
  for ch in s:
    if ch.isUpperAscii:
      result.add("_")
    result.add(ch.toUpperAscii)

template validateMin(T: typedesc, fieldName, envName: string, mins: seq[tuple[name: string, val: float64]]) =
  for m in mins:
    if fieldName == m.name and v < T(m.val):
      raise newException(ValidationError, "'" & envName & "' must be not less than " & $m.val & ". fieldName = " & fieldName)

template validateMax(T: typedesc, fieldName, envName: string, maxs: seq[tuple[name: string, val: float64]]) =
  for m in maxs:
    if fieldName == m.name and T(m.val) < v:
      raise newException(ValidationError, "'" & envName & "' must be not greater than " & $m.val & ". fieldName = " & fieldName)

template validatePattern(fieldName, envName: string, regexps: seq[tuple[name: string, val: Regex]]) =
  for m in regexps:
    var rm: RegexMatch
    if fieldName == m.name and not v.match(m.val, rm):
      raise newException(ValidationError, "'" & envName & "' was not match pattern. fieldName = " & fieldName)

proc getEnvConfig*(T: typedesc, prefix = "", sep = ",",
                   requires: seq[string] = @[],
                   mins: seq[tuple[name: string, val: float64]] = @[],
                   maxs: seq[tuple[name: string, val: float64]] = @[],
                   regexps: seq[tuple[name: string, val: Regex]] = @[],
                   ): T =
  # 1. Get object name and type name
  let envPrefix =
    if prefix != "": prefix
    else: ($T).toUpperAscii

  # 2. Get object field names and type names
  var obj = T()
  var objAny = obj.toAny
  for fieldName, value in obj.fieldPairs:
    # 3. Lookup envaironment variables
    let envName = envPrefix & "_" & fieldName.camelCaseToUpperSnakeCase
    #debugEcho "envName: " & envName
    let envValue = getEnv(envName)

    if fieldName in requires and ((not existsEnv(envName)) or envValue == ""):
      raise newException(ValidationError, "'" & envName & "' environment variable doesn't exist. '" & fieldName & "' requires.")

    # NOTE: can not early return
    if envValue != "":
      # 4. Set value to object
      var v = envValue
      let vType = $value.type
      case vType
      of "string":
        validatePattern(fieldName, envName, regexps)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "bool":
        var v = parseBool(v)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "int":
        var v = parseInt(v)
        validateMin(int, fieldName, envName, mins)
        validateMax(int, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "int8":
        var v = parseInt(v).int8
        validateMin(int8, fieldName, envName, mins)
        validateMax(int8, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "int16":
        var v = parseInt(v).int16
        validateMin(int16, fieldName, envName, mins)
        validateMax(int16, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "int32":
        var v = parseInt(v).int32
        validateMin(int32, fieldName, envName, mins)
        validateMax(int32, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "int64":
        var v = parseInt(v).int64
        validateMin(int64, fieldName, envName, mins)
        validateMax(int64, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "uint":
        var v = parseUInt(v)
        validateMin(uint, fieldName, envName, mins)
        validateMax(uint, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "uint8":
        var v = parseUInt(v).uint8
        validateMin(uint8, fieldName, envName, mins)
        validateMax(uint8, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "uint16":
        var v = parseUInt(v).uint16
        validateMin(uint16, fieldName, envName, mins)
        validateMax(uint16, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "uint32":
        var v = parseUInt(v).uint32
        validateMin(uint32, fieldName, envName, mins)
        validateMax(uint32, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "uint64":
        var v = parseUInt(v).uint64
        validateMin(uint64, fieldName, envName, mins)
        validateMax(uint64, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "float":
        var v = parseFloat(v)
        validateMin(float, fieldName, envName, mins)
        validateMax(float, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "float32":
        var v = parseFloat(v).float32
        validateMin(float32, fieldName, envName, mins)
        validateMax(float32, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "float64":
        var v = parseFloat(v).float64
        validateMin(float64, fieldName, envName, mins)
        validateMax(float64, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "char":
        var v = v[0]
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "byte":
        var v = parseUInt(v).byte
        validateMin(byte, fieldName, envName, mins)
        validateMax(byte, fieldName, envName, maxs)
        var vAny = v.toAny
        objAny[fieldName] = vAny
      else:
        if vType.startsWith("seq"):
          let vType = vType[4..^2]
          var vs: seq[string]
          # TODO: validation
          for v in v.split(sep):
            vs.add(v)

          case vType
          of "string":
            objAny[fieldName] = vs.toAny
          of "bool":
            var vs = vs.mapIt(it.parseBool)
            objAny[fieldName] = vs.toAny
          of "int":
            var vs = vs.mapIt(it.parseInt)
            objAny[fieldName] = vs.toAny
          of "int8":
            var vs = vs.mapIt(it.parseInt.int8)
            objAny[fieldName] = vs.toAny
          of "int16":
            var vs = vs.mapIt(it.parseInt.int16)
            objAny[fieldName] = vs.toAny
          of "int32":
            var vs = vs.mapIt(it.parseInt.int32)
            objAny[fieldName] = vs.toAny
          of "int64":
            var vs = vs.mapIt(it.parseInt.int64)
            objAny[fieldName] = vs.toAny
          of "uint":
            var vs = vs.mapIt(it.parseUInt)
            objAny[fieldName] = vs.toAny
          of "uint8":
            var vs = vs.mapIt(it.parseUInt.uint8)
            objAny[fieldName] = vs.toAny
          of "uint16":
            var vs = vs.mapIt(it.parseUInt.uint16)
            objAny[fieldName] = vs.toAny
          of "uint32":
            var vs = vs.mapIt(it.parseUInt.uint32)
            objAny[fieldName] = vs.toAny
          of "uint64":
            var vs = vs.mapIt(it.parseUInt.uint64)
            objAny[fieldName] = vs.toAny
          of "float":
            var vs = vs.mapIt(it.parseFloat)
            objAny[fieldName] = vs.toAny
          of "float32":
            var vs = vs.mapIt(it.parseFloat.float32)
            objAny[fieldName] = vs.toAny
          of "float64":
            var vs = vs.mapIt(it.parseFloat.float64)
            objAny[fieldName] = vs.toAny
          of "char":
            var vs = vs.mapIt(it[0])
            objAny[fieldName] = vs.toAny
          of "byte":
            var vs = vs.mapIt(it.parseUInt.byte)
            objAny[fieldName] = vs.toAny
          else:
            raiseAssert "not supported types: " & vType
        else:
          raiseAssert "not supported types: " & vType
  return obj
