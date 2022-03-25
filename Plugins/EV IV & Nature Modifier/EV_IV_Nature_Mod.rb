class PokemonSummary_Scene
  def change_Stats
    @sprites["nav"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["nav"].x = 200
    @sprites["nav"].y = 74
    @sprites["nav"].visible
    @sprites["nav"].play
    commands = []
    cmdHP = -1
    cmdAtk = -1
    cmdDef = -1
    cmdSpA = -1
    cmdSpD = -1
    cmdSpe = -1
    stat_choice = 0
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::DOWN)
        if stat_choice == 0
          @sprites["nav"].y += 47
          stat_choice += 1
        elsif stat_choice > 0 && stat_choice < 5
          stat_choice += 1
          @sprites["nav"].y += 32
        elsif stat_choice == 5
          stat_choice -= 5
          @sprites["nav"].y -= 175
        end
      elsif Input.trigger?(Input::UP)
        if stat_choice == 0
          @sprites["nav"].y += 175
          stat_choice += 5
        elsif stat_choice > 1 && stat_choice != 0
          stat_choice -= 1
          @sprites["nav"].y -= 32
        elsif stat_choice == 1
          stat_choice -= 1
          @sprites["nav"].y -= 47
        end
      elsif Input.trigger?(Input::C)
        @scene.pbMessage(_INTL("Change which?\\ch[34,4,EVs,IVs,Cancel]"))
        stat = $game_variables[34]
        pkmn = @pokemon
        case stat_choice
        when 0
          if stat == 0
            params = ChooseNumberParams.new
            upperLimit = 0
            GameData::Stat.each_main { |s| upperLimit += pkmn.ev[s.id] if s.id != pkmn.ev[:HP] }
            upperLimit = Pokemon::EV_LIMIT - upperLimit
            upperLimit = [upperLimit, Pokemon::EV_STAT_LIMIT].min
            thisValue = [pkmn.ev[:HP], upperLimit].min
            params.setRange(0, upperLimit)
            params.setDefaultValue(thisValue)
            params.setCancelValue(thisValue)
            f = pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).",
               GameData::Stat.get(:HP).name, upperLimit), params) { pbUpdate }
            if f != pkmn.ev[:HP]
              pkmn.ev[:HP] = f
              pkmn.calc_stats
              dorefresh = true
            end
          elsif stat == 1
            params = ChooseNumberParams.new
            params.setRange(0, Pokemon::IV_STAT_LIMIT)
            params.setDefaultValue(pkmn.iv[:HP])
            params.setCancelValue(pkmn.iv[:HP])
            f = pbMessageChooseNumber(_INTL("Set the IV for {1} (max. 31).",
               GameData::Stat.get(:HP).name), params) { pbUpdate }
            if f != pkmn.iv[:HP]
              pkmn.iv[:HP] = f
              pkmn.calc_stats
              dorefresh = true
            end
          else
            break
          end
        when 1
          if stat == 0
            params = ChooseNumberParams.new
            upperLimit = 0
            GameData::Stat.each_main { |s| upperLimit += pkmn.ev[s.id] if s.id != pkmn.ev[:ATTACK] }
            upperLimit = Pokemon::EV_LIMIT - upperLimit
            upperLimit = [upperLimit, Pokemon::EV_STAT_LIMIT].min
            thisValue = [pkmn.ev[:ATTACK], upperLimit].min
            params.setRange(0, upperLimit)
            params.setDefaultValue(thisValue)
            params.setCancelValue(thisValue)
            f = pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).",
               GameData::Stat.get(:ATTACK).name, upperLimit), params) { pbUpdate }
            if f != pkmn.ev[:ATTACK]
              pkmn.ev[:ATTACK] = f
              pkmn.calc_stats
              dorefresh = true
            end
          elsif stat == 1
            params = ChooseNumberParams.new
            params.setRange(0, Pokemon::IV_STAT_LIMIT)
            params.setDefaultValue(pkmn.iv[:ATTACK])
            params.setCancelValue(pkmn.iv[:ATTACK])
            f = pbMessageChooseNumber(_INTL("Set the IV for {1} (max. 31).",
               GameData::Stat.get(:ATTACK).name), params) { pbUpdate }
            if f != pkmn.iv[:ATTACK]
              pkmn.iv[:ATTACK] = f
              pkmn.calc_stats
              dorefresh = true
            end
          else
            break
          end
      when 2
        if stat == 0
          params = ChooseNumberParams.new
          upperLimit = 0
          GameData::Stat.each_main { |s| upperLimit += pkmn.ev[s.id] if s.id != pkmn.ev[:DEFENSE] }
          upperLimit = Pokemon::EV_LIMIT - upperLimit
          upperLimit = [upperLimit, Pokemon::EV_STAT_LIMIT].min
          thisValue = [pkmn.ev[:DEFENSE], upperLimit].min
          params.setRange(0, upperLimit)
          params.setDefaultValue(thisValue)
          params.setCancelValue(thisValue)
          f = pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).",
             GameData::Stat.get(:DEFENSE).name, upperLimit), params) { pbUpdate }
          if f != pkmn.ev[:DEFENSE]
            pkmn.ev[:DEFENSE] = f
            pkmn.calc_stats
            dorefresh = true
          end
        elsif stat == 1
          params = ChooseNumberParams.new
          params.setRange(0, Pokemon::IV_STAT_LIMIT)
          params.setDefaultValue(pkmn.iv[:DEFENSE])
          params.setCancelValue(pkmn.iv[:DEFENSE])
          f = pbMessageChooseNumber(_INTL("Set the IV for {1} (max. 31).",
             GameData::Stat.get(:DEFENSE).name), params) { pbUpdate }
          if f != pkmn.iv[:DEFENSE]
            pkmn.iv[:DEFENSE] = f
            pkmn.calc_stats
            dorefresh = true
          end
        else
          break
        end
    when 3
        if stat == 0
          params = ChooseNumberParams.new
          upperLimit = 0
          GameData::Stat.each_main { |s| upperLimit += pkmn.ev[s.id] if s.id != pkmn.ev[:SPECIAL_ATTACK] }
          upperLimit = Pokemon::EV_LIMIT - upperLimit
          upperLimit = [upperLimit, Pokemon::EV_STAT_LIMIT].min
          thisValue = [pkmn.ev[:SPECIAL_ATTACK], upperLimit].min
          params.setRange(0, upperLimit)
          params.setDefaultValue(thisValue)
          params.setCancelValue(thisValue)
          f = pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).",
             GameData::Stat.get(:SPECIAL_ATTACK).name, upperLimit), params) { pbUpdate }
          if f != pkmn.ev[:SPECIAL_ATTACK]
            pkmn.ev[:SPECIAL_ATTACK] = f
            pkmn.calc_stats
            dorefresh = true
          end
        elsif stat == 1
          params = ChooseNumberParams.new
          params.setRange(0, Pokemon::IV_STAT_LIMIT)
          params.setDefaultValue(pkmn.iv[:SPECIAL_ATTACK])
          params.setCancelValue(pkmn.iv[:SPECIAL_ATTACK])
          f = pbMessageChooseNumber(_INTL("Set the IV for {1} (max. 31).",
             GameData::Stat.get(:SPECIAL_ATTACK).name), params) { pbUpdate }
          if f != pkmn.iv[:SPECIAL_ATTACK]
            pkmn.iv[:SPECIAL_ATTACK] = f
            pkmn.calc_stats
            dorefresh = true
          end
        else
          break
        end
    when 4
      if stat == 0
        params = ChooseNumberParams.new
        upperLimit = 0
        GameData::Stat.each_main { |s| upperLimit += pkmn.ev[s.id] if s.id != pkmn.ev[:SPECIAL_DEFENSE] }
        upperLimit = Pokemon::EV_LIMIT - upperLimit
        upperLimit = [upperLimit, Pokemon::EV_STAT_LIMIT].min
        thisValue = [pkmn.ev[:SPECIAL_DEFENSE], upperLimit].min
        params.setRange(0, upperLimit)
        params.setDefaultValue(thisValue)
        params.setCancelValue(thisValue)
        f = pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).",
           GameData::Stat.get(:SPECIAL_DEFENSE).name, upperLimit), params) { pbUpdate }
        if f != pkmn.ev[:SPECIAL_DEFENSE]
          pkmn.ev[:SPECIAL_DEFENSE] = f
          pkmn.calc_stats
          dorefresh = true
        end
      elsif stat == 1
        params = ChooseNumberParams.new
        params.setRange(0, Pokemon::IV_STAT_LIMIT)
        params.setDefaultValue(pkmn.iv[:SPECIAL_DEFENSE])
        params.setCancelValue(pkmn.iv[:SPECIAL_DEFENSE])
        f = pbMessageChooseNumber(_INTL("Set the IV for {1} (max. 31).",
           GameData::Stat.get(:SPECIAL_DEFENSE).name), params) { pbUpdate }
        if f != pkmn.iv[:SPECIAL_DEFENSE]
          pkmn.iv[:SPECIAL_DEFENSE] = f
          pkmn.calc_stats
          dorefresh = true
        end
      else
        break
      end
    when 5
      if stat == 0
        params = ChooseNumberParams.new
        upperLimit = 0
        GameData::Stat.each_main { |s| upperLimit += pkmn.ev[s.id] if s.id != pkmn.ev[:SPEED] }
        upperLimit = Pokemon::EV_LIMIT - upperLimit
        upperLimit = [upperLimit, Pokemon::EV_STAT_LIMIT].min
        thisValue = [pkmn.ev[:SPEED], upperLimit].min
        params.setRange(0, upperLimit)
        params.setDefaultValue(thisValue)
        params.setCancelValue(thisValue)
        f = pbMessageChooseNumber(_INTL("Set the EV for {1} (max. {2}).",
           GameData::Stat.get(:SPEED).name, upperLimit), params) { pbUpdate }
        if f != pkmn.ev[:SPEED]
          pkmn.ev[:SPEED] = f
          pkmn.calc_stats
          dorefresh = true
        end
      elsif stat == 1
        params = ChooseNumberParams.new
        params.setRange(0, Pokemon::IV_STAT_LIMIT)
        params.setDefaultValue(pkmn.iv[:SPEED])
        params.setCancelValue(pkmn.iv[:SPEED])
        f = pbMessageChooseNumber(_INTL("Set the IV for {1} (max. 31).",
           GameData::Stat.get(:SPEED).name), params) { pbUpdate }
        if f != pkmn.iv[:SPEED]
          pkmn.iv[:SPEED] = f
          pkmn.calc_stats
          dorefresh = true
        end
      else
        break
      end
    end
      elsif Input.trigger?(Input::B)
        @sprites["nav"].visible = false
        pbPlayCloseMenuSE
        break
      end
      if dorefresh
        drawPage(@page)
      end
    end
  end

  def change_Nature
    commands = []
    ids = []
    pkmn = @pokemon
    GameData::Nature.each do |nature|
      if nature.stat_changes.length == 0
        commands.push(_INTL("{1} (---)", nature.real_name))
      else
        plus_text = ""
        minus_text = ""
        nature.stat_changes.each do |change|
          if change[1] > 0
            plus_text += "/" if !plus_text.empty?
            plus_text += GameData::Stat.get(change[0]).name_brief
          elsif change[1] < 0
            minus_text += "/" if !minus_text.empty?
            minus_text += GameData::Stat.get(change[0]).name_brief
          end
        end
        commands.push(_INTL("{1} (+{2}, -{3})", nature.real_name, plus_text, minus_text))
      end
      ids.push(nature.id)
    end
    commands.push(_INTL("[Reset]"))
    cmd = ids.index(pkmn.nature_id || ids[0])
    loop do
      msg = _INTL("Nature is {1}.", pkmn.nature.name)
      cmd = pbShowCommands(commands, cmd)
      break if cmd < 0
      if cmd >= 0 && cmd < commands.length - 1   # Set nature
        pkmn.nature = ids[cmd]
        dorefresh = true
      elsif cmd == commands.length - 1   # Reset
        pkmn.nature = nil
        dorefresh = true
      end
      if dorefresh
        drawPage(@page)
        break
      end
    end
  end

  def pbScene
    GameData::Species.play_cry_from_pokemon(@pokemon)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        GameData::Species.play_cry_from_pokemon(@pokemon)
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page==5
          pbPlayDecisionSE
          pbMoveSelection
          dorefresh = true
        elsif !@inbattle
          pbPlayDecisionSE
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && @partyindex>0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && @partyindex<@party.length-1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex!=oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        @page = 5 if @page>5
        if @page!=oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        @page = 5 if @page>5
        if @page!=oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end

  def pbOptions
    dorefresh = false
    commands   = []
    cmdGiveItem = -1
    cmdTakeItem = -1
    cmdPokedex  = -1
    cmdNature = -1
    cmdStatChange = -1
    cmdMark     = -1
    if !@pokemon.egg?
      commands[cmdGiveItem = commands.length] = _INTL("Give item")
      commands[cmdTakeItem = commands.length] = _INTL("Take item") if @pokemon.hasItem?
      commands[cmdPokedex = commands.length]  = _INTL("View Pokédex") if $Trainer.has_pokedex
      if @page == 2 || @page == 3 #|| @page == 4
        commands[cmdNature = commands.length] = _INTL("Change Nature") #if $game_switches[73]
      end
      if @page == 3 #|| @page == 4
        commands[cmdStatChange = commands.length] = _INTL("Change EVs/IVs") #if $game_switches[73]
      end
    end
    commands[cmdMark = commands.length]       = _INTL("Mark")
    commands[commands.length]                 = _INTL("Cancel")
    command = pbShowCommands(commands)
    if cmdGiveItem>=0 && command==cmdGiveItem
      item = nil
      pbFadeOutIn {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene,$PokemonBag)
        item = screen.pbChooseItemScreen(Proc.new { |itm| GameData::Item.get(itm).can_hold? })
      }
      if item
        dorefresh = pbGiveItemToPokemon(item,@pokemon,self,@partyindex)
      end
    elsif cmdTakeItem>=0 && command==cmdTakeItem
      dorefresh = pbTakeItemFromPokemon(@pokemon,self)
    elsif cmdPokedex>=0 && command==cmdPokedex
      $Trainer.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn {
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbStartSceneSingle(@pokemon.species)
      }
      dorefresh = true
    elsif cmdNature>=0 && command==cmdNature
      change_Nature
    elsif cmdStatChange>=0 && command==cmdStatChange
      change_Stats
    elsif cmdMark>=0 && command==cmdMark
      dorefresh = pbMarking(@pokemon)
    end
    return dorefresh
  end
end
