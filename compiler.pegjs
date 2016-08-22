{
  var template = `
(() => {
  var root = this;

  var protos = {};

  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = protos;
    }
    exports.proto = protos;
  } else {
    root.proto = protos;
  }

}
`;

  function makeInteger(o) {
    return parseInt(o.join(""), 10);
  }

  var toCamelCase = (string, capitializeInitial) => {
    capitializeInitial = !!capitializeInitial;
    string = string.replace(/\_(.)/g, function(match, p1) {
      return p1.toUpperCase();
    });
    if (capitializeInitial) {
      string = string.replace(/^(.)/, (match) => {
        return match.toUpperCase();
      });
    }
    return string;
  }
}

Expression = _ message:(Message _)* {
  var definitions = [];
  for (var i = 0; i < message.length; i++) {
    definitions.push(message[i][0]);
  }
  definitions = definitions.join('\n\n');
  var output = `
(() => {
  var root = this;

  var protos = {};

  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = protos;
    }
    exports.proto = protos;
  } else {
    root.proto = protos;
  }

  ${definitions}

}
  `;
  return output;
}

Message = "message" _ identifier:Identifier _ "{" _ rules:((Rule / ";") _)* "}" {
  var messageDefinition = `
  var ${identifier} = function() {};
  ${identifier}.Builder = function() {};
  ${identifier}.newBuilder = function() {
    return new ${identifier}.Builder;
  }
  `;
  for (var i = 0; i < rules.length; i++) {
    var rule = rules[i][0];
    if (rule[0] == ';') {
      continue; // Empty rule.
    }
    var ruleDefintion = `
  ${identifier}.Builder.prototype.${rule.setterName} = function(value) {
    this.${rule.identifier} = value;
    return this;
  };
    `;
    console.log(rule);
    messageDefinition += '\n' + ruleDefintion;
  }
  messageDefinition += `
  root.${identifier} = ${identifier};
  `;
  return messageDefinition;
}

Rule = ("optional" / "required" / "repeated") _ Type _ identifier:Identifier _ "=" _ index:Integer _ ";" {
  var lowerCamelCase = toCamelCase(identifier);
  var upperCamelCase = toCamelCase(identifier, true);
  return {
    identifier: lowerCamelCase,
    index: index,
    setterName: 'set' + upperCamelCase,
    getterName: 'set' + upperCamelCase,
    adderName: 'add' + upperCamelCase
  };
}

Type = ("string" / "int32" / "int64" / "bool" / "float" / "double") {
  return text();
}

Expression1
  = head:Term tail:(_ ("+" / "-") _ Term)* {
  var result = head, i;
  console.log(a);
  for (i = 0; i < tail.length; i++) {
    if (tail[i][1] === "+") { result += tail[i][3]; }
    if (tail[i][1] === "-") { result -= tail[i][3]; }
  }

  return template;
}

Term
  = head:Factor tail:(_ ("*" / "/") _ Factor)* {
  var result = head, i;

  for (i = 0; i < tail.length; i++) {
    if (tail[i][1] === "*") { result *= tail[i][3]; }
    if (tail[i][1] === "/") { result /= tail[i][3]; }
  }

  return result;
}

Factor
  = "(" _ expr:Expression _ ")" { return expr; }
/ Integer

Integer "integer"
  = [0-9]+ { return parseInt(text(), 10); }

Identifier "identifier" = [_a-zA-Z]+[_a-zA-Z0-9]* {
  return text();
}

_ "whitespace"
  = [ \t\n\r]*
