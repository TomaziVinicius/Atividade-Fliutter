# Documentação du ZapiZapi

Projeto de faculdade: aplicativo de mensagens estilo WhatsApp, desenvolvido em Flutter e integrado ao Supabase.

---

## 📌 Visão Geral
- **Nome:** ZapiZapi  
- **Descrição:** Aplicativo de mensagens em tempo real.  
- **Objetivo:** Permitir autenticação de usuários, criação de conversas e envio de mensagens.  
- **Plataformas:** Android, iOS, Web, Linux, macOS, Windows  

---

## 📂 Estrutura de Pastas
lib/ core/ supabase_client.dart # Configuração da conexão com Supabase services/ auth_service.dart # Serviço de autenticação ui/ pages/ auth/ login_page.dart # Tela de login home/ home_page.dart # Tela inicial com lista de conversas chat/ chat_page.dart # Tela de mensagens contacts/ contacts_page.dart # Tela de contatos para iniciar novos chats widgets/ # Componentes reutilizáveis assets/ logos/ logo_login.png # Logo usada na tela de login

Código

---

## 📦 Dependências
Definidas no `pubspec.yaml`:

- **flutter** → SDK principal  
- **image_picker** → seleção de imagens (ex.: avatar, envio de mídia)  
- **supabase_flutter** → integração com Supabase (auth, banco de dados, realtime)  
- **flutter_test** → testes automatizados  
- **flutter_lints** → boas práticas de código  

---

## 🖥️ Fluxo de Telas
- **AuthGate** → decide se o usuário vai para `LoginPage` ou `HomePage` com base na sessão  
- **LoginPage** → autenticação do usuário  
- **HomePage** → lista de conversas + menu (novo chat, configurações, sair)  
- **ContactsPage** → lista de contatos, inicia nova conversa  
- **ChatPage** → mensagens em tempo real, envio de texto  

---

## 🗄️ Banco de Dados (Supabase)
- **Tabela `perfis`** → usuários (`id`, `nome`, `avatar_url`)  
- **Tabela `conversas`** → conversas (`id`, `nome`, `is_group`, `created_by`, `created_at`)  
- **Tabela `participants`** → participantes da conversa (`user_id`, `conversation_id`, `joined_at`)  
- **Tabela `messages`** → mensagens (`id`, `chat_id`, `sender_id`, `content`, `created_at`)  

---

## 🚀 Instalação e Execução
1. Clonar o repositório  
2. Configurar Supabase (chaves no `supabase_client.dart`)  
3. Instalar dependências:
   ```bash
   flutter pub get
Executar:

bash
flutter run
🔧 Manutenção
Novas telas → adicionar em lib/ui/pages/

Componentes reutilizáveis → criar em lib/ui/widgets/

Atualizar dependências → editar pubspec.yaml

Testes → implementar em test/