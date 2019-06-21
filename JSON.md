Puppet Strings JSON Data
========================

Puppet Strings can generate JSON to STDOUT with the `--format` option:
```shell
puppet strings generate --format json
```

Document Schema
===============

At the top level, there are nine arrays in the JSON document:

| Document Key      | Description                                                                   |
| ----------------- | ----------------------------------------------------------------------------- |
| puppet_classes    | The list of Puppet classes that were parsed.                                  |
| data_types        | The list of data types that were parsed.                                      |
| data_type_aliases | | The list of data types that were parsed.                                      |
| defined_types     | The list of defined types that were parsed.                                   |
| resource_types    | The list of resource types that were parsed.                                  |
| providers         | The list of resource providers that were parsed.                              |
| puppet_functions  | The list of Puppet functions (4.x, 4.x and Puppet language) that were parsed. |
| puppet_tasks      | The list of Puppet tasks that were parsed.                                    |
| puppet_plans      | The list of Puppet plans that were parsed.                                    |

Puppet Classes
--------------

Each entry in the `puppet_classes` list is an object with the following attributes:

| Attribute Key | Description                                           |
| ------------- | ----------------------------------------------------- |
| name          | The name of the Puppet class.                         |
| file          | The file defining the Puppet class.                   |
| line          | The line where the Puppet class is defined.           |
| inherits      | The name of the Puppet class the class inherits from. |
| docstring     | The *DocString* object for the class (see below).     |
| defaults      | The map of parameter names to default values.         |
| source        | The Puppet source code for the class.                 |

Data Types
----------

Each entry in the `data_types` list is an object with the following attributes:

| Attribute Key | Description                                                 |
| ------------- | ----------------------------------------------------------- |
| name          | The name of the data type.                                  |
| file          | The file defining the data type.                            |
| line          | The line where the data type is data.                       |
| docstring     | The *DocString* object for the data type (see below).       |
| defaults      | The map of parameter names to default values.               |
| source        | The ruby source code for the data type. (Not Implemented)   |

Data Type Aliases
-----------------

Each entry in the `data_type_aliases` list is an object with the following attributes:

| Attribute Key | Description                                                       |
| ------------- | ----------------------------------------------------------------- |
| name          | The name of the data type.                                        |
| file          | The file defining the data type.                                  |
| line          | The line where the data type is defined.                          |
| docstring     | The *DocString* object for the data type (see below).             |
| alias_of      | The actual type this is an alias of.                              |
| source        | The Puppet source code for the data type alias. (Not Implemented) |

Defined Types
-------------

Each entry in the `defined_types` list is an object with the following attributes:

| Attribute Key | Description                                              |
| ------------- | -------------------------------------------------------- |
| name          | The name of the defined type.                            |
| file          | The file defining the defined type.                      |
| line          | The line where the defined type is defined.              |
| docstring     | The *DocString* object for the defined type (see below). |
| defaults      | The map of parameter names to default values.            |
| source        | The Puppet source code for the defined type.             |

Resource Types
--------------

Each entry in the `resource_types` list is an object with the following attributes:

| Attribute Key | Description                                               |
| ------------- | --------------------------------------------------------- |
| name          | The name of the resource type.                            |
| file          | The file defining the resource type.                      |
| line          | The line where the resource type is defined.              |
| docstring     | The *DocString* object for the resource type (see below). |
| properties    | The list of properties for the resource type (see below). |
| parameters    | The list of parameters for the resource type (see below). |
| features      | The list of features for the resource type (see below).   |

Each entry in the `properties` list is an object with the following attributes:

| Attribute Key | Description                                             |
| ------------- | ------------------------------------------------------- |
| name          | The name of the property.                               |
| description   | The description of the property.                        |
| values        | The array of acceptable string values for the property. |
| aliases       | The map of new values aliased to existing values.       |
| isnamevar     | True if the property is a namevar or false if not.      |
| default       | The default value for the property.                     |

Each entry in the `parameters` list is an object with the following attributes:

| Attribute Key | Description                                              |
| ------------- | -------------------------------------------------------- |
| name          | The name of the parameter.                               |
| description   | The description of the parameter.                        |
| values        | The array of acceptable string values for the parameter. |
| aliases       | The map of new values aliased to existing values.        |
| isnamevar     | True if the parameter is a namevar or false if not.      |
| default       | The default value for the parameter.                     |

Each entry in the `features` list is an object with the following attributes:

| Attribute Key | Description                     |
| ------------- | ------------------------------- |
| name          | The name of the feature.        |
| description   | The description of the feature. |

Providers
---------

Each entry in the `providers` list is an object with the following attributes:

| Attribute Key | Description                                          |
| ------------- | ---------------------------------------------------- |
| name          | The name of the provider.                            |
| type_name     | The name of the resource type of the provider.       |
| file          | The file defining the provider.                      |
| line          | The line where the provider is defined.              |
| docstring     | The *DocString* object for the provider (see below). |
| confines      | The string map of confines for the provider.         |
| features      | The list of features implemented by the provider.    |
| defaults      | The list of lists of "default for" for the provider. |
| commands      | The string map of commands for the provider.         |

Puppet Functions
----------------

Each entry in the `puppet_functions` list is an object with the following attributes:

| Attribute Key | Description                                                                   |
| ------------- | ----------------------------------------------------------------------------- |
| name          | The name of the function.                                                     |
| file          | The file defining the function.                                               |
| line          | The line where the function is defined.                                       |
| type          | The function type (e.g. ruby3x, ruby4x, puppet).                              |
| signatures    | A list of Puppet signatures of the function, including overloads if present.  |
| docstring     | The *DocString* object for the function (see below).                          |
| defaults      | The map of parameter names to default values.                                 |
| source        | The source code for the function.                                             |

Puppet Tasks
------------

Each entry in the `puppet_tasks` list is an object with the following attributes:

| Attribute Key | Description                                                                   |
| ------------- | ----------------------------------------------------------------------------- |
| name          | The name of the task.                                                         |
| file          | The file defining the task.                                                   |
| line          | The line where the task is defined.                                           |
| docstring     | The *DocString* object for the task (see below).                              |
| source        | The source code for the task.                                                 |
| supports_noop | Whether the task supports noop mode                                           |
| input_method  | Maps to the `input_method` key in the task json                               |

Puppet Plans
------------

Each entry in the `puppet_plans` list is an object with the following attributes:

| Attribute Key | Description                                                                   |
| ------------- | ----------------------------------------------------------------------------- |
| name          | The name of the plan.                                                         |
| file          | The file defining the plan.                                                   |
| line          | The line where the plan is defined.                                           |
| docstring     | The *DocString* object for the plan (see below).                              |
| defaults      | The map of parameter names to default values.                                 |
| source        | The source code for the plan.                                                 |

Signature Objects
-----------------

The `signatures` key is a function-specific list containing an object for each signature of a
function. Each object includes the `signature` itself, as well as each of its `param` and `return`
tags. Puppet 4.x functions with overloads will contain multiple signatures, while other function
types will contain only one.

Each signature is represented as an object with the following attributes:

| Attribute Key | Description                                                                                        |
| ------------- | -------------------------------------------------------------------------------------------------- |
| signature     | The signature of the function.                                                                     |
| docstring     | The *DocString* object describing the signature, which includes `text`, `param` and `return` tags. |

DocString Objects
-----------------

For the above types, their docstrings are represented as an object with the following attributes:

| Attribute Key | Description                                         |
| ------------- | --------------------------------------------------- |
| text          | The textual part of the DocString.                  |
| tags          | The array of tag objects, if any are present.       |

Each entry in the `tags` list is an object with the following properties:

| Attribute Key | Description                                             |
| ------------- | ------------------------------------------------------- |
| tag_name      | The name of the tag (e.g. param, return, etc.).         |
| text          | The descriptive text of the tag.                        |
| types         | The array of types associated with the tag.             |
| name          | The name associated with the tag (e.g. parameter name). |

For Puppet 4.x functions with overloads, `overload` tags will contain three additional attributes:

| Attribute Key | Description                                     |
| ------------- | ----------------------------------------------- |
| signature     | The Puppet signature of the overload.           |
| docstring     | The *DocString* object describing the overload. |
| defaults      | The map of parameter names to default values.   |


Example JSON Document
---------------------

An example JSON document describing a Puppet class, defined type, resource type, provider, and Puppet functions:

```json
{
  "puppet_classes": [
    {
      "name": "foo",
      "file": "site.pp",
      "line": 5,
      "inherits": "foo::bar",
      "docstring": {
        "text": "A simple class.",
        "tags": [
          {
            "tag_name": "param",
            "text": "First param.",
            "types": [
              "Integer"
            ],
            "name": "param1"
          },
          {
            "tag_name": "param",
            "text": "Second param.",
            "types": [
              "Any"
            ],
            "name": "param2"
          },
          {
            "tag_name": "param",
            "text": "Third param.",
            "types": [
              "String"
            ],
            "name": "param3"
          }
        ]
      },
      "defaults": {
        "param3": "hi"
      },
      "source": "class foo(Integer $param1, $param2, String $param3 = hi) inherits foo::bar {\n}"
    }
  ],
  "defined_types": [
    {
      "name": "dt",
      "file": "site.pp",
      "line": 12,
      "docstring": {
        "text": "A simple defined type.",
        "tags": [
          {
            "tag_name": "param",
            "text": "First param.",
            "types": [
              "Integer"
            ],
            "name": "param1"
          },
          {
            "tag_name": "param",
            "text": "Second param.",
            "types": [
              "Any"
            ],
            "name": "param2"
          },
          {
            "tag_name": "param",
            "text": "Third param.",
            "types": [
              "String"
            ],
            "name": "param3"
          }
        ]
      },
      "defaults": {
        "param3": "hi"
      },
      "source": "define dt(Integer $param1, $param2, String $param3 = hi) {\n}"
    }
  ],
  "resource_types": [
    {
      "name": "database",
      "file": "database.rb",
      "line": 43,
      "docstring": {
        "text": "An example database server resource type."
      },
      "properties": [
        {
          "name": "ensure",
          "description": "What state the database should be in.",
          "values": [
            "present",
            "absent",
            "up",
            "down"
          ],
          "aliases": {
            "up": "present",
            "down": "absent"
          },
          "default": "up"
        },
        {
          "name": "file",
          "description": "The database file to use."
        },
        {
          "name": "log_level",
          "description": "The log level to use.",
          "values": [
            "debug",
            "warn",
            "error"
          ],
          "default": "warn"
        }
      ],
      "parameters": [
        {
          "name": "address",
          "description": "The database server name.",
          "isnamevar": true
        },
        {
          "name": "encryption_key",
          "description": "The encryption key to use."
        },
        {
          "name": "encrypt",
          "description": "Whether or not to encrypt the database.",
          "values": [
            "true",
            "false",
            "yes",
            "no"
          ],
          "default": "false"
        }
      ],
      "features": [
        {
          "name": "encryption",
          "description": "The provider supports encryption."
        }
      ]
    }
  ],
  "providers": [
    {
      "name": "linux",
      "type_name": "database",
      "file": "linux.rb",
      "line": 33,
      "docstring": {
        "text": "An example provider on Linux."
      },
      "confines": {
        "kernel": "Linux",
        "osfamily": "RedHat"
      },
      "features": [
        "implements_some_feature",
        "some_other_feature"
      ],
      "defaults": [
        [
          [
            "kernel",
            "Linux"
          ]
        ],
        [
          [
            "osfamily",
            "RedHat",
          ],
          [
            "operatingsystemmajrelease",
            "7"
          ]
        ]
      ],
      "commands": {
        "foo": "/usr/bin/foo"
      }
    }
  ],
  "puppet_functions": [
    {
      "name": "func",
      "file": "site.pp",
      "line": 20,
      "type": "puppet",
      "signatures": [
        {
          "signature": "func(Integer $param1, Any $param2, String $param3 = hi)",
          "docstring": {
            "text": "A simple function.",
            "tags": [
              {
                "tag_name": "param",
                "text": "First param.",
                "types": [
                  "Integer"
                ],
                "name": "param1"
              },
              {
                "tag_name": "param",
                "text": "Second param.",
                "types": [
                  "Any"
                ],
                "name": "param2"
              },
              {
                "tag_name": "param",
                "text": "Third param.",
                "types": [
                  "String"
                ],
                "name": "param3"
              },
              {
                "tag_name": "return",
                "text": "Returns nothing.",
                "types": [
                  "Undef"
                ]
              }
            ]
          }
        }
      ],
      "docstring": {
        "text": "A simple function.",
        "tags": [
          {
            "tag_name": "param",
            "text": "First param.",
            "types": [
              "Integer"
            ],
            "name": "param1"
          },
          {
            "tag_name": "param",
            "text": "Second param.",
            "types": [
              "Any"
            ],
            "name": "param2"
          },
          {
            "tag_name": "param",
            "text": "Third param.",
            "types": [
              "String"
            ],
            "name": "param3"
          },
          {
            "tag_name": "return",
            "text": "Returns nothing.",
            "types": [
              "Undef"
            ]
          }
        ]
      },
      "defaults": {
        "param3": "hi"
      },
      "source": "function func(Integer $param1, $param2, String $param3 = hi) {\n}"
    },
    {
      "name": "func3x",
      "file": "func3x.rb",
      "line": 1,
      "type": "ruby3x",
      "signatures": [
        {
          "signature": "func3x(String $first, Any $second)",
          "docstring": {
            "text": "An example 3.x function.",
            "tags": [
              {
                "tag_name": "param",
                "text": "The first parameter.",
                "types": [
                  "String"
                ],
                "name": "first"
              },
              {
                "tag_name": "param",
                "text": "The second parameter.",
                "types": [
                  "Any"
                ],
                "name": "second"
              },
              {
                "tag_name": "return",
                "text": "Returns nothing.",
                "types": [
                  "Undef"
                ]
              }
            ]
          }
        }
      ],
      "docstring": {
        "text": "An example 3.x function.",
        "tags": [
          {
            "tag_name": "param",
            "text": "The first parameter.",
            "types": [
              "String"
            ],
            "name": "first"
          },
          {
            "tag_name": "param",
            "text": "The second parameter.",
            "types": [
              "Any"
            ],
            "name": "second"
          },
          {
            "tag_name": "return",
            "text": "Returns nothing.",
            "types": [
              "Undef"
            ]
          }
        ]
      },
      "source": "Puppet::Parser::Functions.newfunction(:func3x, doc: <<-DOC\nAn example 3.x function.\n@param [String] first The first parameter.\n@param second The second parameter.\n@return [Undef] Returns nothing.\nDOC\n) do |*args|\nend"
    },
    {
      "name": "func4x",
      "file": "func4x.rb",
      "line": 11,
      "type": "ruby4x",
      "signatures": [
        {
          "signature": "func4x(Integer $param1, Any $param2, Optional[Array[String]] $param3)",
          "docstring": {
            "text": "The first overload.",
            "tags": [
              {
                "tag_name": "param",
                "text": "The first parameter.",
                "types": [
                  "Integer"
                ],
                "name": "param1"
              },
              {
                "tag_name": "param",
                "text": "The second parameter.",
                "types": [
                  "Any"
                ],
                "name": "param2"
              },
              {
                "tag_name": "param",
                "text": "The third parameter.",
                "types": [
                  "Optional[Array[String]]"
                ],
                "name": "param3"
              },
              {
                "tag_name": "return",
                "text": "Returns nothing.",
                "types": [
                  "Undef"
                ]
              }
            ]
          }
        },
        {
          "signature": "func4x(Boolean $param, Callable &$block)",
          "docstring": {
            "text": "The second overload.",
            "tags": [
              {
                "tag_name": "param",
                "text": "The first parameter.",
                "types": [
                  "Boolean"
                ],
                "name": "param"
              },
              {
                "tag_name": "param",
                "text": "The block parameter.",
                "types": [
                  "Callable"
                ],
                "name": "&block"
              },
              {
                "tag_name": "return",
                "text": "Returns a string.",
                "types": [
                  "String"
                ]
              }
            ]
          }
        }
      ],
      "docstring": {
        "text": "An example 4.x function.",
        "tags": [
          {
            "tag_name": "overload",
            "signature": "func4x(Integer $param1, Any $param2, Optional[Array[String]] $param3)",
            "docstring": {
              "text": "The first overload.",
              "tags": [
                {
                  "tag_name": "param",
                  "text": "The first parameter.",
                  "types": [
                    "Integer"
                  ],
                  "name": "param1"
                },
                {
                  "tag_name": "param",
                  "text": "The second parameter.",
                  "types": [
                    "Any"
                  ],
                  "name": "param2"
                },
                {
                  "tag_name": "param",
                  "text": "The third parameter.",
                  "types": [
                    "Optional[Array[String]]"
                  ],
                  "name": "param3"
                },
                {
                  "tag_name": "return",
                  "text": "Returns nothing.",
                  "types": [
                    "Undef"
                  ]
                }
              ]
            },
            "name": "func4x"
          },
          {
            "tag_name": "overload",
            "signature": "func4x(Boolean $param, Callable &$block)",
            "docstring": {
              "text": "The second overload.",
              "tags": [
                {
                  "tag_name": "param",
                  "text": "The first parameter.",
                  "types": [
                    "Boolean"
                  ],
                  "name": "param"
                },
                {
                  "tag_name": "param",
                  "text": "The block parameter.",
                  "types": [
                    "Callable"
                  ],
                  "name": "&block"
                },
                {
                  "tag_name": "return",
                  "text": "Returns a string.",
                  "types": [
                    "String"
                  ]
                }
              ]
            },
            "name": "func4x"
          }
        ]
      },
      "source": "Puppet::Functions.create_function(:func4x) do\n  # The first overload.\n  # @param param1 The first parameter.\n  # @param param2 The second parameter.\n  # @param param3 The third parameter.\n  # @return [Undef] Returns nothing.\n  dispatch :foo do\n    param          'Integer',       :param1\n    param          'Any',           :param2\n    optional_param 'Array[String]', :param3\n  end\n\n  # The second overload.\n  # @param param The first parameter.\n  # @param block The block parameter.\n  # @return [String] Returns a string.\n  dispatch :other do\n    param 'Boolean', :param\n    block_param\n  end\nend"
    }
  ],
  "puppet_tasks": [
    {
      "name": "(stdin)",
      "file": "(stdin)",
      "line": 0,
      "docstring": {
        "text": "Allows you to backup your database to local file.",
        "tags": [
          {
            "name": "database",
            "tag_name": "param",
            "text": "Database to connect to",
            "types": [
              "Optional[String[1]]"
            ]
          },
          {
            "name": "user",
            "tag_name": "param",
            "text": "The user",
            "types": [
              "Optional[String[1]]"
            ]
          },
          {
            "name": "password",
            "tag_name": "param",
            "text": "The password",
            "types": [
              "Optional[String[1]]"
            ]
          },
          {
            "name": "sql",
            "tag_name": "param",
            "text": "Path to file you want backup to",
            "types": [
              "String[1]"
            ]
          }
        ]
      },
      "source": "{\n  \"description\": \"Allows you to backup your database to local file.\",\n  \"input_method\": \"stdin\",\n  \"parameters\": {\n    \"database\": {\n      \"description\": \"Database to connect to\",\n      \"type\": \"Optional[String[1]]\"\n    },\n    \"user\": {\n      \"description\": \"The user\",\n      \"type\": \"Optional[String[1]]\"\n    },\n    \"password\": {\n      \"description\": \"The password\",\n      \"type\": \"Optional[String[1]]\"\n    },\n     \"sql\": {\n      \"description\": \"Path to file you want backup to\",\n      \"type\": \"String[1]\"\n    }\n  }\n}\n",
      "supports_noop": false,
      "input_method": "stdin"
    }
  ],
  "puppet_plans": [
    {
      "name": "plann",
      "file": "(stdin)",
      "line": 5,
      "docstring": {
        "text": "A simple plan.",
        "tags": [
          {
            "tag_name": "param",
            "text": "First param.",
            "types": [
              "String"
            ],
            "name": "param1"
          },
          {
            "tag_name": "param",
            "text": "Second param.",
            "types": [
              "Any"
            ],
            "name": "param2"
          },
          {
            "tag_name": "param",
            "text": "Third param.",
            "types": [
              "Integer"
            ],
            "name": "param3"
          }
        ]
      },
      "defaults": {
        "param3": "1"
      },
      "source": "plan plann(String $param1, $param2, Integer $param3 = 1) {\n}"
    }
  ]
}
```
