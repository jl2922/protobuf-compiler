{
  const EntityType = {
    ENUM: 100,
    ENUM_FIELD: 101,
    MESSAGE: 200,
    MESSAGE_FIELD: 201,
    PACKAGE: 300
  };
}

Protobuf "protobuf" =
_ entities:((Package / Message / Enum / Comment) _)* {
  var messages = [];
  var enums = [];
  var protoPackage;
  for (var i = 0; i < entities.length; i++) {
    var entity = entities[i][0];
    switch (entity._type) {
      case EntityType.PACKAGE:
        protoPackage = entity;
        break;
      case EntityType.MESSAGE:
        messages.push(entity);
        break;
      case EntityType.ENUM:
        enums.push(entity);
        break;
      default:
        // Do nothing.
    }
  }
  return {
    package: protoPackage,
    messages: messages,
    enums: enums
  };
}

Package "package" =
"package" _ name:PackageName _ ';' {
  return {
    packageName: name,
    isPackage: true,
    _type: EntityType.PACKAGE
  }
}

PackageName "package name" =
root:Identifier nodes:('.' Identifier)* {
  var packageName = [root];
  for (var i = 0; i < nodes.length; i++) {
    packageName.push(nodes[i][1]);
  }
  return packageName;
}

Enum "enum" =
"enum" _ name:Identifier _ "{" _ entities:((EnumField / Comment) _)* "}" {
  var fields = [];
  for (var i = 0; i < entities.length; i++) {
    var entity = entities[i][0];
    if (entity._type != EntityType.ENUM_FIELD) {
      continue;
    }
    fields.push(entity);
  }
  return {
    enumName: name,
    enumFields: fields,
    isEnum: true,
    _type: EntityType.ENUM
  };
}

EnumField "enum field" =
name:Identifier _ "=" _ tag:Integer _ ";" {
  return {
    fieldName: name,
    fieldTag: tag,
    isEnumField: true,
    _type: EntityType.ENUM_FIELD
  };
}

Message =
"message" _ name:Identifier _ "{" _ entities:(MessageBodyEntity _)* "}" {
  var fields = [];
  var subEnums = [];
  var subMessages = [];
  for (var i = 0; i < entities.length; i++) {
    var entity = entities[i][0];
    switch (entity._type) {
      case EntityType.MESSAGE_FIELD:
        fields.push(entity);
        break;
      case EntityType.ENUM:
        subEnums.push(entity);
        break;
      case EntityType.MESSAGE:
        subMessages.push(entity);
        break;
    }
  }
  return {
    messageName: name,
    messageFields: fields,
    subEnums: subEnums,
    subMessages: subMessages,
    isMessage: true,
    _type: EntityType.MESSAGE
  };
}

MessageBodyEntity "message body entity" =
entity:(MessageField / Enum / Message / Comment / ";") {
  return entity;
}

MessageField "message field" =
rule:FieldRule _ type:Identifier _ name:Identifier _ "=" _ tag:Integer _ ";" {
  return {
    fieldRule: rule,
    isOptional: rule == 'optional',
    isRequired: rule == 'required',
    isRepeated: rule == 'repeated',
    fieldType: type,
    fieldName: name,
    fieldTag: tag,
    isMessageField: true,
    _type: EntityType.MESSAGE_FIELD
  };
}

FieldRule "field rule" =
("optional" / "required" / "repeated") {
  return text();
}

Comment "comment" =
(SingleLineComment / MultipleLinesComment)

SingleLineComment "single line comment" =
"//" (!LineTerminator .)*

MultipleLinesComment "multiple lines comment" =
"/*" (!"*/" .)* "*/"

LineTerminator "line terminator" =
[\r\n]

Identifier "identifier" =
[_a-zA-Z]+[_a-zA-Z0-9]* {
  return text();
}

Integer "integer" =
[0-9]+ {
  return parseInt(text(), 10);
}

Whitespace "whitespace" =
[ \t\r\n]

_ "whitespaces" =
Whitespace*
