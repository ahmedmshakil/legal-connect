import 'package:get/get.dart';
import 'app_routes.dart';
import 'initial_binding.dart';
import '../views/splash/splash_page.dart';
import '../views/main_shell.dart';
import '../views/auth/login_page.dart';
import '../views/auth/register_page.dart';
import '../views/auth/forgot_password_page.dart';
import '../views/auth/verify_email_page.dart';
import '../views/dashboard/user_dashboard_page.dart';
import '../views/dashboard/lawyer_dashboard_page.dart';
import '../views/cases/cases_list_page.dart';
import '../views/cases/case_detail_page.dart';
import '../views/cases/create_case_page.dart';
import '../views/lawyers/find_lawyers_page.dart';
import '../views/lawyers/lawyer_profile_page.dart';
import '../views/lawyers/lawyer_onboarding_page.dart';
import '../views/chat/chat_list_page.dart';
import '../views/chat/chat_conversation_page.dart';
import '../views/ai_chat/ai_chat_page.dart';
import '../views/blogs/blog_list_page.dart';
import '../views/blogs/blog_detail_page.dart';
import '../views/blogs/blog_editor_page.dart';
import '../views/meetings/meetings_page.dart';
import '../views/payments/payments_page.dart';
import '../views/notifications/notifications_page.dart';
import '../views/profile/profile_page.dart';
import '../views/profile/change_password_page.dart';
import '../views/schedules/schedules_page.dart';
import '../middlewares/auth_middleware.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        InitialBinding().dependencies();
      }),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
    ),
    GetPage(name: AppRoutes.verifyEmail, page: () => const VerifyEmailPage()),
    // Main shell with bottom navigation
    GetPage(
      name: AppRoutes.home,
      page: () => const MainShell(),
      middlewares: [AuthMiddleware()],
    ),
    // User routes
    GetPage(
      name: AppRoutes.userDashboard,
      page: () => const UserDashboardPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.userCases,
      page: () => const CasesListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.userCreateCase,
      page: () => const CreateCasePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.userCaseDetails,
      page: () => const CaseDetailPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.userFindLawyers,
      page: () => const FindLawyersPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.userLawyerProfile,
      page: () => const LawyerProfilePage(),
      middlewares: [AuthMiddleware()],
    ),
    // Lawyer routes
    GetPage(
      name: AppRoutes.lawyerDashboard,
      page: () => const LawyerDashboardPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.lawyerCases,
      page: () => const CasesListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.lawyerCaseDetails,
      page: () => const CaseDetailPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.lawyerOnboarding,
      page: () => const LawyerOnboardingPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.lawyerProfile,
      page: () => const LawyerProfilePage(),
      middlewares: [AuthMiddleware()],
    ),
    // Shared routes
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.chatConversation,
      page: () => const ChatConversationPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.aiChat,
      page: () => const AiChatPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.blogs,
      page: () => const BlogListPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.blogDetail,
      page: () => const BlogDetailPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.blogCreate,
      page: () => const BlogEditorPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.blogEdit,
      page: () => const BlogEditorPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.meetings,
      page: () => const MeetingsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.payments,
      page: () => const PaymentsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.schedules,
      page: () => const SchedulesPage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
