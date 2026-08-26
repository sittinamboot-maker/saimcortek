enum SubscriptionPlan { free, pro, business }

enum SubscriptionStatus {
  active,
  paymentDue,
  gracePeriod,
  readOnly,
  suspended,
}

enum CompanyRole { owner, admin, designer, sales, viewer }

enum MemberStatus { invited, active, disabled }

class CompanyMember {
  String id;
  String name;
  String email;
  CompanyRole role;
  MemberStatus status;
  DateTime joinedAt;

  CompanyMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'status': status.name,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory CompanyMember.fromJson(Map<String, dynamic> json) => CompanyMember(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: CompanyRole.values.firstWhere(
          (item) => item.name == json['role'],
          orElse: () => CompanyRole.viewer,
        ),
        status: MemberStatus.values.firstWhere(
          (item) => item.name == json['status'],
          orElse: () => MemberStatus.invited,
        ),
        joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? ''),
      );
}

class CompanyWorkspace {
  String id;
  String name;
  String email;
  String phone;
  String address;
  String taxId;
  SubscriptionPlan plan;
  SubscriptionStatus subscriptionStatus;
  DateTime? trialEndsAt;
  List<CompanyMember> members;
  DateTime updatedAt;

  CompanyWorkspace({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.taxId = '',
    this.plan = SubscriptionPlan.free,
    this.subscriptionStatus = SubscriptionStatus.active,
    this.trialEndsAt,
    List<CompanyMember>? members,
    DateTime? updatedAt,
  })  : members = members ?? [],
        updatedAt = updatedAt ?? DateTime.now();

  int get memberLimit => switch (plan) {
        SubscriptionPlan.free => 1,
        SubscriptionPlan.pro => 5,
        SubscriptionPlan.business => 9999,
      };

  bool get canWrite =>
      subscriptionStatus == SubscriptionStatus.active ||
      subscriptionStatus == SubscriptionStatus.paymentDue ||
      subscriptionStatus == SubscriptionStatus.gracePeriod;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'taxId': taxId,
        'plan': plan.name,
        'subscriptionStatus': subscriptionStatus.name,
        'trialEndsAt': trialEndsAt?.toIso8601String(),
        'members': members.map((item) => item.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CompanyWorkspace.fromJson(Map<String, dynamic> json) =>
      CompanyWorkspace(
        id: json['id'] as String? ?? 'local-company',
        name: json['name'] as String? ?? 'บริษัทของฉัน',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        taxId: json['taxId'] as String? ?? '',
        plan: SubscriptionPlan.values.firstWhere(
          (item) => item.name == json['plan'],
          orElse: () => SubscriptionPlan.free,
        ),
        subscriptionStatus: SubscriptionStatus.values.firstWhere(
          (item) => item.name == json['subscriptionStatus'],
          orElse: () => SubscriptionStatus.active,
        ),
        trialEndsAt: DateTime.tryParse(json['trialEndsAt'] as String? ?? ''),
        members: (json['members'] as List? ?? [])
            .map((item) =>
                CompanyMember.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      );
}

extension SubscriptionPlanLabel on SubscriptionPlan {
  String get label => name.toUpperCase();
}

extension CompanyRoleLabel on CompanyRole {
  String get label => switch (this) {
        CompanyRole.owner => 'เจ้าของ',
        CompanyRole.admin => 'ผู้ดูแล',
        CompanyRole.designer => 'ผู้ออกแบบ',
        CompanyRole.sales => 'ฝ่ายขาย',
        CompanyRole.viewer => 'ผู้ดูข้อมูล',
      };
}

extension SubscriptionStatusLabel on SubscriptionStatus {
  String get label => switch (this) {
        SubscriptionStatus.active => 'ACTIVE',
        SubscriptionStatus.paymentDue => 'PAYMENT DUE',
        SubscriptionStatus.gracePeriod => 'GRACE PERIOD',
        SubscriptionStatus.readOnly => 'READ ONLY',
        SubscriptionStatus.suspended => 'SUSPENDED',
      };
}
