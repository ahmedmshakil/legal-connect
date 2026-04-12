class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';

  // User
  static const userDashboard = '/user/dashboard';
  static const userCases = '/user/cases';
  static const userCreateCase = '/user/cases/create';
  static const userCaseDetails = '/user/cases/:id';
  static const userFindLawyers = '/user/find-lawyers';
  static const userLawyerProfile = '/user/lawyers/:id';

  // Lawyer
  static const lawyerDashboard = '/lawyer/dashboard';
  static const lawyerCases = '/lawyer/cases';
  static const lawyerCaseDetails = '/lawyer/cases/:id';
  static const lawyerOnboarding = '/lawyer/onboarding';
  static const lawyerProfile = '/lawyer/profile';

  // Shared
  static const chat = '/chat';
  static const chatConversation = '/chat/:id';
  static const aiChat = '/ai-chat';
  static const aiChatSession = '/ai-chat/:id';
  static const blogs = '/blogs';
  static const blogDetail = '/blogs/:id';
  static const blogCreate = '/blogs/create';
  static const blogEdit = '/blogs/edit/:id';
  static const meetings = '/meetings';
  static const payments = '/payments';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const changePassword = '/change-password';
  static const schedules = '/schedules';
}
