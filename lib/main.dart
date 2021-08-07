import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'filesystem.dart';

file f = file();
void main() {
  runApp(FriendlyChatApp());
}

class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FriendlyChat',
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.cyan,
  accentColor: Colors.cyanAccent,
);

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  _ChatScreenState() {}
  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isComposing = false;
  void initState() {
    super.initState();
    final Future myFuture = f.start();
    myFuture.then((value) => fill());
  }

  void fill() {
    List<String> texts = f.get();
    print("this is texts: $texts");
    for (int i = 0; i < texts.length; i++) {
      _textController.clear();
      setState(() {
        _isComposing = false;
      });
      var message = ChatMessage(
        text: texts[i],
        name: "You",
        symbol: "+",
        animationController: AnimationController(
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 200),
          vsync: this,
        ),
      );
      setState(() {
        _messages.insert(0, message);
      });
      _focusNode.requestFocus();
      message.animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyTodoList', style: TextStyle(color: Colors.white)),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: _clearAll,
        child: const Icon(
          Icons.delete_forever,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) {
                  return GestureDetector(
                      onDoubleTap: () {
                        _clear(index);
                      },
                      child: _messages[index]);
                },
                itemCount: _messages.length,
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration.collapsed(hintText: 'Send a message'),
              focusNode: _focusNode,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            child: Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoButton(
                    child: Text('Send'),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(_textController.text)
                        : null,
                  )
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(_textController.text)
                        : null,
                  ),
          )
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) {
      _handleSubmittedSystem("You can't enter an empty note!", "System", "!");
      _messages[0].animationController
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              setState(() {
                _clear(0);
                f.saveFile(_messages);
              });
            });
          }
        });
      return;
    }
    f.addToFile(text);
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    var message = ChatMessage(
      text: text,
      name: "You",
      symbol: "+",
      animationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 250),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    _focusNode.requestFocus();
    message.animationController.forward();
  }

  void _handleSubmittedSystem(String text, String name, String symbol) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    var message = ChatMessage(
      text: text,
      name: name,
      symbol: symbol,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    _focusNode.requestFocus();
    message.animationController.forward();
  }

  void _clearAll() {
    if (_messages.isEmpty) {
      _handleSubmittedSystem("No messages to delete!", "System", "!");
      _messages[0].animationController
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              setState(() {
                _clear(0);
                f.saveFile(_messages);
              });
            });
          }
        });
      return;
    }
    for (int i = _messages.length - 1; i >= 0; i--) {
      _messages[i].animationController.reverse();
      _messages[i].animationController
        ..addStatusListener((status) {
          if (status == AnimationStatus.dismissed) {
            setState(() {
              _messages.removeAt(i);
            });
          }
        });
    }
    f.saveFile(_messages);
  }

  void _clear(int index) {
    if (_messages.isEmpty) {
      _handleSubmittedSystem("No messages to delete!", "System", "!");
      _messages[0].animationController
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              setState(() {
                _clear(index);
                f.saveFile(_messages);
              });
            });
          }
        });
      return;
    }
    _messages[index].animationController.reverse();
    _messages[index].animationController
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          setState(() {
            _messages.removeAt(index);
            f.saveFile(_messages);
          });
        }
      });
  }

  @override
  void dispose() {
    for (var message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage(
      {required this.text,
      required this.animationController,
      required this.name,
      required this.symbol});
  final String text;
  final AnimationController animationController;
  final String name;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(symbol)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.headline4),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
