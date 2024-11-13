import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  final List<Map<String, String>> termsAndConditions = [
    {
      "title": "1. Introdução",
      "text": """Bem-vindo à GOTUK (“Aplicação”). Estes Termos e Condições regulam o uso da nossa Aplicação, disponível através de dispositivos móveis e outras plataformas. Ao utilizar a nossa Aplicação, concorda em cumprir os presentes Termos e Condições. Caso não concorde com os mesmos, não deverá utilizar a Aplicação."""
    },
    {
      "title": "2. Definições",
      "text": """Aplicação: Refere-se à plataforma digital GOTUK disponibilizada para os
              utilizadores.
              Utilizador: Refere-se à pessoa física ou jurídica que acede ou utiliza a Aplicação.
              Nós ou Nosso/Nossa: Refere-se à entidade proprietária da Aplicação – C inove."""
    },
    {
      "title": "3. Condições de Utilização",
      "text": """O Utilizador compromete-se a utilizar a Aplicação de acordo com a lei, a moral e a
ordem pública, abstendo-se de realizar atividades ilícitas ou que possam causar
prejuízos à Aplicação ou a terceiros."""
    },
    {
      "title": "4. Registo e Conta do Utilizador",
      "text": """Para utilizar algumas funcionalidades da Aplicação, o Utilizador deverá criar uma
conta fornecendo informações verdadeiras e completas. O Utilizador é responsável
por manter a confidencialidade dos dados de acesso à sua conta e por todas as
atividades realizadas na sua conta."""
    },
    {
      "title": "5. Privacidade e Proteção de Dados",
      "text": """Cumprimos com o RGPD e outras legislações aplicáveis de proteção de dados em
Portugal. Ao utilizar a nossa Aplicação, o Utilizador concorda com a nossa Política
de Privacidade, que descreve como recolhemos, usamos e protegemos os seus
dados pessoais."""
    },
    {
      "title": "6. Propriedade Intelectual",
      "text": """Todos os direitos de propriedade intelectual relacionados com a Aplicação,
incluindo, mas não se limitando a, textos, imagens, logotipos, gráficos, e software,

são da nossa propriedade ou licenciados para nós. O Utilizador não poderá utilizar
nenhum conteúdo da Aplicação sem a nossa prévia autorização por escrito."""
    },
    {
      "title": "7. Limitação de Responsabilidade",
      "text": """Nós envidaremos todos os esforços para manter a Aplicação operacional e livre de
erros. No entanto, não podemos garantir que a Aplicação funcionará sem
interrupções ou erros. Não somos responsáveis por quaisquer perdas ou danos que
possam resultar do uso ou da incapacidade de usar a Aplicação, exceto quando tal
responsabilidade seja obrigatória por lei."""
    },
    {
      "title": "8. Modificações nos Termos e Condições",
      "text": """Reservamo-nos o direito de alterar estes Termos e Condições a qualquer momento,
mediante aviso prévio ao Utilizador. As alterações serão publicadas na Aplicação, e
o uso continuado da Aplicação após tais alterações implicará a aceitação dos novos
Termos e Condições."""
    },
    {
      "title": "9. Resolução de Litígios",
      "text": """Em caso de litígio decorrente do uso da Aplicação, este será submetido aos
tribunais competentes de Lisboa, em conformidade com a legislação portuguesa."""
    },
    {
      "title": "10. Lei Aplicável",
      "text": """Estes Termos e Condições são regidos pela legislação vigente em Portugal."""
    },
    {
      "title": "11. Contacto",
      "text": """Para mais informações ou esclarecimentos sobre estes Termos e Condições, entre
em contacto connosco através do e-mail: tuktuk@c-leveltech.pt."""
    }
  ];

  TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: termsAndConditions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            termsAndConditions[index]["title"]!,
                            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            termsAndConditions[index]["text"]!,
                            style: const TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    })
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to handle acceptance, e.g., save preference, navigate, etc.
                Navigator.pop(context); // Close the screen after accepting
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }
}
