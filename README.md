# Qualification System

## Features

- **Admin Management Panel**: Full GUI for creating and managing qualifications via `!qualadmin` chat command
- **Context Menu Integration**: Hold C and right-click players to assign/remove qualifications
- **Teacher System**: Allow certain qualified players to assign specific qualifications
- **Custom Properties**: Each qualification can have:
  - Custom player model
  - Extra weapons
  - Custom health and armor values
  - Custom Lua functions for advanced features
- **Persistent Storage**: All qualifications and assignments stored in SQLite database
- **Permission System**: Control who can assign qualifications (staff-only or teacher-enabled)

## Installation

1. Place the `qualification-system` folder in your `garrysmod/addons/` directory
2. Restart your server or run `lua_refresh` in console
3. Configure admin ranks in `lua/autorun/sh_qualification_config.lua`

## Configuration

Edit `lua/autorun/sh_qualification_config.lua` to configure:

```lua
-- Add your admin ranks here
QualSystem.Config.AdminRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
    -- Add more as needed
}

-- Change the admin command if desired
QualSystem.Config.AdminCommand = "!qualadmin"
```

## Usage

### For Admins

**Opening the Admin Menu:**
- Type `!qualadmin` in chat
- This opens the qualification management panel

**Creating a Qualification:**
1. Click "Create New Qualification" button
2. Fill in the required fields:
   - **Internal Name**: Unique identifier (no spaces, e.g., "medic_basic")
   - **Display Name**: Name shown to players (e.g., "Basic Medic")
   - **Description**: Optional description
   - **Model**: Custom player model path (optional)
   - **Health/Armor**: Set custom values
   - **Weapons**: Comma-separated list of weapon class names
   - **Staff Only**: If checked, only staff can assign this qualification
   - **Allow Teachers**: If checked, players with the "Teacher Qualification" can assign this
   - **Teacher Qualification**: The internal name of the qualification that grants teaching permissions
   - **Custom Function**: Optional Lua code to run when assigned (receives `ply` and `qualData` parameters)
3. Click "Create Qualification"

**Editing a Qualification:**
1. Select a qualification from the list
2. Click "Edit"
3. Modify fields and click "Update Qualification"

**Deleting a Qualification:**
1. Select a qualification from the list
2. Click "Delete"
3. Confirm the deletion

### Assigning Qualifications to Players

**Method 1: Context Menu (Recommended)**
1. Hold C to open the context menu
2. Right-click on a player
3. Select "Manage Qualifications"
4. Double-click a qualification to add it to the player
5. Double-click a current qualification to remove it

**Method 2: Through Properties**
- Follow the same steps as Method 1

### For Teachers

If a qualification has "Allow Teachers" enabled:
- Players who possess the specified "Teacher Qualification" can assign that qualification to others
- Teachers can only manage qualifications they have teaching permissions for
- Teachers use the same context menu system as admins

## Examples

### Example 1: Basic Medic Qualification
- **Internal Name**: `medic_basic`
- **Display Name**: `Basic Medic`
- **Health**: 125
- **Armor**: 50
- **Weapons**: `weapon_medkit`
- **Staff Only**: Checked

### Example 2: Advanced Medic with Teacher System
- **Internal Name**: `medic_advanced`
- **Display Name**: `Advanced Medic`
- **Health**: 150
- **Armor**: 100
- **Weapons**: `weapon_medkit, weapon_defibrillator`
- **Staff Only**: Unchecked
- **Allow Teachers**: Checked
- **Teacher Qualification**: `medic_instructor`

### Example 3: Police Officer with Custom Model and Function
- **Internal Name**: `police_officer`
- **Display Name**: `Police Officer`
- **Model**: `models/player/police.mdl`
- **Health**: 100
- **Armor**: 75
- **Weapons**: `weapon_pistol, weapon_stunstick`
- **Custom Function**:
```lua
ply:SetRunSpeed(400)
ply:SetWalkSpeed(200)
ply:ChatPrint("You are now a Police Officer!")
```

## Custom Functions

The custom function field allows you to run Lua code when a qualification is assigned. The function receives two parameters:

- `ply` - The player receiving the qualification
- `qualData` - Table containing all qualification data

**Example Custom Functions:**

```lua
-- Set custom speeds
ply:SetRunSpeed(400)
ply:SetWalkSpeed(200)

-- Give armor over time
timer.Create("QualRegen_" .. ply:SteamID(), 5, 0, function()
    if IsValid(ply) and ply:Armor() < 100 then
        ply:SetArmor(math.min(ply:Armor() + 10, 100))
    end
end)

-- Print a message
ply:ChatPrint("You've been qualified as " .. qualData.display_name .. "!")

-- Set player color
ply:SetPlayerColor(Vector(0, 0, 1))
```

## Database Tables

The addon creates two SQLite tables:

1. `qualification_system_quals` - Stores all qualifications
2. `qualification_system_player_quals` - Stores player-qualification relationships

## Troubleshooting

**"You don't have permission" error:**
- Make sure your usergroup is listed in `AdminRanks` in the config file
- The usergroup name is case-sensitive

**Qualifications not appearing:**
- Check console for SQL errors
- Ensure the addon is properly loaded (`lua_refresh` in console)

**Context menu not showing:**
- Make sure you're looking at another player (not yourself)
- Verify you have permission (admin or teacher for at least one qualification)

## Support

For issues or questions, check:
- Server console for error messages
- The config file for proper admin rank setup
- That all files are in the correct directories

## Version

Version 1.0 - Initial Release
