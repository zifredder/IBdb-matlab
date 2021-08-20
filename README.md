# `IBdb-matlab`
API request handler for the [IBdb](https://insectbraindb.org).

### Getting started
##### Requirements
- (Optional) Become a member of the IBdb community and [request API usage permission](https://insectbraindb.org/app/about/api).
- (Required) MATLAB R2019a or newer
- (Optional) Login credential input dialog with [`passfield`](https://github.com/okomarov/passfield)
- (Required for some functions) [Python](https://python.org) (tested with version 3.9) and the [`requests`](https://docs.python-requests.org/) package.

##### Object construction and authentication
```
obj = IBdb; % create an IBdb object
```

During object construction, the user can authenticate for full API usage access in different ways. The easiest is providing a text file with the user's login credentials in the form `username,password` (single line, comma-delimited). If no file is provided, the user is prompted to type in their credentials. If this is aborted, no login is communicated with the data base; consequently, the user only has access to public API functions. This login process can be done without user interaction:
```
obj = IBdb('my_credentials_file.txt'); % provide the path to the credentials text file
obj = IBdb('Token asdf123'); % provide the TokenAuth string as acquired from the data base's Swagger UI
```

##### Make a request
Use a predefined function for a specific endpoint:
```
obj.neuron_get(111)
ans =
  struct with fields:

                        id: 111
        persistent_records: {["20.500.12158/NIN-0000111.1"]}
               uploaded_by: [1×1 struct]
                       nin: "NIN-0000111"
                 full_name: "sg-CPU1a-R2"
                      name: "CPU1a-R2"
                short_name: "CPU1a-R2"
                       sex: "UNKNOWN"
                       <...>
```

The same can be achieved by manually specifying request method and URL:
```
obj.request("get", "/neuron/111/");
```

Query parameters are (usually) passed as name value pairs to Matlab functions:
```
obj.neuron_query("short_name", "CPU1a-R2").id; % 111

% Add a neuron to the data base:
resp = obj.neuron_post("name", "test-asdf", "short_name", "test-asdf", "hemisphere", "u", "species", 9);
% And delete it:
obj.neuron_delete(resp.id);
```

### Notes
Just as the API itself, this repository is a beta version. The API and this repository are subject to continuous change; they are not maintained by the same person, so if API endpoints are changed, parts of this code will break.

Pull requests are welcome!

Enumeration input is designed to be convenient and robust. E. g., for "hemisphere", accepted values are "LEFT", "RIGHT", "UNPAIRED" (case sensitive). However, you can pass "r" as value for the "hemisphere" parameter in request functions; it will automatically be parsed as "RIGHT".

### Developer notes
- Use `string`s where possible, not `char`s.
- Use RESTful request method names in function signatures if possible. E. g., not `neuron_add()`, but `neuron_post()`.

###### Function argument validation
Consistently use `arguments` with name value pairs. This is convenient because the name value pairs can be easily passed as parameter pairs for requests after converting them with `namedargs2cell`. Downside: Name value pairs are always optional, so it has to be manually validated which name value pairs are required. Check out `IBdb.convertSchemaToArguments()` to save some time when writing new functions. There may be exceptions from this rule in cases where using `arguments` is unnecessary overload, e. g., when a function requires only one or two inputs that are both not directly passed as parameters to the data base.

Use query parameter names for MATLAB functions literally like they are accepted by the data base (with reasonable exceptions). One exception would e. g. be `POST`ing data associated to an existing neuron: `addDataToNeuron(neuron_id)` makes more sense (to me) than `addDataToNeuron('neuron', id, ...)`.

Concerning parameter validation: Validation in MATLAB functions could be skipped and handled by the data base. It is debatable which approach is better. Currently, there is quite some validation implemented in MATLAB, but this is subject to change.

Argument validation for parameters in requests: In the `arguments` block, use
- `arg {IBdb.mustBeEmptyOrScalarInteger}` for scalar integer input
- `arg string {IBdb.mustBeEmptyOrScalarText}` for string input
- `arg {IBdb.mustBeEmptyOrLogical}` for scalar boolean input
- `arg {mustBeInteger}` for integer array input
If you are absolutely sure that a parameter is mandatory for the request and therefore must not be empty, specifying the size with `arg (dim1,dim2) <class>` works, too.

###### Enumerations
`constant` properties that are enumeration like strings are spelled in UPPERCASE. These properties need not be defined manually: See `IBdb.convertSchemaEnumsToCode`.

Use custom validation functions to parse function input. Especially, use `validatestring` for enumeration strings, because this enables fuzzy string matching. Enclose these validation function calls in `if isfield(NameValue, '<parameter>') <...> end` blocks if the input parameter is required to be non-empty.

Resources:
- https://restfulapi.net/http-status-codes/
- https://insectbraindb.org/api/schema/swagger-ui/
- https://insectbraindb.org/api/schema/redoc/
- https://insectbraindb.org/documentation
- https://insectbraindb.org/app/forum
