var basic = require('./basicProto');
const Message = basic.Message;
const Type = basic.Type;
const Author = basic.Author;

describe('basic protobuf', function() {
  it('should build a message from a basic proto.', function() {
    var builder = Message.newBuilder();
    var author = Author.newBuilder().setName('My Name').build();
    builder.setTitle('My title').setContent('My content').addAuthor(author).setType(Type.EMAIL);
    var message = builder.build();
    expect(message.getTitle()).toBe('My title');
    expect(message.getContent()).toBe('My content');
    expect(message.getAuthorList()[0].getName()).toBe('My Name');
    expect(message.getType()).toBe(Type.EMAIL);
  });

  it('should throw error when requirement not met.', function() {
    var buildMessage = function() {
      var message = Message.newBuilder().build();
    };
    expect(buildMessage).toThrowError("title is required.");
  });

  it('should parse and return the correct message from JSON.', function() {
    var message = Message.newBuilder().fromJSON('["My title", "My content", [["My name"]], 1]').build();
    expect(message.getTitle()).toBe('My title');
    expect(message.getContent()).toBe('My content');
    expect(message.getAuthorList()[0].getName()).toBe('My name');
    expect(message.getType()).toBe(Type.EMAIL);
  });

  it('should output the expected JSON.', function() {
    var author = Author.newBuilder().setName('My name').build();
    var message =
      Message.newBuilder().setTitle('My title').setContent('My content').addAuthor(author).setType(Type.EMAIL).build();
    expect(JSON.stringify(message)).toEqual('["My title","My content",[["My name"]],1]');
  });
});