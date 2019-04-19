import 'dart:async';
import 'dart:math';
import 'package:async/async.dart' show StreamGroup;

class CallCenter {
  List<Responder> workers = [];
  List<Responder> directors = [];
  List<Responder> managers = [];

  List<List<Responder>> allProcessors = [];

  List<Call> queueCalls = [];

  StreamController<List<List<Responder>>> _responderStream = StreamController();
  StreamController<List<Call>> _queue = StreamController();
  Stream changes;

  CallCenter() {
    workers.addAll([
      Responder(type: ResponderType.Worker, name: 'John'),
      Responder(type: ResponderType.Worker, name: 'Campbell'),
      Responder(type: ResponderType.Worker, name: 'Mclean'),
      Responder(type: ResponderType.Worker, name: 'Heisenber'),
    ]);
    managers.addAll([
      Responder(type: ResponderType.Manager, name: 'Doug'),
      Responder(type: ResponderType.Manager, name: 'Steve'),
      Responder(type: ResponderType.Manager, name: 'Heisenber'),
    ]);
    directors.addAll([
      Responder(type: ResponderType.Director, name: 'James'),
      Responder(type: ResponderType.Director, name: 'Toreto'),
    ]);
    allProcessors.add(workers);
    allProcessors.add(managers);
    allProcessors.add(directors);

    changes = StreamGroup.merge([_responderStream.stream, _queue.stream]);
  }

  dispatchCall(Call call) {
    Responder processor;
    for (var i = 0; i < allProcessors.length; i++) {
      try {
        processor = allProcessors[i].firstWhere((Responder p) => !p.isBusy());
      } catch (err) {
        print('Sitching to nextlevel');
        continue;
      }
      if (processor != null) {
        break;
      }
    }
    if (processor == null) {
      queueCalls.add(call);
      _queue.sink.add(queueCalls);
    } else {
      processor.respondToCall(call);
      call.addEndCallback(callEnded);
      _responderStream.sink.add(allProcessors);
    }
  }

  endRandomCall(){
    Random random = Random();
    var groupRandom = random.nextInt(allProcessors.length);
    var subGroupRandom = random.nextInt(allProcessors[groupRandom].length);
    allProcessors[groupRandom][subGroupRandom].endCurrentCall();
  }

  callEnded() {
    _responderStream.sink.add(allProcessors);
    if (queueCalls.length > 0) {
      dispatchCall(queueCalls[0]);
      queueCalls.removeAt(0);
      _queue.sink.add(queueCalls);
    }
  }
}

enum ResponderType { Manager, Director, Worker }

class Responder {
  final ResponderType type;
  Call call;
  final String name;

  Responder({this.type, this.name});

  void respondToCall(Call incoming) {
    if (isBusy()) {
      throw ResponderBusyException('Responder $name of typ $type is Busy');
    }
    call = incoming;
  }

  bool isBusy() {
    return this.call != null;
  }

  endCurrentCall() {
    if (this.isBusy()) {
      var temp = call;
      call = null;
      temp.endCall();
    }
  }
}

class ResponderBusyException implements Exception{
  String msg;
  ResponderBusyException(this.msg);
}

class Call {
  String msg;
  List<Function> endCallbacks = [];
  // constructor
  Call(this.msg);

  addEndCallback(Function callback) {
    endCallbacks.add(callback);
  }

  endCall() {
    endCallbacks.forEach((f) => f());
  }
}
