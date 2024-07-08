import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/absence/absence_screen.dart';
import 'package:web/campus/campus_screen.dart';
import 'package:web/class/class_screen.dart';
import 'package:web/class_id/class_id_screen.dart';
import 'package:web/core/services/auth_services.dart';
import 'package:web/document/document_screen.dart';
import 'package:web/grade/grade_screen.dart';
import 'package:web/information/information_screen.dart';
import 'package:web/path/path_screen.dart';
import 'package:web/profile/profile_screen.dart';
import 'package:web/register/register_screen.dart';
import 'package:web/schedule/schedule_screen.dart';
import 'package:web/school/school_screen.dart';
import 'package:web/login/login_screen.dart';
import 'package:web/student/student_screen.dart';
import 'package:web/teacher/teacher_screen.dart';
import 'package:web/welcome/welcome_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _router = GoRouter(
  initialLocation: '/login',
  navigatorKey: _rootNavigatorKey,
  redirect: (context, state) async {
    final jwt = await AuthService.init();

    final unprotectedPaths = ['/login', '/register'];
    if(jwt == null && !unprotectedPaths.contains(state.fullPath)) {
      return '/login';
    }

    if (jwt != null && (state.fullPath == '/login' || state.fullPath == '/register')) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: LoginScreen());
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register',
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: RegisterScreen());
      },
    ),
    ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
            child: SideNavigationBar(
              child: child,
            ),
          );
        },
        routes: [
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: WelcomeScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/profile',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: ProfileScreen());
            },
          ),          
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/schools',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: SchoolScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/paths',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: PathScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/campus',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: CampusScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/class',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: ClassScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/class/:id',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: ClassIdScreen(id: int.parse(state.pathParameters['id']!)));
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/students',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: StudentScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/teachers',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: TeacherScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/schedules',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: ScheduleScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/grades',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: GradeScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/absences',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: AbsenceScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/documents',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: DocumentScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/informations',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: InformationScreen());
            },
          ),
        ])
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: true,
      title: 'Studies',
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: Color.fromRGBO(109, 53, 172, 1),
            unselectedLabelStyle:
                TextStyle(color: Color.fromRGBO(190, 191, 190, 1)),
            unselectedItemColor: Color.fromRGBO(190, 191, 190, 1),
            unselectedIconTheme:
                IconThemeData(color: Color.fromRGBO(190, 191, 190, 1)),
            selectedIconTheme:
                IconThemeData(color: Color.fromRGBO(109, 53, 172, 1))),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.amber,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SideNavigationBar extends StatefulWidget {
  const SideNavigationBar({super.key, required this.child});

  final Widget child;

  @override
  State<SideNavigationBar> createState() => _SideNavigationBarBarState();
}

class _SideNavigationBarBarState extends State<SideNavigationBar> {
  int _selectedIndex = 0;
  late List<MyCustomSideBarItem> tabs;
  late String firstname;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(AuthService.jwt!);
    int userKind = decodedToken['user']['userKind'];
    firstname = decodedToken['user']['firstname'];

    tabs = _getTabsForUserKind(userKind);
  }

  List<MyCustomSideBarItem> _getTabsForUserKind(int? userKind) {
    switch (userKind) {
      case 1:
        //Teacher
        return [
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.calendarDays),
            label: 'Emplois du Temps',
            initialLocation: '/schedules',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.pencilSquare),
            label: 'Notes',
            initialLocation: '/grades',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.document),
            label: 'Documents',
            initialLocation: '/documents',
          ),        
        ];
      case 3:
        //Superadmin
        return [
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.academicCap),
            label: 'Écoles',
            initialLocation: '/schools',
          ),
        ];   
      case 2:
      default:
        //Admin
        return [
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.academicCap),
            label: 'École',
            initialLocation: '/schools',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.buildingOffice),
            label: 'Campus',
            initialLocation: '/campus',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.briefcase),
            label: 'Filières',
            initialLocation: '/paths',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.presentationChartBar),
            label: 'Classes',
            initialLocation: '/class',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.userGroup),
            label: 'Élèves',
            initialLocation: '/students',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.user),
            label: 'Intervenants',
            initialLocation: '/teachers',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.calendarDays),
            label: 'Emplois du Temps',
            initialLocation: '/schedules',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.pencilSquare),
            label: 'Notes',
            initialLocation: '/grades',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.noSymbol),
            label: 'Absences',
            initialLocation: '/absences',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.document),
            label: 'Documents',
            initialLocation: '/documents',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.informationCircle),
            label: 'Informations',
            initialLocation: '/informations',
          ),
        ];    
    }
  }

  void _goOtherTab(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    GoRouter router = GoRouter.of(context);
    String location = tabs[index].initialLocation;

    setState(() {
      _selectedIndex = index;
    });
    router.go(location);
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    GoRouter.of(context).go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.grey[200],
            child: Column(
              children: [
                const SizedBox(height: 50),
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('default-picture.jpg'),
                ),
                const SizedBox(height: 10),
                Text('Bonjour $firstname', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: tabs[index].icon,
                        title: Text(tabs[index].label),
                        selected: index == _selectedIndex,
                        onTap: () {
                          _goOtherTab(context, index);
                        },
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const HeroIcon(
                    HeroIcons.user,
                  ),
                  title: const Text(
                    'Profil',
                  ),
                  onTap: () {
                    GoRouter router = GoRouter.of(context);
                    router.go('/profile');
                  },
                ),
                ListTile(
                  leading: const HeroIcon(
                    HeroIcons.arrowLeftOnRectangle,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Déconnexion',
                    style: TextStyle(
                      color: Colors.red
                    ),
                  ),
                  onTap: () {
                    _logout(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class MyCustomSideBarItem {
  final HeroIcon icon;
  final String label;
  final String initialLocation;

  const MyCustomSideBarItem({
    required this.icon,
    required this.label,
    required this.initialLocation,
  });
}
