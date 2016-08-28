#! /usr/bin/env node
const fs = require('fs');
const path = require('path');

const uglifyJS = require("uglify-js");
const changeCase = require('change-case');
const commandLineArgs = require('command-line-args');
const hogan = require('hogan.js');
const peg = require('pegjs');

const options = commandLineArgs([{name: 'input', type: String, defaultOption: true}]);

const pegFile = path.resolve(__dirname, 'compiler.pegjs');
const templateFile = path.resolve(__dirname, 'template.mustache');
var template = hogan.compile(fs.readFileSync(templateFile, 'utf-8'));
var parser = peg.generate(fs.readFileSync(pegFile, 'utf-8'));

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
  for (var i = 0; i < AST.messages.length; i++) {
    var message = AST.messages[i];
    for (var j = 0; j < message.fields.length; j++) {
      var field = message.fields[j];
      var fieldName = field.fieldName;
      var camelCaseFieldName = changeCase.camelCase(fieldName);
      var pascalCaseName = changeCase.pascalCase(fieldName);
      field.camelCaseFieldName = camelCaseFieldName;
      field.adderName = 'add' + pascalCaseName;
      field.getterName = 'get' + pascalCaseName;
      field.setterName = 'set' + pascalCaseName;
    }
  }

  var jsProtoDefinition = template.render(AST);

  // jsProtoDefinition = uglifyJS.minify(jsProtoDefinition, {
  //   fromString: true
  // }).code;

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