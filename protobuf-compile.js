#! /usr/bin/env node
const fs = require('fs');
const path = require('path');

const uglifyJS = require("uglify-js");
const changeCase = require('change-case');
const commandLineArgs = require('command-line-args');
const hogan = require('hogan.js');
const peg = require('pegjs');

const options = commandLineArgs([{name: 'input', type: String, defaultOption: true}]);

const loadFile = (filename) => {
  var filepath = path.resolve(__dirname, filename);
  return fs.readFileSync(filepath, 'utf-8');
};
const parser = peg.generate(loadFile('compiler.pegjs'));
const mainTemplate = hogan.compile(loadFile('templates/main.mustache'));
const enumPartial = hogan.compile(loadFile('templates/enum.mustache'));
const messagePartial = hogan.compile(loadFile('templates/message.mustache'));
const input = options['input'];

const compile = (inputFile) => {
  var outputFile = (() => {
    var inputPath = path.parse(inputFile);
    return path.format({
      dir: inputPath.dir,
      base: changeCase.camelCase(inputPath.name) + 'Proto.js',
    });
  })();

  var protoDefinition = fs.readFileSync(inputFile, 'utf-8');

  var AST = parser.parse(protoDefinition);

  // Insert camel case names and setter and getter for fields.
  var insert = function(messages) {
    for (var i = 0; i < messages.length; i++) {
      var message = messages[i];
      for (var j = 0; j < message.messageFields.length; j++) {
        var field = message.messageFields[j];
        var fieldName = field.fieldName;
        var camelCaseFieldName = changeCase.camelCase(fieldName);
        var pascalCaseName = changeCase.pascalCase(fieldName);
        field.camelCaseFieldName = camelCaseFieldName;
        field.adderName = 'add' + pascalCaseName;
        field.getterName = 'get' + pascalCaseName;
        field.setterName = 'set' + pascalCaseName;
      }
      insert(message.subMessages);
    }
  };
  insert(AST.messages);

  var jsProtoDefinition = mainTemplate.render(AST, {
    enumDefinition: enumPartial,
    messageDefinition: messagePartial
  });

  jsProtoDefinition = uglifyJS.minify(jsProtoDefinition, {
    fromString: true
  }).code;

  var banner = `/*! Compiled by protobuf-compiler on ${new Date()}. */\n`;
  jsProtoDefinition = banner + jsProtoDefinition;

  fs.writeFileSync(outputFile, jsProtoDefinition);
};

const compileDirectory = (directory) => {
  var files = fs.readdirSync(directory);
  var protoFilePattern = /.*.proto/;
  for (var i = 0; i < files.length; i++) {
    var file = files[i];
    if (protoFilePattern.test(file)) {
      compile(path.join(directory, file));
    }
  }
};

(() => {
  var stats = fs.statSync(input);
  if (stats.isFile()) {
    compile(input);
  } else if (stats.isDirectory()) {
    compileDirectory(input);
  } else {
    throw new Error('Illegal input argument.');
  }
})();