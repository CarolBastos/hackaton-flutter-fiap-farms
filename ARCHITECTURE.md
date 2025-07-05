# Clean Architecture - FIAP Farms

Este projeto foi projetado para seguir os princípios da Clean Architecture, proporcionando melhor separação de responsabilidades, testabilidade e manutenibilidade.

## Estrutura da Arquitetura

```
lib/
├── domain/                    # Camada de Domínio
│   ├── entities/             # Entidades de negócio
│   │   └── user.dart
│   ├── repositories/         # Contratos dos repositórios
│   │   └── auth_repository.dart
│   └── usecases/            # Casos de uso
│       └── auth_usecases.dart
├── data/                     # Camada de Dados
│   └── repositories/         # Implementações dos repositórios
│       └── auth_repository_impl.dart
├── presentation/             # Camada de Apresentação
│   └── controllers/         # Controllers
│       └── auth_controller.dart
├── di/                      # Injeção de Dependências
│   └── dependency_injection.dart
└── screens/                 # Widgets da UI
    ├── login_screen.dart
    └── sales_dashboard.dart
```

## Camadas

### 1. Domain Layer (Domínio)

- **Entidades**: Representam os objetos de negócio (ex: `User`)
- **Repositórios**: Contratos que definem as operações de dados
- **Casos de Uso**: Contêm a lógica de negócio da aplicação

### 2. Data Layer (Dados)

- **Repositórios**: Implementações concretas dos repositórios
- **APIs**: Comunicação com serviços externos (Firebase, REST APIs)
- **Modelos**: Mapeamento entre dados externos e entidades

### 3. Presentation Layer (Apresentação)

- **Controllers**: Gerenciam o estado da UI e comunicação com casos de uso
- **Widgets**: Componentes da interface do usuário
- **Providers**: Gerenciamento de estado (Provider pattern)

## Benefícios da Clean Architecture

1. **Separação de Responsabilidades**: Cada camada tem uma responsabilidade específica
2. **Testabilidade**: Fácil de testar cada camada isoladamente
3. **Independência de Frameworks**: A lógica de negócio não depende de frameworks específicos
4. **Manutenibilidade**: Mudanças em uma camada não afetam outras
5. **Escalabilidade**: Fácil de adicionar novas funcionalidades

## Como Usar

### 1. Injeção de Dependências

```dart
final di = DependencyInjection();
final authController = di.authController;
```

### 2. Usando o Controller

```dart
// No widget
Consumer<AuthController>(
  builder: (context, authController, child) {
    return ElevatedButton(
      onPressed: authController.isLoading ? null : _login,
      child: Text(authController.isAuthenticated ? 'Logout' : 'Login'),
    );
  },
)
```

### 3. Adicionando Novos Casos de Uso

1. Crie a entidade no `domain/entities/`
2. Defina o repositório no `domain/repositories/`
3. Implemente o caso de uso no `domain/usecases/`
4. Implemente o repositório no `data/repositories/`
5. Crie o controller no `presentation/controllers/`
6. Adicione no `di/dependency_injection.dart`

## Exemplo de Fluxo

1. **UI** chama método do **Controller**
2. **Controller** executa **Use Case**
3. **Use Case** chama **Repository**
4. **Repository** implementa comunicação com **Firebase/API**
5. Dados retornam pela mesma cadeia até a **UI**

## Dependências

- `provider`: Gerenciamento de estado
- `firebase_auth`: Autenticação
- `cloud_firestore`: Banco de dados

## Próximos Passos

1. Implementar testes unitários para cada camada
2. Adicionar tratamento de erros mais robusto
3. Implementar cache local
4. Adicionar logging e analytics
5. Implementar outras funcionalidades seguindo o mesmo padrão
