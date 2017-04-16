# Application skeleton

### Loader
Service that load all skeleton services and classes.

### OperatingSystem
Class for detecting current OS.

### Service
Base service that provides functional-way execution and params validations.

### Concerns::StateMachine
Module that provides common state machine and state machine with multiple field states.

### Error
Base class for errors implementation. Errors requires:
- `column` - service attribute name;
- `error_type` - type of error;
- `options` - related to `error_type`.

### Error::Collection
Collection for errors that provides some additional methods.

### Error::Type
Class that contains constants of types of errors. Additional options for errors with different error types:

|Type        |Options                   |
|------------|--------------------------|
|BLANK       |---                       |
|INVALID_TYPE|`class_name` - valid class|
|NOT_INCLUDED|`in` - valid collection   |













