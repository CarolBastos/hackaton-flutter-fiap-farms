# fiap_farms

## Sobre o Projeto

Este projeto foi desenvolvido como parte do Hackaton final da Pós Graduação FIAP. O Hackaton é o momento de colocar em prática todo o conhecimento adquirido ao longo do curso, desenvolvendo uma solução inovadora e completa para um desafio real.

### Contexto do Hackaton

A Cooperativa de Fazendas FIAP Farms está lançando uma solução para ajudar seus integrantes a obter uma visão estratégica das vendas e planejar de forma mais assertiva os alimentos de maior lucro. O desafio é criar uma solução cross-platform (mobile e web) que atenda às necessidades da cooperativa.

### Requisitos do Projeto

- **Dashboard de vendas:** visão dos produtos por maior lucro
- **Dashboard de produção:** visão do que está aguardando, em produção e já colhido
- **Controle de Estoque e Vendas:** input e análise de dados de venda e produção
- **Metas de vendas e produção:** sistema de notificações ao bater metas
- **Autenticação de usuários**

Além dos requisitos acima, o projeto incentiva criatividade, inovação e a implementação de features extras!

## Tecnologias Utilizadas

- Flutter
- Cloud Firestore
- Firebase Storage
- Provider
- Flutter Secure Storage
- Firebase Auth

## Como Configurar e Executar

1. Clone o repositório:

   ```bash
   git clone git@github.com:CarolBastos/hackaton-flutter-fiap-farms.git
   ```

2. Adicione o arquivo google-service.json:
   Coloque este arquivo no diretório android/app com as credenciais do Firebase.
   Por conter nossas credenciais, esse arquivo se encontra no link do Google Drive que disponibilizamos na plataforma da Fiap.

3. Liste emuladores disponíveis:

   ```bash
   flutter emulators
   ```

   Se não houver emuladores listados, será necessário criar um.

4. Inicie emulador escolhido:

   ```bash
   flutter emulators --launch <emulator_id>
   ```

5. Execute o projeto:
   ```bash
   flutter run
   ```

## Detalhes da Arquitetura

O projeto segue o padrão Clean Architecture para garantir organização, escalabilidade e facilidade de manutenção.

➡️ [Veja os detalhes da arquitetura aqui](ARCHITECTURE.md)
