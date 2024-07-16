import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:toastification/toastification.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:web/core/services/school_services.dart';
import 'package:web/project/project_screen.dart';
import 'package:web/schedule_id/schedule_id.dart';
import 'package:web/welcome/welcome_screen.dart';

import 'absence/absence_screen.dart';
import 'campus/campus_screen.dart';
import 'chat/chat_screen.dart';
import 'chat_id/chat_id_screen.dart';
import 'class/class_screen.dart';
import 'class_id/class_id_screen.dart';
import 'core/services/auth_services.dart';
import 'course/course_screen.dart';
import 'document/document_screen.dart';
import 'note/note_screen.dart';
import 'information/information_screen.dart';
import 'path/path_screen.dart';
import 'profile/profile_screen.dart';
import 'register/register_screen.dart';
import 'schedule/schedule_screen.dart';
import 'school/school_screen.dart';
import 'login/login_screen.dart';
import 'student/student_screen.dart';
import 'teacher/teacher_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _router = GoRouter(
  initialLocation: '/login',
  navigatorKey: _rootNavigatorKey,
  redirect: (context, state) async {
    final jwt = await AuthService.init();

    final unprotectedPaths = ['/login', '/register'];
    if (jwt == null && !unprotectedPaths.contains(state.fullPath)) {
      return '/login';
    }

    final adminPaths = [
      '/schools',
      '/paths',
      '/courses',
      '/campus',
      '/class',
      '/students',
      '/teachers'
    ];
    if (jwt != null && adminPaths.contains(state.fullPath)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(jwt!);
      int userKind = decodedToken['user']['userKind'];

      if (userKind < 2) {
        return '/';
      }
    }

    if (jwt != null &&
        (state.fullPath == '/login' || state.fullPath == '/register')) {
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
            path: '/projects',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: ProjectScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/courses',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: CourseScreen());
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
              return NoTransitionPage(
                  child: ClassIdScreen(
                      id: int.parse(state.pathParameters['id']!)));
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
            path: '/chat',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: ChannelScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/chat/:id',
            pageBuilder: (context, state) {
              return NoTransitionPage(
                  child: ChannelIdScreen(
                      id: int.parse(state.pathParameters['id']!)));
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
              return NoTransitionPage(child: ScheduleScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/schedules/:id',
            pageBuilder: (context, state) {
              return NoTransitionPage(
                  child: ScheduleIdScreen(
                      scheduleId: int.parse(state.pathParameters['id']!)));
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/grades',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: NoteScreen());
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
              return NoTransitionPage(child: DocumentScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/informations',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: InformationScreen());
            },
          ),
        ])
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
        child: MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Studies',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(245, 242, 249, 1),
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
    ));
  }
}

class SideNavigationBar extends StatefulWidget {
  const SideNavigationBar({super.key, required this.child});

  final Widget child;

  @override
  State<SideNavigationBar> createState() => _SideNavigationBarBarState();
}

class _SideNavigationBarBarState extends State<SideNavigationBar> {
  late List<MyCustomSideBarItem> tabs;
  bool isLoading = true;
  late String firstname;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(AuthService.jwt!);
    int userKind = decodedToken['user']['userKind'];

    _initializeTabs(userKind);
  }

  void _initializeTabs(int userKind) async {
    tabs = await _getTabsForUserKind(userKind);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<MyCustomSideBarItem>> _getTabsForUserKind(int? userKind) async {
    switch (userKind) {
      case 1:
        //Teacher
        return [
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.calendarDays),
            label: 'Emplois du temps',
            initialLocation: '/schedules',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.adjustmentsHorizontal),
            label: 'Projets',
            initialLocation: '/projects',
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
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.chatBubbleOvalLeft),
            label: 'Discussions',
            initialLocation: '/chat',
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
        final school = await SchoolService().getSchool();
        if (school == null) {
          return [
            const MyCustomSideBarItem(
              icon: HeroIcon(HeroIcons.academicCap),
              label: 'École',
              initialLocation: '/schools',
            ),
          ];
        }
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
            label: 'Professeurs',
            initialLocation: '/teachers',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.bookOpen),
            label: 'Cours',
            initialLocation: '/courses',
          ),
          const MyCustomSideBarItem(
            icon: HeroIcon(HeroIcons.calendarDays),
            label: 'Emplois du Temps',
            initialLocation: '/schedules',
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
    setState(() {
      _selectedIndex = index;
    });
    GoRouter router = GoRouter.of(context);
    String location = tabs[index].initialLocation;

    router.go(location);
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    GoRouter.of(context).go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final currentLocation =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 50),
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('default-picture.jpg'),
                ),
                const SizedBox(height: 10),
                const Text('Bonjour', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: tabs[index].icon,
                        title: Text(tabs[index].label),
                        selected: _selectedIndex == index &&
                            !currentLocation.startsWith('/profile'),
                        selectedTileColor: Colors.blueGrey[100],
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
                  selected: currentLocation.startsWith('/profile'),
                  selectedTileColor: Colors.blueGrey[100],
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
                    style: TextStyle(color: Colors.red),
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
