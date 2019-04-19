import 'package:flutter/material.dart';
import 'package:callcenter/models/callcenter.dart';
// import 'package:flutter_callcenter/models/CallCenter.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call center',
      theme: ThemeData(primaryColor: Colors.black),
      home: CallCenterWidget(),
    );
  }
}

class CallCenterWidget extends StatefulWidget {
  CallCenterWidget({Key key}) : super(key: key);

  @override
  _CallCenterState createState() => _CallCenterState();
}

class _CallCenterState extends State<CallCenterWidget> {
  CallCenter callCenter = CallCenter();
  addCall() {
    var random = Random();
    callCenter.dispatchCall(Call("Customer #${random.nextInt(50)}"));
  }

  endCall() {
    callCenter.endRandomCall();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: Text('Call center')),
        body: StreamBuilder(
          stream: callCenter.changes,
          builder: (context, snapshot) {
            return Column(
              children:  _buildBody() +
                  [_buildButton()] +
                  [_buildQueueView(callCenter.queueCalls)],
            );
          },
        ));
  }

  List<Widget> _buildBody() {
    List<Widget> result = [];
    callCenter.allProcessors
        .forEach((group) => result.add(_buildResponderRow(group)));
    return result;
  }

  Widget _buildResponderRow(List<Responder> group) {
    return Container(
      height: 100.0,
      child: ListView.builder(
        itemCount: group.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return _buildResponderView(group[index]);
        },
      ),
    );
  }

  Widget _buildQueueView(List<Call> queueCalls) {
    return Column(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: queueCalls.map((call) => Text(call.msg)).toList());
  }

  Widget _buildResponderView(Responder responder) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          responder.name,
          style: TextStyle(
              color: responder.isBusy() ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.call_end),
          onPressed: responder.isBusy() ? responder.endCurrentCall : null,
        )
      ]),
    );
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: RaisedButton.icon(
            icon: Icon(Icons.call),
            onPressed: addCall,
            label: Text("Add Call"),
          ),
        ),
        RaisedButton.icon(
          icon: Icon(Icons.call_made),
          onPressed: endCall,
          label: Text("End Random Call"),
        )
      ],
    );
  }
}
