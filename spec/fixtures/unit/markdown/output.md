# Reference

## Classes
* [`klass`](#klass): A simple class.
* [`noparams`](#noparams): Overview for class noparams
* [`noparams_desc`](#noparams_desc): 
## Defined types
* [`klass::dt`](#klassdt): A simple defined type.
## Resource types
* [`apt_key`](#apt_key): Example resource type using the new API.
* [`database`](#database): An example database server type.
## Functions
* [`func`](#func): A simple Puppet function.
* [`func3x`](#func3x): Documentation for an example 3.x function.
* [`func4x`](#func4x): An example 4.x function.
* [`func4x_1`](#func4x_1): An example 4.x function with only one signature.
## Classes

### klass

An overview for a simple class.

* **Since** 1.0.0

* **See also**
www.puppet.com


#### Examples
##### This is an example
```puppet
class { 'klass':
  param1 => 1,
  param3 => 'foo',
}
```

##### This is another example
```puppet
class { 'klass':
  param1 => 1,
  param3 => 'foo',
}
```


#### Parameters

The following parameters are available in the `klass` class.

##### `param1`

Data type: `Integer`

First param.

Default value: 1

##### `param2`

Data type: `Any`

Second param.

Options:

* **:opt1** `String`: something about opt1
* **:opt2** `Hash`: a hash of stuff

Default value: `undef`

##### `param3`

Data type: `String`

Third param.

Default value: 'hi'


### noparams

Overview for class noparams


### noparams_desc

The noparams_desc class.


## Defined types

### klass::dt

An overview for a simple defined type.

* **Since** 1.1.0

* **See also**
www.puppet.com


#### Examples
##### Here's an example of this type:
```puppet
klass::dt { 'foo':
  param1 => 33,
  param4 => false,
}
```


#### Parameters

The following parameters are available in the `klass::dt` defined type.

##### `param1`

Data type: `Integer`

First param.

Default value: 44

##### `param2`

Data type: `Any`

Second param.

Options:

* **:opt1** `String`: something about opt1
* **:opt2** `Hash`: a hash of stuff

##### `param3`

Data type: `String`

Third param.

Default value: 'hi'

##### `param4`

Data type: `Boolean`

Fourth param.

Default value: `true`


## Resource types

### apt_key

This type provides Puppet with the capabilities to manage GPG keys needed
by apt to perform package validation. Apt has it's own GPG keyring that can
be manipulated through the `apt-key` command.
**Autorequires**:
If Puppet is given the location of a key file which looks like an absolute
path this type will autorequire that file.

#### Examples
##### here's an example
```puppet
apt_key { '6F6B15509CF8E59E6E469F327F438280EF8D349F':
  source => 'http://apt.puppetlabs.com/pubkey.gpg'
}
```

#### Properties

The following properties are available in the `apt_key` type.

##### `ensure`

Data type: `Enum[present, absent]`

Whether this apt key should be present or absent on the target system.

##### `created`

Data type: `String`

Date the key was created, in ISO format.

#### Parameters

The following parameters are available in the `apt_key` type.

##### `id`

namevar

Data type: `Variant[Pattern[/A(0x)?[0-9a-fA-F]{8}Z/], Pattern[/A(0x)?[0-9a-fA-F]{16}Z/], Pattern[/A(0x)?[0-9a-fA-F]{40}Z/]]`
_*this data type contains a regex that may not be accurately reflected in generated documentation_

The ID of the key you want to manage.


### database

An example database server type.

#### Examples
##### here's an example
```puppet
database { 'foo':
  address => 'qux.baz.bar',
}
```

#### Properties

The following properties are available in the `database` type.

##### `ensure`

Valid values: present, absent, up, down

Aliases: "up"=>"present", "down"=>"absent"

What state the database should be in.

Default value: up

##### `file`

The database file to use.

##### `log_level`

Valid values: debug, warn, error

The log level to use.

Default value: warn

#### Parameters

The following parameters are available in the `database` type.

##### `address`

namevar

The database server name.

##### `encryption_key`

The encryption key to use.

##### `encrypt`

Valid values: `true`, `false`, yes, no

Whether or not to encrypt the database.

Default value: `false`


## Functions

### func
Type: Puppet Language

A simple Puppet function.

#### `func(Integer $param1, Any $param2, String $param3 = hi)`

A simple Puppet function.

Returns: `Undef` Returns nothing.

Raises:
* `SomeError` this is some error

##### `param1`

Data type: `Integer`

First param.

##### `param2`

Data type: `Any`

Second param.

##### `param3`

Data type: `String`

Third param.

Options:

* **:param3opt** `Array`: Something about this option

### func3x
Type: Ruby 3.x API

Documentation for an example 3.x function.

#### `func3x(String $param1, Integer $param2)`

Documentation for an example 3.x function.

Returns: `Undef`

##### `param1`

Data type: `String`

The first parameter.

##### `param2`

Data type: `Integer`

The second parameter.

### func4x
Type: Ruby 4.x API

An example 4.x function.

#### `func4x(Integer $param1, Any $param2, Optional[Array[String]] $param3)`

An overview for the first overload.

Returns: `Undef` Returns nothing.

##### `param1`

Data type: `Integer`

The first parameter.

##### `param2`

Data type: `Any`

The second parameter.

Options:

* **:option** `String`: an option
* **:option2** `String`: another option

##### `param3`

Data type: `Optional[Array[String]]`

The third parameter.

#### `func4x(Boolean $param, Callable &$block)`

An overview for the second overload.

Returns: `String` Returns a string.

##### `param`

Data type: `Boolean`

The first parameter.

##### `&block`

Data type: `Callable`

The block parameter.

### func4x_1
Type: Ruby 4.x API

An example 4.x function with only one signature.

#### `func4x_1(Integer $param1)`

An example 4.x function with only one signature.

Returns: `Undef` Returns nothing.

##### `param1`

Data type: `Integer`

The first parameter.

