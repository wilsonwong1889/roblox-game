# Weekly Source Snapshots

This folder stores week-by-week copies of the active `src` tree.

Structure:

- `Weeks/Week1/src`
- `Weeks/Week2/src`
- `Weeks/Week3/src`
- `Weeks/Week4/src`
- `Weeks/Week5/src`
- `Weeks/Week6/src`
- `Weeks/Week7/src`
- `Weeks/Week8/src`

Use:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Save-WeekSourceSnapshot.ps1 -WeekNumber 3
```

Add `-Force` if you want to replace an existing week snapshot.

Each snapshot should be the direct `src` copy for that week, so the archived source matches the runtime that the smoke test validated.

For Week 3, the snapshot reflects the wall upgrade path, owner front door, high walls, earnings board, and cleaner upgrade lane layout.

For Week 4, the docs now define the expanded first-floor target: larger floor footprint, 8 droppers, starter clicker, owner door button, auto collector unlock, corner spawn placement, and a `100000` test wallet.
