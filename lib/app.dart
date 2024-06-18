import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/absence/absence_screen.dart';
import 'package:web/campus/campus_screen.dart';
import 'package:web/class/class_screen.dart';
import 'package:web/document/document_screen.dart';
import 'package:web/grade/grade_screen.dart';
import 'package:web/information/information_screen.dart';
import 'package:web/schedule/schedule_screen.dart';
import 'package:web/school/school_screen.dart';
import 'package:web/login/login_screen.dart';
import 'package:web/student/student_screen.dart';
import 'package:web/teacher/teacher_screen.dart';
import 'package:web/welcome/welcome_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _router = GoRouter(
  initialLocation: '/login',
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: LoginScreen());
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
            path: '/schools',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: SchoolScreen());
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
              return const NoTransitionPage(child: ClassScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/students',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: StudentScreen());
            },
          ),
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            path: '/teachers',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: TeacherScreen());
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

  static const List<MyCustomSideBarItem> tabs = [
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.academicCap),
      label: 'Schools',
      initialLocation: '/schools',
    ),
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.buildingOffice),
      label: 'Campus',
      initialLocation: '/campus',
    ),
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.presentationChartBar),
      label: 'Class',
      initialLocation: '/class',
    ),
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.userGroup),
      label: 'Students',
      initialLocation: '/students',
    ),
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.user),
      label: 'Teachers',
      initialLocation: '/teachers',
    ),
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.calendarDays),
      label: 'Schedule',
      initialLocation: '/schedules',
    ),
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.pencilSquare),
      label: 'Grades',
      initialLocation: '/grades',
    ),
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.noSymbol),
      label: 'Absences',
      initialLocation: '/absences',
    ),
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.document),
      label: 'Documents',
      initialLocation: '/documents',
    ),
    MyCustomSideBarItem(
      icon: HeroIcon(HeroIcons.informationCircle),
      label: 'Informations',
      initialLocation: '/informations',
    ),
  ];

  void _goOtherTab(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    GoRouter router = GoRouter.of(context);
    String location = tabs[index].initialLocation;

    setState(() {
      _selectedIndex = index;
    });
    router.go(location);
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
                  backgroundImage: AssetImage('profile.jpg'),
                ),
                const SizedBox(height: 10),
                const Text('Bonjour Antoine', style: TextStyle(fontSize: 20)),
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