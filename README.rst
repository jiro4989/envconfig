#########
envconfig
#########

|nimble-version| |nimble-install| |nimble-docs| |gh-actions|

envconfig provides a function to get config objects from environment variables.
envconfig is inspired by `Go envconfig <https://github.com/kelseyhightower/envconfig>`_.

.. contents:: Table of contents
   :depth: 3

************
Installation
************

.. code-block:: Bash

   nimble install envconfig

*****
Usage
*****

-----
Basic
-----

Example that setting environment variables with shell.

.. code-block:: Bash

   export MYAPP_NAME=envconfig
   export MYAPP_VERSION=v1.0.0
   export MYAPP_DIR=/opt/envconfig
   export MYAPP_PORT=1234
   export MYAPP_DEV=true

.. code-block:: Nim

   import envconfig

   type
     MyApp = object
       name, version, dir: string
       port: int
       dev: bool

   let config = getEnvConfig(MyApp)

   echo "MYAPP_NAME: " & config.name       # envconfig
   echo "MYAPP_VERSION: " & config.version # v1.0.0
   echo "MYAPP_DIR: " & config.dir         # /opt/envconfig
   echo "MYAPP_PORT: " & $config.port      # 1234
   echo "MYAPP_DEV: " & $config.dev        # true

Example that setting environment variables with Nim.

.. code-block:: Nim

  import envconfig
  from os import putEnv

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

  echo "MYAPP_NAME: " & config.name       # envconfig
  echo "MYAPP_VERSION: " & config.version # v1.0.0
  echo "MYAPP_DIR: " & config.dir         # /opt/envconfig
  echo "MYAPP_PORT: " & $config.port      # 1234
  echo "MYAPP_DEV: " & $config.dev        # true

----------
Validation
----------

Provides tiny functions to validate values.
A procedure can validate `requires`, `min value`, `max value` and `regex match`.
For more informations, see also `API documents <https://jiro4989.github.io/envconfig/envconfig.html>`_.

*************
API Documents
*************

* `envconfig <https://jiro4989.github.io/envconfig/envconfig.html>`_

*******
LICENSE
*******

MIT

.. |nimble-version| image:: https://nimble.directory/ci/badges/envconfig/version.svg
   :target: https://nimble.directory/ci/badges/envconfig/nimdevel/output.html
.. |nimble-install| image:: https://nimble.directory/ci/badges/envconfig/nimdevel/status.svg
   :target: https://nimble.directory/ci/badges/envconfig/nimdevel/output.html
.. |nimble-docs| image:: https://nimble.directory/ci/badges/envconfig/nimdevel/docstatus.svg
   :target: https://nimble.directory/ci/badges/envconfig/nimdevel/doc_build_output.html
.. |gh-actions| image:: https://github.com/jiro4989/envconfig/workflows/build/badge.svg
   :target: https://github.com/jiro4989/envconfig/actions
