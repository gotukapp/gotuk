import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Domain/tour.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

import '../Guide/account.dart';

const int availableStatus = 0;
const int unavailableStatus = 1;
const int tripStatus = 2;

class AppUser {

  final String id;
  late String? name;
  final String? email;
  final String? phone;
  final String? firebaseToken;
  final bool accountValidated;
  num? rating;
  List<String>? languages;

  AppUser(this.id, this.name, this.email, this.phone, this.accountValidated, this.rating, this.languages, this.firebaseToken);

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();
    return AppUser(snapshot.id, data?['name'], data?['email'],
        data?['phone'], data?['accountValidated'],
        data?['rating'], data?['languages'], data?['firebaseToken']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "accountValidated": accountValidated,
      "rating": rating,
      "languages": languages,
      "firebaseToken": firebaseToken
    };
  }

  static Future<void> updateTripUnavailability(String guideId, Tour tour, DateTime tripDate, int hours, int minutes) async {
    for (int i = 0; i < tour.durationSlots; i++) {
      // Calculate total minutes from the starting point
      int totalMinutes = (hours * 60) + minutes +
          (i * 30);
      int newHour = totalMinutes ~/ 60; // Integer division to get hours
      int newMinutes = totalMinutes % 60; // Remainder to get minutes
      String hour = '${newHour.toString().padLeft(2, '0')}:${newMinutes
          .toString().padLeft(2, '0')}';
      String date = DateFormat('yyyy-MM-dd').format(tripDate);
      await updateUserCollection(date, hour, unavailableStatus);
      await updateUnavailabilityCollection(guideId, date, hour, unavailableStatus);
    }
  }

  static Future<void> updateUnavailability(DateTime date,int status) async {
    String day = DateFormat('yyyy-MM-dd').format(date);
    String hour = DateFormat('HH:mm').format(date);
    await updateUserCollection(day, hour, status);
    await updateUnavailabilityCollection(FirebaseAuth.instance.currentUser!.uid, day, hour, status);
  }

  static Future<void> updateUserCollection(String day, String hour, int status) async {
    CollectionReference userUnavailability = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('unavailability');

    DocumentSnapshot dayUnavailability = await userUnavailability.doc(day).get();
    List<dynamic> slots = [];
    if (dayUnavailability.exists) {
      slots = dayUnavailability.get("slots");
    }
    if (status == availableStatus) {
      slots.remove(hour);
    } else {
      slots.add(hour);
    }
    await userUnavailability.doc(day).set({
      "date": DateTime.parse(day),
      "slots": slots
    });
  }

  static Future<void> updateUnavailabilityCollection(String guideId, String day, String hour, int status) async {
    CollectionReference unavailability = FirebaseFirestore.instance
        .collection('unavailability');

    DocumentSnapshot dayUnavailability = await unavailability.doc(day).get();
    List<dynamic> guides = [];
    if (dayUnavailability.exists) {
      final data = dayUnavailability.data() as Map<String, dynamic>?;
      if(data != null && data.containsKey(hour)) {
        guides = dayUnavailability.get(hour);
      }
    }

    if (status == availableStatus) {
      guides.remove(guideId);
    } else {
      guides.add(guideId);
    }

    if (dayUnavailability.exists) {
      unavailability.doc(day).update({
        hour: guides
      });
    } else {
      unavailability.doc(day).set({
        hour: guides
      });
    }

  }

  Future<void> submitAccountData(List<Item> data) async {
    Map<String, dynamic> documents = {};
    for(Item item in data) {
      for(dynamic field in item.fields) {
        if(field["field"] != null ) {
          if (field["type"] == 'String'){
            documents[field["fieldName"]] = field["field"].text;
          } else if (field["type"] == 'Array'){
            if (field["field"].length > 0) {
              documents[field["fieldName"]] = field["field"];
            }
          } else {
            documents[field["fieldName"]] = field["field"];
          }
        }
      }
    }

    documents["submitDate"] = DateTime.now();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('documents').add(documents);

    Item item = data.firstWhere((i) => i.itemName == "personalData");
    dynamic field = item.fields.firstWhere((i) => i["fieldName"] == "language");
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      "language": field["field"]
    });

    Item vehicleData = data.firstWhere((i) => i.itemName == "vehicleData");
    dynamic fieldLicensePlate = vehicleData.fields.firstWhere((i) => i["fieldName"] == "vehicleLicensePlate");
    dynamic fieldSeatsNumber = vehicleData.fields.firstWhere((i) => i["fieldName"] == "vehicleSeatsNumber");
    dynamic fieldVehicleType = vehicleData.fields.firstWhere((i) => i["fieldName"] == "vehicleType");

    await FirebaseFirestore.instance
        .collection('tuktuks')
        .doc(fieldLicensePlate["field"].text).set({
      "electric": fieldVehicleType["field"],
      "licensePlate": fieldLicensePlate["field"].text,
      "seats": int.parse(fieldSeatsNumber["field"].text)
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      "tuktukElectric": fieldVehicleType["field"],
      "tuktukSeats": int.parse(fieldSeatsNumber["field"].text),
      "tuktuk": FirebaseFirestore.instance.doc('tuktuks/${fieldLicensePlate["field"].text}')
    });
  }

  void update(String name) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      "name": name
    });

    this.name = name;
  }

  void setFirebaseToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      if (token != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({ "firebaseToken": token});
      }
    } on Exception catch (_, e) {
      print(e);
    }
  }
}

Future<bool> userExists(String phone) async {
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  QuerySnapshot<Object?> snapshot = await users.where("phone", isEqualTo: phone).get();
  return snapshot.docs.isNotEmpty;
}

Future<AppUser> getUserFirebaseInstance(bool guideMode, User user) async {
  final ref = FirebaseFirestore.instance.collection("users").doc(user.uid)
      .withConverter(
    fromFirestore: AppUser.fromFirestore,
    toFirestore: (AppUser user, _) => user.toFirestore(),
  );
  final docSnap = await ref.get();
  AppUser? appUser = docSnap.data();
  if (appUser == null) {
    appUser = AppUser(user.uid, user.displayName, user.email, user.phoneNumber, false, 0.0, null, null);
    FirebaseFirestore.instance.collection("users")
        .doc(user.uid)
        .set(appUser.toFirestore());
  }

  if (guideMode) {
    FirebaseFirestore.instance.collection("users")
        .doc(user.uid)
        .update({"guideMode": true});
  }

  if (!guideMode) {
    FirebaseFirestore.instance.collection("users")
        .doc(user.uid)
        .update({"clientMode": true});
  }

  return appUser;
}

final List<Map<String, String>> dataProtectionPolicy = [
  {
    "title": "1. Introdução",
    "text": "C inove, empresa responsável pelo desenvolvimento da aplicação GOTUK, "
        "está comprometida em proteger a privacidade dos seus utilizadores e dos "
        "seus dados pessoais. Esta Política de Proteção de Dados explica como são "
        "recolhidos, utilizados, armazenados e protegidos os dados pessoais em "
        "conformidade com o Regulamento Geral sobre a Proteção de Dados (RGPD)."
  },
  {
    "title": "2. Dados Pessoais Recolhidos",
    "text": """Durante o uso da aplicação GOTUK, podem ser recolhidos e processados os seguintes dados pessoais:
    
  Informações de Registo: Nome, endereço de e-mail, número de telefone, password e outros dados fornecidos ao criar uma conta.
  
  Dados de Uso: Informações sobre como o utilizador utiliza a aplicação, tais como interações, tempo de utilização e preferências.
  
  Dados de localização: Se autorizados, poder recolher a localização para melhorar a experiência do utilizador.
  
  Dados do Dispositivo: Tipo de dispositivo, sistema operacional, versão, endereço IP e identificadores de dispositivo.
  
  Dados de Pagamento: Informações de cartão de crédito ou outros métodos de pagamento (através de fornecedores de serviços de pagamento seguros).
  
  Outros Dados: Quaisquer outros dados pessoais que o utilizador fornecer voluntariamente, como feedback ou solicitações de suporte."""
  },
  {
    "title": "3. Finalidades do Tratamento dos Dados",
    "text": """Os dados recolhidos na aplicação são usados para os seguintes fins:
    
Criar e gerir a sua conta de utilizador;

Fornecer e melhorar os serviços oferecidos pela aplicação;

Personalizar a experiência do utilizador com base nas preferências e
comportamento;

Processar pagamentos, quando aplicável;

Enviar notificações, atualizações e comunicações relacionadas à aplicação;

Analisar e monitorar o desempenho e a utilização da aplicação;

Cumprir obrigações legais e regulatórias."""
  },
  {
    "title": "4. Fundamento Legal para o Tratamento dos Dados",
    "text": """O tratamento dos dados pessoais na aplicação GOTUK baseia-se nos seguintes fundamentos legais:
    
Execução de um contrato (necessário para o funcionamento da aplicação);

Consentimento (para dados que exigem o consentimento explícito do utilizador, como localização e marketing);

Cumprimento de obrigações legais;

Interesse legítimo da empresa em melhorar a aplicação e prevenir fraudes."""
  },
  {
    "title": "5. Partilha de Dados",
    "text": """Os dados pessoais do utilizador não serão partilhados com terceiros, exceto nas seguintes situações:
    
Fornecedores de serviços: Podem ser partilhados os dados do utilizador com fornecedores terceirizados que ajudam a operar a aplicação (ex.: serviços de hospedagem, análise de dados, processamento de pagamentos).

Autoridades legais: Caso seja obrigatório por lei ou autoridade competente, os dados do utilizador podem ser partilhados.

Fusões ou aquisições: No caso de fusão, venda ou transferência de ativos, os dados do utilizador poderão ser transferidos como parte dos ativos da empresa."""
  },
  {
    "title": "6. Direitos dos Utilizadores",
    "text": """De acordo com o RGPD, estes são os direitos que o utilizador possui em relação aos seus dados pessoais:
    
Direito de Acesso: Solicitar uma cópia dos dados possuídos sobre o utilizador;

Direito de Retificação: Corrigir dados incompletos ou incorretos;

Direito ao Esquecimento: Solicitar a exclusão dos dados pessoais do utilizador, exceto quando a retenção for necessária por motivos legais;

Direito à Limitação do Tratamento: Restringir temporariamente o tratamento dos dados do utilizador em determinadas circunstâncias;

Direito de Oposição: Opor-se ao tratamento dos dados do utilizador para finalidades específicas, como marketing direto;

Direito à Portabilidade: Receber os dados do utilizador num formato estruturado e transferível para outro controlador.

Para exercer qualquer um desses direitos, o utilizador deve entrar em contacto através do endereço de email: tuktuk@c-leveltech.pt."""
  },
  {
    "title": "7. Segurança dos Dados",
    "text": "São implementadas medidas técnicas e organizacionais adequadas para "
        "garantir a segurança dos dados pessoais do utilizador contra acessos não "
        "autorizados, perda, destruição ou divulgação indevida. Essas medidas"
  },
  {
    "title": "8. Retenção dos Dados",
    "text": "Serão mantidos os dados pessoais do utilizador apenas pelo tempo "
        "necessário para cumprir os propósitos descritos nesta Política, "
        "a menos que um período de retenção mais longo seja exigido ou permitido por lei."
  },
  {
    "title": "9. Uso de Cookies e Tecnologias Semelhantes",
    "text": "A aplicação GOTUK pode usar cookies e tecnologias semelhantes para recolher "
        "informações automaticamente, como padrões de navegação, preferências e "
        "configurações do dispositivo. O utilizador pode gerir as suas preferências "
        "de cookies nas configurações da aplicação ou do dispositivo."
  },
  {
    "title": "10. Transferência Internacional de Dados",
    "text": "Se os dados do utilizador forem transferidos para fora do "
        "Espaço Econômico Europeu (EEE), é garantido que a transferência seja "
        "realizada em conformidade com as leis de proteção de dados aplicáveis e "
        "com um nível adequado de proteção dos dados pessoais do utilizador."
  },
  {
    "title": "11. Alterações a esta Política de Proteção de Dados",
    "text": "Esta Política de Proteção de Dados pode ser atualizada periodicamente. "
        "Qualquer mudança significativa será notificada por meio de uma atualização na "
        "aplicação ou outro meio de comunicação adequado. É recomendado que consulte "
        "esta política regularmente."
  },
  {
    "title": "12. Contato",
    "text": """Se o utilizador tiver qualquer dúvida em relação a esta Política de Proteção de Dados ou sobre como são tratados os dados pessoais do utilizador, deve entrar em contacto através do e-mail: tuktuk@c-leveltech.pt.
    
    Endereço: Rua do Dondo, Lote 402, 5º Dto., 1800 - 107 Lisboa,"""
  },
];

final List<Map<String, String>> termsAndConditions = [
  {
    "title": "1. Introdução",
    "text": """Bem-vindo à GOTUK (“Aplicação”). Estes Termos e Condições regulam o uso da nossa Aplicação, disponível através de dispositivos móveis e outras plataformas. Ao utilizar a nossa Aplicação, concorda em cumprir os presentes Termos e Condições. Caso não concorde com os mesmos, não deverá utilizar a Aplicação."""
  },
  {
    "title": "2. Definições",
    "text": """Aplicação: Refere-se à plataforma digital GOTUK disponibilizada para os utilizadores. Utilizador: Refere-se à pessoa física ou jurídica que acede ou utiliza a Aplicação. Nós ou Nosso/Nossa: Refere-se à entidade proprietária da Aplicação – C inove."""
  },
  {
    "title": "3. Condições de Utilização",
    "text": """O Utilizador compromete-se a utilizar a Aplicação de acordo com a lei, a moral e a ordem pública, abstendo-se de realizar atividades ilícitas ou que possam causar prejuízos à Aplicação ou a terceiros."""
  },
  {
    "title": "4. Registo e Conta do Utilizador",
    "text": """Para utilizar algumas funcionalidades da Aplicação, o Utilizador deverá criar uma conta fornecendo informações verdadeiras e completas. O Utilizador é responsável por manter a confidencialidade dos dados de acesso à sua conta e por todas as atividades realizadas na sua conta."""
  },
  {
    "title": "5. Privacidade e Proteção de Dados",
    "text": """Cumprimos com o RGPD e outras legislações aplicáveis de proteção de dados em Portugal. Ao utilizar a nossa Aplicação, o Utilizador concorda com a nossa Política de Privacidade, que descreve como recolhemos, usamos e protegemos os seus dados pessoais."""
  },
  {
    "title": "6. Propriedade Intelectual",
    "text": """Todos os direitos de propriedade intelectual relacionados com a Aplicação, incluindo, mas não se limitando a, textos, imagens, logotipos, gráficos, e software, são da nossa propriedade ou licenciados para nós. O Utilizador não poderá utilizar nenhum conteúdo da Aplicação sem a nossa prévia autorização por escrito."""
  },
  {
    "title": "7. Limitação de Responsabilidade",
    "text": """Nós envidaremos todos os esforços para manter a Aplicação operacional e livre de erros. No entanto, não podemos garantir que a Aplicação funcionará sem interrupções ou erros. Não somos responsáveis por quaisquer perdas ou danos que possam resultar do uso ou da incapacidade de usar a Aplicação, exceto quando tal responsabilidade seja obrigatória por lei."""
  },
  {
    "title": "8. Modificações nos Termos e Condições",
    "text": """Reservamo-nos o direito de alterar estes Termos e Condições a qualquer momento, mediante aviso prévio ao Utilizador. As alterações serão publicadas na Aplicação, e o uso continuado da Aplicação após tais alterações implicará a aceitação dos novos Termos e Condições."""
  },
  {
    "title": "9. Resolução de Litígios",
    "text": """Em caso de litígio decorrente do uso da Aplicação, este será submetido aos tribunais competentes de Lisboa, em conformidade com a legislação portuguesa."""
  },
  {
    "title": "10. Lei Aplicável",
    "text": """Estes Termos e Condições são regidos pela legislação vigente em Portugal."""
  },
  {
    "title": "11. Contacto",
    "text": """Para mais informações ou esclarecimentos sobre estes Termos e Condições, entre em contacto connosco através do e-mail: tuktuk@c-leveltech.pt."""
  }
];
