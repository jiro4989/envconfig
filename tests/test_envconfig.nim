discard """
  output: '''
range error 1
range error 2
range error 3
value error 1
validation error 1
validation error 2
validation error 3
validation error 4
validation error 5
'''
"""

import os
include envconfig

doAssert "camelCase".camelCaseToUpperSnakeCase == "CAMEL_CASE"
doAssert "url".camelCaseToUpperSnakeCase == "URL"
doAssert "iPhone".camelCaseToUpperSnakeCase == "I_PHONE"
doAssert "env1".camelCaseToUpperSnakeCase == "ENV1"

block:
  type
    MyApp = object
      name, version, dir: string
      port: int
      dev: bool
      taxRate: float
  putEnv("MYAPP_NAME", "envconfig")
  putEnv("MYAPP_VERSION", "v1.0.0")
  putEnv("MYAPP_DIR", "/opt/envconfig")
  putEnv("MYAPP_PORT", "1234")
  putEnv("MYAPP_DEV", "true")
  putEnv("MYAPP_TAX_RATE", "0.08")
  doAssert getEnvConfig(MyApp) == MyApp(
    name: "envconfig",
    version: "v1.0.0",
    dir: "/opt/envconfig",
    port: 1234,
    dev: true,
    taxRate: 0.08,
    )

block:
  type
    MyApp = object
      name: string
  putEnv("MY_APP_NAME", "envconfig2")
  doAssert getEnvConfig(MyApp, "MY_APP") == MyApp(
    name: "envconfig2",
    )

block:
  type AllTypes = object
    s: string
    i1: int
    i2: int8
    i3: int16
    i4: int32
    i5: int64
    ui1: uint
    ui2: uint8
    ui3: uint16
    ui4: uint32
    ui5: uint64
    f1: float
    f2: float32
    f3: float64
    b: bool
    c: char
    bb: byte
  putEnv("ALLTYPES_S", "string")
  putEnv("ALLTYPES_I1", "1")
  putEnv("ALLTYPES_I2", "127")
  putEnv("ALLTYPES_I3", "32767")
  putEnv("ALLTYPES_I4", "2147483647")
  putEnv("ALLTYPES_I5", "9223372036854775807")
  putEnv("ALLTYPES_UI1", "1")
  putEnv("ALLTYPES_UI2", "255")
  putEnv("ALLTYPES_UI3", "65535")
  putEnv("ALLTYPES_UI4", "4294967295")
  putEnv("ALLTYPES_UI5", "18446744073709551615")
  putEnv("ALLTYPES_F1", "1.0")
  putEnv("ALLTYPES_F2", "2147483647.1")
  putEnv("ALLTYPES_F3", "9223372036854775807.1")
  putEnv("ALLTYPES_B", "true")
  putEnv("ALLTYPES_C", "a")
  putEnv("ALLTYPES_BB", "255")
  doAssert getEnvConfig(AllTypes) == AllTypes(
    s: "string",
    i1: 1,
    i2: 127'i8,
    i3: 32767'i16,
    i4: 2147483647'i32,
    i5: 9223372036854775807'i64,
    ui1: uint(1),
    ui2: 255'u8,
    ui3: 65535'u16,
    ui4: 4294967295'u32,
    ui5: 18446744073709551615'u64,
    f1: 1.0,
    f2: 2147483647.1'f32,
    f3: 9223372036854775807.1'f64,
    b: true,
    c: 'a',
    bb: 255.byte,
    )

block:
  type ArrayObj = object
    s: seq[string]
    i1: seq[int]
    i2: seq[int8]
    i3: seq[int16]
    i4: seq[int32]
    i5: seq[int64]
    ui1: seq[uint]
    ui2: seq[uint8]
    ui3: seq[uint16]
    ui4: seq[uint32]
    ui5: seq[uint64]
    f1: seq[float]
    f2: seq[float32]
    f3: seq[float64]
    b: seq[bool]
    c: seq[char]
    bb: seq[byte]
  putEnv("ARRAYOBJ_S", "string,string,string")
  putEnv("ARRAYOBJ_I1", "1,1,1")
  putEnv("ARRAYOBJ_I2", "127,127,127")
  putEnv("ARRAYOBJ_I3", "32767,32767,32767")
  putEnv("ARRAYOBJ_I4", "2147483647,2147483647,2147483647")
  putEnv("ARRAYOBJ_I5", "9223372036854775807,9223372036854775807,9223372036854775807")
  putEnv("ARRAYOBJ_UI1", "1,1,1")
  putEnv("ARRAYOBJ_UI2", "255,255,255")
  putEnv("ARRAYOBJ_UI3", "65535,65535,65535")
  putEnv("ARRAYOBJ_UI4", "4294967295,4294967295,4294967295")
  putEnv("ARRAYOBJ_UI5", "18446744073709551615,18446744073709551615,18446744073709551615")
  putEnv("ARRAYOBJ_F1", "1.0,1.0,1.0")
  putEnv("ARRAYOBJ_F2", "2147483647.1,2147483647.1,2147483647.1")
  putEnv("ARRAYOBJ_F3", "9223372036854775807.1,9223372036854775807.1,9223372036854775807.1")
  putEnv("ARRAYOBJ_B", "true,true,true")
  putEnv("ARRAYOBJ_C", "a,a,a")
  putEnv("ARRAYOBJ_BB", "255,255,255")
  doAssert getEnvConfig(ArrayObj) == ArrayObj(
    s: @["string", "string", "string"],
    i1: @[1, 1, 1],
    i2: @[127'i8, 127'i8, 127'i8],
    i3: @[32767'i16, 32767'i16, 32767'i16],
    i4: @[2147483647'i32, 2147483647'i32, 2147483647'i32],
    i5: @[9223372036854775807'i64, 9223372036854775807'i64,
        9223372036854775807'i64],
    ui1: @[uint(1), uint(1), uint(1)],
    ui2: @[255'u8, 255'u8, 255'u8],
    ui3: @[65535'u16, 65535'u16, 65535'u16],
    ui4: @[4294967295'u32, 4294967295'u32, 4294967295'u32],
    ui5: @[18446744073709551615'u64, 18446744073709551615'u64,
        18446744073709551615'u64],
    f1: @[1.0, 1.0, 1.0],
    f2: @[2147483647.1'f32, 2147483647.1'f32, 2147483647.1'f32],
    f3: @[9223372036854775807.1'f64, 9223372036854775807.1'f64,
        9223372036854775807.1'f64],
    b: @[true, true, true],
    c: @['a', 'a', 'a'],
    bb: @[255.byte, 255.byte, 255.byte],
    )

when NimMajor == 1 and NimMinor <= 2:
  type RangeDefect2 = RangeError
else:
  type RangeDefect2 = RangeDefect

block:
  type ErrorObj = object
    v: int8
  putEnv("ERROROBJ_V", "128")
  try: discard getEnvConfig(ErrorObj)
  except RangeDefect2: echo "range error 1"

block:
  type ErrorObj = object
    v: int16
  putEnv("ERROROBJ_V", "32768")
  try: discard getEnvConfig(ErrorObj)
  except RangeDefect2: echo "range error 2"

block:
  type ErrorObj = object
    v: int32
  putEnv("ERROROBJ_V", "2147483648")
  try: discard getEnvConfig(ErrorObj)
  except RangeDefect2: echo "range error 3"

block:
  type ErrorObj = object
    v: int64
  putEnv("ERROROBJ_V", "9223372036854775808")
  try: discard getEnvConfig(ErrorObj)
  except ValueError: echo "value error 1"

block:
  type ErrorObj2 = object
    v: uint8
  putEnv("ERROROBJ_V", "256")
  doAssert getEnvConfig(ErrorObj2).v == 0

block:
  type ErrorObj2 = object
    v: uint16
  putEnv("ERROROBJ_V", "65536")
  doAssert getEnvConfig(ErrorObj2).v == 0

block:
  type ErrorObj2 = object
    v: uint32
  putEnv("ERROROBJ_V", "4294967296")
  doAssert getEnvConfig(ErrorObj2).v == 0

block:
  type ErrorObj2 = object
    v: uint64
  putEnv("ERROROBJ_V", "18446744073709551616")
  doAssert getEnvConfig(ErrorObj2).v == 0

block:
  type ReqObj = object
    v: string
  putEnv("reqobj_V", "test")
  try: discard getEnvConfig(ReqObj, requires = @["v"])
  except ValidationError: echo "validation error 1"

block:
  type ReqObj2 = object
    v1: string
    v2: string
  putEnv("REQOBJ2_V1", "test")
  putEnv("REQOBJ3_V1", "")
  try: discard getEnvConfig(ReqObj2, requires = @["v2"])
  except ValidationError: echo "validation error 2"

block:
  type ValMinObj = object
    n: int
  putEnv("VALMINOBJ_N", "10")
  doAssert getEnvConfig(ValMinObj, mins = @[("n", 10.0)]).n == 10
  type ValMinObj2 = object
    n: int
  putEnv("VALMINOBJ2_N", "9")
  try: discard getEnvConfig(ValMinObj2, mins = @[("n", 10.0)])
  except ValidationError: echo "validation error 3"

block:
  type ValMaxObj = object
    n: int
  putEnv("VALMAXOBJ_N", "100")
  doAssert getEnvConfig(ValMaxObj, maxs = @[("n", 100.0)]).n == 100
  type ValMaxObj2 = object
    n: int
  putEnv("VALMAXOBJ2_N", "101")
  try: discard getEnvConfig(ValMaxObj2, maxs = @[("n", 100.0)])
  except ValidationError: echo "validation error 4"

block:
  type ValRegObj = object
    n: string
  putEnv("VALREGOBJ_N", "bdc")
  doAssert getEnvConfig(ValRegObj, regexps = @[("n", re"[bcd]{3}")]).n == "bdc"
  type ValRegObj2 = object
    n: string
  putEnv("VALREGOBJ2_N", "abc")
  try: discard getEnvConfig(ValRegObj2, regexps = @[("n", re"[bcd]{3}")])
  except ValidationError: echo "validation error 5"

block:
  type AllObj = object
    i: int
    user: string
    user2: string
  putEnv("ALLOBJ_I", "10")
  putEnv("ALLOBJ_USER", "john")
  putEnv("ALLOBJ_USER2", "bob")
  doAssert getEnvConfig(
    AllObj,
    mins = @[("i", 0.0)],
    maxs = @[("i", 20.0)],
    regexps = @[("user", re"(john|bob)"),
                ("user2", re"(john|bob)")]) == AllObj(
                  i: 10,
                  user: "john",
                  user2: "bob",
                  )

block:
  type EmptyObj = object
    s: string
    i: int
    i2: int
  putEnv("EMPTYOBJ_S", "")
  putEnv("EMPTYOBJ_I", "")
  # No env
  # putEnv("EMPTYOBJ_I2", "")
  doAssert getEnvConfig(EmptyObj) == EmptyObj()

block:
  # TODO: Need supporting ref object
  when false:
    type RefObj = ref object
      s: string
      i: int
    putEnv("REFOBJ_S", "hello")
    putEnv("REFOBJ_I", "123")
    doAssert getEnvConfig(RefObj)[] == RefObj(s: "hello", i: 123)[]
