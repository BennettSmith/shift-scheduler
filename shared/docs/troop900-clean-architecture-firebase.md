# Troop 900 Tree Lot Scheduler
## Clean Architecture Firebase Cloud Functions Implementation Guide

**Version:** 1.0  
**Date:** December 2024  
**Project:** Firebase Cloud Functions implementation following Clean Architecture principles

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Layer Definitions](#layer-definitions)
3. [Project Structure](#project-structure)
4. [Domain Layer](#domain-layer)
5. [Application Layer (Use Cases)](#application-layer-use-cases)
6. [Infrastructure Layer](#infrastructure-layer)
7. [Interface Layer (Function Handlers)](#interface-layer-function-handlers)
8. [Dependency Injection](#dependency-injection)
9. [Error Handling](#error-handling)
10. [Use Case Catalog](#use-case-catalog)
11. [Implementation Examples](#implementation-examples)
12. [Testing Strategy](#testing-strategy)
13. [Deployment Considerations](#deployment-considerations)

---

## Architecture Overview

This Cloud Functions implementation follows **Clean Architecture** principles adapted for serverless TypeScript functions:

- **Firebase/Firestore is an implementation detail** hidden behind repository and gateway abstractions
- **The domain layer is completely independent** of Firebase, HTTP, or any infrastructure
- **Use cases orchestrate business logic** through single-purpose execute methods
- **Repositories handle data persistence** (Firestore reads/writes)
- **Gateways handle external services** (FCM push notifications, external APIs)
- **Function handlers are thin adapters** that translate HTTP/trigger events to use case calls
- **Dependencies flow inward** - outer layers depend on inner layers, never the reverse

### The Dependency Rule

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        INTERFACE LAYER (Outer)                              │
│   (Cloud Function Handlers, HTTP Adapters, Trigger Handlers)                │
│   Receives requests, calls use cases, returns responses                     │
│                                                                             │
│   ┌───────────────────────────────────────────────────────────────────────┐ │
│   │                      APPLICATION LAYER                                │ │
│   │   (Use Cases - Application-Specific Business Rules)                   │ │
│   │   Orchestrates domain entities to fulfill business requirements       │ │
│   │                                                                       │ │
│   │   ┌───────────────────────────────────────────────────────────────┐   │ │
│   │   │                      DOMAIN LAYER (Core)                      │   │ │
│   │   │   (Entities, Value Objects, Business Rules)                   │   │ │
│   │   │   Pure TypeScript - No external dependencies                  │   │ │
│   │   └───────────────────────────────────────────────────────────────┘   │ │
│   └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                       INFRASTRUCTURE LAYER                                  │
│   (Firebase Implementations, Firestore Repositories, FCM Gateway)           │
│   Implements interfaces defined in Domain/Application layers                │
│                                                                             │
│   ┌─────────────────────────────┐  ┌──────────────────────────────────────┐ │
│   │      REPOSITORIES          │  │           GATEWAYS                   │ │
│   │  (Firestore Data Access)   │  │  (FCM, External Services)            │ │
│   └─────────────────────────────┘  └──────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Domain entities are pure TypeScript** - No Firebase types, no decorators
2. **Repository interfaces live in the Domain layer** - Implementations in Infrastructure
3. **Gateway interfaces for external services** - FCM, email, external APIs
4. **Use cases have a single `execute` method** - Accept request DTO, return response DTO
5. **Function handlers are thin adapters** - Validate input, call use case, format response
6. **Firebase types never appear in Domain** - All Firebase-specific code is in Infrastructure
7. **Errors are domain-specific** - Mapped to HTTP status codes at the Interface layer

---

## Layer Definitions

### Domain Layer (Innermost)

The domain layer contains:
- **Entities**: Core business objects (User, Shift, Assignment, Household, etc.)
- **Value Objects**: Immutable types representing domain concepts (UserRole, ShiftStatus, AttendanceStatus)
- **Repository Interfaces**: Contracts for data persistence
- **Gateway Interfaces**: Contracts for external services
- **Domain Errors**: Business-level error definitions
- **Business Rules**: Pure functions that validate business constraints

**Key Rule**: This layer has ZERO dependencies on external packages. No Firebase, no Express, nothing.

### Application Layer (Use Cases)

The application layer contains:
- **Use Cases**: Application-specific business logic
- **Request/Response DTOs**: Input/output types for each use case
- **Use Case Interfaces**: Contracts for use case implementations
- **Application Errors**: Application-level error definitions

**Key Rule**: Use cases only depend on Domain layer. They receive repository/gateway interfaces via dependency injection.

### Infrastructure Layer

The infrastructure layer contains:
- **Repository Implementations**: Firestore-backed implementations of domain repository interfaces
- **Gateway Implementations**: FCM, Cloud Scheduler implementations
- **Mappers**: Convert between Firestore documents and Domain entities
- **Firebase DTOs**: Type definitions for Firestore document shapes

**Key Rule**: This layer knows about Firebase but Domain/Application layers don't.

### Interface Layer (Outermost)

The interface layer contains:
- **HTTPS Callable Handlers**: Cloud Function entry points for callable functions
- **Trigger Handlers**: Firestore onCreate/onUpdate/onDelete handlers
- **Scheduled Handlers**: Cloud Scheduler cron job handlers
- **Input Validators**: Request validation using Zod or similar
- **Response Formatters**: Map domain results to HTTP responses
- **Error Mappers**: Convert domain errors to appropriate HTTP status codes

**Key Rule**: Handlers call use cases and translate between HTTP/Firebase triggers and domain operations.

---

## Project Structure

```
functions/
├── package.json
├── tsconfig.json
├── .eslintrc.js
│
└── src/
    ├── index.ts                          # Cloud Function exports
    │
    ├── domain/                           # DOMAIN LAYER
    │   ├── entities/
    │   │   ├── User.ts
    │   │   ├── Shift.ts
    │   │   ├── Assignment.ts
    │   │   ├── Household.ts
    │   │   ├── FamilyUnit.ts
    │   │   ├── Season.ts
    │   │   ├── ShiftTemplate.ts
    │   │   ├── InviteCode.ts
    │   │   └── Message.ts
    │   │
    │   ├── value-objects/
    │   │   ├── UserRole.ts
    │   │   ├── AccountStatus.ts
    │   │   ├── ShiftStatus.ts
    │   │   ├── AttendanceStatus.ts
    │   │   ├── AssignmentType.ts
    │   │   ├── StaffingStatus.ts
    │   │   └── index.ts
    │   │
    │   ├── repositories/                 # Repository Interfaces
    │   │   ├── IUserRepository.ts
    │   │   ├── IShiftRepository.ts
    │   │   ├── IAssignmentRepository.ts
    │   │   ├── IHouseholdRepository.ts
    │   │   ├── IFamilyUnitRepository.ts
    │   │   ├── ISeasonRepository.ts
    │   │   ├── ITemplateRepository.ts
    │   │   ├── IInviteCodeRepository.ts
    │   │   ├── IMessageRepository.ts
    │   │   └── index.ts
    │   │
    │   ├── gateways/                     # Gateway Interfaces
    │   │   ├── INotificationGateway.ts
    │   │   ├── IAuthGateway.ts
    │   │   └── index.ts
    │   │
    │   ├── errors/
    │   │   └── DomainError.ts
    │   │
    │   └── rules/                        # Business Rules
    │       ├── ShiftRules.ts
    │       ├── AttendanceRules.ts
    │       ├── PermissionRules.ts
    │       └── index.ts
    │
    ├── application/                      # APPLICATION LAYER
    │   ├── use-cases/
    │   │   ├── auth/
    │   │   │   ├── ProcessInviteCodeUseCase.ts
    │   │   │   ├── ClaimProfileUseCase.ts
    │   │   │   └── index.ts
    │   │   │
    │   │   ├── family/
    │   │   │   ├── AddFamilyMemberUseCase.ts
    │   │   │   ├── LinkScoutToHouseholdUseCase.ts
    │   │   │   ├── RegenerateHouseholdLinkCodeUseCase.ts
    │   │   │   ├── DeactivateFamilyUseCase.ts
    │   │   │   └── index.ts
    │   │   │
    │   │   ├── schedule/
    │   │   │   ├── GetCurrentSeasonUseCase.ts
    │   │   │   ├── GenerateSeasonScheduleUseCase.ts
    │   │   │   ├── PublishSeasonScheduleUseCase.ts
    │   │   │   ├── UpdateSeasonScheduleUseCase.ts
    │   │   │   ├── GetWeekScheduleViewUseCase.ts
    │   │   │   ├── GetStaffingAlertsUseCase.ts
    │   │   │   └── index.ts
    │   │   │
    │   │   ├── templates/
    │   │   │   ├── ListTemplatesUseCase.ts
    │   │   │   ├── CreateTemplateUseCase.ts
    │   │   │   ├── UpdateTemplateUseCase.ts
    │   │   │   ├── DeleteTemplateUseCase.ts
    │   │   │   └── index.ts
    │   │   │
    │   │   ├── attendance/
    │   │   │   ├── CheckInUseCase.ts
    │   │   │   ├── CheckOutUseCase.ts
    │   │   │   ├── MarkNoShowUseCase.ts
    │   │   │   ├── AddWalkInUseCase.ts
    │   │   │   ├── GetShiftAttendanceUseCase.ts
    │   │   │   ├── GetAttendanceHistoryUseCase.ts
    │   │   │   └── index.ts
    │   │   │
    │   │   ├── reporting/
    │   │   │   ├── GetLeaderboardUseCase.ts
    │   │   │   ├── GetMyStatsUseCase.ts
    │   │   │   ├── GetScoutBucksReportUseCase.ts
    │   │   │   └── index.ts
    │   │   │
    │   │   ├── notifications/
    │   │   │   ├── SendMessageNotificationUseCase.ts
    │   │   │   ├── SendShiftRemindersUseCase.ts
    │   │   │   ├── NotifyNewShiftUseCase.ts
    │   │   │   └── index.ts
    │   │   │
    │   │   └── index.ts
    │   │
    │   ├── dtos/                         # Request/Response DTOs
    │   │   ├── auth/
    │   │   │   ├── ProcessInviteCodeDTO.ts
    │   │   │   └── ClaimProfileDTO.ts
    │   │   ├── family/
    │   │   │   ├── AddFamilyMemberDTO.ts
    │   │   │   └── LinkScoutDTO.ts
    │   │   ├── schedule/
    │   │   │   ├── GenerateScheduleDTO.ts
    │   │   │   └── WeekScheduleDTO.ts
    │   │   ├── attendance/
    │   │   │   ├── CheckInDTO.ts
    │   │   │   └── AttendanceDTO.ts
    │   │   └── index.ts
    │   │
    │   └── errors/
    │       └── ApplicationError.ts
    │
    ├── infrastructure/                   # INFRASTRUCTURE LAYER
    │   ├── firebase/
    │   │   ├── FirebaseAdmin.ts          # Firebase Admin SDK initialization
    │   │   └── FirestoreClient.ts        # Firestore instance
    │   │
    │   ├── repositories/
    │   │   ├── FirestoreUserRepository.ts
    │   │   ├── FirestoreShiftRepository.ts
    │   │   ├── FirestoreAssignmentRepository.ts
    │   │   ├── FirestoreHouseholdRepository.ts
    │   │   ├── FirestoreFamilyUnitRepository.ts
    │   │   ├── FirestoreSeasonRepository.ts
    │   │   ├── FirestoreTemplateRepository.ts
    │   │   ├── FirestoreInviteCodeRepository.ts
    │   │   ├── FirestoreMessageRepository.ts
    │   │   └── index.ts
    │   │
    │   ├── gateways/
    │   │   ├── FCMNotificationGateway.ts
    │   │   ├── FirebaseAuthGateway.ts
    │   │   └── index.ts
    │   │
    │   ├── mappers/
    │   │   ├── UserMapper.ts
    │   │   ├── ShiftMapper.ts
    │   │   ├── AssignmentMapper.ts
    │   │   ├── HouseholdMapper.ts
    │   │   └── index.ts
    │   │
    │   └── dtos/                         # Firebase Document Types
    │       ├── UserDocument.ts
    │       ├── ShiftDocument.ts
    │       ├── AssignmentDocument.ts
    │       └── index.ts
    │
    ├── interface/                        # INTERFACE LAYER
    │   ├── handlers/
    │   │   ├── callable/                 # HTTPS Callable Functions
    │   │   │   ├── auth/
    │   │   │   │   ├── processInviteCode.ts
    │   │   │   │   └── claimProfile.ts
    │   │   │   ├── family/
    │   │   │   │   ├── addFamilyMember.ts
    │   │   │   │   └── linkScoutToHousehold.ts
    │   │   │   ├── schedule/
    │   │   │   │   ├── getCurrentSeason.ts
    │   │   │   │   ├── generateSeasonSchedule.ts
    │   │   │   │   └── getWeekScheduleView.ts
    │   │   │   ├── attendance/
    │   │   │   │   ├── checkIn.ts
    │   │   │   │   ├── checkOut.ts
    │   │   │   │   └── addWalkIn.ts
    │   │   │   ├── reporting/
    │   │   │   │   ├── getLeaderboard.ts
    │   │   │   │   └── getScoutBucksReport.ts
    │   │   │   └── index.ts
    │   │   │
    │   │   ├── triggers/                 # Firestore Triggers
    │   │   │   ├── onShiftCreated.ts
    │   │   │   ├── onMessageCreated.ts
    │   │   │   └── index.ts
    │   │   │
    │   │   └── scheduled/                # Scheduled Functions
    │   │       ├── sendShiftReminders.ts
    │   │       └── index.ts
    │   │
    │   ├── validators/                   # Input Validation (Zod schemas)
    │   │   ├── authValidators.ts
    │   │   ├── familyValidators.ts
    │   │   ├── scheduleValidators.ts
    │   │   ├── attendanceValidators.ts
    │   │   └── index.ts
    │   │
    │   ├── middleware/
    │   │   ├── authMiddleware.ts         # Authentication verification
    │   │   ├── roleMiddleware.ts         # Role-based access control
    │   │   └── index.ts
    │   │
    │   └── errors/
    │       ├── ErrorMapper.ts            # Domain error → HTTP status
    │       └── HttpError.ts
    │
    └── di/                               # DEPENDENCY INJECTION
        ├── Container.ts                  # DI Container
        └── types.ts                      # Injection tokens
```

---

## Domain Layer

### Entity Example: User

```typescript
// src/domain/entities/User.ts

import { UserRole } from '../value-objects/UserRole';
import { AccountStatus } from '../value-objects/AccountStatus';

export interface User {
  readonly id: string;
  readonly email: string | null;
  readonly firstName: string;
  readonly lastName: string;
  readonly displayName: string;
  readonly role: UserRole;
  readonly accountStatus: AccountStatus;
  readonly households: readonly string[];
  readonly canManageHouseholds: readonly string[];
  readonly familyUnitId: string;
  readonly isClaimed: boolean;
  readonly claimCode: string | null;
  readonly householdLinkCode: string | null;
  readonly fcmTokens: readonly string[];
  readonly notificationPreferences: NotificationPreferences;
  readonly createdAt: Date;
  readonly updatedAt: Date;
}

export interface NotificationPreferences {
  readonly newShifts: boolean;
  readonly shiftReminders: boolean;
  readonly committeeMessages: boolean;
}

// Factory function for creating users (ensures valid state)
export function createUser(props: Omit<User, 'displayName'>): User {
  return {
    ...props,
    displayName: `${props.firstName} ${props.lastName}`,
  };
}
```

### Entity Example: Shift

```typescript
// src/domain/entities/Shift.ts

import { ShiftStatus } from '../value-objects/ShiftStatus';

export interface Shift {
  readonly id: string;
  readonly date: Date;
  readonly startTime: Date;
  readonly endTime: Date;
  readonly requiredScouts: number;
  readonly requiredParents: number;
  readonly currentScouts: number;
  readonly currentParents: number;
  readonly location: string;
  readonly label: string;
  readonly notes: string | null;
  readonly status: ShiftStatus;
  readonly seasonId: string | null;
  readonly templateId: string | null;
  readonly isSpecialEvent: boolean;
  readonly createdAt: Date;
  readonly createdBy: string;
}
```

### Value Object Example: UserRole

```typescript
// src/domain/value-objects/UserRole.ts

export const UserRole = {
  ADMIN: 'admin',
  COMMITTEE: 'committee',
  PARENT: 'parent',
  SCOUT: 'scout',
} as const;

export type UserRole = typeof UserRole[keyof typeof UserRole];

// Helper functions
export function isCommitteeOrAdmin(role: UserRole): boolean {
  return role === UserRole.ADMIN || role === UserRole.COMMITTEE;
}

export function canManageShifts(role: UserRole): boolean {
  return isCommitteeOrAdmin(role);
}

export function canManageFamily(role: UserRole): boolean {
  return role === UserRole.PARENT || isCommitteeOrAdmin(role);
}
```

### Value Object Example: AttendanceStatus

```typescript
// src/domain/value-objects/AttendanceStatus.ts

export const AttendanceStatus = {
  PENDING: 'pending',
  CHECKED_IN: 'checked_in',
  CHECKED_OUT: 'checked_out',
  NO_SHOW: 'no_show',
} as const;

export type AttendanceStatus = typeof AttendanceStatus[keyof typeof AttendanceStatus];
```

### Repository Interface Example

```typescript
// src/domain/repositories/IUserRepository.ts

import { User } from '../entities/User';

export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByClaimCode(claimCode: string): Promise<User | null>;
  findByHouseholdLinkCode(code: string): Promise<User | null>;
  findByHousehold(householdId: string): Promise<User[]>;
  findByFamilyUnit(familyUnitId: string): Promise<User[]>;
  findActiveWithFCMTokens(): Promise<User[]>;
  findByRole(role: UserRole): Promise<User[]>;
  save(user: User): Promise<void>;
  update(id: string, updates: Partial<User>): Promise<void>;
  updateBatch(updates: Array<{ id: string; data: Partial<User> }>): Promise<void>;
}
```

```typescript
// src/domain/repositories/IShiftRepository.ts

import { Shift } from '../entities/Shift';
import { ShiftStatus } from '../value-objects/ShiftStatus';

export interface IShiftRepository {
  findById(id: string): Promise<Shift | null>;
  findByDateRange(startDate: Date, endDate: Date): Promise<Shift[]>;
  findBySeason(seasonId: string): Promise<Shift[]>;
  findBySeasonAndStatus(seasonId: string, status: ShiftStatus): Promise<Shift[]>;
  findUpcoming(daysAhead: number): Promise<Shift[]>;
  save(shift: Shift): Promise<string>;
  saveBatch(shifts: Shift[]): Promise<string[]>;
  update(id: string, updates: Partial<Shift>): Promise<void>;
  updateBatch(updates: Array<{ id: string; data: Partial<Shift> }>): Promise<void>;
  delete(id: string): Promise<void>;
}
```

```typescript
// src/domain/repositories/IAssignmentRepository.ts

import { Assignment } from '../entities/Assignment';
import { AttendanceStatus } from '../value-objects/AttendanceStatus';

export interface IAssignmentRepository {
  findById(id: string): Promise<Assignment | null>;
  findByShift(shiftId: string): Promise<Assignment[]>;
  findByUser(userId: string): Promise<Assignment[]>;
  findByUserAndSeason(userId: string, seasonId: string): Promise<Assignment[]>;
  findByHousehold(householdId: string): Promise<Assignment[]>;
  findByFamilyUnit(familyUnitId: string): Promise<Assignment[]>;
  findByShiftAndUser(shiftId: string, userId: string): Promise<Assignment | null>;
  findByAttendanceStatus(status: AttendanceStatus, seasonId?: string): Promise<Assignment[]>;
  findCheckedOutBySeason(seasonId: string): Promise<Assignment[]>;
  save(assignment: Assignment): Promise<string>;
  update(id: string, updates: Partial<Assignment>): Promise<void>;
  delete(id: string): Promise<void>;
}
```

### Gateway Interface Example

```typescript
// src/domain/gateways/INotificationGateway.ts

export interface NotificationPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

export interface INotificationGateway {
  sendToUser(userId: string, payload: NotificationPayload): Promise<void>;
  sendToUsers(userIds: string[], payload: NotificationPayload): Promise<void>;
  sendToTokens(tokens: string[], payload: NotificationPayload): Promise<SendResult>;
  sendToTopic(topic: string, payload: NotificationPayload): Promise<void>;
}

export interface SendResult {
  successCount: number;
  failureCount: number;
  failedTokens: string[];
}
```

### Domain Error

```typescript
// src/domain/errors/DomainError.ts

export class DomainError extends Error {
  constructor(
    public readonly code: DomainErrorCode,
    message: string,
    public readonly details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'DomainError';
  }
}

export enum DomainErrorCode {
  // Auth errors
  INVALID_INVITE_CODE = 'INVALID_INVITE_CODE',
  INVITE_CODE_USED = 'INVITE_CODE_USED',
  INVITE_CODE_EXPIRED = 'INVITE_CODE_EXPIRED',
  INVALID_CLAIM_CODE = 'INVALID_CLAIM_CODE',
  PROFILE_ALREADY_CLAIMED = 'PROFILE_ALREADY_CLAIMED',
  
  // Permission errors
  NOT_AUTHORIZED = 'NOT_AUTHORIZED',
  INACTIVE_USER = 'INACTIVE_USER',
  INACTIVE_FAMILY = 'INACTIVE_FAMILY',
  NOT_HOUSEHOLD_MANAGER = 'NOT_HOUSEHOLD_MANAGER',
  CANNOT_MANAGE_CLAIMED_USER = 'CANNOT_MANAGE_CLAIMED_USER',
  
  // Shift errors
  SHIFT_NOT_FOUND = 'SHIFT_NOT_FOUND',
  SHIFT_FULL = 'SHIFT_FULL',
  SHIFT_NOT_PUBLISHED = 'SHIFT_NOT_PUBLISHED',
  ALREADY_ASSIGNED = 'ALREADY_ASSIGNED',
  NOT_ASSIGNED = 'NOT_ASSIGNED',
  
  // Attendance errors
  SHIFT_NOT_STARTED = 'SHIFT_NOT_STARTED',
  SHIFT_ENDED = 'SHIFT_ENDED',
  ALREADY_CHECKED_IN = 'ALREADY_CHECKED_IN',
  NOT_CHECKED_IN = 'NOT_CHECKED_IN',
  CHECKOUT_WINDOW_EXPIRED = 'CHECKOUT_WINDOW_EXPIRED',
  MUST_CHECK_IN_SELF_FIRST = 'MUST_CHECK_IN_SELF_FIRST',
  
  // Schedule errors
  SEASON_NOT_FOUND = 'SEASON_NOT_FOUND',
  SEASON_NOT_DRAFT = 'SEASON_NOT_DRAFT',
  SEASON_ALREADY_PUBLISHED = 'SEASON_ALREADY_PUBLISHED',
  
  // Template errors
  TEMPLATE_NOT_FOUND = 'TEMPLATE_NOT_FOUND',
  TEMPLATE_NAME_EXISTS = 'TEMPLATE_NAME_EXISTS',
  INVALID_SHIFT_TIMES = 'INVALID_SHIFT_TIMES',
  SHIFTS_OVERLAP = 'SHIFTS_OVERLAP',
  CANNOT_DELETE_USED_TEMPLATE = 'CANNOT_DELETE_USED_TEMPLATE',
  
  // Family errors
  USER_NOT_FOUND = 'USER_NOT_FOUND',
  HOUSEHOLD_NOT_FOUND = 'HOUSEHOLD_NOT_FOUND',
  SCOUT_ALREADY_IN_HOUSEHOLD = 'SCOUT_ALREADY_IN_HOUSEHOLD',
  INVALID_HOUSEHOLD_LINK_CODE = 'INVALID_HOUSEHOLD_LINK_CODE',
  
  // Generic
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  NOT_FOUND = 'NOT_FOUND',
  INTERNAL_ERROR = 'INTERNAL_ERROR',
}
```

### Business Rules

```typescript
// src/domain/rules/AttendanceRules.ts

import { Shift } from '../entities/Shift';
import { Assignment } from '../entities/Assignment';
import { User } from '../entities/User';
import { AttendanceStatus } from '../value-objects/AttendanceStatus';
import { UserRole, isCommitteeOrAdmin } from '../value-objects/UserRole';

const CHECK_IN_WINDOW_MINUTES = 15;
const CHECK_OUT_GRACE_HOURS = 2;

export function canCheckIn(
  shift: Shift,
  assignment: Assignment,
  now: Date = new Date()
): { allowed: boolean; reason?: string } {
  const shiftStart = shift.startTime.getTime();
  const shiftEnd = shift.endTime.getTime();
  const currentTime = now.getTime();
  
  // Check if already checked in
  if (assignment.attendanceStatus === AttendanceStatus.CHECKED_IN) {
    return { allowed: false, reason: 'Already checked in' };
  }
  
  // Check if already checked out
  if (assignment.attendanceStatus === AttendanceStatus.CHECKED_OUT) {
    return { allowed: false, reason: 'Already checked out' };
  }
  
  // Check if shift has ended
  if (currentTime > shiftEnd) {
    return { allowed: false, reason: 'Shift has already ended' };
  }
  
  // Check if too early (more than 15 minutes before start)
  const earliestCheckIn = shiftStart - (CHECK_IN_WINDOW_MINUTES * 60 * 1000);
  if (currentTime < earliestCheckIn) {
    return { allowed: false, reason: 'Shift has not started yet' };
  }
  
  return { allowed: true };
}

export function canCheckInOther(
  caller: User,
  callerAssignment: Assignment | null,
  target: User,
  targetAssignment: Assignment
): { allowed: boolean; reason?: string } {
  // Committee/admin can always check in others
  if (isCommitteeOrAdmin(caller.role)) {
    return { allowed: true };
  }
  
  // Parent can check in scout on same shift if parent is checked in
  if (caller.role !== UserRole.PARENT) {
    return { allowed: false, reason: 'Only parents can check in others' };
  }
  
  if (!callerAssignment) {
    return { allowed: false, reason: 'You must be assigned to this shift' };
  }
  
  if (callerAssignment.attendanceStatus !== AttendanceStatus.CHECKED_IN) {
    return { allowed: false, reason: 'You must check yourself in first' };
  }
  
  if (target.role !== UserRole.SCOUT) {
    return { allowed: false, reason: 'You can only check in scouts' };
  }
  
  if (callerAssignment.shiftId !== targetAssignment.shiftId) {
    return { allowed: false, reason: 'You can only check in scouts on your same shift' };
  }
  
  return { allowed: true };
}

export function canCheckOut(
  shift: Shift,
  assignment: Assignment,
  now: Date = new Date()
): { allowed: boolean; reason?: string } {
  // Must be checked in
  if (assignment.attendanceStatus !== AttendanceStatus.CHECKED_IN) {
    return { allowed: false, reason: 'User is not checked in' };
  }
  
  // Check if within grace period after shift end
  const shiftEnd = shift.endTime.getTime();
  const gracePeriodEnd = shiftEnd + (CHECK_OUT_GRACE_HOURS * 60 * 60 * 1000);
  const currentTime = now.getTime();
  
  if (currentTime > gracePeriodEnd) {
    return { allowed: false, reason: 'Check-out window has expired' };
  }
  
  return { allowed: true };
}

export function calculateHoursWorked(checkInTime: Date, checkOutTime: Date): number {
  const milliseconds = checkOutTime.getTime() - checkInTime.getTime();
  const hours = milliseconds / (1000 * 60 * 60);
  return Math.round(hours * 100) / 100; // Round to 2 decimal places
}
```

```typescript
// src/domain/rules/ShiftRules.ts

import { Shift } from '../entities/Shift';
import { User } from '../entities/User';
import { Assignment } from '../entities/Assignment';
import { ShiftStatus } from '../value-objects/ShiftStatus';
import { StaffingStatus } from '../value-objects/StaffingStatus';

export function canSignUp(
  shift: Shift,
  user: User,
  existingAssignments: Assignment[]
): { allowed: boolean; reason?: string } {
  // Check shift status
  if (shift.status !== ShiftStatus.PUBLISHED) {
    return { allowed: false, reason: 'Shift is not available for signup' };
  }
  
  // Check if user is active
  if (user.accountStatus !== 'active') {
    return { allowed: false, reason: 'Your account is not active' };
  }
  
  // Check if already signed up
  const alreadyAssigned = existingAssignments.some(a => a.userId === user.id);
  if (alreadyAssigned) {
    return { allowed: false, reason: 'Already signed up for this shift' };
  }
  
  // Check capacity based on role
  if (user.role === 'scout') {
    if (shift.currentScouts >= shift.requiredScouts) {
      return { allowed: false, reason: 'Scout slots are full' };
    }
  } else {
    if (shift.currentParents >= shift.requiredParents) {
      return { allowed: false, reason: 'Parent slots are full' };
    }
  }
  
  return { allowed: true };
}

export function calculateStaffingStatus(current: number, required: number): StaffingStatus {
  if (required === 0) return StaffingStatus.FULL;
  
  const percentage = (current / required) * 100;
  
  if (percentage >= 100) return StaffingStatus.FULL;
  if (percentage >= 75) return StaffingStatus.OK;
  if (percentage >= 50) return StaffingStatus.LOW;
  if (percentage >= 25) return StaffingStatus.CRITICAL;
  return StaffingStatus.EMPTY;
}

export function getWorseStatus(a: StaffingStatus, b: StaffingStatus): StaffingStatus {
  const priority = {
    [StaffingStatus.EMPTY]: 0,
    [StaffingStatus.CRITICAL]: 1,
    [StaffingStatus.LOW]: 2,
    [StaffingStatus.OK]: 3,
    [StaffingStatus.FULL]: 4,
  };
  
  return priority[a] < priority[b] ? a : b;
}
```

```typescript
// src/domain/rules/PermissionRules.ts

import { User } from '../entities/User';
import { Assignment } from '../entities/Assignment';
import { isCommitteeOrAdmin } from '../value-objects/UserRole';

export function canManageAssignment(
  caller: User,
  assignment: Assignment,
  targetUser: User
): { allowed: boolean; reason?: string } {
  // Committee/admin can manage any assignment
  if (isCommitteeOrAdmin(caller.role)) {
    return { allowed: true };
  }
  
  // User can manage their own assignment
  if (caller.id === assignment.userId) {
    return { allowed: true };
  }
  
  // Parent can manage unclaimed family member's assignment
  if (caller.role === 'parent') {
    // Check if caller manages a household containing the target
    const sharedHouseholds = caller.canManageHouseholds.filter(
      h => targetUser.households.includes(h)
    );
    
    if (sharedHouseholds.length === 0) {
      return { allowed: false, reason: 'User is not in your household' };
    }
    
    // Check if target is claimed
    if (targetUser.isClaimed) {
      return { allowed: false, reason: 'Cannot manage assignments for users who have claimed their profile' };
    }
    
    // Check if assignment was created by caller's household
    if (!sharedHouseholds.includes(assignment.householdId)) {
      return { allowed: false, reason: 'This assignment was created by another household' };
    }
    
    return { allowed: true };
  }
  
  return { allowed: false, reason: 'Not authorized' };
}
```

---

## Application Layer (Use Cases)

### Use Case Interface Pattern

```typescript
// src/application/use-cases/IUseCase.ts

export interface IUseCase<TRequest, TResponse> {
  execute(request: TRequest): Promise<TResponse>;
}
```

### Use Case Example: CheckIn

```typescript
// src/application/use-cases/attendance/CheckInUseCase.ts

import { IUseCase } from '../IUseCase';
import { IUserRepository } from '../../../domain/repositories/IUserRepository';
import { IShiftRepository } from '../../../domain/repositories/IShiftRepository';
import { IAssignmentRepository } from '../../../domain/repositories/IAssignmentRepository';
import { DomainError, DomainErrorCode } from '../../../domain/errors/DomainError';
import { canCheckIn, canCheckInOther } from '../../../domain/rules/AttendanceRules';
import { AttendanceStatus } from '../../../domain/value-objects/AttendanceStatus';
import { CheckInRequest, CheckInResponse } from '../../dtos/attendance/CheckInDTO';

export class CheckInUseCase implements IUseCase<CheckInRequest, CheckInResponse> {
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly shiftRepository: IShiftRepository,
    private readonly assignmentRepository: IAssignmentRepository
  ) {}

  async execute(request: CheckInRequest): Promise<CheckInResponse> {
    const { callerId, assignmentId, targetUserId, notes } = request;
    const now = new Date();
    
    // Get caller
    const caller = await this.userRepository.findById(callerId);
    if (!caller) {
      throw new DomainError(DomainErrorCode.USER_NOT_FOUND, 'User not found');
    }
    
    if (caller.accountStatus !== 'active') {
      throw new DomainError(DomainErrorCode.INACTIVE_USER, 'Your account is not active');
    }
    
    // Get assignment
    const assignment = await this.assignmentRepository.findById(assignmentId);
    if (!assignment) {
      throw new DomainError(DomainErrorCode.NOT_FOUND, 'Assignment not found');
    }
    
    // Get shift
    const shift = await this.shiftRepository.findById(assignment.shiftId);
    if (!shift) {
      throw new DomainError(DomainErrorCode.SHIFT_NOT_FOUND, 'Shift not found');
    }
    
    // Determine target user
    const effectiveTargetId = targetUserId || callerId;
    const isSelfCheckIn = effectiveTargetId === callerId;
    
    // Validate assignment belongs to target
    if (assignment.userId !== effectiveTargetId) {
      throw new DomainError(
        DomainErrorCode.NOT_AUTHORIZED,
        'Assignment does not belong to target user'
      );
    }
    
    // Check shift timing
    const timingCheck = canCheckIn(shift, assignment, now);
    if (!timingCheck.allowed) {
      throw new DomainError(DomainErrorCode.SHIFT_NOT_STARTED, timingCheck.reason!);
    }
    
    // If checking in someone else, validate permissions
    if (!isSelfCheckIn) {
      const target = await this.userRepository.findById(effectiveTargetId);
      if (!target) {
        throw new DomainError(DomainErrorCode.USER_NOT_FOUND, 'Target user not found');
      }
      
      // Get caller's assignment on this shift
      const callerAssignment = await this.assignmentRepository.findByShiftAndUser(
        shift.id,
        callerId
      );
      
      const permissionCheck = canCheckInOther(caller, callerAssignment, target, assignment);
      if (!permissionCheck.allowed) {
        throw new DomainError(DomainErrorCode.NOT_AUTHORIZED, permissionCheck.reason!);
      }
    }
    
    // Update assignment
    await this.assignmentRepository.update(assignmentId, {
      checkInTime: now,
      checkInBy: callerId,
      checkInByName: caller.displayName,
      attendanceStatus: AttendanceStatus.CHECKED_IN,
      attendanceNotes: notes || null,
    });
    
    return {
      success: true,
      checkInTime: now,
      checkedInBy: callerId,
      checkedInByName: caller.displayName,
    };
  }
}
```

### Use Case Example: GenerateSeasonSchedule

```typescript
// src/application/use-cases/schedule/GenerateSeasonScheduleUseCase.ts

import { IUseCase } from '../IUseCase';
import { IUserRepository } from '../../../domain/repositories/IUserRepository';
import { ISeasonRepository } from '../../../domain/repositories/ISeasonRepository';
import { IShiftRepository } from '../../../domain/repositories/IShiftRepository';
import { ITemplateRepository } from '../../../domain/repositories/ITemplateRepository';
import { DomainError, DomainErrorCode } from '../../../domain/errors/DomainError';
import { isCommitteeOrAdmin } from '../../../domain/value-objects/UserRole';
import { ShiftStatus } from '../../../domain/value-objects/ShiftStatus';
import { Shift } from '../../../domain/entities/Shift';
import {
  GenerateScheduleRequest,
  GenerateScheduleResponse,
} from '../../dtos/schedule/GenerateScheduleDTO';

export class GenerateSeasonScheduleUseCase
  implements IUseCase<GenerateScheduleRequest, GenerateScheduleResponse>
{
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly seasonRepository: ISeasonRepository,
    private readonly shiftRepository: IShiftRepository,
    private readonly templateRepository: ITemplateRepository
  ) {}

  async execute(request: GenerateScheduleRequest): Promise<GenerateScheduleResponse> {
    const {
      callerId,
      seasonName,
      startDate,
      endDate,
      templateIds,
      specialDates,
      location,
    } = request;

    // Validate caller permissions
    const caller = await this.userRepository.findById(callerId);
    if (!caller || !isCommitteeOrAdmin(caller.role)) {
      throw new DomainError(DomainErrorCode.NOT_AUTHORIZED, 'Not authorized to create schedules');
    }

    // Load templates
    const templates = await Promise.all(
      templateIds.map(id => this.templateRepository.findById(id))
    );
    
    const validTemplates = templates.filter((t): t is NonNullable<typeof t> => t !== null);
    if (validTemplates.length !== templateIds.length) {
      throw new DomainError(DomainErrorCode.TEMPLATE_NOT_FOUND, 'One or more templates not found');
    }

    // Create season record
    const seasonId = await this.seasonRepository.save({
      id: '', // Will be assigned by repository
      name: seasonName,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      status: 'draft',
      templateIds,
      location,
      createdBy: callerId,
      createdAt: new Date(),
      publishedAt: null,
    });

    // Generate shifts for each date
    const shifts: Omit<Shift, 'id'>[] = [];
    const start = new Date(startDate);
    const end = new Date(endDate);
    
    for (let date = new Date(start); date <= end; date.setDate(date.getDate() + 1)) {
      const currentDate = new Date(date);
      const dayOfWeek = currentDate.getDay();
      
      // Check for special dates
      const specialDate = specialDates?.find(
        sd => sd.date === currentDate.toISOString().split('T')[0]
      );
      
      if (specialDate?.isClosed) {
        continue; // Skip closed days
      }
      
      if (specialDate?.customShifts) {
        // Use custom shifts for this day
        for (const customShift of specialDate.customShifts) {
          shifts.push(this.createShift(currentDate, customShift, seasonId, null, callerId, location, true));
        }
      } else {
        // Find matching template
        const template = validTemplates.find(t => t.dayOfWeek.includes(dayOfWeek));
        
        if (template) {
          for (const templateShift of template.shifts) {
            shifts.push(this.createShift(
              currentDate,
              templateShift,
              seasonId,
              template.id,
              callerId,
              location,
              false
            ));
          }
        }
      }
    }

    // Batch save all shifts
    await this.shiftRepository.saveBatch(shifts as Shift[]);

    return {
      success: true,
      seasonId,
      shiftsCreated: shifts.length,
      dateRange: {
        start: startDate,
        end: endDate,
      },
    };
  }

  private createShift(
    date: Date,
    shiftDef: { startTime: string; endTime: string; requiredScouts: number; requiredParents: number; label: string; notes?: string },
    seasonId: string,
    templateId: string | null,
    createdBy: string,
    location: string,
    isSpecialEvent: boolean
  ): Omit<Shift, 'id'> {
    const [startHour, startMin] = shiftDef.startTime.split(':').map(Number);
    const [endHour, endMin] = shiftDef.endTime.split(':').map(Number);
    
    const startTime = new Date(date);
    startTime.setHours(startHour, startMin, 0, 0);
    
    const endTime = new Date(date);
    endTime.setHours(endHour, endMin, 0, 0);
    
    return {
      date: new Date(date),
      startTime,
      endTime,
      requiredScouts: shiftDef.requiredScouts,
      requiredParents: shiftDef.requiredParents,
      currentScouts: 0,
      currentParents: 0,
      location,
      label: shiftDef.label,
      notes: shiftDef.notes || null,
      status: ShiftStatus.DRAFT,
      seasonId,
      templateId,
      isSpecialEvent,
      createdAt: new Date(),
      createdBy,
    };
  }
}
```

### Use Case Example: GetLeaderboard

```typescript
// src/application/use-cases/reporting/GetLeaderboardUseCase.ts

import { IUseCase } from '../IUseCase';
import { IUserRepository } from '../../../domain/repositories/IUserRepository';
import { IAssignmentRepository } from '../../../domain/repositories/IAssignmentRepository';
import { IFamilyUnitRepository } from '../../../domain/repositories/IFamilyUnitRepository';
import { ISeasonRepository } from '../../../domain/repositories/ISeasonRepository';
import { DomainError, DomainErrorCode } from '../../../domain/errors/DomainError';
import { AttendanceStatus } from '../../../domain/value-objects/AttendanceStatus';
import {
  GetLeaderboardRequest,
  GetLeaderboardResponse,
  LeaderboardEntry,
} from '../../dtos/reporting/LeaderboardDTO';

export class GetLeaderboardUseCase
  implements IUseCase<GetLeaderboardRequest, GetLeaderboardResponse>
{
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly assignmentRepository: IAssignmentRepository,
    private readonly familyUnitRepository: IFamilyUnitRepository,
    private readonly seasonRepository: ISeasonRepository
  ) {}

  async execute(request: GetLeaderboardRequest): Promise<GetLeaderboardResponse> {
    const { callerId, type, seasonId, limit = 10 } = request;

    // Validate caller
    const caller = await this.userRepository.findById(callerId);
    if (!caller || caller.accountStatus !== 'active') {
      throw new DomainError(DomainErrorCode.INACTIVE_USER, 'User not active');
    }

    // Get season (or current season)
    const effectiveSeasonId = seasonId || (await this.getCurrentSeasonId());
    
    // Get all checked-out assignments for the season
    const assignments = await this.assignmentRepository.findCheckedOutBySeason(effectiveSeasonId);

    let leaderboard: LeaderboardEntry[];
    
    if (type === 'individual') {
      leaderboard = await this.calculateIndividualLeaderboard(assignments, limit);
    } else {
      leaderboard = await this.calculateFamilyLeaderboard(assignments, limit);
    }

    // Calculate caller's rank
    const currentUserRank = await this.findCallerRank(assignments, callerId, type);
    const currentFamilyRank = await this.findFamilyRank(assignments, caller.familyUnitId);

    return {
      type,
      seasonId: effectiveSeasonId,
      lastUpdated: new Date(),
      leaderboard,
      currentUserRank,
      currentFamilyRank,
    };
  }

  private async calculateIndividualLeaderboard(
    assignments: Assignment[],
    limit: number
  ): Promise<LeaderboardEntry[]> {
    // Group by userId
    const userHours = new Map<string, { hours: number; shifts: number }>();
    
    for (const assignment of assignments) {
      const existing = userHours.get(assignment.userId) || { hours: 0, shifts: 0 };
      existing.hours += assignment.hoursWorked || 0;
      existing.shifts += 1;
      userHours.set(assignment.userId, existing);
    }

    // Sort by hours descending, shifts as tiebreaker
    const sorted = Array.from(userHours.entries())
      .sort((a, b) => {
        if (b[1].hours !== a[1].hours) return b[1].hours - a[1].hours;
        return b[1].shifts - a[1].shifts;
      })
      .slice(0, limit);

    // Enrich with user names
    const entries: LeaderboardEntry[] = [];
    let rank = 1;
    
    for (const [userId, stats] of sorted) {
      const user = await this.userRepository.findById(userId);
      entries.push({
        rank,
        id: userId,
        name: user?.displayName || 'Unknown',
        totalHours: stats.hours,
        totalShifts: stats.shifts,
        isCurrentUser: false, // Will be set by caller
      });
      rank++;
    }

    return entries;
  }

  private async calculateFamilyLeaderboard(
    assignments: Assignment[],
    limit: number
  ): Promise<LeaderboardEntry[]> {
    // Group by familyUnitId
    const familyHours = new Map<string, { hours: number; shifts: number }>();
    
    for (const assignment of assignments) {
      const familyUnitId = assignment.familyUnitId;
      const existing = familyHours.get(familyUnitId) || { hours: 0, shifts: 0 };
      existing.hours += assignment.hoursWorked || 0;
      existing.shifts += 1;
      familyHours.set(familyUnitId, existing);
    }

    // Sort by hours descending
    const sorted = Array.from(familyHours.entries())
      .sort((a, b) => {
        if (b[1].hours !== a[1].hours) return b[1].hours - a[1].hours;
        return b[1].shifts - a[1].shifts;
      })
      .slice(0, limit);

    // Enrich with family unit names
    const entries: LeaderboardEntry[] = [];
    let rank = 1;
    
    for (const [familyUnitId, stats] of sorted) {
      const familyUnit = await this.familyUnitRepository.findById(familyUnitId);
      entries.push({
        rank,
        id: familyUnitId,
        name: familyUnit?.name || 'Unknown Family',
        totalHours: stats.hours,
        totalShifts: stats.shifts,
        isCurrentUser: false,
      });
      rank++;
    }

    return entries;
  }

  private async getCurrentSeasonId(): Promise<string> {
    const season = await this.seasonRepository.findCurrent();
    if (!season) {
      throw new DomainError(DomainErrorCode.SEASON_NOT_FOUND, 'No active season found');
    }
    return season.id;
  }

  private async findCallerRank(
    assignments: Assignment[],
    callerId: string,
    type: 'individual' | 'family'
  ): Promise<{ rank: number; totalHours: number; totalShifts: number }> {
    // Implementation similar to leaderboard calculation but finding specific user's rank
    // ... (omitted for brevity)
    return { rank: 0, totalHours: 0, totalShifts: 0 };
  }

  private async findFamilyRank(
    assignments: Assignment[],
    familyUnitId: string
  ): Promise<{ rank: number; familyUnitId: string; familyUnitName: string; totalHours: number; totalShifts: number }> {
    // Implementation finding specific family's rank
    // ... (omitted for brevity)
    return { rank: 0, familyUnitId: '', familyUnitName: '', totalHours: 0, totalShifts: 0 };
  }
}
```

### DTOs (Request/Response)

```typescript
// src/application/dtos/attendance/CheckInDTO.ts

export interface CheckInRequest {
  callerId: string;
  assignmentId: string;
  targetUserId?: string;
  notes?: string;
}

export interface CheckInResponse {
  success: boolean;
  checkInTime: Date;
  checkedInBy: string;
  checkedInByName: string;
}
```

```typescript
// src/application/dtos/schedule/GenerateScheduleDTO.ts

export interface GenerateScheduleRequest {
  callerId: string;
  seasonName: string;
  startDate: string;
  endDate: string;
  templateIds: string[];
  specialDates?: SpecialDate[];
  location: string;
  notifyOnPublish?: boolean;
}

export interface SpecialDate {
  date: string;
  isClosed?: boolean;
  customShifts?: ShiftDefinition[];
}

export interface ShiftDefinition {
  startTime: string;
  endTime: string;
  requiredScouts: number;
  requiredParents: number;
  label: string;
  notes?: string;
}

export interface GenerateScheduleResponse {
  success: boolean;
  seasonId: string;
  shiftsCreated: number;
  dateRange: {
    start: string;
    end: string;
  };
}
```

---

## Infrastructure Layer

### Repository Implementation Example

```typescript
// src/infrastructure/repositories/FirestoreUserRepository.ts

import { Firestore, FieldValue } from 'firebase-admin/firestore';
import { IUserRepository } from '../../domain/repositories/IUserRepository';
import { User } from '../../domain/entities/User';
import { UserRole } from '../../domain/value-objects/UserRole';
import { UserMapper } from '../mappers/UserMapper';
import { UserDocument } from '../dtos/UserDocument';

export class FirestoreUserRepository implements IUserRepository {
  private readonly collection: FirebaseFirestore.CollectionReference;

  constructor(firestore: Firestore) {
    this.collection = firestore.collection('users');
  }

  async findById(id: string): Promise<User | null> {
    const doc = await this.collection.doc(id).get();
    if (!doc.exists) return null;
    return UserMapper.toDomain(doc.id, doc.data() as UserDocument);
  }

  async findByClaimCode(claimCode: string): Promise<User | null> {
    const snapshot = await this.collection
      .where('claimCode', '==', claimCode)
      .limit(1)
      .get();
    
    if (snapshot.empty) return null;
    const doc = snapshot.docs[0];
    return UserMapper.toDomain(doc.id, doc.data() as UserDocument);
  }

  async findByHouseholdLinkCode(code: string): Promise<User | null> {
    const snapshot = await this.collection
      .where('householdLinkCode', '==', code)
      .limit(1)
      .get();
    
    if (snapshot.empty) return null;
    const doc = snapshot.docs[0];
    return UserMapper.toDomain(doc.id, doc.data() as UserDocument);
  }

  async findByHousehold(householdId: string): Promise<User[]> {
    const snapshot = await this.collection
      .where('households', 'array-contains', householdId)
      .get();
    
    return snapshot.docs.map(doc => 
      UserMapper.toDomain(doc.id, doc.data() as UserDocument)
    );
  }

  async findByFamilyUnit(familyUnitId: string): Promise<User[]> {
    const snapshot = await this.collection
      .where('familyUnitId', '==', familyUnitId)
      .get();
    
    return snapshot.docs.map(doc => 
      UserMapper.toDomain(doc.id, doc.data() as UserDocument)
    );
  }

  async findActiveWithFCMTokens(): Promise<User[]> {
    const snapshot = await this.collection
      .where('accountStatus', '==', 'active')
      .get();
    
    return snapshot.docs
      .map(doc => UserMapper.toDomain(doc.id, doc.data() as UserDocument))
      .filter(user => user.fcmTokens.length > 0);
  }

  async findByRole(role: UserRole): Promise<User[]> {
    const snapshot = await this.collection
      .where('role', '==', role)
      .get();
    
    return snapshot.docs.map(doc => 
      UserMapper.toDomain(doc.id, doc.data() as UserDocument)
    );
  }

  async save(user: User): Promise<void> {
    const document = UserMapper.toDocument(user);
    await this.collection.doc(user.id).set(document);
  }

  async update(id: string, updates: Partial<User>): Promise<void> {
    const documentUpdates = UserMapper.toPartialDocument(updates);
    documentUpdates.updatedAt = FieldValue.serverTimestamp();
    await this.collection.doc(id).update(documentUpdates);
  }

  async updateBatch(updates: Array<{ id: string; data: Partial<User> }>): Promise<void> {
    const batch = this.collection.firestore.batch();
    
    for (const update of updates) {
      const documentUpdates = UserMapper.toPartialDocument(update.data);
      documentUpdates.updatedAt = FieldValue.serverTimestamp();
      batch.update(this.collection.doc(update.id), documentUpdates);
    }
    
    await batch.commit();
  }
}
```

### Mapper Example

```typescript
// src/infrastructure/mappers/UserMapper.ts

import { User, createUser, NotificationPreferences } from '../../domain/entities/User';
import { UserRole } from '../../domain/value-objects/UserRole';
import { AccountStatus } from '../../domain/value-objects/AccountStatus';
import { UserDocument } from '../dtos/UserDocument';

export class UserMapper {
  static toDomain(id: string, doc: UserDocument): User {
    return createUser({
      id,
      email: doc.email || null,
      firstName: doc.firstName,
      lastName: doc.lastName,
      role: doc.role as UserRole,
      accountStatus: doc.accountStatus as AccountStatus,
      households: doc.households || [],
      canManageHouseholds: doc.canManageHouseholds || [],
      familyUnitId: doc.familyUnitId,
      isClaimed: doc.isClaimed ?? false,
      claimCode: doc.claimCode || null,
      householdLinkCode: doc.householdLinkCode || null,
      fcmTokens: doc.fcmTokens || [],
      notificationPreferences: {
        newShifts: doc.notificationPreferences?.newShifts ?? true,
        shiftReminders: doc.notificationPreferences?.shiftReminders ?? true,
        committeeMessages: doc.notificationPreferences?.committeeMessages ?? true,
      },
      createdAt: doc.createdAt?.toDate() || new Date(),
      updatedAt: doc.updatedAt?.toDate() || new Date(),
    });
  }

  static toDocument(user: User): UserDocument {
    return {
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      displayName: user.displayName,
      role: user.role,
      accountStatus: user.accountStatus,
      households: [...user.households],
      canManageHouseholds: [...user.canManageHouseholds],
      familyUnitId: user.familyUnitId,
      isClaimed: user.isClaimed,
      claimCode: user.claimCode,
      householdLinkCode: user.householdLinkCode,
      fcmTokens: [...user.fcmTokens],
      notificationPreferences: { ...user.notificationPreferences },
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }

  static toPartialDocument(updates: Partial<User>): Record<string, any> {
    const doc: Record<string, any> = {};
    
    if (updates.email !== undefined) doc.email = updates.email;
    if (updates.firstName !== undefined) doc.firstName = updates.firstName;
    if (updates.lastName !== undefined) doc.lastName = updates.lastName;
    if (updates.role !== undefined) doc.role = updates.role;
    if (updates.accountStatus !== undefined) doc.accountStatus = updates.accountStatus;
    if (updates.households !== undefined) doc.households = [...updates.households];
    if (updates.canManageHouseholds !== undefined) {
      doc.canManageHouseholds = [...updates.canManageHouseholds];
    }
    if (updates.isClaimed !== undefined) doc.isClaimed = updates.isClaimed;
    if (updates.claimCode !== undefined) doc.claimCode = updates.claimCode;
    if (updates.householdLinkCode !== undefined) {
      doc.householdLinkCode = updates.householdLinkCode;
    }
    if (updates.fcmTokens !== undefined) doc.fcmTokens = [...updates.fcmTokens];
    if (updates.notificationPreferences !== undefined) {
      doc.notificationPreferences = { ...updates.notificationPreferences };
    }
    
    return doc;
  }
}
```

### Gateway Implementation Example

```typescript
// src/infrastructure/gateways/FCMNotificationGateway.ts

import { getMessaging, Message, MulticastMessage } from 'firebase-admin/messaging';
import { INotificationGateway, NotificationPayload, SendResult } from '../../domain/gateways/INotificationGateway';
import { IUserRepository } from '../../domain/repositories/IUserRepository';

export class FCMNotificationGateway implements INotificationGateway {
  constructor(private readonly userRepository: IUserRepository) {}

  async sendToUser(userId: string, payload: NotificationPayload): Promise<void> {
    const user = await this.userRepository.findById(userId);
    if (!user || user.fcmTokens.length === 0) return;

    await this.sendToTokens(user.fcmTokens as string[], payload);
  }

  async sendToUsers(userIds: string[], payload: NotificationPayload): Promise<void> {
    const users = await Promise.all(
      userIds.map(id => this.userRepository.findById(id))
    );
    
    const tokens = users
      .filter((u): u is NonNullable<typeof u> => u !== null)
      .flatMap(u => u.fcmTokens as string[]);
    
    if (tokens.length > 0) {
      await this.sendToTokens(tokens, payload);
    }
  }

  async sendToTokens(tokens: string[], payload: NotificationPayload): Promise<SendResult> {
    if (tokens.length === 0) {
      return { successCount: 0, failureCount: 0, failedTokens: [] };
    }

    const messaging = getMessaging();
    
    // FCM has a limit of 500 tokens per multicast
    const batches = this.chunkArray(tokens, 500);
    let successCount = 0;
    let failureCount = 0;
    const failedTokens: string[] = [];

    for (const batch of batches) {
      const message: MulticastMessage = {
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: payload.data,
        tokens: batch,
      };

      try {
        const response = await messaging.sendEachForMulticast(message);
        successCount += response.successCount;
        failureCount += response.failureCount;

        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(batch[idx]);
          }
        });
      } catch (error) {
        failureCount += batch.length;
        failedTokens.push(...batch);
      }
    }

    return { successCount, failureCount, failedTokens };
  }

  async sendToTopic(topic: string, payload: NotificationPayload): Promise<void> {
    const messaging = getMessaging();
    
    const message: Message = {
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data,
      topic,
    };

    await messaging.send(message);
  }

  private chunkArray<T>(array: T[], size: number): T[][] {
    const chunks: T[][] = [];
    for (let i = 0; i < array.length; i += size) {
      chunks.push(array.slice(i, i + size));
    }
    return chunks;
  }
}
```

---

## Interface Layer (Function Handlers)

### Callable Function Handler Example

```typescript
// src/interface/handlers/callable/attendance/checkIn.ts

import * as functions from 'firebase-functions';
import { z } from 'zod';
import { container } from '../../../../di/Container';
import { CheckInUseCase } from '../../../../application/use-cases/attendance/CheckInUseCase';
import { mapDomainErrorToHttps } from '../../../errors/ErrorMapper';

const CheckInSchema = z.object({
  assignmentId: z.string().min(1),
  targetUserId: z.string().optional(),
  notes: z.string().optional(),
});

export const checkIn = functions.https.onCall(async (data, context) => {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  // Validate input
  const parseResult = CheckInSchema.safeParse(data);
  if (!parseResult.success) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Invalid input',
      parseResult.error.flatten()
    );
  }

  const { assignmentId, targetUserId, notes } = parseResult.data;

  try {
    const useCase = container.resolve<CheckInUseCase>('CheckInUseCase');
    
    const result = await useCase.execute({
      callerId: context.auth.uid,
      assignmentId,
      targetUserId,
      notes,
    });

    return {
      success: result.success,
      checkInTime: result.checkInTime.toISOString(),
      checkedInBy: result.checkedInBy,
      checkedInByName: result.checkedInByName,
    };
  } catch (error) {
    throw mapDomainErrorToHttps(error);
  }
});
```

### Trigger Handler Example

```typescript
// src/interface/handlers/triggers/onMessageCreated.ts

import * as functions from 'firebase-functions';
import { container } from '../../../di/Container';
import { SendMessageNotificationUseCase } from '../../../application/use-cases/notifications/SendMessageNotificationUseCase';

export const onMessageCreated = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snap, context) => {
    const messageId = context.params.messageId;
    const messageData = snap.data();

    try {
      const useCase = container.resolve<SendMessageNotificationUseCase>(
        'SendMessageNotificationUseCase'
      );

      await useCase.execute({
        messageId,
        title: messageData.title,
        body: messageData.body,
        targetAudience: messageData.targetAudience,
        priority: messageData.priority,
        senderId: messageData.createdBy,
      });

      console.log(`Notifications sent for message ${messageId}`);
    } catch (error) {
      console.error(`Failed to send notifications for message ${messageId}:`, error);
      // Don't rethrow - we don't want to retry notification failures
    }
  });
```

### Scheduled Function Handler Example

```typescript
// src/interface/handlers/scheduled/sendShiftReminders.ts

import * as functions from 'firebase-functions';
import { container } from '../../../di/Container';
import { SendShiftRemindersUseCase } from '../../../application/use-cases/notifications/SendShiftRemindersUseCase';

export const sendShiftReminders = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async () => {
    try {
      const useCase = container.resolve<SendShiftRemindersUseCase>(
        'SendShiftRemindersUseCase'
      );

      const result = await useCase.execute({
        reminderWindowHours: 24,
      });

      console.log(`Sent ${result.remindersSent} shift reminders`);
    } catch (error) {
      console.error('Failed to send shift reminders:', error);
      throw error; // Rethrow to trigger retry
    }
  });
```

### Error Mapper

```typescript
// src/interface/errors/ErrorMapper.ts

import * as functions from 'firebase-functions';
import { DomainError, DomainErrorCode } from '../../domain/errors/DomainError';

const errorCodeToHttpStatus: Record<DomainErrorCode, functions.https.FunctionsErrorCode> = {
  // Auth errors
  [DomainErrorCode.INVALID_INVITE_CODE]: 'not-found',
  [DomainErrorCode.INVITE_CODE_USED]: 'already-exists',
  [DomainErrorCode.INVITE_CODE_EXPIRED]: 'failed-precondition',
  [DomainErrorCode.INVALID_CLAIM_CODE]: 'not-found',
  [DomainErrorCode.PROFILE_ALREADY_CLAIMED]: 'already-exists',
  
  // Permission errors
  [DomainErrorCode.NOT_AUTHORIZED]: 'permission-denied',
  [DomainErrorCode.INACTIVE_USER]: 'permission-denied',
  [DomainErrorCode.INACTIVE_FAMILY]: 'permission-denied',
  [DomainErrorCode.NOT_HOUSEHOLD_MANAGER]: 'permission-denied',
  [DomainErrorCode.CANNOT_MANAGE_CLAIMED_USER]: 'permission-denied',
  
  // Shift errors
  [DomainErrorCode.SHIFT_NOT_FOUND]: 'not-found',
  [DomainErrorCode.SHIFT_FULL]: 'failed-precondition',
  [DomainErrorCode.SHIFT_NOT_PUBLISHED]: 'failed-precondition',
  [DomainErrorCode.ALREADY_ASSIGNED]: 'already-exists',
  [DomainErrorCode.NOT_ASSIGNED]: 'not-found',
  
  // Attendance errors
  [DomainErrorCode.SHIFT_NOT_STARTED]: 'failed-precondition',
  [DomainErrorCode.SHIFT_ENDED]: 'failed-precondition',
  [DomainErrorCode.ALREADY_CHECKED_IN]: 'already-exists',
  [DomainErrorCode.NOT_CHECKED_IN]: 'failed-precondition',
  [DomainErrorCode.CHECKOUT_WINDOW_EXPIRED]: 'deadline-exceeded',
  [DomainErrorCode.MUST_CHECK_IN_SELF_FIRST]: 'failed-precondition',
  
  // Schedule errors
  [DomainErrorCode.SEASON_NOT_FOUND]: 'not-found',
  [DomainErrorCode.SEASON_NOT_DRAFT]: 'failed-precondition',
  [DomainErrorCode.SEASON_ALREADY_PUBLISHED]: 'already-exists',
  
  // Template errors
  [DomainErrorCode.TEMPLATE_NOT_FOUND]: 'not-found',
  [DomainErrorCode.TEMPLATE_NAME_EXISTS]: 'already-exists',
  [DomainErrorCode.INVALID_SHIFT_TIMES]: 'invalid-argument',
  [DomainErrorCode.SHIFTS_OVERLAP]: 'invalid-argument',
  [DomainErrorCode.CANNOT_DELETE_USED_TEMPLATE]: 'failed-precondition',
  
  // Family errors
  [DomainErrorCode.USER_NOT_FOUND]: 'not-found',
  [DomainErrorCode.HOUSEHOLD_NOT_FOUND]: 'not-found',
  [DomainErrorCode.SCOUT_ALREADY_IN_HOUSEHOLD]: 'already-exists',
  [DomainErrorCode.INVALID_HOUSEHOLD_LINK_CODE]: 'not-found',
  
  // Generic
  [DomainErrorCode.VALIDATION_ERROR]: 'invalid-argument',
  [DomainErrorCode.NOT_FOUND]: 'not-found',
  [DomainErrorCode.INTERNAL_ERROR]: 'internal',
};

export function mapDomainErrorToHttps(error: unknown): functions.https.HttpsError {
  if (error instanceof DomainError) {
    const status = errorCodeToHttpStatus[error.code] || 'internal';
    return new functions.https.HttpsError(status, error.message, {
      code: error.code,
      details: error.details,
    });
  }

  if (error instanceof functions.https.HttpsError) {
    return error;
  }

  console.error('Unexpected error:', error);
  return new functions.https.HttpsError('internal', 'An unexpected error occurred');
}
```

### Input Validators (Zod Schemas)

```typescript
// src/interface/validators/attendanceValidators.ts

import { z } from 'zod';

export const CheckInSchema = z.object({
  assignmentId: z.string().min(1, 'Assignment ID is required'),
  targetUserId: z.string().optional(),
  notes: z.string().max(500).optional(),
});

export const CheckOutSchema = z.object({
  assignmentId: z.string().min(1, 'Assignment ID is required'),
  targetUserId: z.string().optional(),
  notes: z.string().max(500).optional(),
});

export const MarkNoShowSchema = z.object({
  assignmentId: z.string().min(1, 'Assignment ID is required'),
  notes: z.string().max(500).optional(),
});

export const AddWalkInSchema = z.object({
  shiftId: z.string().min(1, 'Shift ID is required'),
  userId: z.string().min(1, 'User ID is required'),
  coveringForUserId: z.string().optional(),
  notes: z.string().max(500).optional(),
});

export const GetShiftAttendanceSchema = z.object({
  shiftId: z.string().min(1, 'Shift ID is required'),
});

export const GetAttendanceHistorySchema = z.object({
  userId: z.string().optional(),
  householdId: z.string().optional(),
  seasonId: z.string().optional(),
});
```

```typescript
// src/interface/validators/scheduleValidators.ts

import { z } from 'zod';

export const GenerateScheduleSchema = z.object({
  seasonName: z.string().min(1).max(100),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
  templateIds: z.array(z.string().min(1)).min(1, 'At least one template required'),
  specialDates: z.array(z.object({
    date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    isClosed: z.boolean().optional(),
    customShifts: z.array(z.object({
      startTime: z.string().regex(/^\d{2}:\d{2}$/),
      endTime: z.string().regex(/^\d{2}:\d{2}$/),
      requiredScouts: z.number().int().min(0),
      requiredParents: z.number().int().min(0),
      label: z.string().min(1).max(100),
      notes: z.string().max(500).optional(),
    })).optional(),
  })).optional(),
  location: z.string().min(1).max(200),
  notifyOnPublish: z.boolean().optional(),
}).refine(data => new Date(data.startDate) < new Date(data.endDate), {
  message: 'End date must be after start date',
});

export const GetWeekScheduleSchema = z.object({
  weekStartDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)'),
  seasonId: z.string().optional(),
});

export const GetCurrentSeasonSchema = z.object({
  includeAll: z.boolean().optional(),
});
```

---

## Dependency Injection

### Container Setup

```typescript
// src/di/Container.ts

import { getFirestore } from 'firebase-admin/firestore';
import { initializeApp } from 'firebase-admin/app';

// Initialize Firebase
initializeApp();

// Import repositories
import { FirestoreUserRepository } from '../infrastructure/repositories/FirestoreUserRepository';
import { FirestoreShiftRepository } from '../infrastructure/repositories/FirestoreShiftRepository';
import { FirestoreAssignmentRepository } from '../infrastructure/repositories/FirestoreAssignmentRepository';
import { FirestoreHouseholdRepository } from '../infrastructure/repositories/FirestoreHouseholdRepository';
import { FirestoreFamilyUnitRepository } from '../infrastructure/repositories/FirestoreFamilyUnitRepository';
import { FirestoreSeasonRepository } from '../infrastructure/repositories/FirestoreSeasonRepository';
import { FirestoreTemplateRepository } from '../infrastructure/repositories/FirestoreTemplateRepository';
import { FirestoreInviteCodeRepository } from '../infrastructure/repositories/FirestoreInviteCodeRepository';
import { FirestoreMessageRepository } from '../infrastructure/repositories/FirestoreMessageRepository';

// Import gateways
import { FCMNotificationGateway } from '../infrastructure/gateways/FCMNotificationGateway';

// Import use cases
import { CheckInUseCase } from '../application/use-cases/attendance/CheckInUseCase';
import { CheckOutUseCase } from '../application/use-cases/attendance/CheckOutUseCase';
import { MarkNoShowUseCase } from '../application/use-cases/attendance/MarkNoShowUseCase';
import { AddWalkInUseCase } from '../application/use-cases/attendance/AddWalkInUseCase';
import { GetShiftAttendanceUseCase } from '../application/use-cases/attendance/GetShiftAttendanceUseCase';
import { GetAttendanceHistoryUseCase } from '../application/use-cases/attendance/GetAttendanceHistoryUseCase';
import { GenerateSeasonScheduleUseCase } from '../application/use-cases/schedule/GenerateSeasonScheduleUseCase';
import { PublishSeasonScheduleUseCase } from '../application/use-cases/schedule/PublishSeasonScheduleUseCase';
import { GetCurrentSeasonUseCase } from '../application/use-cases/schedule/GetCurrentSeasonUseCase';
import { GetWeekScheduleViewUseCase } from '../application/use-cases/schedule/GetWeekScheduleViewUseCase';
import { GetLeaderboardUseCase } from '../application/use-cases/reporting/GetLeaderboardUseCase';
import { GetMyStatsUseCase } from '../application/use-cases/reporting/GetMyStatsUseCase';
import { GetScoutBucksReportUseCase } from '../application/use-cases/reporting/GetScoutBucksReportUseCase';
import { SendMessageNotificationUseCase } from '../application/use-cases/notifications/SendMessageNotificationUseCase';
import { SendShiftRemindersUseCase } from '../application/use-cases/notifications/SendShiftRemindersUseCase';
// ... more use case imports

class Container {
  private instances = new Map<string, unknown>();
  private factories = new Map<string, () => unknown>();

  constructor() {
    this.registerDependencies();
  }

  private registerDependencies(): void {
    const firestore = getFirestore();

    // Register repositories (singletons)
    const userRepository = new FirestoreUserRepository(firestore);
    const shiftRepository = new FirestoreShiftRepository(firestore);
    const assignmentRepository = new FirestoreAssignmentRepository(firestore);
    const householdRepository = new FirestoreHouseholdRepository(firestore);
    const familyUnitRepository = new FirestoreFamilyUnitRepository(firestore);
    const seasonRepository = new FirestoreSeasonRepository(firestore);
    const templateRepository = new FirestoreTemplateRepository(firestore);
    const inviteCodeRepository = new FirestoreInviteCodeRepository(firestore);
    const messageRepository = new FirestoreMessageRepository(firestore);

    this.instances.set('UserRepository', userRepository);
    this.instances.set('ShiftRepository', shiftRepository);
    this.instances.set('AssignmentRepository', assignmentRepository);
    this.instances.set('HouseholdRepository', householdRepository);
    this.instances.set('FamilyUnitRepository', familyUnitRepository);
    this.instances.set('SeasonRepository', seasonRepository);
    this.instances.set('TemplateRepository', templateRepository);
    this.instances.set('InviteCodeRepository', inviteCodeRepository);
    this.instances.set('MessageRepository', messageRepository);

    // Register gateways
    const notificationGateway = new FCMNotificationGateway(userRepository);
    this.instances.set('NotificationGateway', notificationGateway);

    // Register use case factories
    this.factories.set('CheckInUseCase', () => new CheckInUseCase(
      userRepository,
      shiftRepository,
      assignmentRepository
    ));

    this.factories.set('CheckOutUseCase', () => new CheckOutUseCase(
      userRepository,
      shiftRepository,
      assignmentRepository
    ));

    this.factories.set('MarkNoShowUseCase', () => new MarkNoShowUseCase(
      userRepository,
      shiftRepository,
      assignmentRepository
    ));

    this.factories.set('AddWalkInUseCase', () => new AddWalkInUseCase(
      userRepository,
      shiftRepository,
      assignmentRepository,
      householdRepository
    ));

    this.factories.set('GetShiftAttendanceUseCase', () => new GetShiftAttendanceUseCase(
      userRepository,
      shiftRepository,
      assignmentRepository
    ));

    this.factories.set('GetAttendanceHistoryUseCase', () => new GetAttendanceHistoryUseCase(
      userRepository,
      assignmentRepository,
      householdRepository
    ));

    this.factories.set('GenerateSeasonScheduleUseCase', () => new GenerateSeasonScheduleUseCase(
      userRepository,
      seasonRepository,
      shiftRepository,
      templateRepository
    ));

    this.factories.set('PublishSeasonScheduleUseCase', () => new PublishSeasonScheduleUseCase(
      userRepository,
      seasonRepository,
      shiftRepository,
      notificationGateway
    ));

    this.factories.set('GetCurrentSeasonUseCase', () => new GetCurrentSeasonUseCase(
      userRepository,
      seasonRepository,
      shiftRepository
    ));

    this.factories.set('GetWeekScheduleViewUseCase', () => new GetWeekScheduleViewUseCase(
      userRepository,
      shiftRepository,
      assignmentRepository
    ));

    this.factories.set('GetLeaderboardUseCase', () => new GetLeaderboardUseCase(
      userRepository,
      assignmentRepository,
      familyUnitRepository,
      seasonRepository
    ));

    this.factories.set('GetMyStatsUseCase', () => new GetMyStatsUseCase(
      userRepository,
      assignmentRepository,
      familyUnitRepository,
      seasonRepository
    ));

    this.factories.set('GetScoutBucksReportUseCase', () => new GetScoutBucksReportUseCase(
      userRepository,
      assignmentRepository,
      familyUnitRepository,
      householdRepository,
      seasonRepository
    ));

    this.factories.set('SendMessageNotificationUseCase', () => new SendMessageNotificationUseCase(
      userRepository,
      messageRepository,
      notificationGateway
    ));

    this.factories.set('SendShiftRemindersUseCase', () => new SendShiftRemindersUseCase(
      shiftRepository,
      assignmentRepository,
      userRepository,
      notificationGateway
    ));

    // ... register more use cases
  }

  resolve<T>(token: string): T {
    // First check instances (singletons)
    if (this.instances.has(token)) {
      return this.instances.get(token) as T;
    }

    // Then check factories (transient)
    const factory = this.factories.get(token);
    if (factory) {
      return factory() as T;
    }

    throw new Error(`No registration found for token: ${token}`);
  }
}

export const container = new Container();
```

---

## Error Handling

### Application Error

```typescript
// src/application/errors/ApplicationError.ts

export class ApplicationError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly cause?: Error
  ) {
    super(message);
    this.name = 'ApplicationError';
  }
}
```

### Error Handling Pattern in Use Cases

```typescript
// Pattern for error handling in use cases

async execute(request: SomeRequest): Promise<SomeResponse> {
  try {
    // Business logic...
    
  } catch (error) {
    // Re-throw domain errors as-is
    if (error instanceof DomainError) {
      throw error;
    }
    
    // Wrap unexpected errors
    console.error('Unexpected error in SomeUseCase:', error);
    throw new DomainError(
      DomainErrorCode.INTERNAL_ERROR,
      'An unexpected error occurred',
      { originalError: String(error) }
    );
  }
}
```

---

## Use Case Catalog

### Authentication & Family Management

| Use Case | Description | Trigger |
|----------|-------------|---------|
| ProcessInviteCodeUseCase | Validate invite code and create family | Callable |
| ClaimProfileUseCase | Allow scouts to claim their profile | Callable |
| AddFamilyMemberUseCase | Add scouts/spouses to family | Callable |
| LinkScoutToHouseholdUseCase | Add scout to additional household | Callable |
| RegenerateHouseholdLinkCodeUseCase | Generate new link code for scout | Callable |
| DeactivateFamilyUseCase | Deactivate entire family (admin) | Callable |

### Schedule Management

| Use Case | Description | Trigger |
|----------|-------------|---------|
| GetCurrentSeasonUseCase | Get current season with week navigation | Callable |
| GenerateSeasonScheduleUseCase | Bulk create shifts from templates | Callable |
| PublishSeasonScheduleUseCase | Publish draft shifts | Callable |
| UpdateSeasonScheduleUseCase | Modify draft season | Callable |
| GetWeekScheduleViewUseCase | Get week view with staffing | Callable |
| GetStaffingAlertsUseCase | Get understaffed shift alerts | Callable |

### Template Management

| Use Case | Description | Trigger |
|----------|-------------|---------|
| ListTemplatesUseCase | List all shift templates | Callable |
| CreateTemplateUseCase | Create new shift template | Callable |
| UpdateTemplateUseCase | Update existing template | Callable |
| DeleteTemplateUseCase | Deactivate or delete template | Callable |

### Attendance Tracking

| Use Case | Description | Trigger |
|----------|-------------|---------|
| CheckInUseCase | Check in user for shift | Callable |
| CheckOutUseCase | Check out user from shift | Callable |
| MarkNoShowUseCase | Mark user as no-show | Callable |
| AddWalkInUseCase | Add walk-in volunteer | Callable |
| GetShiftAttendanceUseCase | Get attendance for a shift | Callable |
| GetAttendanceHistoryUseCase | Get attendance history | Callable |

### Reporting

| Use Case | Description | Trigger |
|----------|-------------|---------|
| GetLeaderboardUseCase | Get hours leaderboard | Callable |
| GetMyStatsUseCase | Get personal statistics | Callable |
| GetScoutBucksReportUseCase | Generate Scout Bucks report | Callable |

### Notifications

| Use Case | Description | Trigger |
|----------|-------------|---------|
| SendMessageNotificationUseCase | Send committee message | Firestore trigger |
| SendShiftRemindersUseCase | Send 24-hour reminders | Scheduled |
| NotifyNewShiftUseCase | Notify users of new shift | Firestore trigger |

---

## Testing Strategy

### Unit Testing Use Cases

```typescript
// src/__tests__/application/use-cases/attendance/CheckInUseCase.test.ts

import { CheckInUseCase } from '../../../../application/use-cases/attendance/CheckInUseCase';
import { DomainError, DomainErrorCode } from '../../../../domain/errors/DomainError';
import { AttendanceStatus } from '../../../../domain/value-objects/AttendanceStatus';
import { MockUserRepository } from '../../../mocks/MockUserRepository';
import { MockShiftRepository } from '../../../mocks/MockShiftRepository';
import { MockAssignmentRepository } from '../../../mocks/MockAssignmentRepository';
import { createTestUser, createTestShift, createTestAssignment } from '../../../factories';

describe('CheckInUseCase', () => {
  let useCase: CheckInUseCase;
  let mockUserRepository: MockUserRepository;
  let mockShiftRepository: MockShiftRepository;
  let mockAssignmentRepository: MockAssignmentRepository;

  beforeEach(() => {
    mockUserRepository = new MockUserRepository();
    mockShiftRepository = new MockShiftRepository();
    mockAssignmentRepository = new MockAssignmentRepository();
    
    useCase = new CheckInUseCase(
      mockUserRepository,
      mockShiftRepository,
      mockAssignmentRepository
    );
  });

  describe('self check-in', () => {
    it('should successfully check in user within time window', async () => {
      // Arrange
      const now = new Date();
      const shiftStart = new Date(now.getTime() + 5 * 60 * 1000); // 5 min from now
      const shiftEnd = new Date(shiftStart.getTime() + 3 * 60 * 60 * 1000); // 3 hours later
      
      const user = createTestUser({ id: 'user-1', accountStatus: 'active' });
      const shift = createTestShift({ id: 'shift-1', startTime: shiftStart, endTime: shiftEnd });
      const assignment = createTestAssignment({
        id: 'assignment-1',
        userId: 'user-1',
        shiftId: 'shift-1',
        attendanceStatus: AttendanceStatus.PENDING,
      });

      mockUserRepository.setUser(user);
      mockShiftRepository.setShift(shift);
      mockAssignmentRepository.setAssignment(assignment);

      // Act
      const result = await useCase.execute({
        callerId: 'user-1',
        assignmentId: 'assignment-1',
      });

      // Assert
      expect(result.success).toBe(true);
      expect(result.checkedInBy).toBe('user-1');
      expect(mockAssignmentRepository.getUpdates('assignment-1')).toMatchObject({
        attendanceStatus: AttendanceStatus.CHECKED_IN,
        checkInBy: 'user-1',
      });
    });

    it('should throw error if shift has not started', async () => {
      // Arrange
      const now = new Date();
      const shiftStart = new Date(now.getTime() + 60 * 60 * 1000); // 1 hour from now
      const shiftEnd = new Date(shiftStart.getTime() + 3 * 60 * 60 * 1000);
      
      const user = createTestUser({ id: 'user-1', accountStatus: 'active' });
      const shift = createTestShift({ id: 'shift-1', startTime: shiftStart, endTime: shiftEnd });
      const assignment = createTestAssignment({
        id: 'assignment-1',
        userId: 'user-1',
        shiftId: 'shift-1',
        attendanceStatus: AttendanceStatus.PENDING,
      });

      mockUserRepository.setUser(user);
      mockShiftRepository.setShift(shift);
      mockAssignmentRepository.setAssignment(assignment);

      // Act & Assert
      await expect(useCase.execute({
        callerId: 'user-1',
        assignmentId: 'assignment-1',
      })).rejects.toThrow(DomainError);
    });

    it('should throw error if already checked in', async () => {
      // Arrange
      const user = createTestUser({ id: 'user-1', accountStatus: 'active' });
      const shift = createTestShift({ id: 'shift-1' });
      const assignment = createTestAssignment({
        id: 'assignment-1',
        userId: 'user-1',
        shiftId: 'shift-1',
        attendanceStatus: AttendanceStatus.CHECKED_IN,
      });

      mockUserRepository.setUser(user);
      mockShiftRepository.setShift(shift);
      mockAssignmentRepository.setAssignment(assignment);

      // Act & Assert
      await expect(useCase.execute({
        callerId: 'user-1',
        assignmentId: 'assignment-1',
      })).rejects.toMatchObject({
        code: DomainErrorCode.ALREADY_CHECKED_IN,
      });
    });
  });

  describe('parent checking in scout', () => {
    it('should allow parent to check in scout when parent is already checked in', async () => {
      // Arrange
      const parent = createTestUser({
        id: 'parent-1',
        role: 'parent',
        accountStatus: 'active',
      });
      const scout = createTestUser({
        id: 'scout-1',
        role: 'scout',
        accountStatus: 'active',
      });
      const shift = createTestShift({ id: 'shift-1' });
      const parentAssignment = createTestAssignment({
        id: 'parent-assignment',
        userId: 'parent-1',
        shiftId: 'shift-1',
        attendanceStatus: AttendanceStatus.CHECKED_IN,
      });
      const scoutAssignment = createTestAssignment({
        id: 'scout-assignment',
        userId: 'scout-1',
        shiftId: 'shift-1',
        attendanceStatus: AttendanceStatus.PENDING,
      });

      mockUserRepository.setUser(parent);
      mockUserRepository.setUser(scout);
      mockShiftRepository.setShift(shift);
      mockAssignmentRepository.setAssignment(parentAssignment);
      mockAssignmentRepository.setAssignment(scoutAssignment);

      // Act
      const result = await useCase.execute({
        callerId: 'parent-1',
        assignmentId: 'scout-assignment',
        targetUserId: 'scout-1',
      });

      // Assert
      expect(result.success).toBe(true);
      expect(result.checkedInBy).toBe('parent-1');
    });

    it('should reject if parent is not checked in first', async () => {
      // Arrange
      const parent = createTestUser({
        id: 'parent-1',
        role: 'parent',
        accountStatus: 'active',
      });
      const scout = createTestUser({
        id: 'scout-1',
        role: 'scout',
        accountStatus: 'active',
      });
      const shift = createTestShift({ id: 'shift-1' });
      const parentAssignment = createTestAssignment({
        id: 'parent-assignment',
        userId: 'parent-1',
        shiftId: 'shift-1',
        attendanceStatus: AttendanceStatus.PENDING, // Not checked in
      });
      const scoutAssignment = createTestAssignment({
        id: 'scout-assignment',
        userId: 'scout-1',
        shiftId: 'shift-1',
        attendanceStatus: AttendanceStatus.PENDING,
      });

      mockUserRepository.setUser(parent);
      mockUserRepository.setUser(scout);
      mockShiftRepository.setShift(shift);
      mockAssignmentRepository.setAssignment(parentAssignment);
      mockAssignmentRepository.setAssignment(scoutAssignment);

      // Act & Assert
      await expect(useCase.execute({
        callerId: 'parent-1',
        assignmentId: 'scout-assignment',
        targetUserId: 'scout-1',
      })).rejects.toMatchObject({
        code: DomainErrorCode.MUST_CHECK_IN_SELF_FIRST,
      });
    });
  });
});
```

### Mock Repository Example

```typescript
// src/__tests__/mocks/MockUserRepository.ts

import { IUserRepository } from '../../domain/repositories/IUserRepository';
import { User } from '../../domain/entities/User';
import { UserRole } from '../../domain/value-objects/UserRole';

export class MockUserRepository implements IUserRepository {
  private users = new Map<string, User>();

  setUser(user: User): void {
    this.users.set(user.id, user);
  }

  async findById(id: string): Promise<User | null> {
    return this.users.get(id) || null;
  }

  async findByClaimCode(claimCode: string): Promise<User | null> {
    return Array.from(this.users.values()).find(u => u.claimCode === claimCode) || null;
  }

  async findByHouseholdLinkCode(code: string): Promise<User | null> {
    return Array.from(this.users.values()).find(u => u.householdLinkCode === code) || null;
  }

  async findByHousehold(householdId: string): Promise<User[]> {
    return Array.from(this.users.values()).filter(u => u.households.includes(householdId));
  }

  async findByFamilyUnit(familyUnitId: string): Promise<User[]> {
    return Array.from(this.users.values()).filter(u => u.familyUnitId === familyUnitId);
  }

  async findActiveWithFCMTokens(): Promise<User[]> {
    return Array.from(this.users.values()).filter(
      u => u.accountStatus === 'active' && u.fcmTokens.length > 0
    );
  }

  async findByRole(role: UserRole): Promise<User[]> {
    return Array.from(this.users.values()).filter(u => u.role === role);
  }

  async save(user: User): Promise<void> {
    this.users.set(user.id, user);
  }

  async update(id: string, updates: Partial<User>): Promise<void> {
    const existing = this.users.get(id);
    if (existing) {
      this.users.set(id, { ...existing, ...updates });
    }
  }

  async updateBatch(updates: Array<{ id: string; data: Partial<User> }>): Promise<void> {
    for (const update of updates) {
      await this.update(update.id, update.data);
    }
  }
}
```

### Test Factory Example

```typescript
// src/__tests__/factories/index.ts

import { User, createUser } from '../../domain/entities/User';
import { Shift } from '../../domain/entities/Shift';
import { Assignment } from '../../domain/entities/Assignment';
import { UserRole } from '../../domain/value-objects/UserRole';
import { ShiftStatus } from '../../domain/value-objects/ShiftStatus';
import { AttendanceStatus } from '../../domain/value-objects/AttendanceStatus';

export function createTestUser(overrides: Partial<User> = {}): User {
  const defaults = {
    id: 'test-user-id',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    role: UserRole.SCOUT,
    accountStatus: 'active' as const,
    households: ['household-1'],
    canManageHouseholds: [],
    familyUnitId: 'family-1',
    isClaimed: true,
    claimCode: null,
    householdLinkCode: null,
    fcmTokens: [],
    notificationPreferences: {
      newShifts: true,
      shiftReminders: true,
      committeeMessages: true,
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  return createUser({ ...defaults, ...overrides });
}

export function createTestShift(overrides: Partial<Shift> = {}): Shift {
  const now = new Date();
  const startTime = new Date(now.getTime() - 30 * 60 * 1000); // 30 min ago
  const endTime = new Date(now.getTime() + 2.5 * 60 * 60 * 1000); // 2.5 hours from now

  return {
    id: 'test-shift-id',
    date: now,
    startTime,
    endTime,
    requiredScouts: 5,
    requiredParents: 2,
    currentScouts: 0,
    currentParents: 0,
    location: 'Tree Lot',
    label: 'Test Shift',
    notes: null,
    status: ShiftStatus.PUBLISHED,
    seasonId: 'season-1',
    templateId: 'template-1',
    isSpecialEvent: false,
    createdAt: new Date(),
    createdBy: 'admin-1',
    ...overrides,
  };
}

export function createTestAssignment(overrides: Partial<Assignment> = {}): Assignment {
  return {
    id: 'test-assignment-id',
    shiftId: 'shift-1',
    userId: 'user-1',
    userName: 'Test User',
    userRole: UserRole.SCOUT,
    householdId: 'household-1',
    familyUnitId: 'family-1',
    assignedBy: 'user-1',
    assignedByName: 'Test User',
    assignedAt: new Date(),
    assignmentType: 'scheduled',
    status: 'confirmed',
    attendanceStatus: AttendanceStatus.PENDING,
    checkInTime: null,
    checkInBy: null,
    checkInByName: null,
    checkOutTime: null,
    checkOutBy: null,
    checkOutByName: null,
    hoursWorked: null,
    attendanceNotes: null,
    coveringForUserId: null,
    coveringForUserName: null,
    ...overrides,
  };
}
```

---

## Deployment Considerations

### Function Entry Point

```typescript
// src/index.ts

// Callable functions
export { checkIn } from './interface/handlers/callable/attendance/checkIn';
export { checkOut } from './interface/handlers/callable/attendance/checkOut';
export { markNoShow } from './interface/handlers/callable/attendance/markNoShow';
export { addWalkIn } from './interface/handlers/callable/attendance/addWalkIn';
export { getShiftAttendance } from './interface/handlers/callable/attendance/getShiftAttendance';
export { getAttendanceHistory } from './interface/handlers/callable/attendance/getAttendanceHistory';

export { processInviteCode } from './interface/handlers/callable/auth/processInviteCode';
export { claimProfile } from './interface/handlers/callable/auth/claimProfile';

export { addFamilyMember } from './interface/handlers/callable/family/addFamilyMember';
export { linkScoutToHousehold } from './interface/handlers/callable/family/linkScoutToHousehold';
export { regenerateHouseholdLinkCode } from './interface/handlers/callable/family/regenerateHouseholdLinkCode';
export { deactivateFamily } from './interface/handlers/callable/family/deactivateFamily';

export { getCurrentSeason } from './interface/handlers/callable/schedule/getCurrentSeason';
export { generateSeasonSchedule } from './interface/handlers/callable/schedule/generateSeasonSchedule';
export { publishSeasonSchedule } from './interface/handlers/callable/schedule/publishSeasonSchedule';
export { updateSeasonSchedule } from './interface/handlers/callable/schedule/updateSeasonSchedule';
export { getWeekScheduleView } from './interface/handlers/callable/schedule/getWeekScheduleView';
export { getStaffingAlerts } from './interface/handlers/callable/schedule/getStaffingAlerts';

export { listTemplates } from './interface/handlers/callable/templates/listTemplates';
export { createTemplate } from './interface/handlers/callable/templates/createTemplate';
export { updateTemplate } from './interface/handlers/callable/templates/updateTemplate';
export { deleteTemplate } from './interface/handlers/callable/templates/deleteTemplate';

export { getLeaderboard } from './interface/handlers/callable/reporting/getLeaderboard';
export { getMyStats } from './interface/handlers/callable/reporting/getMyStats';
export { getScoutBucksReport } from './interface/handlers/callable/reporting/getScoutBucksReport';

// Trigger functions
export { onMessageCreated } from './interface/handlers/triggers/onMessageCreated';
export { onShiftCreated } from './interface/handlers/triggers/onShiftCreated';

// Scheduled functions
export { sendShiftReminders } from './interface/handlers/scheduled/sendShiftReminders';
```

### TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "module": "commonjs",
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "outDir": "lib",
    "sourceMap": true,
    "strict": true,
    "target": "es2020",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "baseUrl": ".",
    "paths": {
      "@domain/*": ["src/domain/*"],
      "@application/*": ["src/application/*"],
      "@infrastructure/*": ["src/infrastructure/*"],
      "@interface/*": ["src/interface/*"],
      "@di/*": ["src/di/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "lib"]
}
```

### Package Dependencies

```json
// package.json (partial)
{
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.3.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.0",
    "ts-jest": "^29.1.0",
    "eslint": "^8.56.0",
    "@typescript-eslint/eslint-plugin": "^6.19.0",
    "@typescript-eslint/parser": "^6.19.0"
  }
}
```

---

## Summary

This Clean Architecture implementation for Firebase Cloud Functions ensures:

1. **Firebase is hidden** - All Firebase code is in the Infrastructure layer
2. **Domain is pure** - No external dependencies in entities, value objects, or business rules
3. **Use cases orchestrate** - Application logic through single-purpose execute methods
4. **Repositories for persistence** - Firestore operations through interfaces
5. **Gateways for external services** - FCM, external APIs through interfaces
6. **Thin handlers** - Function handlers only translate between HTTP/triggers and use cases
7. **Testability** - Repository and gateway interfaces enable easy mocking
8. **Clear boundaries** - Each layer has specific responsibilities
9. **Single responsibility** - Each use case does one thing
10. **Correct dependency direction** - Outer layers depend on inner layers

The separation provides clear semantics:
- **Domain Layer**: "What are the core business concepts and rules?"
- **Application Layer**: "What operations can users perform?"
- **Infrastructure Layer**: "How do we persist data and integrate with external services?"
- **Interface Layer**: "How do we expose functionality to the outside world?"

This architecture scales well as the application grows and makes it easy to:
- Add new features without modifying existing code
- Test business logic in isolation
- Swap out Firebase for another provider if needed
- Understand what each part of the codebase does

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Dec 2024 | Initial | Complete clean architecture guide for Cloud Functions |
