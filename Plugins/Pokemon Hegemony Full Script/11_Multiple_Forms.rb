#================
#Multiple Forms
#================

MultipleForms.register(:CASTFORM,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0 if endBattle
    next 1 if pkmn.form == 1
  },
  "getPrimalForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:CASTFORMITE)
    next
  }
})


MultipleForms.register(:DIALGA,{
  "getForm" => proc { |pkmn|
    if pkmn.hasItem?(:ADAMANTORB)
      next 1
    end
    next 0
  }
})

MultipleForms.register(:PALKIA,{
  "getForm" => proc { |pkmn|
    if pkmn.hasItem?(:LUSTROUSORB)
      next 1
    end
    next 0
  }
})

MultipleForms.register(:ROTOM,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    $appliance = 7 if endBattle
    next $appliance
  },
  "getForm" => proc { |pkmn|
    if pkmn.hasItem?(:ROTOMMULTITOOL)
      if $appliance == nil
        next 7
      else
        next $appliance
      end
    end
    next 0
  },
  "onSetForm" => proc { |pkmn, form, oldForm|
    form_moves = [
       :OVERHEAT,    # Heat, Microwave
       :HYDROPUMP,   # Wash, Washing Machine
       :BLIZZARD,    # Frost, Refrigerator
       :WINDDRILL,    # Fan
       :LEAFSTORM,    # Mow, Lawnmower
       :FLASHCANNON,   #Dex
       :ROTOBLAST    #Multitool
    ]
    move_index = -1
    pkmn.moves.each_with_index do |move, i|
      next if !form_moves.any? { |m| m == move.id }
      move_index = i
      break
    end
    if form == 0
      $appliance = nil
      # Turned back into the base form; forget form-specific moves
      if move_index >= 0
        move_name = pkmn.moves[move_index].name
        pkmn.forget_move_at_index(move_index)
        pbMessage(_INTL("{1} forgot {2}...", pkmn.name, move_name))
        pbLearnMove(:THUNDERSHOCK) if pkmn.numMoves == 0
      end
    elsif form < 8 && $appliance == nil
      # Turned into an alternate form; try learning that form's unique move
      new_move_id = form_moves[form - 1]
      if move_index >= 0
        # Knows another form's unique move; replace it
        old_move_name = pkmn.moves[move_index].name
        if GameData::Move.exists?(new_move_id) && old_move_name != "Rotoblast" && new_move_id != :ROTOBLAST
          pkmn.moves[move_index].id = new_move_id
          new_move_name = pkmn.moves[move_index].name
          pbMessage(_INTL("1,\\wt[16] 2, and\\wt[16]...\\wt[16] ...\\wt[16] ... Ta-da!\\se[Battle ball drop]\1"))
          pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...\1", pkmn.name, old_move_name))
          pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]", pkmn.name, new_move_name))
        else
            pkmn.forget_move_at_index(move_index) if new_move_id != :ROTOBLAST && old_move_name != "Rotoblast"
            pbMessage(_INTL("{1} forgot {2}...", pkmn.name, old_move_name))
            pbLearnMove(:THUNDERSHOCK) if pkmn.numMoves == 0
        end
      else
        # Just try to learn this form's unique move
        if form < 8 && $appliance == nil
          pbLearnMove(pkmn, new_move_id, true)
        end
      end
    end
  }
})


class PokeBattle_Battler
  def pbCheckFormOnWeatherChange
    return if fainted? || @effects[PBEffects::Transform]
    # Castform - Forecast
      if isSpecies?(:CASTFORM)
        if hasActiveAbility?(:FORECAST)
          newForm = 0
          case @battle.pbWeather
          when :Fog then                        newForm = 5
#          when :Overcast then                   newForm = 6
          when :Starstorm then   			        	newForm = 6
#          when :DClear then 				          	newForm = 6
          when :Eclipse then                    newForm = 7
          when :Windy then                      newForm = 8
#          when :HeatLight then                  newForm = 9
          when :StrongWinds then                newForm = 9
          when :AcidRain then                   newForm = 11
          when :Sandstorm then                  newForm = 12
  #        when :Rainbow then                    newForm = 13
  #        when :DustDevil then                  newForm = 14
  #        when :DAshfall then                   newForm = 15
  #        when :VolcanicAsh then                newForm = 16
  #        when :Borealis then                   newForm = 17
  #        when :Humid then                      newForm = 18
          when :Sun, :HarshSun then             newForm = 2
          when :Rain, :Storm, :HeavyRain then   newForm = 3
          when :Hail, :Sleet then               newForm = 4
          end
          if @form!=newForm
            @battle.pbShowAbilitySplash(self,true)
            @battle.pbHideAbilitySplash(self)
            pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
          end
        elsif hasActiveAbility?(:ACCLIMATE)
          newType = nil
          case @battle.pbWeather
          when :Fog then                        newType = :FAIRY
#          when :Overcast then                   newForm = 6
          when :Starstorm then   			        	newType = :COSMIC
#          when :DClear then 				          	newForm = 6
          when :Eclipse then                    newType = :DARK
          when :Windy then                      newType = :FLYING
#          when :HeatLight then                  newForm = 9
          when :StrongWinds then                newType = :FLYING
          when :AcidRain then                   newType = :POISON
          when :Sandstorm then                  newType = :ROCK
  #        when :Rainbow then                    newForm = 13
  #        when :DustDevil then                  newForm = 14
  #        when :DAshfall then                   newForm = 15
  #        when :VolcanicAsh then                newForm = 16
  #        when :Borealis then                   newForm = 17
  #        when :Humid then                      newForm = 18
          when :Sun, :HarshSun then             newType = :FIRE
          when :Rain, :Storm, :HeavyRain then   newType = :WATER
          when :Hail, :Sleet then               newType = :ICE
          when :None then                       newType = :NORMAL
          end
          self.type1 = newType
        else
          pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
    # Cherrim - Flower Gift
    if isSpecies?(:CHERRIM)
      if hasActiveAbility?(:FLOWERGIFT)
        newForm = 0
        case @battle.pbWeather
        when :Sun, :HarshSun then newForm = 1
        end
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
  end
end

MultipleForms.register(:PIKACHU,{
  "getForm" => proc { |pkmn|
    next if pkmn.form_simple >= 2
    if $game_map
      map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
      next 1 if map_metadata == 137  # Krypto Quay
    end
    next 0
  }
})

MultipleForms.copy(:PIKACHU,:EXEGGCUTE)


MultipleForms.register(:MIMEJR,{
  "getForm" => proc { |pkmn|
    next if pkmn.form_simple >= 2
    maps = [105,106,107,108,109]
    if $game_map && maps.include?($game_map.map_id)
      next 1  # Mt Nenox
    end
    next 0
  }
})

def update_forms_from_glitches
  pbEachPokemon { |poke,_box|
    species = poke.species
    if species == :BASCULIN && poke.obtain_method == 1
      poke.form = 2
    end
  }
  $glitches_fixed = true
end

Events.onMapUpdate+=proc {|sender,e|
  update_forms_from_glitches if $glitches_fixed != true
}
