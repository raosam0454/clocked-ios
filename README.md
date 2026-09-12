# Clocked

An hours tracker for international students in Australia, built around one moment: answering a
roster message without breaking a visa work limit.

> Clocked is a planning tool, not legal advice. All hours are entered by the student.

## The problem

A student visa allows 48 hours of work per fortnight while the course is in session, counted
across every employer combined. Hours during scheduled course breaks are not limited.

That total is invisible at the moment it matters. Rosters arrive from two or three employers who
never see each other's hours, a cover request lands at 4pm for a 6pm shift, and the student has
minutes to answer. Most breaches are arithmetic, not intent.

Credible sources also disagree on what "a fortnight" means. Under a fixed Monday to Sunday block
reading, 30 hours one week and 30 the next is compliant. Under a rolling 14 day reading it is a
breach. Clocked enforces the rolling reading, the strictest one, and says so in the app: a false
warning costs a shift, a false reassurance costs a visa.

## What the app does

| Screen | Purpose |
| --- | --- |
| Fortnight meter | Hours used and hours left in the tightest current 14 day window |
| Record shift | Log a shift in about ten seconds |
| Check a shift offer | Test a proposed shift against every 14 day window it touches, before accepting |
| Work record | History by employer, exportable |

## Architecture

```
Presentation/Screens      SwiftUI views, no business rules
Presentation/ViewModels   screen state, calls use cases only
UseCases                  one struct per business operation, typed errors
Domain/Models             WorkShift, Employer, StudyPeriod, FortnightWindow
Domain/Policies           the work limit and how a fortnight is measured
Data/Repositories         protocols, in memory today
```

Two rules hold the layers apart: views never reach past their view model, and the domain layer
imports neither SwiftUI nor any storage framework.

## Setup

1. Xcode 16 or later, iOS 17 or later simulator.
2. Open `Clocked/Clocked.xcodeproj`.
3. Cmd+R to run, Cmd+U to test.

## Sources

- Migration Regulations 1994, Schedule 8, clause 8105
- studyaustralia.gov.au work rights guidance
- Australian migration advisory publications, 2025 to 2026, which differ on the definition of a
  fortnight
