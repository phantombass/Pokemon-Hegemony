#===================================
#Items
#===================================
class PokeBattle_Battle
  def pbItemMenu(idxBattler,firstAction)
    if !@internalBattle || @opponent
      pbDisplay(_INTL("Items can't be used here."))
      return false
    end
    ret = false
    @scene.pbItemMenu(idxBattler,firstAction) { |item,useType,idxPkmn,idxMove,itemScene|
      next false if !item
      battler = pkmn = nil
      case useType
      when 1, 2, 6, 7   # Use on Pokémon/Pokémon's move
        pbDisplay(_INTL("Healing items can't be used here."))
        next false
      when 3, 8   # Use on battler
        pbDisplay(_INTL("Healing items can't be used here."))
        next false
      when 4, 9   # Poké Balls
        next false if idxPkmn<0
        battler = @battlers[idxPkmn]
        pkmn    = battler.pokemon if battler
      when 5, 10   # No target (Poké Doll, Guard Spec., Launcher items)
        pbDisplay(_INTL("Boosin items can't be used here."))
        next false
      else
        next false
      end
      next false if !pkmn
      next false if !ItemHandlers.triggerCanUseInBattle(item,
         pkmn,battler,idxMove,firstAction,self,itemScene)
      next false if !pbRegisterItem(idxBattler,item,idxPkmn,idxMove)
      ret = true
      next true
    }
    return ret
  end
end

class PokeBattle_Battler
  def hasActiveItem?(check_item, ignore_fainted = false)
    return false if !itemActive?(ignore_fainted)
    return check_item.include?(@item_id) if check_item.is_a?(Array)
    return self.item == check_item
  end
end

class BagWindowEBDX
  def confirm
    pbSEPlay("EBDX/SE_Select2")
    if @index != 1
      hide
      @scene.pbDisplay(_INTL("Healing items can't be used."))
      show
    elsif @index < 4
      cmd = [2, 3, 5, 7]
      cmd = [2, 1, 4, 5] if Settings.bag_pocket_names.length == 6
      self.drawPocket(cmd[@index], @index)
      @sprites["sel"].target(@back ? @sprites["pocket5"] : @items["#{@item}"])
    else
      @selPocket = 0
      @page = -1
      @ret = @lastUsed
      @lastUsed = 0 if !($PokemonBag.pbQuantity(@lastUsed) > 1)
    end
  end
end

def pbRaiseHappinessAndLowerEV(pkmn,scene,stat,messages)
  h = pkmn.happiness<255
  e = pkmn.ev[stat]>0
  if !h && !e
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if h
    pkmn.changeHappiness("evberry")
  end
  if e
    pkmn.ev[stat] = 0
    pkmn.calc_stats
  end
  scene.pbRefresh
  scene.pbDisplay(messages[2-(h ? 0 : 2)-(e ? 0 : 1)])
  return true
end


def pbCut
  if $PokemonBag.pbQuantity(:CHAINSAW)==0
    pbMessage(_INTL("This tree looks like it can be cut down."))
    return false
  end
  pbMessage(_INTL("This tree looks like it can be cut down!\1"))
  if pbConfirmMessage(_INTL("Would you like to cut it?"))
    pbMessage(_INTL("{1} used {2}!",$Trainer.name,GameData::Item.get(:CHAINSAW).name))
    return true
  end
  return false
end

def pbRaiseEffortValues(pkmn, stat, evGain = 10, ev_limit = true)
  stat = GameData::Stat.get(stat).id
  return 0 if ev_limit && pkmn.ev[stat] >= 252
  evTotal = 0
  GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
  evGain = evGain.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat])
  evGain = evGain.clamp(0, 252 - pkmn.ev[stat]) if ev_limit
  evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
  if evGain > 0
    pkmn.ev[stat] += evGain
    pkmn.calc_stats
  end
  return evGain
end

def pbDive
  return false if $game_player.pbFacingEvent
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  return false if !map_metadata || !map_metadata.dive_map_id
  if $PokemonBag.pbQuantity(:SCUBATANK)==0
    pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
    return false
  end
  if pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
    pbMessage(_INTL("{1} used {2}!",$Trainer.name,GameData::Item.get(:SCUBATANK).name))
    pbFadeOutIn {
       $game_temp.player_new_map_id    = map_metadata.dive_map_id
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       $PokemonGlobal.surfing = false
       $PokemonGlobal.diving  = true
       pbUpdateVehicle
       $scene.transfer_player(false)
       $game_map.autoplay
       $game_map.refresh
    }
    return true
  end
  return false
end

def pbSurfacing
  return if !$PokemonGlobal.diving
  return false if $game_player.pbFacingEvent
  surface_map_id = nil
  GameData::MapMetadata.each do |map_data|
    next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
    surface_map_id = map_data.id
    break
  end
  return if !surface_map_id
  if $PokemonBag.pbQuantity(:SCUBATANK)==0
    pbMessage(_INTL("Light is filtering down from above. A Pokémon may be able to surface here."))
    return false
  end
  if pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
    pbMessage(_INTL("{1} used {2}!",$Trainer.name,GameData::Item.get(:SCUBATANK).name))
    pbFadeOutIn {
       $game_temp.player_new_map_id    = surface_map_id
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       $PokemonGlobal.surfing = true
       $PokemonGlobal.diving  = false
       pbUpdateVehicle
       $scene.transfer_player(false)
       surfbgm = GameData::Metadata.get.surf_BGM
       (surfbgm) ?  pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
       $game_map.refresh
    }
    return true
  end
  return false
end

def pbStrength
  if $PokemonMap.strengthUsed
    pbMessage(_INTL("Strength made it possible to move boulders around."))
    return false
  end
  if $PokemonBag.pbQuantity(:FULCRUM)==0
    pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside."))
    return false
  end
  pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside.\1"))
  if pbConfirmMessage(_INTL("Would you like to use Strength?"))
    pbMessage(_INTL("{1} used {2}!",$Trainer.name,GameData::Item.get(:FULCRUM).name))
    pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",$Trainer.name))
    $PokemonMap.strengthUsed = true
    return true
  end
  return false
end

def pbRockSmash
  if $PokemonBag.pbQuantity(:HAMMER)==0
    pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
    return false
  end
  if pbConfirmMessage(_INTL("This rock appears to be breakable. Would you like to use Rock Smash?"))
    pbMessage(_INTL("{1} used {2}!",$Trainer.name,GameData::Item.get(:HAMMER).name))
    return true
  end
  return false
end

def pbSurf
  return false if $game_player.pbFacingEvent
  return false if $game_player.pbHasDependentEvents?
  if $PokemonBag.pbQuantity(:HOVERCRAFT)==0
    return false
  end
  if pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
    pbMessage(_INTL("{1} used {2}!",$Trainer.name,GameData::Item.get(:HOVERCRAFT).name))
    pbCancelVehicles
    surfbgm = GameData::Metadata.get.surf_BGM
    pbCueBGM(surfbgm,0.5) if surfbgm
    pbStartSurfing
    return true
  end
  return false
end

def pbWaterfall
  if $PokemonBag.pbQuantity(:AQUAROCKET)==0
    pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    return false
  end
  if pbConfirmMessage(_INTL("It's a large waterfall. Would you like to use Waterfall?"))
    pbMessage(_INTL("{1} used {2}!",$Trainer.name,GameData::Item.get(:AQUAROCKET).name))
    pbAscendWaterfall
    return true
  end
  return false
end

def canUseMoveCut?
  showmsg = true
   return false if !$PokemonBag.pbHasItem?(:CHAINSAW)
   facingEvent = $game_player.pbFacingEvent
   if !facingEvent || !facingEvent.name[/cuttree/i]
     pbMessage(_INTL("Can't use that here.")) if showmsg
     return false
   end
   return true
end

def useMoveCut
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used a {2}!",$Trainer.name,GameData::Item.get(:CHAINSAW).name))
  end
  facingEvent = $game_player.pbFacingEvent
  if facingEvent
    pbSmashEvent(facingEvent)
  end
  return true
end

def canUseMoveDive?
   showmsg = true
   return false if !$PokemonBag.pbQuantity(:SCUBATANK)==0
   if $PokemonGlobal.diving
     surface_map_id = nil
     GameData::MapMetadata.each do |map_data|
       next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
       surface_map_id = map_data.id
       break
     end
     if !surface_map_id ||
        !$MapFactory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
       pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
   else
     if !GameData::MapMetadata.exists?($game_map.map_id) ||
        !GameData::MapMetadata.get($game_map.map_id).dive_map_id
       pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
     if !$game_player.terrain_tag.can_dive
       pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
   end
   return true
end
def useMoveDive
  wasdiving = $PokemonGlobal.diving
  if $PokemonGlobal.diving
    dive_map_id = nil
    GameData::MapMetadata.each do |map_data|
      next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
      dive_map_id = map_data.id
      break
    end
  else
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    dive_map_id = map_metadata.dive_map_id if map_metadata
  end
  return false if !dive_map_id
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used a {2}!",$Trainer.name,GameData::Item.get(:SCUBATANK).name))
  end
  pbFadeOutIn {
    $game_temp.player_new_map_id    = dive_map_id
    $game_temp.player_new_x         = $game_player.x
    $game_temp.player_new_y         = $game_player.y
    $game_temp.player_new_direction = $game_player.direction
    $PokemonGlobal.surfing = wasdiving
    $PokemonGlobal.diving  = !wasdiving
    pbUpdateVehicle
    $scene.transfer_player(false)
    $game_map.autoplay
    $game_map.refresh
  }
  return true
end

def canUseMoveFlash?
   showmsg = true
   if !GameData::MapMetadata.exists?($game_map.map_id) ||
      !GameData::MapMetadata.get($game_map.map_id).dark_map
     pbMessage(_INTL("Can't use that here.")) if showmsg
     return false
   end
   if $PokemonGlobal.flashUsed
     pbMessage(_INTL("Flash is already being used.")) if showmsg
     return false
   end
   return true
end
def useMoveFlash
  darkness = $PokemonTemp.darknessSprite
  return false if !darkness || darkness.disposed?
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used a {2}!",$Trainer.name,GameData::Item.get(:TORCH).name))
  end
  $PokemonGlobal.flashUsed = true
  radiusDiff = 8*20/Graphics.frame_rate
  while darkness.radius<darkness.radiusMax
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius += radiusDiff
    darkness.radius = darkness.radiusMax if darkness.radius>darkness.radiusMax
  end
  return true
end

def canUseMoveFly?
  showmsg = true
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  if !GameData::MapMetadata.exists?($game_map.map_id) ||
     !GameData::MapMetadata.get($game_map.map_id).outdoor_map
    pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
end

def useMoveFly
  if !$PokemonTemp.flydata
    pbMessage(_INTL("Can't use that here."))
    return false
  end
  pbMessage(_INTL("{1} used the {2}!",$Trainer.name,GameData::Item.get(:WINGSUIT).name))
  pbFadeOutIn {
    $game_temp.player_new_map_id    = $PokemonTemp.flydata[0]
    $game_temp.player_new_x         = $PokemonTemp.flydata[1]
    $game_temp.player_new_y         = $PokemonTemp.flydata[2]
    for i in 115..121
      $game_switches[i] = false
    end
    $game_switches[125] = false
    $CanToggle = true
    $game_temp.player_new_direction = 2
    $PokemonTemp.flydata = nil
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  }
  pbEraseEscapePoint
  return true
end

class PokemonReadyMenu
  def pbStartReadyMenu(moves,items)
    commands = [[],[]]   # Moves, items
    for i in moves
      commands[0].push([i[0], GameData::Move.get(i[0]).name, true, i[1]])
    end
    commands[0].sort! { |a,b| a[1]<=>b[1] }
    for i in items
      commands[1].push([i, GameData::Item.get(i).name, false])
    end
    commands[1].sort! { |a,b| a[1]<=>b[1] }
    @scene.pbStartScene(commands)
    loop do
      command = @scene.pbShowCommands
      break if command==-1
      if command[0]==0   # Use a move
        move = commands[0][command[1]][0]
        user = $Trainer.party[commands[0][command[1]][3]]
        if move == :FLY
          ret = nil
          pbFadeOutInWithUpdate(99999,@scene.sprites) {
            pbHideMenu
            scene = PokemonRegionMap_Scene.new(-1,false)
            screen = PokemonRegionMapScreen.new(scene)
            ret = screen.pbStartFlyScreen
            pbShowMenu if !ret
          }
          if ret
            $PokemonTemp.flydata = ret
            $game_temp.in_menu = false
            pbUseHiddenMove(user,move)
            break
          end
        else
          pbHideMenu
          if pbConfirmUseHiddenMove(user,move)
            $game_temp.in_menu = false
            pbUseHiddenMove(user,move)
            break
          else
            pbShowMenu
          end
        end
      else   # Use an item
        item = commands[1][command[1]][0]
        if item == :WINGSUIT
          if !canUseMoveFly?
            break
          else
          ret = nil
          pbFadeOutInWithUpdate(99999,@scene.sprites) {
            pbHideMenu
            scene = PokemonRegionMap_Scene.new(-1,false)
            screen = PokemonRegionMapScreen.new(scene)
            ret = screen.pbStartFlyScreen
            pbShowMenu if !ret
          }
          if ret
            $PokemonTemp.flydata = ret
            $game_temp.in_menu = false
            useMoveFly
            break
          end
          end
        else
          pbHideMenu
          if ItemHandlers.triggerConfirmUseInField(item)
            $game_temp.in_menu = false
            break if pbUseKeyItemInField(item)
            $game_temp.in_menu = true
          end
          if pbConfirmUseHiddenMove(user,move)
            $game_temp.in_menu = false
            pbUseHiddenMove(user,move)
            break
          else
            pbShowMenu
          end
        end
        pbHideMenu
      end
      pbShowMenu
    end
    @scene.pbEndScene
  end
end

def canUseMoveRockSmash?
  showmsg = true
  return false if $PokemonBag.pbQuantity(:HAMMER)==0
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/smashrock/i]
    pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
end
def useMoveRockSmash
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used a {2}!",$Trainer.name,GameData::Item.get(:HAMMER).name))
  end
  facingEvent = $game_player.pbFacingEvent
  if facingEvent
    pbSmashEvent(facingEvent)
    pbRockSmashRandomEncounter
    pbRockSmashRandomItem
  end
  return true
end

def canUseMoveStrength?
   showmsg = true
   return false if $PokemonBag.pbQuantity(:FULCRUM)==0
   if $PokemonMap.strengthUsed
     pbMessage(_INTL("The Fulcrum is already being used.")) if showmsg
     return false
   end
   return true
end
def useMoveStrength
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used a {2}!\1",$Trainer.name,GameData::Item.get(:FULCRUM).name))
  end
  pbMessage(_INTL("{1}'s {2} made it possible to move boulders around!",$Trainer.name,GameData::Item.get(:FULCRUM).name))
  $PokemonMap.strengthUsed = true
  return true
end
def canUseMoveSurf?
   showmsg = true
   return false if $PokemonBag.pbQuantity(:HOVERCRAFT)==0
   if $PokemonGlobal.surfing
     pbMessage(_INTL("You're already surfing.")) if showmsg
     return false
   end
   if $game_player.pbHasDependentEvents?
     pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
     return false
   end
   if GameData::MapMetadata.exists?($game_map.map_id) &&
      GameData::MapMetadata.get($game_map.map_id).always_bicycle
     pbMessage(_INTL("Let's enjoy cycling!")) if showmsg
     return false
   end
   if !$game_player.pbFacingTerrainTag.can_surf_freely ||
      !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
     pbMessage(_INTL("No surfing here!")) if showmsg
     return false
   end
   return true
end

def useMoveSurf
  $game_temp.in_menu = false
  pbCancelVehicles
  if !pbHiddenMoveAnimation(nil)
    pbMessage(_INTL("{1} used {2}!",$Trainer.name,GameData::Item.get(:HOVERCRAFT).name))
  end
  surfbgm = GameData::Metadata.get.surf_BGM
  pbCueBGM(surfbgm,0.5) if surfbgm
  pbStartSurfing
  return true
end

def canUseMoveWaterfall?
  showmsg = true
  if !$game_player.pbFacingTerrainTag.waterfall
    pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
end
def useMoveWaterfall
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used an {2}!",$Trainer.name,GameData::Item.get(:AQUAROCKET).name))
  end
  pbAscendWaterfall
  return true
end

def canUseMoveRockClimb?
  showmsg = true
  return false if $PokemonBag.pbQuantity(:HIKINGGEAR)==0
   if !$game_player.pbFacingTerrainTag.rock_climb
     pbMessage(_INTL("Can't use that here.")) if showmsg
     return false
   end
   return true
end
def useMoveRockClimb
   if !pbHiddenMoveAnimation(nil)
     pbMessage(_INTL("{1} uses the {2}!",$Trainer.name,GameData::Item.get(:HIKINGGEAR).name))
   end
   if event.direction=8
     pbRockClimbUp
   elsif event.direction=2
     pbRockClimbDown
   end
   return true
end
def pbRockSmashRandomItem
  randItem = rand(100)+1
  return nil if randItem < 51
  if randItem < 76
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    pbItemBall(:HARDSTONE)
  elsif randItem < 86
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    pbItemBall(:NUGGET)
  elsif randItem < 96
    pbExclaim(get_character(-1))
    pbWait(8)
    pbMessage(_INTL("Oh, there was an item!"))
    randFossil = rand(2)
      if randFossil == 1
        pbItemBall(:TOMBSEAL)
      else
        pbItemBall(:ANCIENTTOTEM)
      end
    else
      pbExclaim(get_character(-1))
      pbWait(8)
      pbMessage(_INTL("Oh, there was an item!"))
      pbItemBall(:BIGNUGGET)
  end
end

def pbRockClimbUp(event=nil)
  event = $game_player if !event
  return if !event
  return if event.direction != 8   # can't ascend if not facing up
  oldthrough   = event.through
  oldmovespeed = event.move_speed
  return if !$game_player.pbFacingTerrainTag.rock_climb
  event.through = true
  event.move_speed += 2
  loop do
    event.move_up
    if !$game_player.pbFacingTerrainTag.rock_climb
      event.move_up
      break
    end
  end
  event.through    = oldthrough
  event.move_speed = oldmovespeed
end

def pbRockClimbDown(event=nil)
  event = $game_player if !event
  return if !event
  return if event.direction != 2    # Can't descend if not facing down
  oldthrough   = event.through
  oldmovespeed = event.move_speed
  return if !$game_player.pbFacingTerrainTag.rock_climb
  event.through = true
  event.move_speed += 2
  loop do
    event.move_down
    if !$game_player.pbFacingTerrainTag.rock_climb
      event.move_down
      break
    end
  end
  event.through    = oldthrough
  event.move_speed = oldmovespeed
end

def pbRockClimb
  event = $game_player if !event
  if $PokemonBag.pbQuantity(:HIKINGGEAR)==0
    pbMessage(_INTL("These rocks look climbable."))
    return false
  end
  if pbConfirmMessage(_INTL("It's a large rock wall. Would you like to climb it?"))
    if $PokemonBag.pbQuantity(:HIKINGGEAR)>0
      pbMessage(_INTL("{1} used the {2}!",$Trainer.name,GameData::Item.get(:HIKINGGEAR).name))
      pbHiddenMoveAnimation(nil)
    end
    if event.direction==8
      pbRockClimbUp
    elsif event.direction==2
      pbRockClimbDown
    end
    return true
  end
  return false
end

Events.onAction += proc { |_sender,_e|
  if $game_player.pbFacingTerrainTag.rock_climb
    pbRockClimb
  end
}

ItemHandlers::UseFromBag.add(:CHAINSAW,proc{|item|
  next canUseMoveCut? ? 2 : 0
})

ItemHandlers::UseInField.add(:CHAINSAW,proc{|item|
  useMoveCut if canUseMoveCut?
})

ItemHandlers::UseFromBag.add(:SCUBATANK,proc{|item|
   next canUseMoveDive? ? 2 : 0
})

ItemHandlers::UseInField.add(:SCUBATANK,proc{|item|
   useMoveDive if canUseMoveDive?
})

ItemHandlers::UseFromBag.add(:TORCH,proc{|item|
   next canUseMoveFlash? ? 2 : 0
})

ItemHandlers::UseInField.add(:TORCH,proc{|item|
   useMoveFlash if canUseMoveFlash?
})

ItemHandlers::UseFromBag.add(:WINGSUIT,proc{|item|
  ret = nil
    pbFadeOutIn{
    scene = PokemonRegionMap_Scene.new(-1,false)
    screen = PokemonRegionMapScreen.new(scene)
    ret = screen.pbStartFlyScreen
    next 0 if !ret
  if ret
    $PokemonTemp.flydata = ret
    $game_temp.in_menu = false
    useMoveFly
  end
  next 2
}
})

ItemHandlers::UseInField.add(:WINGSUIT,proc{|item|
   useMoveFly if canUseMoveFly?
})

ItemHandlers::UseFromBag.add(:HAMMER,proc{|item|
   next canUseMoveRockSmash? ? 2 : 0
})

ItemHandlers::UseInField.add(:HAMMER,proc{|item|
   useMoveRockSmash if canUseMoveRockSmash?
})

ItemHandlers::UseFromBag.add(:FULCRUM,proc{|item|
   next canUseMoveStrength? ? 2 : 0
})

ItemHandlers::UseInField.add(:FULCRUM,proc{|item|
   useMoveStrength if canUseMoveStrength?
})

ItemHandlers::UseFromBag.add(:HOVERCRAFT,proc{|item|
   next canUseMoveSurf? ? 2 : 0
})

ItemHandlers::UseInField.add(:HOVERCRAFT,proc{|item|
   useMoveSurf if canUseMoveSurf?
})

ItemHandlers::UseFromBag.add(:AQUAROCKET,proc{|item|
   next canUseMoveWaterfall? ? 2 : 0
})

ItemHandlers::UseInField.add(:AQUAROCKET,proc{|item|
   useMoveWaterfall if canUseMoveWaterfall?
})

ItemHandlers::UseFromBag.add(:HIKINGGEAR,proc{|item|
   next canUseMoveRockClimb? ? 2 : 0
})

ItemHandlers::UseInField.add(:HIKINGGEAR,proc{|item|
   useMoveRockClimb if canUseMoveRockClimb?
})

ItemHandlers::UseFromBag.add(:ESCAPEROPE,proc { |item|
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next 0
  end
  if ($PokemonGlobal.escapePoint rescue false) && $PokemonGlobal.escapePoint.length>0
    next 2   # End screen and consume item
  end
  pbMessage(_INTL("Can't use that here."))
  next 0
})

ItemHandlers::UseInField.add(:ESCAPEROPE,proc { |item|
  escape = ($PokemonGlobal.escapePoint rescue nil)
  if !escape || escape==[]
    pbMessage(_INTL("Can't use that here."))
    next 0
  end
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next 0
  end
  pbUseItemMessage(item)
  pbFadeOutIn {
    $game_temp.player_new_map_id    = escape[0]
    $game_temp.player_new_x         = escape[1]
    $game_temp.player_new_y         = escape[2]
    $game_temp.player_new_direction = escape[3]
    pbCancelVehicles
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  }
  pbEraseEscapePoint
  next 2
})

Events.onStepTaken += proc {
  if $PokemonGlobal.repel > 0 && !$game_player.terrain_tag.ice   # Shouldn't count down if on ice
    $PokemonGlobal.repel -= 1
    if $PokemonGlobal.repel <= 0
      if $PokemonBag.pbHasItem?(:REPEL) ||
         $PokemonBag.pbHasItem?(:SUPERREPEL) ||
         $PokemonBag.pbHasItem?(:MAXREPEL)
         if pbConfirmMessage(_INTL("The repellent's effect wore off! Would you like to use another one?"))
           if $PokemonBag.pbHasItem?(:REPEL) && !$PokemonBag.pbHasItem?(:SUPERREPEL) && !$PokemonBag.pbHasItem?(:MAXREPEL)
             pbMessage(_INTL("Which one?\\ch[34,2,Repel]"))
             if pbGet(34) == 0
               pbUseItem($PokemonBag,:REPEL)
             end
           elsif !$PokemonBag.pbHasItem?(:REPEL) && $PokemonBag.pbHasItem?(:SUPERREPEL) && !$PokemonBag.pbHasItem?(:MAXREPEL)
             pbMessage(_INTL("\\ch[34,2,Super Repel]"))
             if pbGet(34) == 0
               pbUseItem($PokemonBag,:SUPERREPEL)
             end
           elsif !$PokemonBag.pbHasItem?(:REPEL) && !$PokemonBag.pbHasItem?(:SUPERREPEL) && $PokemonBag.pbHasItem?(:MAXREPEL)
             pbMessage(_INTL("\\ch[34,2,Max Repel]"))
             if pbGet(34) == 0
               pbUseItem($PokemonBag,:MAXREPEL)
             end
           elsif $PokemonBag.pbHasItem?(:REPEL) && $PokemonBag.pbHasItem?(:SUPERREPEL) && !$PokemonBag.pbHasItem?(:MAXREPEL)
             pbMessage(_INTL("\\ch[34,3,Repel,Super Repel]"))
             if pbGet(34) == 0
               pbUseItem($PokemonBag,:REPEL)
             elsif pbGet(34) == 1
               pbUseItem($PokemonBag,:SUPERREPEL)
             end
           elsif !$PokemonBag.pbHasItem?(:REPEL) && $PokemonBag.pbHasItem?(:SUPERREPEL) && $PokemonBag.pbHasItem?(:MAXREPEL)
             pbMessage(_INTL("\\ch[34,3,Super Repel,Max Repel]"))
             if pbGet(34) == 0
               pbUseItem($PokemonBag,:SUPERREPEL)
             elsif pbGet(34) == 1
               pbUseItem($PokemonBag,:MAXREPEL)
             end
           elsif $PokemonBag.pbHasItem?(:REPEL) && !$PokemonBag.pbHasItem?(:SUPERREPEL) && $PokemonBag.pbHasItem?(:MAXREPEL)
             pbMessage(_INTL("\\ch[34,3,Repel,Max Repel]"))
             if pbGet(34) == 0
               pbUseItem($PokemonBag,:REPEL)
             elsif pbGet(34) == 1
               pbUseItem($PokemonBag,:MAXREPEL)
             end
           elsif $PokemonBag.pbHasItem?(:REPEL) && $PokemonBag.pbHasItem?(:SUPERREPEL) && $PokemonBag.pbHasItem?(:MAXREPEL)
             pbMessage(_INTL("\\ch[34,3,Repel,Super Repel,Max Repel]"))
             if pbGet(34) == 0
               pbUseItem($PokemonBag,:REPEL)
             elsif pbGet(34) == 1
               pbUseItem($PokemonBag,:SUPERREPEL)
             elsif pbGet(34) == 2
               pbUseItem($PokemonBag,:MAXREPEL)
             end
           end
         end
       else
        pbMessage(_INTL("The repellent's effect wore off!"))
      end
    end
  end
}

BattleHandlers::WeatherExtenderItem.add(:WEATHERROCK,
  proc { |item,weather,duration,battler,battle|
    next 8 if weather != :None
  }
)

ItemHandlers::UseOnPokemon.add(:RARECANDY,proc { |item,pkmn,scene|
  if pkmn.level>=GameData::GrowthRate.max_level || pkmn.shadowPokemon? || pkmn.level>=$game_variables[106]
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pbChangeLevel(pkmn,pkmn.level+1,scene)
  scene.pbHardRefresh
  next true
})

ItemHandlers::UseOnPokemon.add(:ADAMANTMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:ADAMANT
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:ADAMANT)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:BRAVEMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:BRAVE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:BRAVE)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:NAUGHTYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:NAUGHTY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:NAUGHTY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:LONELYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:LONELY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:LONELY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:BOLDMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:BOLD
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:BOLD)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:IMPISHMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:IMPISH
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:IMPISH)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:LAXMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:LAX
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:LAX)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:RELAXEDMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:RELAXED
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:RELAXED)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:MODESTMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:MODEST
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:MODEST)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:MILDMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:MILD
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:MILD)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:RASHMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:RASH
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:RASH)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:QUIETMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:QUIET
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:QUIET)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:CALMMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:CALM
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:CALM)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:GENTLEMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:GENTLE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:GENTLE)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:CAREFULMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:CAREFUL
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:CAREFUL)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:SASSYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:SASSY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:SASSY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:TIMIDMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:TIMID
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:TIMID)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:HASTYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:HASTY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:HASTY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:JOLLYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:JOLLY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:JOLLY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:NAIVEMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:NAIVE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:NAIVE)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:BASHFULMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:BASHFUL
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:BASHFUL)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:HARDYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:HARDY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:HARDY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:DOCILEMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:DOCILE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:DOCILE)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:QUIRKYMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:QUIRKY
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:QUIRKY)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:SERIOUSMINT,proc { |item,pkmn,scene|
  if pkmn.nature==:SERIOUS
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.setNature(:SERIOUS)
  pkmn.calcStats
  scene.pbDisplay(_INTL("{1}'s Nature changed!",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.add(:IVMAXSTONE,proc { |item,pkmn,scene|
  choices = []
  for i in 0...6
    choices.push(_INTL(GameData::Stat.get(i).name))
  end
  choices.push(_INTL("Cancel"))
  command = pbMessage("Which IV would you like to max out?",choices,choices.length)
  statChoice = (command == 6) ? -1 : command
  next false if statChoice == -1
  if pkmn.iv[statChoice] == 31
    scene.pbDisplay(_INTL("This stat is already maxed out!"))
    return false
  end
  stat = GameData::Stat.get(statChoice).id
  statDisp = GameData::Stat.get(statChoice).name
    pkmn.iv[stat] = 31
    pkmn.calc_stats
    scene.pbDisplay(_INTL("{1}'s {2} IVs were maxed out!",pkmn.name,statDisp))
  next true
})

ItemHandlers::UseOnPokemon.add(:IVMINSTONE,proc { |item,pkmn,scene|
  choices = []
  for i in 0...6
    choices.push(_INTL(GameData::Stat.get(i).name))
  end
  choices.push(_INTL("Cancel"))
  command = pbMessage("Which IV would you like to zero out?",choices,choices.length)
  statChoice = (command == 6) ? -1 : command
  next false if statChoice == -1
  if pkmn.iv[statChoice] == 0
    scene.pbDisplay(_INTL("This stat is already zeroed out!"))
    return false
  end
  stat = GameData::Stat.get(statChoice).id
  statDisp = GameData::Stat.get(statChoice).name
    pkmn.iv[stat] = 31
    pkmn.calc_stats
    scene.pbDisplay(_INTL("{1}'s {2} IVs were zeroed out!",pkmn.name,statDisp))
  next true
})

ItemHandlers::UseOnPokemon.add(:POMEGBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:HP,[
     _INTL("{1} adores you! Its base HP fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base HP can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base HP fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:KELPSYBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:ATTACK,[
     _INTL("{1} adores you! Its base Attack fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Attack can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Attack fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:QUALOTBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:DEFENSE,[
     _INTL("{1} adores you! Its base Defense fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Defense can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Defense fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:HONDEWBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:SPECIAL_ATTACK,[
     _INTL("{1} adores you! Its base Special Attack fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Special Attack can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Special Attack fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:GREPABERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:SPECIAL_DEFENSE,[
     _INTL("{1} adores you! Its base Special Defense fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Special Defense can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Special Defense fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:TAMATOBERRY,proc { |item,pkmn,scene|
  next pbRaiseHappinessAndLowerEV(pkmn,scene,:SPEED,[
     _INTL("{1} adores you! Its base Speed fell!",pkmn.name),
     _INTL("{1} became more friendly. Its base Speed can't go lower.",pkmn.name),
     _INTL("{1} became more friendly. However, its base Speed fell!",pkmn.name)
  ])
})

ItemHandlers::UseOnPokemon.add(:ABILITYPATCH,proc { |item,pkmn,scene|
  abils = pkmn.getAbilityList
  abilsarr = []
  hiddenArr =[]
  for i in abils
    hiddenArr.push([i[1],i[0]]) if i[0] && i[1]>1 && pkmn.ability_index != i[1]
  end
  for j in abils
    abilsarr.push([j[1],j[0]]) if j[0] && j[1]<2 && pkmn.ability_index != j[1]
  end
  if pkmn.isSpecies?(:ZYGARDE) || pkmn.isSpecies?(:HOPPALM) || pkmn.isSpecies?(:PAPYRUN) || pkmn.isSpecies?(:ALTEMPER) || pkmn.isSpecies?(:NEFLORA) || pkmn.isSpecies?(:CHARPHINCH) || pkmn.isSpecies?(:PHIRUNDO) || pkmn.isSpecies?(:PHIRENIX) || pkmn.isSpecies?(:BARBOL) || pkmn.isSpecies?(:BOWLTISIS) || pkmn.isSpecies?(:SATURABTU) || pkmn.isSpecies?(:APOPHICARY) || pkmn.isSpecies?(:FALKMUNRA) || pkmn.isSpecies?(:CASTFORM) || pkmn.isSpecies?(:FORMETEOS) || pkmn.isSpecies?(:UNOWN) || pkmn.isSpecies?(:EYEROGLYPH) || pkmn.isSpecies?(:SPOOKLOTH) || pkmn.isSpecies?(:RELICLOTH) || pkmn.isSpecies?(:CORPUSCUFF) || pkmn.isSpecies?(:YAMASK) || pkmn.isSpecies?(:COFAGRIGUS) || pkmn.isSpecies?(:RUNERIGUS)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if pkmn.ability_index != 2
    abilRand = rand(hiddenArr.length)
    newabil = hiddenArr[abilRand]
    abilMarker = 1
  else
    abilRand = rand(abilsarr.length)
    newabil = abilsarr[abilRand]
    abilMarker = 0
  end
  newabilname = GameData::Ability.get(newabil[1]).name
  if scene.pbConfirm(_INTL("Would you like to change {1}'s Ability to {2}?",pkmn.name,newabilname))
    pkmn.ability = nil
    pkmn.ability_index = newabil[0]
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s Ability changed to {2}!",pkmn.name,newabilname))
    next true
  end
  next false
})

BattleHandlers::DamageCalcUserItem.add(:STELLARPLATE,
  proc { |item,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if type == :COSMIC
  }
)

BattleHandlers::DamageCalcUserItem.add(:SONARPLATE,
  proc { |item,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if type == :SOUND
  }
)

BattleHandlers::DamageCalcUserItem.add(:TEMPORALPLATE,
  proc { |item,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if type == :TIME
  }
)

class PokeBattle_Battle
  def pbUsePokeBallInBattle(item,idxBattler,userBattler)
    if $game_switches[81]
      pbDisplay(_INTL("This Pokémon cannot be caught!"))
      $PokemonBag.pbStoreItem(item)
      return false
    else
      idxBattler = userBattler.index if idxBattler<0
      battler = @battlers[idxBattler]
      ItemHandlers.triggerUseInBattle(item,battler,self)
      @choices[userBattler.index][1] = nil   # Delete item from choice
    end
  end
end

module PokeBattle_BattleCommon
  def pbCaptureCalc(pkmn,battler,catch_rate,ball)
    return 4 if $DEBUG && Input.press?(Input::CTRL)
    # Get a catch rate if one wasn't provided
    catch_rate = pkmn.species_data.catch_rate if !catch_rate
    # Modify catch_rate depending on the Poké Ball's effect
    ultraBeast = [:NIHILEGO, :BUZZWOLE, :PHEROMOSA, :XURKITREE, :CELESTEELA,
                  :KARTANA, :GUZZLORD, :POIPOLE, :NAGANADEL, :STAKATAKA,
                  :BLACEPHALON, :OSIRAM, :UNOWN, :BASTUNGSTEN, :FENIXET,
                  :ORRUSTORM, :MAUSELYNX, :SOBEKODILE, :MERITEMPO, :CENTISEPA,
                  :EYEROGLYPH, :PHIRENIX, :SATURABTU, :NEFLORA, :APOPHICARY,
                  :FALKMUNRA, :CANINPU].include?(pkmn.species)
    if !ultraBeast || ball == :BEASTBALL
      catch_rate = BallHandlers.modifyCatchRate(ball,catch_rate,self,battler,ultraBeast)
    else
      catch_rate /= 10
    end
    # First half of the shakes calculation
    a = battler.totalhp
    b = battler.hp
    x = ((3*a-2*b)*catch_rate.to_f)/(3*a)
    # Calculation modifiers
    if battler.status == :SLEEP || battler.status == :FROZEN
      x *= 2.5
    elsif battler.status != :NONE
      x *= 1.5
    end
    x = x.floor
    x = 1 if x<1
    # Definite capture, no need to perform randomness checks
    return 4 if x>=255 || BallHandlers.isUnconditional?(ball,self,battler)
    # Second half of the shakes calculation
    y = ( 65536 / ((255.0/x)**0.1875) ).floor
    # Critical capture check
    if Settings::ENABLE_CRITICAL_CAPTURES
      c = 0
      numOwned = $Trainer.pokedex.owned_count
      if numOwned>600;    c = x*5/12
      elsif numOwned>450; c = x*4/12
      elsif numOwned>300; c = x*3/12
      elsif numOwned>150; c = x*2/12
      elsif numOwned>30;  c = x/12
      end
      # Calculate the number of shakes
      if c>0 && pbRandom(256)<c
        @criticalCapture = true
        return 4 if pbRandom(65536)<y
        return 0
      end
    end
    # Calculate the number of shakes
    numShakes = 0
    for i in 0...4
      break if numShakes<i
      numShakes += 1 if pbRandom(65536)<y
    end
    return numShakes
  end
end
