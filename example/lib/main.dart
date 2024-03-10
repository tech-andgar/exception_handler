import 'dart:math';

import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';
import 'package:flutter/material.dart';

// Path: model/user_model.dart
class UserModel extends CustomEquatable {
  const UserModel({
    this.id,
    this.name,
    this.username,
    this.email,
    this.address,
    this.phone,
    this.website,
    this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': int? id,
          'name': String? name,
          'username': String? username,
          'email': String? email,
          'address': Map<String, dynamic>? address,
          'phone': String? phone,
          'website': String? website,
          'company': Map<String, dynamic>? company,
        }) {
      return UserModel(
        id: id,
        name: name,
        username: username,
        email: email,
        address: address != null ? Address.fromJson(address) : null,
        phone: phone,
        website: website,
        company: company != null ? Company.fromJson(company) : null,
      );
    } else {
      throw FormatException('Invalid JSON: $json');
    }
  }

  final Address? address;
  final Company? company;
  final String? email;
  final int? id;
  final String? name;
  final String? phone;
  final String? username;
  final String? website;

  @override
  Map<String, Object?> get namedProps => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'address': address,
        'phone': phone,
        'website': website,
        'company': company,
      };

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['email'] = email;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['phone'] = phone;
    data['website'] = website;
    if (company != null) {
      data['company'] = company!.toJson();
    }
    return data;
  }
}

class Address extends CustomEquatable {
  const Address({
    this.street,
    this.suite,
    this.city,
    this.zipcode,
    this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'street': String? street,
          'suite': String? suite,
          'city': String? city,
          'zipcode': String? zipcode,
          'geo': Map<String, dynamic>? geo,
        }) {
      return Address(
        street: street,
        suite: suite,
        city: city,
        zipcode: zipcode,
        geo: geo != null ? Geo.fromJson(geo) : null,
      );
    } else {
      throw FormatException('Invalid JSON: $json');
    }
  }

  final String? city;
  final Geo? geo;
  final String? street;
  final String? suite;
  final String? zipcode;

  @override
  Map<String, Object?> get namedProps => {
        'suite': suite,
        'street': street,
        'city': city,
        'zipcode': zipcode,
        'geo': geo,
      };

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['street'] = street;
    data['suite'] = suite;
    data['city'] = city;
    data['zipcode'] = zipcode;
    if (geo != null) {
      data['geo'] = geo!.toJson();
    }
    return data;
  }
}

class Geo extends CustomEquatable {
  const Geo({this.lat, this.lng});

  factory Geo.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'lat': String? lat,
          'lng': String? lng,
        }) {
      final Geo geo = Geo(lat: lat, lng: lng);
      return geo;
    } else {
      throw FormatException('Invalid JSON: $json');
    }
  }

  final String? lat;
  final String? lng;

  @override
  Map<String, Object?> get namedProps => {
        'lat': lat,
        'lng': lng,
      };

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class Company extends CustomEquatable {
  const Company({this.name, this.catchPhrase, this.bs});

  factory Company.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'name': String? name,
          'catchPhrase': String? catchPhrase,
          'bs': String? bs,
        }) {
      return Company(
        name: name,
        catchPhrase: catchPhrase,
        bs: bs,
      );
    } else {
      throw FormatException('Invalid JSON: $json');
    }
  }

  final String? bs;
  final String? catchPhrase;
  final String? name;

  @override
  Map<String, Object?> get namedProps => {
        'name': name,
        'catchPhrase': catchPhrase,
        'bs': bs,
      };

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['catchPhrase'] = catchPhrase;
    data['bs'] = bs;
    return data;
  }
}

// Path: services/user_service.dart
class UserService {
  final Dio dio = Dio();
  Future<ResultState<UserModel>> getDataUser(int id) async {
    final ResultState<UserModel> result =
        await DioExceptionHandler.callApi<Response, UserModel>(
      ApiHandler(
        apiCall: () =>
            dio.get('https://jsonplaceholder.typicode.com/users/$id'),
        parserModel: (Object? data) =>
            UserModel.fromJson(data as Map<String, dynamic>),
      ),
    );
    return result;
  }

  Future<ResultState<UserModel>> getDataUserExtensionDio(int id) async {
    final ResultState<UserModel> result = await dio
        .get('https://jsonplaceholder.typicode.com/users/$id')
        .fromJson(UserModel.fromJson);

    return result;
  }
}

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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
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
                // future: UserService().getDataUser(_counter),
                future: UserService().getDataUserExtensionDio(_counter),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<ResultState<UserModel>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final ResultState<UserModel> resultState =
                      snapshot.requireData;

                  final StatelessWidget uiWidget = switch (resultState) {
                    SuccessState<UserModel> success =>
                      UiUserWidget(success.data),
                    FailureState<UserModel> failure =>
                      UiExceptionWidget(failure.exception),
                  };
                  return uiWidget;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
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
      DataClientExceptionState<UserModel>() =>
        'Debugger Error Client: $exception',
      DataParseExceptionState<UserModel>() =>
        'Debugger Error Parse: $exception',
      DataHttpExceptionState<UserModel>() => 'Debugger Error Http: $exception',
      DataNetworkExceptionState<UserModel>() =>
        'Debugger Error Network: $exception\n\nError: ${exception.toString().split('.').last}',
      DataCacheExceptionState<UserModel>() =>
        'Debugger Error Cache: $exception',
      DataInvalidInputExceptionState<UserModel>() =>
        'Debugger Error Invalid Input: $exception',
      DataUnknownExceptionState<UserModel>() =>
        'Debugger Error Unknown: $exception',
    };

    final Text text = Text(
      textException,
      style: TextStyle(color: Colors.orange[800]),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: text));
    });

    final Widget imageException = switch (exception) {
      DataClientExceptionState<UserModel>() =>
        const Icon(Icons.devices_outlined, size: 200),
      DataParseExceptionState<UserModel>() =>
        const Icon(Icons.sms_failed_outlined, size: 200),
      DataHttpExceptionState<UserModel>() => Image.network(
          '${links[Random().nextInt(links.length)]}/404.webp',
        ),
      DataNetworkExceptionState<UserModel>() =>
        const Icon(Icons.wifi_off_outlined, size: 200),
      DataCacheExceptionState<UserModel>() =>
        const Icon(Icons.storage_outlined, size: 200),
      DataInvalidInputExceptionState<UserModel>() =>
        const Icon(Icons.textsms_outlined, size: 200),
      DataUnknownExceptionState<UserModel>() =>
        const Icon(Icons.close, size: 200),
    };
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: imageException,
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
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name: ${user.name}',
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Phone: ${user.phone}',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Address: ${user.address?.street} - ${user.address?.city} ${user.address?.zipcode}',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Email: ${user.email}',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
