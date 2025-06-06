import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dm/Domain/tour.dart';
import 'package:dm/Domain/trip.dart';
import 'package:dm/Utils/email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path/path.dart' as path;

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
  final bool accountAccepted;
  final DocumentReference? organizationRef;
  num? rating;
  List<String>? languages;
  final String? profilePhoto;

  AppUser(this.id, this.name, this.email, this.phone, this.accountValidated, this.accountAccepted, this.rating, this.languages, this.firebaseToken, this.organizationRef, this.profilePhoto);

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,) {
    final data = snapshot.data();

    return AppUser(snapshot.id, data?['name'], data?['email'],
        data?['phone'], data?['accountValidated'] ?? false, data?['accountAccepted'] ?? false,
        data?['rating'], data?['languages'], data?['firebaseToken'],
        data?['organizationRef'], data?['profilePhoto']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "accountValidated": accountValidated,
      "accountAccepted": accountAccepted,
      "rating": rating,
      "language": languages,
      "firebaseToken": firebaseToken,
      "profilePhoto": profilePhoto
    };
  }

  static Future<void> updateUserUnavailability(String guideId, Tour tour, DateTime tripDate, int hours, int minutes, bool available) async {
    for (int i = 0; i < tour.durationSlots; i++) {
      // Calculate total minutes from the starting point
      int totalMinutes = (hours * 60) + minutes +
          (i * 30);
      int newHour = totalMinutes ~/ 60; // Integer division to get hours
      int newMinutes = totalMinutes % 60; // Remainder to get minutes
      String hour = '${newHour.toString().padLeft(2, '0')}:${newMinutes
          .toString().padLeft(2, '0')}';
      String date = DateFormat('yyyy-MM-dd').format(tripDate);
      await updateUserCollection(date, hour, available ? availableStatus : unavailableStatus);
      await updateUnavailabilityCollection(guideId, date, hour, available ? availableStatus : unavailableStatus);
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

  static Future<bool> isGuideAvailable(Trip t) async {
    String date = DateFormat('yyyy-MM-dd').format(t.date);
    DocumentSnapshot<Map<String, dynamic>> dayUnavailability = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('unavailability')
        .doc(date).get();

    List<dynamic> slots = [];
    if (dayUnavailability.exists) {
      slots = dayUnavailability.get("slots");
    }

    for(int i = 0; i < t.tour.durationSlots; i++) {
      // Calculate total minutes from the starting point
      int totalMinutes = (t.date.hour * 60) + t.date.minute + (i * 30);
      int newHour = totalMinutes ~/ 60; // Integer division to get hours
      int newMinutes = totalMinutes % 60; // Remainder to get minutes
      String hour = '${newHour.toString().padLeft(2, '0')}:${newMinutes.toString().padLeft(2, '0')}';
      var result = slots.contains(hour);
      if (result) {
        return false;
      }
    }

    return true;
  }

  Future<bool> submitPersonalData(data) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      final personalDataDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('personalData').doc();

      batch.set(personalDataDocRef, {
        "language": data["language"],
        "identificationNumber": data["identificationNumber"],
        "identificationNumberExpirationDate": data["identificationNumberExpirationDate"],
        "drivingLicenseNumber": data["drivingLicenseNumber"],
        "drivingLicenseExpirationDate": data["drivingLicenseExpirationDate"],
        "status": 'pending',
        "submitDate": FieldValue.serverTimestamp()
      });

      sendTicket(batch, "Documento de Identificação");

      await batch.commit();

      for(File image in data["selectedImages"]) {
        await uploadImage("personalData", personalDataDocRef, image);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({ "language": data["language"] });

      return true;
    } catch (e) {
      await Sentry.captureException(e);
      return false;
    }
  }

  Future<void> submitOrganizationData(orgCode, org) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    final newOrgDataRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('organizationData')
        .doc();

    batch.set(newOrgDataRef ,{
      "code": orgCode,
      "name": org.get("name"),
      "status": 'pending',
      "submitDate": FieldValue.serverTimestamp()
    });

    final userDocRef = FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    batch.update(userDocRef,
        {
          "organizationRef": org.reference,
          "accountAccepted": false
        });


    sendEmail(batch, org.get("email"),
        "Novo guide associado - à espera de aceitação",
        """<p>Olá ${org.get("name")},</p>
        <p>Informamos que um novo guide se associou à tua empresa e encontra-se agora à
espera da tua aceitação.</p>
        <p><strong>Nome: $name</strong></p>
        <p>Podes aceitar o guide através da tua área de utilizador, clica no link
        abaixo:<br>
        <a href="https://business.gotuk.pt/">https://business.gotuk.pt</a>
        </p>
        <p>Após aceitares, iremos proceder à validação da documentação do guide.<br>
        Assim que a validação estiver concluída, este guide ficará associado à tua empresa,
podendo utilizar os teus tuk tuks e ficará pronto a aceitar reservas na nossa plataforma.</p>
        <p>Caso necessites de apoio ou tenhas alguma dúvida, estamos inteiramente disponíveis
        para ajudar.</p>
        <p>Com os melhores cumprimentos,</p>
        <p><img alt="logo" width="50" height="50" src="https://firebasestorage.googleapis.com/v0/b/app-gotuk.appspot.com/o/images%2Fapplogo.png?alt=media&token=882b99c8-8caa-42d4-a580-18f47671f677" />
        <br>
        <strong>Customer Care</strong><br>
        <span style="font-size: 10px">WhatsApp: +351917773031<br>
        Email: suporte@gotuk.pt<br>
        </span></p>
        <p><span style="font-size: 10px">Este é um email automático. Por favor, não respondas a esta mensagem.</span></p>
        <p><span style="font-size: 8px; display: block; line-height:1.0">Este e-mail, assim como os ficheiros eventualmente anexos, é reservado aos seus destinatários, e pode conter informação confidencial
        ou estar sujeito a restrições legais. Se não é o seu destinatário ou se recebeu esta mensagem por motivo de erro, solicitamos que não
        faça qualquer uso ou divulgação do seu conteúdo e proceda à eliminação permanente desta mensagem e respetivos anexos.</span></p>
        """);

    await batch.commit();
  }

  Future<bool> submitWorkAccidentInsurance(data) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      final workAccidentInsuranceDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('workAccidentInsurance').doc();

      batch.set(workAccidentInsuranceDocRef, {
        "name": data["name"],
        "number": data["number"],
        "expirationDate": data["expirationDate"],
        "useOrganizationInsurance": data["useWorkAccidentOrganizationInsurance"],
        "status": 'pending',
        "submitDate": FieldValue.serverTimestamp()
      });

      sendTicket(batch, "Apólice de Seguro de Acidentes de Trabalho");

      await batch.commit();

      for(File image in data["selectedImages"]) {
        await uploadImage("workAccidentInsurance", workAccidentInsuranceDocRef, image);
      }

      return true;
    } catch (e) {
      await Sentry.captureException(e);
      return false;
    }
  }

  Future<bool> submitCriminalRecord(data) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      final criminalRecordDocRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('criminalRecord').doc();

      batch.set(criminalRecordDocRef, {
        "status": 'pending',
        "submitDate": FieldValue.serverTimestamp()
      });

      sendTicket(batch, "Registo Criminal");

      await batch.commit();

      for(File image in data["selectedImages"]) {
        await uploadImage("criminalRecord", criminalRecordDocRef, image);
      }

      return true;
    } catch (e) {
      await Sentry.captureException(e);
      return false;
    }
  }

  Future<String?> uploadImage(String documentType, DocumentReference personalDataDocRef, File imageFile) async {
    try {
      String originalFileName = path.basename(imageFile.path);

      String fileName = "uploads/users/$id/$documentType/${personalDataDocRef.id}/$originalFileName";
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL(); // Get the uploaded image URL
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  void setFirebaseToken() async {
    try {
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.getAPNSToken();
      }

      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && token != firebaseToken) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({ "firebaseToken": token});
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int?> get totalReviews async {
    AggregateQuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('reviews').count().get();

    return querySnapshot.count;
  }

  Future<void> updateRating(double ratingGuide) async {
    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(id);
    int? totalGuideReviews = await totalReviews;

    if (totalGuideReviews != null) {
      double result = (((rating ?? 0) * totalGuideReviews) + ratingGuide) / (totalGuideReviews + 1);

      userDoc.update({
        "rating": double.parse(result.toStringAsFixed(1))
      });
    }
  }

  Future<void> addReview(String tripId, double ratingGuide, String commentGuide) async {
    DocumentReference guideReviewDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('reviews')
        .doc(tripId);

    await guideReviewDoc.set({
      'rating': ratingGuide,
      'comment': commentGuide,
      'creationDate': FieldValue.serverTimestamp()
    });
  }

  Future<bool> associateTukTuk(DocumentReference<Map<String, dynamic>> reference) async {
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var tuktuk = await reference.get();

    WriteBatch batch = FirebaseFirestore.instance.batch();

    DocumentReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(id);

    DocumentReference userTukTukDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('tuktuk')
        .doc(date);

    DocumentReference tuktukGuideDoc = FirebaseFirestore.instance
        .collection('tuktuks')
        .doc(reference.id)
        .collection('guide')
        .doc(date);

    DocumentReference userRefDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(id);

    final docSnapshot = await tuktukGuideDoc.get();
    if (!docSnapshot.exists) {
      batch.set(userTukTukDoc, {
        "tuktukRef": reference
      });
    } else {
      return false;
    }

    batch.set(tuktukGuideDoc, {
      "userRef": userRefDoc
    });


    DocumentReference tuktukActivityDoc = await FirebaseFirestore.instance
        .collection('organizations')
        .doc(organizationRef!.id)
        .collection('tuktukActivity')
        .doc(date);

    final tuktukActivitySnapshot = await tuktukActivityDoc.get();

    if (!tuktukActivitySnapshot.exists) {
      batch.set(tuktukActivityDoc, {
        'tuktuks': [reference]
      });
    } else {
      batch.update(tuktukActivityDoc, {
        'tuktuks': FieldValue.arrayUnion([reference])
      });
    }

    batch.update(userDoc, {
      "tuktukLicensePlate": tuktuk.get("licensePlate"),
      "tuktukElectric": tuktuk.get("electric"),
      "tuktukSeats": tuktuk.get("seats")
    });

    batch.update(userRefDoc, {
      "needSelectTukTuk": false
    });

    await batch.commit();

    return true;
  }

  static Future<List<String>> loadImages(String folderPath) async {
    final List<String> imageUrls = [];
    final storageRef = FirebaseStorage.instance.ref().child(folderPath);

    try {
      final ListResult result = await storageRef.listAll(); // Get all files in folder

      for (var fileRef in result.items) {
        String url = await fileRef.getDownloadURL(); // Get download URL
        imageUrls.add(url);
      }
    } catch (e) {
      print("Error fetching images: $e");
    }

    return imageUrls;
  }

  void updateAppLanguage(String value) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({"appLanguage": value});
  }

  void sendTicket(WriteBatch batch, type) {
    const subject= "Novos Documentos Submetidos para Verificação";
    final body = """
      <p>Olá,</p>
      <p>O guide <strong>$name</strong> enviou novos documentos para verificação.</p>
      <p><strong>Tipo de Documentos:</strong> $type.</p>
      <p>Para aceder e verificar os documentos submetidos, clique no link abaixo:</p>
      <p><a href="http://backoffice.gotuk.pt/guides/$id" target="_blank">Verificar Documentos</a></p>
    """;

    sendEmail(batch, "support@gotuk.freshdesk.com", subject, body);
  }
}

Future<bool> userExists(String phone) async {
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  QuerySnapshot<Object?> snapshot = await users.where("phone", isEqualTo: phone).get();
  return snapshot.docs.isNotEmpty;
}

Future<AppUser> getUserFirebaseInstance(bool guideMode, User user) async {
  AppUser? appUser;
  final ref = FirebaseFirestore.instance.collection("users").doc(user.uid)
      .withConverter(
    fromFirestore: AppUser.fromFirestore,
    toFirestore: (AppUser user, _) => user.toFirestore(),
  );
  final docSnap = await ref.get();
  if (!docSnap.exists) {
    appUser = AppUser(user.uid, user.displayName, user.email, user.phoneNumber, false, false, 3, null, null, null, null);
    FirebaseFirestore.instance.collection("users")
        .doc(user.uid)
        .set(appUser.toFirestore());
  } else {
    appUser = docSnap.data();
  }

  appUser!.setFirebaseToken();

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
