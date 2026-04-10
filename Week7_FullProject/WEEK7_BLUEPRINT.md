# Week 7 Blueprint

Week 7 turns the expanded tycoon into a persistent competitive server with timed live events instead of a pure sandbox.

## Goal

Make the game feel replayable and server-aware:

- persistent wallet and upgrade restoration
- live competitive summary beyond a single tycoon
- first monetization layer with a usable shop surface
- controlled raid windows instead of unrestricted grief
- rebirth as a long-term progression loop
- a 10-minute live-event rotation that alternates between PvP Arena and Zombie Siege

## Week 7 Scope

- save/load for wallet, collector, upgrades, spins, codes, VIP state, and rebirth count
- autosave and save-on-leave
- world competition board in the shared hub
- world live-event board plus PvP join pad in the shared hub
- start-menu shop tab tied to the VIP starter pack
- rebirth button and prestige loop
- raid console, raid breach pad, breach validation, and collector theft cap
- stronger server-side ownership checks around collector access and theft
- PvP arena join flow during PvP rounds
- zombie sieges that spawn outside claimed tycoons and damage walls during zombie rounds
- a defense chain with alarm beacon, automated turret, and guard tower

## Player-Facing Outcomes

- progress survives rejoin in live servers
- owners can deliberately open a raid window
- raiders can only breach and steal during that window
- the server exposes standings and open-plot status clearly
- prestige creates a reason to restart and scale higher
- every 10 minutes the live event swaps between PvP Arena and Zombie Siege
- players can opt into PvP from the center join pad
- zombie rounds pressure claimed tycoons without leaving the main server
- late first-floor upgrades can automatically defend the base during sieges and raids

## Validation Focus

- load a saved profile and claim a new tycoon
- restore upgrades correctly on claim
- autosave does not break normal play
- raid theft cannot exceed the configured cap
- owners cannot raid themselves
- rebirth resets the build but preserves prestige count
- PvP join pad only works during PvP rounds
- joined PvP players respawn back into the arena while the round is active
- zombie rounds spawn attackers for claimed tycoons and damage walls
- defense turret upgrades automatically fire at nearby zombies, soldiers, and hostile players
