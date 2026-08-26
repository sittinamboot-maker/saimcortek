# PVForge SaaS Technical Specification

> Technical specification สำหรับพัฒนา PVForge จากแอปออกแบบระบบ Solar แบบ Local ไปเป็น Flutter + Firebase SaaS ที่บริษัท Solar หลายบริษัทเช่าใช้งานร่วมกัน โดยข้อมูลของแต่ละบริษัทต้องแยกจากกันอย่างเด็ดขาด

## 1. Product Vision

PVForge คือระบบ SaaS สำหรับบริษัทรับออกแบบและติดตั้ง Solar ใช้บริหารกระบวนการตั้งแต่รับข้อมูลลูกค้า ออกแบบระบบ เลือกอุปกรณ์ ตรวจ String/MPPT จัดทำ BOQ ใบเสนอราคา และรายงาน

เป้าหมายหลัก:

- รองรับหลายบริษัทในระบบเดียวด้วย Multi-Tenant architecture
- ผู้ใช้หนึ่งคนเข้าร่วมได้หลาย Company Workspace
- ข้อมูลทุกเอกสารต้องมี `companyId` และตรวจสิทธิ์ฝั่ง Firebase Rules
- รองรับแพ็กเกจ FREE, PRO และ BUSINESS
- รองรับ Trial, การเชิญสมาชิก และ Role-based access control
- มี Global Equipment Library และรายการอุปกรณ์เฉพาะบริษัท
- รองรับ Super Admin สำหรับบริหาร SaaS โดยไม่เข้าถึงข้อมูลลูกค้าเกินความจำเป็น
- เริ่มแบบ Firebase-native และสามารถแยก Backend service ในอนาคตได้

## 2. Recommended Technology Stack

### Client

- Flutter: Windows, Android, iOS และ Web
- State management: Riverpod
- Routing: GoRouter พร้อม route guards
- Immutable models: Freezed + json_serializable
- Local cache/offline: Cloud Firestore offline persistence; Isar/Drift เฉพาะกรณีต้องการ cache ขั้นสูง
- Charts: fl_chart หรือ CustomPainter
- PDF/report generation: pdf + printing

### Firebase

- Firebase Authentication
- Cloud Firestore
- Cloud Storage
- Cloud Functions v2
- Firebase App Check
- Firebase Cloud Messaging
- Firebase Hosting สำหรับ Web/Admin Portal
- Firebase Crashlytics และ Analytics
- Google Cloud Secret Manager สำหรับ payment/webhook secrets

### Optional integrations

- Payment gateway: Stripe หรือผู้ให้บริการในประเทศไทย
- Transactional email: SendGrid, Mailgun หรือ Firebase Trigger Email Extension
- BigQuery export สำหรับ SaaS analytics

## 3. Multi-Tenant Architecture

### 3.1 Tenant boundary

Company Workspace คือ tenant หลัก ทุกข้อมูลธุรกิจต้องอยู่ภายใต้ `companyId` ห้ามเชื่อถือ `companyId` ที่ client ส่งมาโดยไม่มีการตรวจ membership

หลักการ:

1. ทุก project, customer, quotation, BOQ, report และ company equipment ต้องมี `companyId`
2. Security Rules ตรวจว่า `request.auth.uid` เป็นสมาชิก active ของ company
3. การสร้าง document ต้องบังคับ `request.resource.data.companyId == companyId` จาก path
4. การแก้ไขห้ามเปลี่ยน `companyId`
5. Query ต้องระบุ company scope เสมอ ห้าม query ข้อมูลทุก tenant จาก client
6. งาน privileged เช่น invite, subscription และ global catalog ต้องทำผ่าน Cloud Functions

### 3.2 Recommended Firestore path strategy

ใช้ tenant เป็น parent path เพื่อให้ rules และ query ชัดเจน:

```text
/companies/{companyId}
  /members/{userId}
  /invites/{inviteId}
  /customers/{customerId}
  /projects/{projectId}
  /equipment/{equipmentId}
  /quotations/{quotationId}
  /reports/{reportId}
  /auditLogs/{logId}
```

ข้อมูล global แยกไว้ระดับ root:

```text
/globalEquipment/{equipmentId}
/plans/{planId}
/users/{userId}
/superAdmins/{userId}
```

## 4. Identity, Workspace and Membership

### 4.1 User

`/users/{userId}`

```json
{
  "displayName": "Somchai Installer",
  "email": "user@example.com",
  "phone": "+66812345678",
  "photoUrl": null,
  "defaultCompanyId": "company_123",
  "locale": "th",
  "timezone": "Asia/Bangkok",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp",
  "lastLoginAt": "serverTimestamp",
  "status": "ACTIVE"
}
```

User document ไม่ควรเก็บ permissions ของทุกบริษัทเป็น source of truth สิทธิ์จริงอยู่ใน company membership

### 4.2 Company Workspace

`/companies/{companyId}`

```json
{
  "name": "CORTek Solar Co., Ltd.",
  "slug": "cortek-solar",
  "logoUrl": "...",
  "taxId": "...",
  "phone": "...",
  "email": "...",
  "address": "...",
  "ownerUserId": "uid_123",
  "status": "ACTIVE",
  "planId": "PRO",
  "subscriptionStatus": "ACTIVE",
  "trialEndsAt": null,
  "billingCustomerId": "...",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

### 4.3 Membership

`/companies/{companyId}/members/{userId}`

```json
{
  "userId": "uid_123",
  "email": "user@example.com",
  "displayName": "Somchai",
  "role": "ADMIN",
  "permissions": [],
  "status": "ACTIVE",
  "joinedAt": "serverTimestamp",
  "invitedBy": "uid_owner",
  "updatedAt": "serverTimestamp"
}
```

### 4.4 Default roles

| Role | Purpose |
|---|---|
| OWNER | เจ้าของ Workspace, billing, delete company, full access |
| ADMIN | จัดการสมาชิก ข้อมูลบริษัท อุปกรณ์ และเอกสารทั้งหมด ยกเว้น ownership |
| DESIGNER | ลูกค้า โปรเจกต์ ออกแบบระบบ BOQ และรายงาน |
| SALES | ลูกค้า โปรเจกต์ ใบเสนอราคา อ่านผลออกแบบ |
| VIEWER | อ่านข้อมูลที่ได้รับอนุญาตเท่านั้น |

รองรับ custom permissions สำหรับ BUSINESS แต่ต้องมี permission catalog ที่ระบบควบคุม

### 4.5 Permission keys

```text
company.read
company.update
members.read
members.invite
members.update_role
members.remove
customers.read
customers.create
customers.update
customers.delete
projects.read
projects.create
projects.update
projects.delete
equipment.read
equipment.manage
boq.read
boq.manage
quotation.read
quotation.manage
reports.generate
billing.read
billing.manage
audit.read
```

OWNER ไม่ควรถูกลดสิทธิ์หรือถูกลบ หากยังไม่ได้โอน ownership

## 5. Invitations

`/companies/{companyId}/invites/{inviteId}`

```json
{
  "email": "newmember@example.com",
  "role": "DESIGNER",
  "permissions": [],
  "tokenHash": "sha256-hash",
  "status": "PENDING",
  "expiresAt": "timestamp",
  "invitedBy": "uid_admin",
  "createdAt": "serverTimestamp",
  "acceptedAt": null,
  "acceptedBy": null
}
```

Invitation flow:

1. OWNER/ADMIN เรียก Callable Function `createCompanyInvite`
2. Function ตรวจ permission, plan seat limit และ email normalization
3. สร้าง random token; เก็บเฉพาะ hash
4. ส่ง email link ไปยัง `/accept-invite?token=...`
5. ผู้รับ sign in หรือสร้างบัญชี
6. Callable Function ตรวจ token, expiry และ email
7. Transaction สร้าง membership และเปลี่ยน invite เป็น ACCEPTED
8. เขียน audit log

## 6. Subscription and Entitlements

### 6.1 Plans

`/plans/{planId}` เป็น server-managed configuration

| Capability | FREE | PRO | BUSINESS |
|---|---:|---:|---:|
| Members | 1 | 5 | Configurable |
| Active projects | 5 | 100 | Configurable/Unlimited |
| PDF reports | Basic | Full branding | Full + templates |
| Quotations | Limited | Yes | Yes |
| Company equipment | 20 | Unlimited | Unlimited |
| Custom roles | No | No | Yes |
| Audit retention | 7 days | 180 days | Configurable |
| Cloud sync | Basic | Full | Full |
| API/export | No | Limited | Yes |

อย่าบังคับ entitlement จาก UI อย่างเดียว ต้องตรวจซ้ำใน Cloud Functions และ Rules ที่ทำได้

### 6.2 Subscription document

`/companies/{companyId}/billing/subscription`

```json
{
  "planId": "PRO",
  "status": "ACTIVE",
  "provider": "STRIPE",
  "providerCustomerId": "cus_xxx",
  "providerSubscriptionId": "sub_xxx",
  "seatLimit": 5,
  "currentPeriodStart": "timestamp",
  "currentPeriodEnd": "timestamp",
  "trialStartedAt": "timestamp",
  "trialEndsAt": "timestamp",
  "gracePeriodEndsAt": null,
  "cancelAtPeriodEnd": false,
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

### 6.3 Lifecycle

```text
TRIAL → ACTIVE
TRIAL → READ_ONLY → SUSPENDED
ACTIVE → PAYMENT_DUE → GRACE_PERIOD → ACTIVE
ACTIVE → PAYMENT_DUE → GRACE_PERIOD → READ_ONLY → SUSPENDED
ACTIVE → READ_ONLY (cancelled at period end)
READ_ONLY → ACTIVE (payment recovered)
SUSPENDED → ACTIVE (manual recovery/payment)
```

| Status | Behavior |
|---|---|
| ACTIVE | ใช้งานตาม entitlement ของ plan |
| PAYMENT_DUE | ใช้งานได้ พร้อมแจ้งเตือนให้ชำระ |
| GRACE_PERIOD | ใช้งานได้จำกัดเวลา แสดงวันหมด grace |
| READ_ONLY | อ่านและ export ได้ แต่สร้าง/แก้ไขไม่ได้ |
| SUSPENDED | ระงับ workspace ยกเว้น billing/support |

Subscription status เปลี่ยนโดย trusted backend จาก payment webhook เท่านั้น Client ห้ามเขียน

### 6.4 Trial

- Trial เริ่มเมื่อสร้าง company สำเร็จ เช่น 14 วัน
- Trial plan ควรมี entitlement ชัดเจน ไม่ผูก logic กับวันที่ใน UI
- Scheduled Function ตรวจ trial expiry อย่างน้อยวันละครั้ง
- ส่งแจ้งเตือนก่อนหมดอายุ 7, 3 และ 1 วัน
- เมื่อหมด Trial: FREE, READ_ONLY หรือ SUSPENDED ตาม product policy

## 7. Domain Data Model

### 7.1 Customers

`/companies/{companyId}/customers/{customerId}`

```json
{
  "companyId": "company_123",
  "name": "คุณสมชาย",
  "phone": "0812345678",
  "email": null,
  "billingAddress": "...",
  "installationAddresses": [],
  "notes": "...",
  "tags": ["residential"],
  "createdBy": "uid",
  "createdAt": "serverTimestamp",
  "updatedBy": "uid",
  "updatedAt": "serverTimestamp",
  "deletedAt": null
}
```

### 7.2 Projects

`/companies/{companyId}/projects/{projectId}`

```json
{
  "companyId": "company_123",
  "customerId": "customer_123",
  "name": "บ้านคุณสมชาย",
  "status": "DRAFT",
  "systemType": "HYBRID",
  "monthlyKwh": 850,
  "dayKwhPerDay": 10,
  "nightKwhPerDay": 18.3,
  "hourlyLoadProfile": [0.4, 0.3, 0.3],
  "peakSunHours": 4.5,
  "roof": {
    "widthM": 5,
    "lengthM": 8,
    "areaM2": 40,
    "direction": "SOUTH",
    "slopeDegree": 15,
    "shadingPercent": 3
  },
  "battery": {
    "enabled": true,
    "capacityKwh": 10,
    "depthOfDischargePercent": 80,
    "efficiencyPercent": 95
  },
  "calculation": {
    "recommendedPanels": 10,
    "systemKwp": 6.2,
    "estimatedDailyProductionKwh": 22.1,
    "estimatedMonthlyProductionKwh": 663,
    "systemLossPercent": 18
  },
  "selectedPanelId": "equipment_123",
  "selectedInverterId": "equipment_456",
  "revision": 3,
  "createdBy": "uid",
  "createdAt": "serverTimestamp",
  "updatedBy": "uid",
  "updatedAt": "serverTimestamp",
  "deletedAt": null
}
```

แนะนำเก็บ calculation snapshot เพื่อให้เอกสารเก่าไม่เปลี่ยนเมื่อสูตรหรือ catalog เปลี่ยน และเก็บ `calculationVersion`

### 7.3 BOQ

ใช้ subcollection เพื่อรองรับ revision:

```text
/companies/{companyId}/projects/{projectId}/boq/{boqId}
/companies/{companyId}/projects/{projectId}/boq/{boqId}/items/{itemId}
```

BOQ item ต้องเก็บ snapshot ของชื่อ สเปก หน่วย ราคา VAT และ discount ไม่อ้าง equipment อย่างเดียว

### 7.4 Quotations

`/companies/{companyId}/quotations/{quotationId}`

Fields สำคัญ:

- `companyId`, `projectId`, `customerId`
- `quotationNumber` ที่สร้างจาก server transaction
- `status`: DRAFT, SENT, VIEWED, ACCEPTED, REJECTED, EXPIRED, CANCELLED
- subtotal, discount, VAT, grandTotal, currency
- company/customer snapshot
- BOQ snapshot
- validity date, payment terms, notes
- PDF Storage path และ checksum
- createdBy/updatedBy/timestamps

### 7.5 Reports

`/companies/{companyId}/reports/{reportId}`

- reportType: DESIGN, BOQ, QUOTATION, SITE_SURVEY
- projectId/customerId
- templateId/version
- generationStatus: QUEUED, PROCESSING, READY, FAILED
- storagePath
- generatedBy/generatedAt
- inputRevision
- errorCode/errorMessage

## 8. Equipment Library

### 8.1 Visibility scopes

| Scope | Storage | Visibility | Editable by |
|---|---|---|---|
| GLOBAL | `/globalEquipment` | ทุกบริษัท | Super Admin only |
| COMPANY | `/companies/{companyId}/equipment` | สมาชิกบริษัท | Company equipment manager |
| PRIVATE | Company equipment + `ownerUserId` | ผู้สร้างเท่านั้น | Owner user |

Company/private item ไม่ควร copy ไป global โดยตรง ต้องผ่าน review workflow

### 8.2 Equipment fields

```json
{
  "companyId": null,
  "scope": "GLOBAL",
  "ownerUserId": null,
  "category": "SOLAR_PANEL",
  "brand": "Jinko Solar",
  "model": "JKM620N-78HL4-V",
  "status": "ACTIVE",
  "specification": {
    "watt": 620,
    "voc": 49.5,
    "vmp": 41.8,
    "isc": 15.2,
    "imp": 14.4,
    "efficiencyPercent": 22.5,
    "widthMm": 1134,
    "lengthMm": 2465
  },
  "datasheetUrl": "...",
  "source": "MANUFACTURER",
  "verified": true,
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

Categories: SOLAR_PANEL, INVERTER, BATTERY, BREAKER, SPD, CABLE, MOUNTING, METER, OTHER

Equipment query ใน client:

1. โหลด GLOBAL active
2. โหลด COMPANY ของ current company
3. โหลด PRIVATE ที่ `ownerUserId == uid`
4. merge ด้วย stable ID และแสดง scope badge

## 9. Super Admin Dashboard

Super Admin เป็น platform role แยกจาก company OWNER และเก็บใน custom claims/`superAdmins`

ฟังก์ชันหลัก:

- Dashboard จำนวน companies, active users, MRR, trials และ churn
- Company search และ subscription status
- เปลี่ยน plan/status แบบมีเหตุผลและ audit log
- จัดการ global equipment catalog และ datasheet verification
- ดู job/webhook failures
- ดู usage เทียบ entitlement
- Impersonation เฉพาะ support mode แบบ time-limited, consent-aware และ audit ทุก action
- ห้ามแสดงข้อมูลลูกค้าหรือเอกสารเต็มโดย default

Super Admin operations ควรผ่าน Cloud Functions/Admin SDK เท่านั้น

## 10. Firebase Security Rules Principles

Rules ต้อง deny by default และแยก helper functions

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() {
      return request.auth != null;
    }

    function memberPath(companyId) {
      return /databases/$(database)/documents/companies/$(companyId)/members/$(request.auth.uid);
    }

    function isActiveMember(companyId) {
      return signedIn()
        && exists(memberPath(companyId))
        && get(memberPath(companyId)).data.status == 'ACTIVE';
    }

    function role(companyId) {
      return get(memberPath(companyId)).data.role;
    }

    function isAdmin(companyId) {
      return isActiveMember(companyId)
        && role(companyId) in ['OWNER', 'ADMIN'];
    }

    function writableSubscription(companyId) {
      let company = get(/databases/$(database)/documents/companies/$(companyId));
      return company.data.subscriptionStatus in ['ACTIVE', 'PAYMENT_DUE', 'GRACE_PERIOD'];
    }

    match /companies/{companyId} {
      allow read: if isActiveMember(companyId);
      allow update: if isAdmin(companyId)
        && request.resource.data.ownerUserId == resource.data.ownerUserId
        && request.resource.data.subscriptionStatus == resource.data.subscriptionStatus;

      match /members/{userId} {
        allow read: if isActiveMember(companyId);
        allow write: if false; // use Cloud Functions for membership mutations
      }

      match /projects/{projectId} {
        allow read: if isActiveMember(companyId);
        allow create: if isActiveMember(companyId)
          && writableSubscription(companyId)
          && request.resource.data.companyId == companyId
          && request.resource.data.createdBy == request.auth.uid;
        allow update: if isActiveMember(companyId)
          && writableSubscription(companyId)
          && resource.data.companyId == companyId
          && request.resource.data.companyId == resource.data.companyId;
        allow delete: if isAdmin(companyId) && writableSubscription(companyId);
      }
    }

    match /globalEquipment/{equipmentId} {
      allow read: if signedIn() && resource.data.status == 'ACTIVE';
      allow write: if false;
    }
  }
}
```

ข้อควรระวัง:

- Rules ไม่ใช่ filter; query ต้องตรงกับข้อจำกัดของ rules
- อย่าใช้ role/plan จาก local storage เพื่อ authorize
- Server timestamps และ immutable fields ต้อง validate
- ตรวจ field allowlist ด้วย `diff().affectedKeys()` ใน rules
- จำกัด document size และ array growth
- Storage Rules ต้องตรวจ company membership จาก Firestore
- เปิด App Check แต่ไม่ถือว่า App Check แทน Authentication/Authorization
- เขียน Emulator tests สำหรับ cross-tenant access ทุก collection

## 11. Cloud Functions

Callable/HTTP functions ที่แนะนำ:

- `createCompany`
- `updateCompanyBillingProfile`
- `createCompanyInvite`
- `acceptCompanyInvite`
- `revokeCompanyInvite`
- `updateMemberRole`
- `removeMember`
- `transferCompanyOwnership`
- `createCheckoutSession`
- `createBillingPortalSession`
- `paymentWebhook`
- `generateQuotationNumber`
- `generateProjectReport`
- `publishGlobalEquipment`
- `syncSubscriptionStatuses`
- `expireTrialsAndGracePeriods`

ทุก function ต้อง:

1. ตรวจ Authentication
2. โหลด membership และ permission จาก server
3. ตรวจ subscription entitlement
4. validate input ด้วย schema
5. ใช้ transaction/batch เมื่อแก้หลาย document
6. เขียน audit log
7. ไม่ log token, payment data หรือข้อมูลลูกค้าที่อ่อนไหว

## 12. Offline and Synchronization

- Firestore offline persistence รองรับ draft editing
- ทุก document มี `updatedAt`, `updatedBy`, `revision`
- ใช้ optimistic UI แต่แสดง sync state: LOCAL, SYNCING, SYNCED, CONFLICT, ERROR
- Calculation ทำใน client ได้ แต่ server validate/report snapshot ก่อนสร้างเอกสารทางการ
- Conflict รุ่นแรกใช้ last-write-wins สำหรับข้อมูลทั่วไป
- BOQ/quotation ที่ SENT แล้ว immutable; การแก้ไขสร้าง revision ใหม่
- Local JSON repository ในแอปปัจจุบันต้องอยู่หลัง repository interface เพื่อ migrate ไป Firebase ได้

## 13. Flutter Application Architecture

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    auth/
    errors/
    permissions/
    subscription/
    firebase/
  features/
    authentication/
    companies/
    members/
    customers/
    projects/
    solar_design/
    equipment/
    boq/
    quotations/
    reports/
    billing/
    super_admin/
  shared/
    models/
    widgets/
    repositories/
```

Repository contracts:

```dart
abstract interface class ProjectRepository {
  Stream<List<SolarProject>> watchProjects(String companyId);
  Future<SolarProject?> getProject(String companyId, String projectId);
  Future<void> saveProject(String companyId, SolarProject project);
  Future<void> archiveProject(String companyId, String projectId);
}
```

UI ห้ามเรียก Firestore โดยตรง ให้ผ่าน repository/use case เพื่อทดสอบและเปลี่ยน backend ได้

## 14. Route Guards

Navigation state:

```text
Unauthenticated → /sign-in
Authenticated, no company → /onboarding/company
Pending invite → /accept-invite
Active membership + ACTIVE subscription → workspace
READ_ONLY → workspace read-only + billing banner
SUSPENDED → /workspace-suspended
Super Admin claim → /super-admin
```

Guard ต้อง refresh เมื่อ auth, current company, membership หรือ subscription เปลี่ยน

## 15. Audit and Observability

Audit events:

- COMPANY_CREATED/UPDATED
- MEMBER_INVITED/JOINED/ROLE_CHANGED/REMOVED
- PROJECT_CREATED/UPDATED/ARCHIVED
- QUOTATION_CREATED/SENT/ACCEPTED
- SUBSCRIPTION_CHANGED
- GLOBAL_EQUIPMENT_PUBLISHED
- SUPPORT_ACCESS_STARTED/ENDED

Audit log เก็บ actor, companyId, action, targetType, targetId, timestamp, metadata ที่ไม่อ่อนไหว และ source IP เฉพาะเมื่อมีนโยบายรองรับ

## 16. Required Indexes

ตัวอย่าง composite indexes:

- projects: `status + updatedAt desc`
- projects: `customerId + updatedAt desc`
- customers: `deletedAt + nameNormalized`
- quotations: `status + createdAt desc`
- equipment: `scope + category + status + brand`
- invites: `status + expiresAt`
- auditLogs: `action + createdAt desc`

เก็บ `nameNormalized`, `emailNormalized` สำหรับ exact/prefix strategy หรือใช้ Algolia/Typesense สำหรับ full-text search

## 17. Testing Strategy

- Unit tests: solar calculation, battery sizing, entitlement และ permission mapping
- Widget tests: create/edit project, read-only state, plan limit UI
- Repository tests: local/Firebase mapping และ offline conflict
- Firestore Emulator rules tests: cross-company read/write ต้อง fail
- Functions Emulator tests: invites, seats, subscription transitions
- Integration tests: onboarding → trial → project → quotation → report
- Payment webhook idempotency tests
- PDF golden tests

Critical security test:

```text
User A in Company A must never read/write Company B by changing companyId,
document path, cached object, deep link, query, Storage path or Function payload.
```

## 18. Development Roadmap

### Phase 0 — Foundation

- Refactor current app into feature/repository structure
- Complete serializable domain models and calculation versioning
- Add Firebase projects for dev/staging/prod
- Emulator Suite and CI
- Central error handling, logging and environment configuration

### Phase 1 — Authentication and Company Workspace

- Email/password and Google sign-in
- Create/select company
- Company profile
- Membership and base roles
- Tenant-scoped routing and repositories
- Migration from local JSON to first Firebase company

### Phase 2 — Core Solar Workflow

- Customers and projects
- 24-hour load profile
- Roof, battery, panel and inverter selection
- String/MPPT validation
- Global/company/private equipment library
- Project revision and calculation snapshots

### Phase 3 — Collaboration

- Invite flow
- Member management
- Permission-aware UI
- Audit logs
- Offline/sync indicators
- Project assignment and activity history

### Phase 4 — Commercial Documents

- BOQ editor and pricing
- Quotation numbering and revisions
- Company branding/templates
- PDF reports and Cloud Storage
- Send/share/accept quotation workflow

### Phase 5 — Subscription

- FREE/PRO/BUSINESS entitlements
- Trial and seat limits
- Checkout/billing portal
- Payment webhooks
- PAYMENT_DUE/GRACE_PERIOD/READ_ONLY/SUSPENDED enforcement
- Usage metering and upgrade prompts

### Phase 6 — Super Admin

- SaaS analytics
- Company/subscription management
- Global equipment moderation
- Job/webhook monitoring
- Audited support access

### Phase 7 — Hardening and Scale

- Security audit and rules coverage
- App Check enforcement
- Backup/restore and disaster recovery
- Performance/index tuning
- BigQuery analytics
- Data retention/export/delete workflows
- PDPA/privacy readiness

## 19. Initial Codex Implementation Order

Codex ควรเริ่มตามลำดับนี้:

1. สร้าง environment config `dev/staging/prod`
2. เพิ่ม Firebase initialization และ Emulator support
3. สร้าง Auth, User, Company, Membership models
4. สร้าง `CurrentCompanyController` และ repository interfaces
5. ทำ company onboarding และ workspace switcher
6. ทำ Firestore rules พร้อม emulator tests ก่อน CRUD ธุรกิจ
7. ย้าย local SolarProject ไป tenant-scoped Firestore repository
8. ทำ customers/projects list และ edit
9. ทำ equipment scopes และ merge queries
10. ทำ invitations/RBAC
11. ทำ BOQ/quotation/report snapshots
12. ทำ subscription functions และ route guards
13. ทำ Super Admin เป็น app/route แยกสิทธิ์

## 20. Definition of Done for SaaS MVP

- ผู้ใช้สมัครและสร้าง Company Workspace ได้
- OWNER เชิญสมาชิกและกำหนด role ได้
- สมาชิกเห็นเฉพาะข้อมูล company ที่เลือก
- สร้างลูกค้าและโปรเจกต์ Solar ได้ครบ workflow
- เลือก global/company/private equipment ได้ตามสิทธิ์
- สร้าง BOQ ใบเสนอราคา และ PDF report ได้
- Subscription/Trial จำกัด feature และจำนวนสมาชิกจาก backend
- READ_ONLY และ SUSPENDED บังคับใช้ทั้ง UI, Rules และ Functions
- Super Admin จัดการ company/plan/global catalog ได้พร้อม audit
- Firestore Emulator tests ยืนยัน tenant isolation
- แอปรองรับ offline draft และแสดง sync status
- มี staging environment, monitoring, backup และ deployment procedure

---

เอกสารนี้เป็น baseline architecture สำหรับเริ่มพัฒนา ไม่ควร deploy production จนกว่าจะมี Firestore/Storage Rules tests, payment webhook verification, App Check, audit logging และการตรวจสอบด้าน PDPA/security ครบถ้วน
