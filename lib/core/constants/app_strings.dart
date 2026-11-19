/// Application-wide string constants.
abstract final class AppStrings {
  static const appName = 'LifePilot AI';
  static const tagline = 'Your Personal AI Companion';

  // ── Onboarding ──
  static const onboardingTitle1 = 'Welcome to LifePilot';
  static const onboardingBody1 =
      'Your intelligent personal assistant that helps you organize, plan, and accomplish more every day.';

  static const onboardingTitle2 = 'Smart & Personal';
  static const onboardingBody2 =
      'LifePilot learns your habits and preferences to deliver a truly personalized experience.';

  static const onboardingTitle3 = 'Ready to Begin?';
  static const onboardingBody3 =
      'Let LifePilot guide your daily journey with AI-powered insights and seamless productivity.';

  static const getStarted = 'Get Started';
  static const next = 'Next';
  static const skip = 'Skip';

  // ── Authentication ──
  static const welcomeBack = 'Welcome Back';
  static const loginSubtitle =
      'Sign in to continue your intelligent journey with LifePilot.';
  static const emailLabel = 'Email Address';
  static const emailHint = 'name@example.com';
  static const passwordLabel = 'Password';
  static const passwordHint = '••••••••';
  static const rememberMe = 'Remember Me';
  static const forgotPassword = 'Forgot Password?';
  static const signIn = 'Sign In';
  static const signingIn = 'Signing in...';
  static const dontHaveAccount = "Don't have an account? ";
  static const signUp = 'Sign Up';
  static const demoBadge = 'DEMO';
  static const demoNotice =
      'DEMO MODE — Authentication is simulated. Tap Sign In to enter.';

  // ── Register ──
  static const createAccount = 'Create Account';
  static const registerSubtitle =
      'Join LifePilot and experience your personal AI companion.';
  static const fullNameLabel = 'Full Name';
  static const fullNameHint = 'e.g. Alex Morgan';
  static const confirmPasswordLabel = 'Confirm Password';
  static const confirmPasswordHint = '••••••••';
  static const agreeToTerms =
      'I agree to the Terms of Service and Privacy Policy';
  static const creatingAccount = 'Creating Account...';
  static const alreadyHaveAccount = 'Already have an account? ';
  static const passwordRequirements =
      'Must be at least 8 characters with letters & numbers';

  // ── Forgot Password ──
  static const resetPassword = 'Reset Password';
  static const resetSubtitle =
      "Enter the email associated with your account and we'll send a simulated recovery link.";
  static const sendResetLink = 'Send Reset Link';
  static const sendingResetLink = 'Sending Link...';
  static const resetLinkSent = 'Reset Link Dispatched!';
  static const resetLinkSentDesc =
      'A simulated reset link has been dispatched to';
  static const checkInbox =
      'Check your inbox or try signing in again once reset.';
  static const backToSignIn = 'Back to Sign In';
  static const resendLink = 'Resend Link';

  // ── Form Validation ──
  static const valNameRequired = 'Full name is required';
  static const valNameTooShort = 'Name must be at least 2 characters';
  static const valEmailRequired = 'Email address is required';
  static const valEmailInvalid = 'Please enter a valid email address';
  static const valPasswordRequired = 'Password is required';
  static const valPasswordLength = 'Password must be at least 8 characters';
  static const valPasswordSecurity =
      'Password must contain both letters and numbers';
  static const valConfirmRequired = 'Please confirm your password';
  static const valPasswordMismatch = 'Passwords do not match';
  static const valTermsRequired =
      'Please accept the Terms & Conditions to proceed';
  static const valInvalidCredentials =
      'Invalid email or password. Please try again.';

  // ── Dashboard ──
  static const heroTitle = 'Your day, under control.';
  static const heroSubtitle =
      'Let your AI companion help you make today productive.';

  // ── AI Assistant ──
  static const askLifePilot = 'Ask LifePilot';
  static const aiAssistantDescription =
      'Get instant help with planning, organizing, and managing your daily life.';
  static const aiInputHint = 'What can I help you with today?';

  // ── Quick Actions ──
  static const myTasks = 'My Tasks';
  static const calendar = 'Calendar';
  static const reminders = 'Reminders';
  static const aiPlanner = 'AI Planner';

  // ── Overview ──
  static const todaysOverview = "Today's Overview";
  static const totalTasks = 'Total Tasks';
  static const completed = 'Completed';
  static const upcoming = 'Upcoming';
  static const pending = 'Pending';

  // ── Insight ──
  static const dailyInsight = 'Daily Insight';
  static const insightQuote =
      'Small steps today create meaningful progress tomorrow.';

  // ── Navigation ──
  static const home = 'Home';
  static const assistant = 'Assistant';
  static const planner = 'Planner';
  static const activity = 'Activity';
  static const profile = 'Profile';
  static const signOut = 'Sign Out';

  // ── Placeholder ──
  static const comingSoon = 'Coming Soon';
  static const featurePlaceholder =
      'This feature is under development and will be available in a future update.';
  static const sampleData = 'Sample data';
}
