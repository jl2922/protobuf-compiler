start =
_ terms:((Message / Enum) _)* {
  var messages = [];
  var enums = [];
  for (var i = 0; i < terms.length; i++) {
    var term = terms[i][0];
    if (term._type == 'message') {
      messages.push(term);
    } else {
      enums.push(term);
    }
  }
  return {
    messages: messages,
    enums: enums
  };
}

Enum =
"enum" _ identifier:Identifier _ "{" _ terms:(Option _)* "}" {
  var options = [];
  for (var i = 0; i < terms.length; i++) {
    options.push(terms[i][0]);
  }
  return {
    enumName: identifier,
    options: options,
    _type: "enum"
  };
}

Option =
identifier:Identifier _ "=" _ index:Integer _ ";" {
  return {
    optionName: identifier,
    index: index,
    _type: "option"
  };
}

Message =
"message" _ identifier:Identifier _ "{" _ terms:((Field / ";") _)* "}" {
  var fields = [];
  for (var i = 0; i < terms.length; i++) {
    var field = terms[i][0];
    fields.push(field);
  }
  return {
    messageName: identifier,
    fields: fields,
    _type: "message"
  };
}

Identifier "identifier" =
[_a-zA-Z]+[_a-zA-Z0-9]* {
  return text();
}

Field "field" =
rule:FieldRule _ type:(PrimitiveType / Identifier) _
identifier:Identifier _ "=" _ index:Integer _ ";" {
  return {
    optional: rule == 'optional',
    repeated: rule == 'repeated',
    required: rule == 'required',
    fieldName: identifier,
    type: type,
    index: index,
    _type: "field"
  };
}

FieldRule "field rule" =
("optional" / "required" / "repeated")

PrimitiveType "primitive type"=
("string" / "int32" / "int64" / "bool" / "float" / "double")

Integer "integer" =
[0-9]+ { return parseInt(text(), 10); }

Whitespace "whitespace" =
[ \t\r\n]

_ "whitespaces" =
Whitespace*
