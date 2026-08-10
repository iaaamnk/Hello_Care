import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../models/report_model.dart';
import '../models/doctor_model.dart';

import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/patient_signup_screen.dart';
import '../screens/auth/doctor_signup_screen.dart';

import '../screens/patient/patient_main_screen.dart';
import '../screens/patient/upload_report_screen.dart';
import '../screens/patient/report_detail_screen.dart';
import '../screens/patient/ai_health_summary_screen.dart';
import '../screens/patient/doctor_search_screen.dart';
import '../screens/patient/book_appointment_screen.dart';
import '../screens/patient/qr_share_screen.dart';

import '../screens/doctor/doctor_main_screen.dart';
import '../screens/doctor/qr_scanner_screen.dart';
import '../screens/doctor/view_patient_reports_screen.dart';

GoRouter createRouter(UserProvider userProvider) {
  return GoRouter(
    initialLocation: '/role-selection',
    refreshListenable: userProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuth = userProvider.isAuthenticated;
      final isLoggingIn = state.uri.toString().startsWith('/login') ||
          state.uri.toString().startsWith('/role-selection') ||
          state.uri.toString().startsWith('/patient-signup') ||
          state.uri.toString().startsWith('/doctor-signup');

      if (!isAuth && !isLoggingIn) {
        return '/role-selection';
      }

      if (isAuth && isLoggingIn) {
        return userProvider.isDoctor ? '/doctor' : '/patient';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'patient';
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/patient-signup',
        builder: (context, state) => const PatientSignupScreen(),
      ),
      GoRoute(
        path: '/doctor-signup',
        builder: (context, state) => const DoctorSignupScreen(),
      ),

      // Patient Routes
      GoRoute(
        path: '/patient',
        builder: (context, state) => const PatientMainScreen(),
      ),
      GoRoute(
        path: '/upload-report',
        builder: (context, state) => const UploadReportScreen(),
      ),
      GoRoute(
        path: '/report-detail',
        builder: (context, state) {
          final report = state.extra as ReportModel;
          return ReportDetailScreen(report: report);
        },
      ),
      GoRoute(
        path: '/ai-summary-full',
        builder: (context, state) => const AiHealthSummaryScreen(),
      ),
      GoRoute(
        path: '/doctor-search',
        builder: (context, state) => const DoctorSearchScreen(),
      ),
      GoRoute(
        path: '/book-appointment',
        builder: (context, state) {
          final doctor = state.extra as DoctorModel;
          return BookAppointmentScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/qr-share',
        builder: (context, state) => const QrShareScreen(),
      ),

      // Doctor Routes
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorMainScreen(),
      ),
      GoRoute(
        path: '/scan-qr',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/view-patient-reports',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ViewPatientReportsScreen(patientData: data);
        },
      ),
    ],
  );
}
