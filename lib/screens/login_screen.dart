import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  // Chave global para o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores para armazenar os valores de e-mail e senha
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Associa o formulário à chave
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo de entrada para o e-mail
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  // Verificação básica de formato de e-mail
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}')
                      .hasMatch(value)) {
                    return 'Insira um e-mail válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Campo de entrada para a senha
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Oculta a senha
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Botão de Login
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Se a validação estiver correta, autenticar o usuário
                    print(
                        'Autenticando: ${emailController.text}, ${passwordController.text}');
                    // Ação para navegar para a próxima tela
                    Navigator.pushNamed(context, '/profile');
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              // Link para a tela de cadastro
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Não tem conta? Cadastre-se'),
              ),
              // Link para recuperação de senha
              TextButton(
                onPressed: () {
                  // Implementar navegação para a tela de recuperação de senha
                  print('Esqueci a senha');
                },
                child: Text('Esqueci minha senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
