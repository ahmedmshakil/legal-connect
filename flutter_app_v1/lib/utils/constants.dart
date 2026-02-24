class AppConstants {
  // User roles
  static const String roleUser = 'USER';
  static const String roleLawyer = 'LAWYER';
  static const String roleAdmin = 'ADMIN';

  // Case status
  static const String caseInProgress = 'IN_PROGRESS';
  static const String caseResolved = 'RESOLVED';

  // Lawyer verification status
  static const String verificationPending = 'PENDING';
  static const String verificationApproved = 'APPROVED';
  static const String verificationRejected = 'REJECTED';

  // Document/Note privacy
  static const String privacyShared = 'SHARED';
  static const String privacyPrivate = 'PRIVATE';

  // Blog status
  static const String blogDraft = 'DRAFT';
  static const String blogPublished = 'PUBLISHED';

  // Payment status
  static const String paymentPending = 'PENDING';
  static const String paymentPaid = 'PAID';
  static const String paymentReleased = 'RELEASED';
  static const String paymentRefunded = 'REFUNDED';
  static const String paymentCanceled = 'CANCELED';

  // Bangladesh Courts
  static const List<String> courts = practicingCourts;
  static const List<String> practicingCourts = [
    'Supreme Court of Bangladesh',
    'High Court Division',
    'Appellate Division',
    'District and Sessions Court',
    'Metropolitan Sessions Court',
    'Chief Judicial Magistrate Court',
    'Judicial Magistrate Court',
    'Metropolitan Magistrate Court',
    'Additional Chief Judicial Magistrate Court',
    'Senior Judicial Magistrate Court',
    'Civil Court (Assistant Judge Court)',
    'Family Court',
    'Labour Court',
    'Administrative Tribunal',
    'Tax Appellate Tribunal',
    'Customs, Excise and VAT Appellate Tribunal',
    'Special Tribunal',
    'Cyber Tribunal',
    'Environment Court',
    'Money Loan Court (Artha Rin Adalat)',
    'Bankruptcy Court',
    'Nari O Shishu Nirjatan Daman Tribunal',
    'Anti-Corruption Commission Tribunal',
    'International Crimes Tribunal',
  ];

  // Bangladesh Divisions
  static const List<String> divisions = [
    'Barishal',
    'Chattogram',
    'Dhaka',
    'Khulna',
    'Mymensingh',
    'Rajshahi',
    'Rangpur',
    'Sylhet',
  ];

  // Bangladesh Districts by Division
  static const Map<String, List<String>> districtsByDivision = {
    'Barishal': [
      'Barguna',
      'Barishal',
      'Bhola',
      'Jhalokathi',
      'Patuakhali',
      'Pirojpur',
    ],
    'Chattogram': [
      'Bandarban',
      'Brahmanbaria',
      'Chandpur',
      'Chattogram',
      'Comilla',
      'Cox\'s Bazar',
      'Feni',
      'Khagrachhari',
      'Lakshmipur',
      'Noakhali',
      'Rangamati',
    ],
    'Dhaka': [
      'Dhaka',
      'Faridpur',
      'Gazipur',
      'Gopalganj',
      'Kishoreganj',
      'Madaripur',
      'Manikganj',
      'Munshiganj',
      'Narayanganj',
      'Narsingdi',
      'Rajbari',
      'Shariatpur',
      'Tangail',
    ],
    'Khulna': [
      'Bagerhat',
      'Chuadanga',
      'Jessore',
      'Jhenaidah',
      'Khulna',
      'Kushtia',
      'Magura',
      'Meherpur',
      'Narail',
      'Satkhira',
    ],
    'Mymensingh': ['Jamalpur', 'Mymensingh', 'Netrokona', 'Sherpur'],
    'Rajshahi': [
      'Bogura',
      'Chapainawabganj',
      'Joypurhat',
      'Naogaon',
      'Natore',
      'Nawabganj',
      'Pabna',
      'Rajshahi',
      'Sirajganj',
    ],
    'Rangpur': [
      'Dinajpur',
      'Gaibandha',
      'Kurigram',
      'Lalmonirhat',
      'Nilphamari',
      'Panchagarh',
      'Rangpur',
      'Thakurgaon',
    ],
    'Sylhet': ['Habiganj', 'Moulvibazar', 'Sunamganj', 'Sylhet'],
  };

  // Legal specializations
  static const List<String> specializations = [
    'Criminal Law',
    'Civil Law',
    'Family Law',
    'Corporate Law',
    'Tax Law',
    'Labour Law',
    'Constitutional Law',
    'Environmental Law',
    'Cyber Law',
    'Banking Law',
    'Immigration Law',
    'Property Law',
    'Intellectual Property Law',
    'International Law',
    'Human Rights Law',
    'Administrative Law',
    'Commercial Law',
    'Maritime Law',
    'Arbitration & Mediation',
    'Consumer Protection Law',
  ];

  // Schedule event types
  static const List<String> scheduleTypes = [
    'COURT_HEARING',
    'CLIENT_MEETING',
    'DOCUMENT_DEADLINE',
    'FILING_DEADLINE',
    'MEDIATION',
    'ARBITRATION',
    'DEPOSITION',
    'TRIAL',
    'APPEAL_HEARING',
    'CONSULTATION',
    'CASE_REVIEW',
    'EVIDENCE_SUBMISSION',
    'SETTLEMENT_CONFERENCE',
    'BAIL_HEARING',
    'WITNESS_EXAMINATION',
    'JUDGMENT_DATE',
    'OTHER',
  ];
}
