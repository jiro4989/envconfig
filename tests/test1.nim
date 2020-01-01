import unittest, os

include envconfig

suite "proc camelCaseToUpperSnakeCase":
  test "camelCase":
    check "camelCase".camelCaseToUpperSnakeCase == "CAMEL_CASE"
  test "url":
    check "url".camelCaseToUpperSnakeCase == "URL"
  test "iPhone":
    check "iPhone".camelCaseToUpperSnakeCase == "I_PHONE"
  test "env1":
    check "env1".camelCaseToUpperSnakeCase == "ENV1"

suite "proc getObjectFieldNamesAndTypeNames":
  setup:
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

    putEnv("MY_APP_NAME", "envconfig2")
  teardown:
    delEnv("MYAPP_NAME")
    delEnv("MYAPP_VERSION")
    delEnv("MYAPP_DIR")
    delEnv("MYAPP_PORT")
    delEnv("MYAPP_DEV")
    delEnv("MYAPP_TAX_RATE")

    delEnv("MY_APP_NAME")
  test "simple object":
    check getEnvObject[MyApp]() == MyApp(
      name: "envconfig",
      version: "v1.0.0",
      dir: "/opt/envconfig",
      port: 1234,
      dev: true,
      taxRate: 0.08,
      )
  test "env prefix is MY_APP":
    check getEnvObject[MyApp]("MY_APP") == MyApp(
      name: "envconfig2",
      )
