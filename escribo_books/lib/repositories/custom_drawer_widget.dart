import 'package:flutter/material.dart';

class CustomDrawerWidget extends StatelessWidget {
  const CustomDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    context: context,
                    builder: (BuildContext bc) {
                      return const Wrap(
                        children: [
                          ListTile(
                            title: Text("Camera"),
                            leading: Icon(Icons.photo_camera),
                          ),
                          ListTile(
                            title: Text("Galeria"),
                            leading: Icon(Icons.photo_library),
                          )
                        ],
                      );
                    });
              },
              child: UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 249, 255, 252),
                    child: Image.asset(
                      'assets/icon/logo.png',
                      width: 60,
                    ),
                  ),
                  accountName: Text("User"),
                  accountEmail: Text("email@email.com")),
            ),
            InkWell(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                width: double.infinity,
                child: const Row(
                  children: [
                    Icon(Icons.bookmark),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Favoritos"),
                  ],
                ),
              ),
              onTap: () {},
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                width: double.infinity,
                child: const Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Termos de uso e privacidade"),
                  ],
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    context: context,
                    builder: (BuildContext bc) {
                      return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          child: const Column(
                            children: [
                              Text(
                                "Termos de uso e privacidade",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                " Podemos já vislumbrar o modo pelo qual a mobilidade dos capitais internacionais ainda não demonstrou convincentemente que vai participar na mudança das regras de conduta normativas. A certificação de metodologias que nos auxiliam a lidar com o novo modelo estrutural aqui  proposições. atuação assume importantes posições no estabelecimento das direções preferenciais no sentido do progresso.",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ));
                    });
              },
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                width: double.infinity,
                child: const Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Configurações"),
                  ],
                ),
              ),
              onTap: () {},
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
