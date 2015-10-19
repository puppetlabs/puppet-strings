The Strings JSON Interchange Schema
===================================

Strings has two flags used to emit json.
* `--emit-json $FILE` Saves json to a file.
* `--emit-json-stdout` Prints json on stdout.

Top Level Structure
-------------------

The json outputted by strings is a single object which has 4 keys representing
the different types of Puppet code and extension functions Strings reads. The
value for each key is a list of json objects representing each puppet class,
function, etc.
Here is an example of the top level structure:

```json
{

"defined_types": [...],

"puppet_classes": [...],

"puppet_functions": [...],

"puppet_types": [...],

"puppet_providers": [...]

}
```

Defined Types
-------------

Each defined type or puppet class object has the following properties and values:

* `name`: A string representing the name of the object.
* `file`: The file the object came from. A string.
* `line`: The line in the file the object came from. A number.
* `docstring`: A string. The docstring describing the object.
* `examples`: A list of strings representing the content of the examples in the
   docstring.
* `signatures`: A list of function signatures which may be supported by the
  object. Each function signature is a json object whose keys are the
  parameter names, and whose values are the types those parameters may take.
  This is extracted from the code itself.
* `parameters`: An object whose keys are the parameter names and whose values
  are the parameter's types or null if it has no types. This is extracted from
  the docstring.


Puppet Functions
----------------

Both puppet 4x and 3x functions are represented as json objects kept in the
`puppet_functions` list. Puppet 4x functions have every property that 3x
functions have, as well as a few extras.

Puppet 3x functions have:

* `name`: A string representing the name of the 
* `file`: The file the object came from. A string.
* `line`: The line in the file the object came from. A number.
* `docstring`: A string. The docstring describing our object.
* `function_api_version`: the number 3.
* `documented_params`: A object whose keys are the parameters which were
* documented and whose values are the types they may take, or null.
* `examples`: A list of strings representing the content of the examples in the
   docstring.

Puppet 4x functions have everything 3x functions do as well as:

* The `function_api_version` is the number 4, not 3 (surprise!).
* `signatures`: A list of function signatures which may be supported by the
  object. Each function signature is a json object whose keys are the parameter
  names, and whose values are the types those parameters may take. This is
  extracted from the code itself.

Puppet Types
------------

Each puppet type object has the following properties and values:

* `name`: A string representing the name of the object
* `file`: The file the object came from. A string.
* `line`: The line in the file the object came from. A number.
* `docstring`: A string. The docstring describing our object.
* `examples`: A list of strings representing the content of the examples in the
   docstring.
* `parameters`: A list of objects with the following shape:
    * `allowed_vales`: a list of strings representing the allowed values.
    * `default`: a string or null.
    * `docstring`: The docstring.
    * `name`: the parameter name.
* `properties`: A list of objects with a shape very similar to parameters but
  also including:
    * `namevar`: A boolean.
* `features`: A list of objects representing possible features. They have the
  following shape:
    * `docstring`: The description of the feature.
    * `methods`: null or a list of the available methods as strings.
    * `name`: The feature's name.

Puppet Providers
----------------
Each puppet provider object has the following properties and values:

* `name`: A string representing the name of the object
* `file`: The file the object came from. A string.
* `line`: The line in the file the object came from. A number.
* `docstring`: A string. The docstring describing the object.
* `examples`: A list of strings representing the content of the examples in the
   docstring.
* `commands`: A list of the names of the commands available.
* `confines`: An object whose keys are the confine keys and whose values are
  the confine values.
* `defaults`: Similar to above.
* `features`: A list of strings representing the features this provider
  supports.
* `type_name`: The type this provider accompanies.
