import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:math';

void main() => runApp(UsernameGenerator());

// all components are widgets, including app, layout etc
class UsernameGenerator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Username Generator",
      theme: new ThemeData(
        primaryColor: Colors.red,
      ),
      home: RandomWords(),
    );
  }
}

// container
class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <String>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final Set<String> _saved = new Set<String>();
  ScrollController _scrollController = new ScrollController();

  void _removeSavedWord(String word){
    setState((){
      _saved.remove(word);
      Navigator.pop(context);
      _pushSaved();
    });
  }

  void _pushSaved() {
    // route changing ("push" new view)
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
                (String word) {
              return new ListTile(
                title: new Text(
                  word,
                  style: _biggerFont,
                ),
                trailing: new Icon(Icons.delete),
                onTap: () {_removeSavedWord(word);},
              );
            },
          );
          final List<Widget> divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          )
              .toList();

          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Saved Usernames'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }


  Widget _buildSuggestions(){
    return ListView.builder(
      controller: _scrollController,
      itemBuilder: (context, i){
        if (i.isOdd) return Divider();
        final index = i ~/ 2;

        if (index >= _suggestions.length){
          Random randomNum = new Random();
          String addNum(String word){
            int power = randomNum.nextInt(5);
            if (power != 0){
              return (word + randomNum.nextInt(pow(10, power)).toString());
            }
            else{
              return (word);
            }
          }
          _suggestions.addAll(generateWordPairs().take(10).map((word) => (addNum(word.asPascalCase))));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  void _resetSuggestions(){
    setState((){
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
    Future.delayed(const Duration(milliseconds: 300), (){
      setState((){
        _suggestions.clear();
      });
    });
  }

  Widget _buildRow(String word) {
    final bool alreadySaved = _saved.contains(word);
    return ListTile(
      title: Text(
        word,
        style: _biggerFont,
      ),
      trailing: new Icon(   // Add the lines from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(word);
          } else {
            _saved.add(word);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Username Generator'),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.favorite), onPressed: _pushSaved),
          new IconButton(icon: const Icon(Icons.cached, color:Colors.white), onPressed: _resetSuggestions),
        ],
        leading: new Icon(Icons.people),
      ),
      body: _buildSuggestions(),
    );
  }
}