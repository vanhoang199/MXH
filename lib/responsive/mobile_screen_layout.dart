import 'package:flutter/material.dart';
import 'package:instagram_clone_1/utlis/colors.dart';
import 'package:instagram_clone_1/utlis/gobal_varible.dart';

class PageControllerInherited extends InheritedWidget {
  final PageController pageController;

  const PageControllerInherited({
    super.key,
    required this.pageController,
    required Widget child,
  }) : super(child: child);

  static PageControllerInherited? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PageControllerInherited>();
  }

  @override
  bool updateShouldNotify(PageControllerInherited oldWidget) {
    return oldWidget.pageController != pageController;
  }
}

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageControllerInherited(
      pageController: _pageController,
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: homeItemScreens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: mobileBackgroundColor,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: _page == 0 ? primaryColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  color: _page == 1 ? primaryColor : secondaryColor,
                ),
                label: '',
                backgroundColor: primaryColor),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle_rounded,
                color: _page == 2 ? primaryColor : secondaryColor,
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(
                Icons.favorite,
                color: _page == 3 ? primaryColor : secondaryColor,
              ),
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(
                Icons.person,
                color: _page == 4 ? primaryColor : secondaryColor,
              ),
              backgroundColor: primaryColor,
            ),
          ],
          onTap: navigationTapped,
        ),
      ),
    );
  }
}
