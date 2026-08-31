# Logo Filter Implementation - National Teams Only

## Summary
Modified the Goalivo application to **display logos only for national teams** and hide logos for club/league teams.

## Changes Made

### 1. Model Updates

#### `lib/models/match_models.dart`
- Added `national: bool?` field to `MatchTeam` class
- Updated `MatchTeam.fromJson()` to parse the `national` field from API responses

#### `lib/models/standing_models.dart`
- Added `national: bool?` field to `StandingTeam` class
- Updated `StandingTeam.fromJson()` to parse the `national` field from API responses
- Added `_toBool()` helper function to convert dynamic values to boolean

### 2. Widget Updates

#### `lib/widgets/match_card.dart`
- Modified logo assignment for home and away teams:
  - `homeLogo`: Only assigned if `teams.home.national == true`
  - `awayLogo`: Only assigned if `teams.away.national == true`

#### `lib/screens/team_detail_screen.dart`
- Updated `_TeamLogo` widget call to only pass logo if `info?.national == true`

#### `lib/screens/match_detail_screen.dart`
- Modified `_HeroScoreBoard` build method to conditionally assign logos:
  - `homeLogo`: Only assigned if `teams.home.national == true`
  - `awayLogo`: Only assigned if `teams.away.national == true`

#### `lib/screens/home_screen.dart`
- Updated `_FavoritesView` teams list: CircleAvatar shows logo only if `national == true`
- Updated `_TeamsView` teams list: CircleAvatar shows logo only if `national == true`

#### `lib/screens/league_detail_screen.dart`
- Updated `_StandingRow` build method to only assign logo if `team?.national == true`

## Behavior After Changes

- ✅ **National team logos**: Display normally as before
- ❌ **Club team logos**: Hidden, replaced with initials or placeholder
- ✅ **Team names**: Always displayed (logos don't affect team identification)
- ✅ **All other UI elements**: Unchanged

## API Integration
The changes depend on the API providing the `national` field in responses:
- `/teams` endpoint should include `national` boolean
- `/fixtures` endpoint should include `national` boolean in team objects
- `/standings` endpoint should include `national` boolean in team objects

If the API doesn't provide this field, it will default to `null` and logos will not be displayed (failsafe behavior).

## Notes
- The fallback behavior (initials in placeholder) ensures UI consistency
- No breaking changes to existing functionality
- Backwards compatible if `national` field is missing from API responses
