import 'dart:math';

import 'package:exception_handler/exception_handler.dart';
import 'package:flutter/material.dart';

import 'model/user_model.dart';
import 'service/user_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;

  @override
  void initState() {
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                'ID: $_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              FutureBuilder(
                future: UserService().getDataUser(_counter),
                builder:
                    (context, AsyncSnapshot<ResultState<UserModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final ResultState<UserModel> result = snapshot.requireData;

                  return switch (result) {
                    SuccessState<UserModel> success =>
                      UiUserWidget(success.data),
                    FailureState<UserModel> failure =>
                      UiExceptionWidget(failure.exception),
                  };
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class UiExceptionWidget extends StatelessWidget {
  const UiExceptionWidget(
    this.exception, {
    super.key,
  });

  static const List<String> links = [
    'https://http.pizza',
    'https://http.garden',
    'https://httpducks.com',
    'https://httpgoats.com',
    'https://http.dog',
    'https://httpcats.com',
  ];

  final ExceptionState<UserModel> exception;

  @override
  Widget build(BuildContext context) {
    final String textException = switch (exception) {
      DataClientException<UserModel>() => 'Error Client: $exception',
      DataParseException<UserModel>() => 'Error Parse: $exception',
      DataHttpException<UserModel>() => 'Error Http: $exception',
      DataNetworkException<UserModel>() => 'Error Network: $exception',
      DataCacheException<UserModel>() => 'Error Cache: $exception',
      DataInvalidInputException<UserModel>() =>
        'Error Invalid Input: $exception',
    };

    final Text text = Text(
      textException,
      style: TextStyle(
        color: Colors.orange[700],
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: text));
    });

    return Column(
      children: [
        SizedBox(
          height: 400,
          child: Image.network(
            '${links[Random().nextInt(links.length)]}/404.webp',
          ),
        ),
        const SizedBox(height: 8),
        text,
      ],
    );
  }
}

class UiUserWidget extends StatelessWidget {
  const UiUserWidget(
    this.user, {
    super.key,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name: ${user.name}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Phone: ${user.phone}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Address: ${user.address?.street} - ${user.address?.city} ${user.address?.zipcode}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Email: ${user.email}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
