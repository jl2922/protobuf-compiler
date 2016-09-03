var nest = require('./nestProto');
const Message = nest.Message;

describe('nested protobuf', function() {
  it('should build a message with nested enum.', function() {
    var message = Message.newBuilder().setTitle('My title').setType(Message.Type.EMAIL).build();
    expect(message.getTitle()).toBe('My title');
    expect(message.getType()).toBe(Message.Type.EMAIL);
  });

  it('should build a message with nested submessages.', function() {
    var birthday = Message.Author.Date.newBuilder().setYear(2000).build();
    var author = Message.Author.newBuilder().setName("My name").setBirthday(birthday).build();
    var message = Message.newBuilder().setTitle("My title").addAuthor(author).build();
    expect(message.getAuthorList()[0].getName()).toBe("My name");
    expect(message.getAuthorList()[0].getBirthday().getYear()).toBe(2000);
  });

  it('should output to and reconstruct from json.', function() {
    var birthday = Message.Author.Date.newBuilder().setYear(2000).build();
    var author = Message.Author.newBuilder().setName("My name").setBirthday(birthday).build();
    var message = Message.newBuilder().setTitle("My title").addAuthor(author).build();
    var jsonExpected = '["My title",null,[["My name",[null,null,2000]]]]';
    expect(JSON.stringify(message)).toEqual(jsonExpected);
    var message2 = Message.newBuilder().fromJSON(jsonExpected).build();
    expect(message2.getTitle()).toBe('My title');
    expect(message2.getAuthorList()[0].getName()).toBe("My name");
    expect(message2.getAuthorList()[0].getBirthday().getYear()).toBe(2000);
  });
});