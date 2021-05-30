import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quiz_app/quiz.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Quiz quiz;
  List<Results> results;

  Future<void> fetchEvent() async {
    var res =
        await http.get(Uri.parse("https://opentdb.com/api.php?amount=100"));
    var decRes = jsonDecode(res.body);
    quiz = Quiz.fromJson(decRes);
    results = quiz.results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz App"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchEvent,
        child: FutureBuilder(
          future: fetchEvent(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text("Press Button to Refresh");
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                if (snapshot.hasError) return Container();
                return questionList();
            }
            return null;
          },
        ),
      ),
    );
  }

  ListView questionList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (ctx, index) {
        return Card(
          elevation: 0.0,
          color: Colors.white,
          child: ExpansionTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  results[index]
                      .question
                      .replaceAll("&quot;", "")
                      .replaceAll("&#039;", ""),
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FilterChip(
                        backgroundColor: Colors.grey[100],
                        label: Text(results[index].category),
                        onSelected: (b) {},
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      FilterChip(
                        backgroundColor: Colors.grey[100],
                        label: Text(results[index].difficulty),
                        onSelected: (b) {},
                      )
                    ],
                  ),
                )
              ],
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Text(results[index].type.startsWith("m") ? "M" : "B"),
            ),
            children: results[index].allAnswers.map((m) {
              return AllOptions(
                results: results,
                index: index,
                m: m,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class AllOptions extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;

  const AllOptions({Key key, this.results, this.index, this.m})
      : super(key: key);

  @override
  _AllOptionsState createState() => _AllOptionsState();
}

class _AllOptionsState extends State<AllOptions> {
  Color c = Colors.black;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          if (widget.m == widget.results[widget.index].correctAnswer)
            c = Colors.green;
          else
            c = Colors.red;
        });
      },
      title: Text(
        widget.m,
        textAlign: TextAlign.center,
        style: TextStyle(color: c, fontWeight: FontWeight.bold),
      ),
    );
  }
}
