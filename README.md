# 🐾 Pet Health

> Aplicação iOS nativa para gerir a saúde, vacinação e bem-estar dos teus animais de estimação.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B-blue.svg)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-purple.svg)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/Storage-SwiftData-green.svg)](https://developer.apple.com/documentation/swiftdata)

---

## 📋 Índice

- [Visão geral](#-visão-geral)
- [Funcionalidades](#-funcionalidades)
- [Tecnologia](#-tecnologia)
- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
- [Estrutura do projeto](#-estrutura-do-projeto)
- [Modelo de dados](#-modelo-de-dados)
- [Notificações](#-notificações)
- [Roadmap](#-roadmap)
- [Contribuir](#-contribuir)
- [Licença](#-licença)

---

## 🌟 Visão geral

O **Pet Health** é uma aplicação iOS que ajuda os tutores de animais de estimação a manterem-se organizados em relação a vacinas, desparasitações, consultas e outros eventos de saúde. Todos os dados são armazenados localmente no dispositivo, sem dependências de servidores externos nem contas de utilizador.

## ✨ Funcionalidades

| Área | Descrição |
|------|-----------|
| 🐶 **Gestão de animais** | Adiciona e edita perfis de cães e gatos com raça, data de nascimento, género, cor e tipo de pelagem |
| 💉 **Registos de saúde** | Vacinas, desparasitações, consultas, cirurgias, exames e outros eventos com notas e datas futuras |
| 🔔 **Alertas e lembretes** | Notificações automáticas 3 dias antes e no próprio dia do próximo tratamento |
| 📊 **Indicadores de estado** | Visualiza registos em atraso, a vencer em 7 dias e futuros |
| 📈 **Estatísticas por animal** | Resumo de vacinas, desparasitações e alertas pendentes de cada pet |
| 🔍 **Filtros** | Filtra os registos de saúde por tipo |
| 🎂 **Idade calculada** | Idade do animal calculada automaticamente em anos/meses |

## 🛠 Tecnologia

- **[Swift 5.9](https://swift.org)** — Linguagem principal
- **[SwiftUI](https://developer.apple.com/xcode/swiftui/)** — Interface declarativa nativa
- **[SwiftData](https://developer.apple.com/documentation/swiftdata)** — Persistência local (sucessor moderno do Core Data)
- **[UserNotifications](https://developer.apple.com/documentation/usernotifications)** — Notificações locais agendadas

> 💡 O projeto **não usa dependências externas** — apenas frameworks nativos da Apple.

## 📦 Requisitos

- **iOS 17** ou superior
- **Xcode 15** ou superior
- **macOS Sonoma** (14.0+) para desenvolvimento

## 🚀 Instalação

```bash
# 1. Clona o repositório
git clone https://github.com/<o-teu-username>/pet-health-app.git

# 2. Entra na pasta
cd pet-health-app

# 3. Abre no Xcode
open PetHealthApp.swift
```

No Xcode:
1. Seleciona um simulador ou dispositivo iOS 17+
2. Compila e executa com `Cmd + R`
3. Aceita o pedido de permissão para notificações na primeira execução

## 🗂 Estrutura do projeto

```
pet-health-app/
├── PetHealthApp.swift          # Entry point @main da app
├── Models/
│   ├── Pet.swift                # Modelo Pet (+ Species, Gender, CoatType)
│   └── HealthRecord.swift       # Modelo HealthRecord (+ HealthRecordType)
├── Managers/
│   └── NotificationManager.swift # Agendamento de notificações locais
└── Views/
    ├── ContentView.swift        # Container com TabView principal
    ├── Pets/
    │   ├── PetListView.swift
    │   ├── PetDetailView.swift
    │   └── AddEditPetView.swift
    ├── Health/
    │   └── AddHealthRecordView.swift
    └── Alerts/
        └── AlertsView.swift
```

## 🗃 Modelo de dados

```
┌──────────────────┐         ┌──────────────────────┐
│      Pet         │  1 ──*  │    HealthRecord      │
├──────────────────┤         ├──────────────────────┤
│ name             │         │ type                 │
│ species          │         │ name                 │
│ birthDate        │         │ date                 │
│ breed            │         │ notes                │
│ gender           │         │ nextDueDate?         │
│ color            │         │ notificationID?      │
│ coatType         │         │ pet (relação)        │
│ healthRecords[]  │         └──────────────────────┘
└──────────────────┘
```

A relação `Pet → HealthRecord` usa `deleteRule: .cascade`: ao remover um animal, os seus registos são também eliminados.

## 🔔 Notificações

Sempre que um registo tem `nextDueDate` definida, o [NotificationManager](Managers/NotificationManager.swift) agenda **duas notificações locais**:

- **3 dias antes**, às 09:00 — lembrete antecipado
- **No próprio dia**, às 09:00 — alerta principal

Quando o registo é apagado ou editado, as notificações são canceladas via `cancelNotification(id:)`.

## 🗺 Roadmap

- [ ] Suporte para mais espécies (aves, roedores, répteis)
- [ ] Exportar histórico clínico em PDF
- [ ] iCloud sync entre dispositivos
- [ ] Widget para o ecrã principal com próximas vacinas
- [ ] Versão Apple Watch para alertas
- [ ] Localização em inglês/espanhol

## 🤝 Contribuir

Contribuições são bem-vindas! Para sugerir melhorias:

1. Faz fork do repositório
2. Cria uma branch (`git checkout -b feature/minha-feature`)
3. Faz commit das tuas alterações (`git commit -m 'Adiciona X'`)
4. Faz push para a branch (`git push origin feature/minha-feature`)
5. Abre um Pull Request

## 📄 Licença

Este projeto está licenciado sob a licença MIT — vê o ficheiro [LICENSE](LICENSE) para detalhes.

---

<p align="center">Feito com ❤️ para os nossos amigos de quatro patas</p>
