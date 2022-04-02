# Project code style

This file includes code style references which can help when contributing to project.

## Documentation content

1. [Overview][1]
2. [Project structure][2]
    1. [Outer layer][2.1]
    2. [Inner layer][2.2]
    3. [Extensions][2.3]
    4. [Rakelib][2.4]
3. [Naming convention][3]
    1. [File naming][3.1]
    2. [Module naming][3.2]
    3. [Class naming][3.3]
    4. [Parameters naming][3.4]
    5. [Variables naming][3.5]
4. [Code semantics][4]
    1. [Define modules][4.1]
    2. [Define classes][4.2]
    3. [Define methods][4.3]
5. [Contributing][5]
    1. [Git commits][5.1]
    2. [Rubocop][5.2]
6. [TODO][6]
7. [License][7]

## Overview

This project will show patterns and tips to contribute in this project. Feel free to contribute there!

## Project structure

The project tree consists of several directories. Some of them are described at
RubyGems [documentation](https://guides.rubygems.org/make-your-own-gem/). See it for clearance.

Folder structure in the `lib` directory deserves special attention. There are two other folders there — `lib/extensions`
and `lib/genius`, the last of which is divided into two more layers - outer and inner. The `api.rb` file (referred as
the main file) acts as the outer layer, into which the entire interface is imported which is defined in inner layer
referred as `lib/genius/api` folder.

### Outer layer

As mentioned above, the outer layer consists of only one main file where other files are included. The file consists of
a main module and its submodule to preserve the structure of the project tree, as indicated in the
RubyGems [documentation](https://guides.rubygems.org/patterns/#consistent-naming). The other files act as a category for
the main module which is called `Genius`. Outer layer is stored in `lib/genius`

### Inner layer

The inner layer is a kind of bunch of interfaces and extensions (categories) for the main module. Each of the interface
is named after the resource in [Genius API documentation](https://docs.genius.com). Inner layer is stored
in `lib/genius/api`.

### Extensions

Extensions are the files which represents the methods which are used in a bunch of other methods in the inner layer.
This kind of interfaces were bundled in a separate folder for multiple reuse in other methods. They are not a part of
the `Genius` module interface, so it means that they are a category to other structures (`Hash`, `Object` or `String`
classes). Extensions are stored in `lib/extensions`.

### Rakelib

Rakelib is another sort of extensions but it is used for generating the documentation. Note that the files in this
directory are distributed under the BSD license!

## Naming convention

This paragraph will show the main conventions in naming of some structures or objects, such as files, classes, variables
to represent their semantics more clear.

### File naming

The files are named after the resource from the [Genius API documentation](https://docs.genius.com). File names should
not contain uppercase letters or contain non-letter characters except for the underscore. All files should be stored in
the [inner layer](https://github.com/unurgunite/genius-api/CODESTYLE.md#inner-layer).

### Module naming

Modules should be defined inside the `Genius` module — a top-level project module — and they should be named after the
filename where they defined.

### Class naming

For the most part, classes are used to represent errors and they are stored in the inner layers file — `api/errors.rb`.
Each of this classes must end with the word `Error`.

### Parameters naming

Parameters should be named as a keyword arguments. This rule does not apply to private methods.
See: [Style/OptionHash](https://www.rubydoc.info/github/bbatsov/RuboCop/RuboCop/Cop/Style/OptionHash)

### Variables naming

Variables should be named as in a style guide of the RuboCop.
See: [Naming/VariableName](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Naming/VariableName)

## Code semantics

This paragraph will show some of the style guides for defining some sorts of the structures.

### Define modules

All of the modules defined as a category for the main module `Genius`. For e.g., `Genius::Account`

```ruby
# lib/genius/api/account.rb
module Genius # :nodoc:
  module Account # :nodoc:
    # some interface
  end
end
```

Among other things, modules must have documentation on the top of them. Documentation should consist of a brief
description of the module, its semantics and the semantics of its interface - objects that the module uses, extensions,
etc. For e.g.,

```ruby
# This module reflects the structure of our world, consisting of a class of people and a class of animals.
module World
  class Animal # :nodoc:
    # some interface
  end

  class Human # :nodoc:
    # some interface
  end
end
```

If no documentation is attached to the module, then a special tag in the form of a comment should be placed next to its
name, indicating this — `# :nodoc:`. In instance,

```ruby

module A # :nodoc:
  # some interface
end
```

### Define classes

As mentioned above, classes are usually represents error objects. This classes should be stored in a separate file
— `lib/genius/errors.rb`, they must be inherited from the `Genius::Errors::GeniusExceptionSuperClass` which in turn is
inherited from `StandardError` and they must have at least two readable attributes — `:msg` and `:exception_type`.
Moreover, this constructor must invoke method `super(message)`. Declaration of more arguments for debugging or
additional info to represent while error raised is optional. An example interface logic for such a class would be as
follows:

```ruby

class SomeError < GeniusExceptionSuperClass # :nodoc:
  attr_reader :msg, :exception_type, :some_useful_argument

  # @param [String (frozen)] msg Exception message.
  # @param [String (frozen)] exception_type Exception type.
  # @param [String (frozen)] some_useful_argument Some useful stuff for debugging.
  # @return [String (frozen)]
  def initialize(msg: "Some error message.", exception_type: "some_exception_error", some_useful_argument: nil)
    super(message)
    @msg = msg + some_useful_argument
    @exception_type = exception_type
  end
end
```

As modules, classes must have documentation on top of them and if there is no documentation was attached (in instance,
if there is a category for built-in objects as `Hash` or `String` classes) there should be a special tag inside a
comment which should be placed next to the class name — `# :nodoc:`.

### Define methods

Methods, among other structures, must have at least some documentation, consisting of at least its signature, as well as
the arguments that the method takes. The documentation must be written in a specific syntax, according to
the [YARD documentation](https://www.rubydoc.info/gems/yard/file/docs/Tags.md). This rule is specific for methods inside
classes interface if they are object constructors, because they always point to the instance declaration, so they do not
require explicit specification of their signature at the top of the comments section. For this sort of methods the
return type can be omitted.

Required YARD tags to indicate and theirs abstract syntax:

- `@param [Class] param_name documentation.`
- `@raise [ExceptionClass] if something went wrong.`
- `@return [Class]`

Required YARD tags to indicate and theirs abstract syntax:

- `@example Example usage`
- `@option variable_name [Class] :option documentation.`
- `@see #method_name`

Example for regular singleton methods (inside modules)

```ruby

module M # :nodoc:
  module A # :nodoc:
    class << self
      # +M::A.foo+                                    -> Integer
      # 
      # @param [Integer] arg1 First integer argument.
      # @param [Integer] arg2 Second integer argument.
      # @raise [RuntimeError] if one of the argument is not an integer.
      # @return [Integer]
      def foo(arg1: nil, arg2: nil)
        unless arg1.is_a?(Integer) || arg2.is_a?(Integer)
          raise RuntimeError, 'Some error was raised'
        end
        arg1 + arg2
      rescue RuntimeError => e
        e.message
      end
    end
  end
end
```

Example for regular constructors.

```ruby

class SomeError < GeniusExceptionSuperClass # :nodoc:
  attr_reader :msg, :exception_type, :some_useful_argument

  # @param [String (frozen)] msg Exception message.
  # @param [String (frozen)] exception_type Exception type.
  # @param [String (frozen)] some_useful_argument Some useful stuff for debugging.
  # @return [String (frozen)]
  def initialize(msg: "Some error message.", exception_type: "some_exception_error", some_useful_argument: nil)
    super(message)
    @msg = msg + some_useful_argument
    @exception_type = exception_type
  end
end 
```

## Contributing

This section will demonstrate the rules for contributing in project

### Git commits

Git commits should clearly describe the purpose of your commit. For example, commits as _"Do smth"_ or _"Refactored some
files"_ do not actually represent theirs content. Commits as _"Refactored `README.md`"_ reflects theirs content, so it
will be unused to delve into the purpose of the commit most of the time.

### RuboCop

See: [RuboCop documentation](https://docs.rubocop.org/rubocop/index.html)
Before pushing, you must be sure that the code you write is correct, so it should always be formatted through a static
analyzer. Look towards the `rubocop -D` and `rubocop -A` commands.

## TODO

- [ ] Look at the documentation with fresh eyes
- [ ] Check the file for all sorts of errors

## License

The documentation is available as open source under the terms of
the [CC BY-SA 4.0 License](https://creativecommons.org/licenses/by-sa/4.0/)

![CC BY-SA 4.0](https://mirrors.creativecommons.org/presskit/buttons/88x31/svg/by-nc.svg)

[1]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#overview]

[2]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#project-structure]

[2.1]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#outer-layer]

[2.2]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#inner-layer]

[2.3]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#extensions]

[2.4]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#rakelib]

[3]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#naming-convention]

[3.1]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#file-naming]

[3.2]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#module-naming]

[3.3]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#class-naming]

[3.4]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#parameters-naming]

[3.5]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#variables-naming]

[4]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#code-semantics]

[4.1]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#define-modules]

[4.2]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#define-classes]

[4.3]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#define-methods]

[5]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#contributing]

[5.1]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#git-commits]

[5.2]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#rubocop]

[6]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#todo]

[7]:[https://github.com/unurgunite/genius-api/blob/master/CODESTYLE.md#license]
