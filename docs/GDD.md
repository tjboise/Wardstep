# Game Design Document — Runemark

> Status: Concept Phase  
> Last updated: 2026-08-31

---

## 1. Elevator Pitch

A knight patrols the ramparts of a crumbling castle. The player places magic rune cards along the patrol path — each card fires its effect when the knight steps on it. Monster waves assault the castle gates. Build a synergistic deck of runes, collect powerful relics, and survive as long as possible in a procedurally generated roguelite run.

**Genre:** Roguelite · Deckbuilder · Tower Defense  
**Platform:** PC (Steam)  
**Engine:** TBD (Godot recommended for 2D)

---

## 2. Core Loop

```
Wave starts
  → Monsters march toward the castle gate
  → Knight patrols back and forth on the rampart track
  → Cards on the track fire when the knight steps on them
  → Effects hit monsters (damage, slow, push, etc.)
Wave ends
  → Shop phase: buy / upgrade / remove cards
  → Random event: pick one of 3 risk/reward options
Next wave
```

Every **3 waves = 1 Act**. The 3rd wave of each Act is a **Boss wave** with a random modifier.

---

## 3. The Track

The track is a horizontal path the knight walks back and forth on. Cards are placed in **slots** on the track.

| Act | Track Slots | Description |
|-----|-------------|-------------|
| 1   | 6 slots     | Single lane |
| 2   | 8 slots     | Single lane extended |
| 3   | 10 slots + branch | Knight can switch lanes at a fork |
| 4   | Dual lane   | Two parallel tracks, knight switches |
| 5   | Full map    | Complex layout, final boss |

**Key rule:** Cards placed on the track **never disappear between waves or Acts**. Slot count only ever increases. The player's build accumulates across the entire run.

---

## 4. Cards (Runes)

Cards are placed in track slots and trigger when the knight steps on them. They have a **cooldown** before they can fire again.

### Base Card Types (draft)

| Card | Effect | Cooldown |
|------|--------|----------|
| Arrow Rune | Fires a projectile at the nearest monster | Short |
| Frost Rune | Slows all monsters for 2s | Medium |
| Blade Rune | Damages all monsters in a zone | Medium |
| Haste Rune | Knight moves faster for 3s (steps on more cards) | Short |
| Gold Rune | Generates gold | Long |
| Shield Rune | Absorbs next hit to castle gate | Long |
| Bomb Rune | AoE explosion after 1s delay | Long |
| Echo Rune | Next card the knight steps on fires twice | Short |

### Card Upgrades

Cards can be upgraded 1–2 times:

```
Arrow Rune → Silver Arrow (fires 2 projectiles) → Chain Arrow (chains between monsters)
Frost Rune → Deep Frost (slows harder) → Blizzard (AoE slow + damage)
```

### Card Synergies (Fusion)

Collecting 2 specific cards unlocks a **fusion option** in the shop:

| Cards | Fusion Result |
|-------|---------------|
| Arrow + Echo | Volley Rune (fires 5 arrows) |
| Frost + Bomb | Cryo Bomb (freeze + shatter) |
| Haste + Gold | Merchant Step (gold per step) |

---

## 5. Relics

Relics are passive global effects, collected from boss rewards, events, and rare shop items. They are the main source of build identity.

Each relic modifies the run permanently. Examples:

| Relic | Effect |
|-------|--------|
| Iron Boots | Knight's steps have a 15% chance to trigger the card twice |
| Bloodstone | Each kill heals 1 castle HP |
| Echo Crystal | All Echo-type effects trigger one extra time |
| Miser's Coin | Each Gold Rune also adds 1 card draw at shop |
| Thorn Crown | When castle takes damage, all Blade Runes trigger immediately |
| Runic Compass | Reveal 2 extra cards in every shop |

Target: ~60 relics at launch, ~20 available per run.

---

## 6. Run Structure

```
Run
├── Act 1 (Waves 1-2: normal, Wave 3: Boss)
│     ├── Wave end → Shop
│     ├── Wave end → Random Event
│     └── Boss → Big reward (relic or rare card) + track expands
├── Act 2 (harder, same structure)
├── Act 3
├── Act 4
└── Act 5 (Final Boss — unique mechanics)
```

### Boss Modifiers (random per boss)

- "Monster HP scales +10% each second"
- "All Frost cards are disabled this wave"
- "Monsters move in two directions simultaneously"
- "Your knight moves at half speed"
- "Every 5th monster spawns a shield"

### Random Events (3-choice, every 2 waves)

- *The Merchant:* Pay 30 gold → Get a relic of your choice from 3 options
- *The Gamble:* Flip a coin — heads: rare card, tails: lose 10 castle HP
- *The Forge:* Remove any card from your track → upgrade another card for free
- *The Horde:* Next wave has 2x monsters — reward is also 2x gold
- *The Gift:* Gain a random relic (no cost)

---

## 7. Meta-Progression (Cross-Run Unlocks)

Earned by completing runs, achieving milestones, or losing with style:

- **New card types** enter the card pool
- **New relic types** become available
- **New knight characters** (different starting speed, HP, or passive)
- **New boss modifiers** added to the rotation
- **New track shapes** unlocked for later Acts

---

## 8. Lose Condition

The castle gate has HP (e.g., 20). Monsters that reach the gate deal damage. When gate HP = 0, run ends.

Between Acts, the player can spend gold to repair gate HP.

---

## 9. Aesthetic Direction (TBD)

Candidates:
- **Dark fantasy castle** — stone ramparts, glowing runes, medieval monsters
- **Steampunk fortress** — iron walkways, mechanical cards, clockwork monsters
- **Arcane academy** — floating towers, magical creatures, mystical atmosphere

Western market preference: dark fantasy or steampunk tend to perform best on Steam.

---

## 10. Open Questions

- [ ] What does the knight character look like? (race, gender, style)
- [ ] How many cards at launch? (target: ~80 unique cards)
- [ ] Multiplier system? (Balatro's mult mechanic has a satisfying feel — equivalent?)
- [ ] Should the track be visible/scrollable or a fixed viewport?
- [ ] Sound design direction?
