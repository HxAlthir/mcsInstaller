#!/bin/bash
# change game settings

##  server.properties
# - difficulty            hard
# - game mode             survival
# - spawn protection      off
# - pvp                   enabled
# - white list            enabled
# - op rights             3

##  paper settings
# - paper: allow TNT duplication    : true
# - paper: allow bedrock breaking   : true
# - paper: allow headless pistons   : false

## sed changed to replace only one occurence per line (removed 'g').
## gamemode conflicts with force-gamemode --> fixed with a ^ (works only if there are no leading spaces)

# entity-activation-range options conflict with entity-tracking-range options





###  server.properties ###
if [ -f "server.properties" ]; then
    # network-compression-threshold
    # This option caps the size of a packet before the server attempts to compress it. Setting it higher can save some resources at the cost of more bandwidth, setting it to -1 disables it.
    # Note: If your server is in a network with the proxy on localhost or the same datacenter (<2 ms ping), disabling this (-1) will be beneficial.
    sed -i "s/network-compression-threshold=.*/network-compression-threshold=512/" server.properties
    # difficulty=hard
    sed -i "s/difficulty=.*/difficulty=hard/" server.properties
    # gamemode=survival ### this is fixed with a ^ to match beginning of the line only! ###
    sed -i "s/^gamemode=.*/gamemode=survival/" server.properties
    # Disable Spawn protection
    sed -i "s/spawn-protection=.*/spawn-protection=0/" server.properties
    # pvp=true - default
    # white-list=true
    sed -i "s/white-list=.*/white-list=true/" server.properties
    # op-permission-level=3
    sed -i "s/op-permission-level=.*/op-permission-level=3/" server.properties
    
    # Disable snooper
    sed -i "s/snooper-enabled=true/snooper-enabled=false/" server.properties
    # Increase server watchdog timer to 2min to prevent it from shutting itself down
    sed -i "s/max-tick-time=60000/max-tick-time=120000/" server.properties
fi

### Paper / Spigot / Bukkit Optimization settings ###

# Configure paper.yml options
if [ -f "paper.yml" ]; then
    # early-warning-delay, early-warning-every
    # Disables constant error spam of chunk unloading warnings
    sed -i "s/early-warning-delay: 10000/early-warning-delay: 120000/" paper.yml
    sed -i "s/early-warning-every: 5000/early-warning-every: 60000/" paper.yml
    # optimize-explosions
    # Paper applies a custom and far more efficient algorithm for explosions. It has no impact on gameplay.
    sed -i "s/optimize-explosions: false/optimize-explosions: true/" paper.yml
    # mob-spawner-tick-rate
    # This is the delay (in ticks) before an activated spawner attempts to spawn mobs. Doubling the rate to 2 should have no impact on spawn rates. 
    # Only go higher if you have severe load from ticking spawners. Keep below 10.
    ###sed -i "s/mob-spawner-tick-rate: 1/mob-spawner-tick-rate: 3/" paper.yml
    # container-update-tick-rate
    # This changes how often your containers/inventories are refreshed while open. Do not go higher than 3.
    sed -i "s/container-update-tick-rate: 1/container-update-tick-rate: 2/" paper.yml
    # max-entity-collisions
    # Crammed entities (grinders, farms, etc.) will collide less and consume less TPS in the process.
    sed -i "s/max-entity-collisions: 8/max-entity-collisions: 2/" paper.yml
    ### fire-physics-event-for-redstone --> obsolete?
    ### This stops active redstone from firing BlockPhysicsEvent and can salvage some TPS from a cosmetic task.
    ### Note: If you have a rare plugin that listens to BlockPhysicsEvent, leave this on.
    ##sed -i "s/fire-physics-event-for-redstone: true/fire-physics-event-for-redstone: false/" paper.yml
    # use-faster-eigencraft-redstone
    # This setting eliminates redundant redstone updates by as much as 95% without breaking vanilla mechanics/devices (pretty sure). Empirical testing shows a speedup by as much as 10x!
    sed -i "s/use-faster-eigencraft-redstone: false/use-faster-eigencraft-redstone: true/" paper.yml
    # grass-spread-tick
    # The time (in ticks) before the server attempts to spread grass in loaded chunks. This will have minimal gameplay impact on most game types.
    sed -i "s/grass-spread-tick-rate: 1/grass-spread-tick-rate: 3/" paper.yml
    # despawn-ranges 
    # Soft = The distance (in blocks) from a player where mobs will be periodically removed.
    # Hard = Distance where mobs will be removed instantly.
    ###sed -i "s/soft: 32/soft: 28/" paper.yml
    ###sed -i "s/hard: 128/hard: 96/" paper.yml
    # hopper.disable-move-event
    # This will significantly reduce hopper lag by preventing InventoryMoveItemEvent being called for EVERY slot in a container.
    # Warning: If you have a plugin that listens to InventoryMoveItemEvent, do not set true.
    ### --> affects multiItemSorter? <-- ###
    sed -i "s/disable-move-event: false/disable-move-event: true/" paper.yml
    # non-player-arrow-despawn-rate, creative-arrow-despawn-rate
    # Similar to arrow-despawn-rate in Spigot, but targets skeleton arrows. Since players cannot retrieve mob-fired arrows, this setting is only a cosmetic change.
    sed -i "s/creative-arrow-despawn-rate: -1/creative-arrow-despawn-rate: 60/" paper.yml
    sed -i "s/non-player-arrow-despawn-rate: -1/non-player-arrow-despawn-rate: 60/" paper.yml
    # prevent-moving-into-unloaded-chunks
    # Prevents players from entering an unloaded chunk (due to lag), which causes more TPS loss. The true setting will rubberband them back to a "safe" area.
    # Note: If you did not pregenerate your world (what's wrong with you?!), this setting might be a godsend.
    sed -i "s/prevent-moving-into-unloaded-chunks: false/prevent-moving-into-unloaded-chunks: true/" paper.yml
    # disable-chest-cat-detection
    # By default, chests scan for a cat/ocelot on top of it when opened. While this eliminates a vanilla mechanic (cats block chest opening), do you really need this silly mechanic?
    # I like this :P
    ###sed -i "s/disable-chest-cat-detection: false/disable-chest-cat-detection: true/" paper.yml
    # fix-curing-zombie-villager-discount-exploit
    # fix-curing-zombie-villager-discount-exploit: true
    # bungee-online-mode
    # disable Bungee online mode
    sed -i "s/bungee-online-mode: true/bungee-online-mode: false/" paper.yml
    # keep-spawn-loaded, keep-spawn-loaded-range
    # This causes the nether and the end to be ticked and save so we are going to disable it
    # This setting makes sense on high player count servers but for the Pi it just wastes resources
    ### --> need to check if this affects permaloaders <---
    sed -i "s/keep-spawn-loaded: true/keep-spawn-loaded: false/" paper.yml
    sed -i "s/keep-spawn-loaded-range: 10/keep-spawn-loaded-range: -1/" paper.yml
    
        
    ## activate TNT duplication and bedrock breaking ##
    sed -i "s/allow-permanent-block-break-exploits: false/allow-permanent-block-break-exploits: true/" paper.yml
    sed -i "s/allow-piston-duplication: false/allow-piston-duplication: true/" paper.yml
    # --> need to check if this would break the wood factory <--
    ### sed -i "s/allow-headless-pistons: false/allow-headless-pistons: true/" paper.yml
    ##
    
fi

# Configure bukkit.yml options
if [ -f "bukkit.yml" ]; then
    # monster-spawns
    # This dictates how often (in ticks) the server will attempt to spawn a monster in a legal location. Doubling the time between attempts helps performance without hurting spawn rates. 
    sed -i "s/monster-spawns: 1/monster-spawns: 2/" bukkit.yml
    # autosave
    # This enables Bukkit's world saving function and how often it runs (in ticks). It should be 6000 (5 minutes) by default.
    # This is causing 10 second lag spikes in 1.14 so we are going to increase it to 18000 (15 minutes).
    sed -i "s/autosave: 6000/autosave: 18000/" bukkit.yml
    # warn-on-overload
    # Disables annboying server is overloaded messages
    sed -i "s/warn-on-overload: true/warn-on-overload: false/" bukkit.yml
fi

# Configure spigot.yml options
if [ -f "spigot.yml" ]; then
    # Merging items has a huge impact on tick consumption for ground items. Higher values allow more items to be swept into piles and allow you to avoid plugins like ClearLag.
    # Note: Merging items will lead to the occasional illusion of items disappearing as they merge together a few blocks away. A minor annoyance.
    sed -i "s/exp: 3.0/exp: 6.0/" spigot.yml
    sed -i "s/item: 2.5/item: 4.0/" spigot.yml
    # max-entity-collisions
    # Crammed entities (grinders, farms, etc.) will collide less and consume less TPS in the process.
    sed -i "s/max-entity-collisions: 8/max-entity-collisions: 2/" spigot.yml
    # mob-spawn-range
    # Crammed entities (grinders, farms, etc.) will collide less and consume less TPS in the process.
    sed -i "s/mob-spawn-range: 8/mob-spawn-range: 6/" spigot.yml
    
    # entity-activation-range:  ## conflicts with entity-tracking-range:
    ##sed -i "s/animals: 32/animals: 24/" spigot.yml
    ##sed -i "s/monsters: 32/monsters: 24/" spigot.yml
    ##sed -i "s/raiders: 48/raiders: 48/" spigot.yml
    ##sed -i "s/misc: 16/misc: 12/" spigot.yml
    sed -i "s/tick-inactive-villagers: true/tick-inactive-villagers: false/" spigot.yml
fi












