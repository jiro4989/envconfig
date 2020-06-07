## envconfig provides a function to get config objects from environment variables.
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

template validateAndSetField =
  validateMin(v.typedesc, fieldName, envName, mins)
  validateMax(v.typedesc, fieldName, envName, maxs)
  var vAny = v.toAny
  objAny[fieldName] = vAny

proc getEnvConfig*(T: typedesc, prefix = "", sep = ",",
                   requires: seq[string] = @[],
                   mins: seq[tuple[name: string, val: float64]] = @[],
                   maxs: seq[tuple[name: string, val: float64]] = @[],
                   regexps: seq[tuple[name: string, val: Regex]] = @[],
                   ): T =
  ## Returns a object that values were set to fields by environment variables.
  ## This proc lookups environment variables with UPPERCASE object name (`T`)
  ## and UPPER_SNAKE_CASE object field names.
  ##
  ## A prefix of environment variables is UPPERCASE object name (`T`).
  ## You set `prefix` if you want to change a prefix of environment variables.
  ##
  ## This proc splits values with `sep` if the type of field is `seq`.
  ##
  ## .. code-block:: Bash
  ##    export FLUITS="apple,banana,orange"
  ##    # -> @["apple", "banana", "orange"]
  ##
  ## You can validate values with `requires`, `mins`, `maxs`, `regexps`.
  ##
  ## * `requires` - Environment variables must be set and must be not empty
  ##   value.
  ## * `mins` - Environment variables must not be less than `val` of each items
  ##   of seq.
  ## * `maxs` - Environment variables must not be greater than `val` of each
  ##   items of seq.
  ## * `regexps` - Environment variables must regex-match `val` of each items
  ##   of seq.
  ##
  ## **Avairable field types:**
  ##
  ## * `string`, `bool`, `int`, `int8`, `int16`, `int32`, `int64`, `uint`, `uint8`, `uint16`, `uint32`, `uint64`, `float`, `float32`, `float64`, `char`, `byte`
  ## * `seq[string]`, `seq[bool]`, `seq[int]`, `seq[int8]`, `seq[int16]`, `seq[int32]`, `seq[int64]`, `seq[uint]`, `seq[uint8]`, `seq[uint16]`, `seq[uint32]`, `seq[uint64]`, `seq[float]`, `seq[float32]`, `seq[float64]`, `seq[char]`, `seq[byte]`
  ##
  ## **Raises errors:**
  ##
  ## * `ValidationError <#ValidationError>`_ - Raises this error if set value
  ##   (not integer) to int field. Raises that if value type is float, uint and
  ##   bool. Raises that if value range is not matched `requires`, `mins`,
  ##   `maxs`, `regexps`.
  ##
  ## **Note:**
  ##
  ## * ``array`` type is not supported.
  ## * ``ref object`` type is not supported.
  runnableExamples:
    from os import putEnv

    type
      MyApp = object
        name: string
        num: int
        devMode: bool
        fluits: seq[string]

    putEnv("MYAPP_NAME", "myapp")
    putEnv("MYAPP_NUM", "5")
    putEnv("MYAPP_DEV_MODE", "true")
    putEnv("MYAPP_FLUITS", "apple,banana,orange")

    let config = getEnvConfig(
      MyApp,
      requires = @["name", "num", "devMode", "fluits"],
      mins = @[("num", 0.0)],
      maxs = @[("num", 10.0)],
      )

    doAssert config.name == "myapp"
    doAssert config.num == 5
    doAssert config.devMode
    doAssert config.fluits == @["apple", "banana", "orange"]

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
        validateAndSetField()
      of "int8":
        var v = parseInt(v).int8
        validateAndSetField()
      of "int16":
        var v = parseInt(v).int16
        validateAndSetField()
      of "int32":
        var v = parseInt(v).int32
        validateAndSetField()
      of "int64":
        var v = parseInt(v).int64
        validateAndSetField()
      of "uint":
        var v = parseUInt(v)
        validateAndSetField()
      of "uint8":
        var v = parseUInt(v).uint8
        validateAndSetField()
      of "uint16":
        var v = parseUInt(v).uint16
        validateAndSetField()
      of "uint32":
        var v = parseUInt(v).uint32
        validateAndSetField()
      of "uint64":
        var v = parseUInt(v).uint64
        validateAndSetField()
      of "float":
        var v = parseFloat(v)
        validateAndSetField()
      of "float32":
        var v = parseFloat(v).float32
        validateAndSetField()
      of "float64":
        var v = parseFloat(v).float64
        validateAndSetField()
      of "char":
        var v = v[0]
        var vAny = v.toAny
        objAny[fieldName] = vAny
      of "byte":
        var v = parseUInt(v).byte
        validateAndSetField()
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
