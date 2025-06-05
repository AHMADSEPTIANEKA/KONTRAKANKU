import 'package:appwrite/appwrite.dart';

Client client = Client()
  ..setEndpoint('https://cloud.appwrite.io/v1')
  ..setProject('683fd4ea001852babdc6');

Account account = Account(client);
