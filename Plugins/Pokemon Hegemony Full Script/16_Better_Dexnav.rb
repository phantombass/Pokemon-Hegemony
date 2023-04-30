class NewDexNav

  def initialize
    @viewport1 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport1.z = 99999
    @viewport2 = Viewport.new(30, 120, Graphics.width, Graphics.height)
    @viewport2.z = 999999
    @viewport3 = Viewport.new(0, 120, Graphics.width, Graphics.height)
    @viewport3.z = 999999
    $viewport1 = nil
    searchmon = 0
    @sprites = {}
    @encarray = []
    $encTerr = nil
    @pkmnsprite = []
    @navChoice = 0
    $no_enc = 0
    navAbil = []
    @ab = []
    encstringarray = [] # Savordez simplified this on discord but I kept it for me to understand better
    getEncData
    # Following variable is unused, but can be a good sub in if you need it
    #textColor=["0070F8,78B8E8","E82010,F8A8B8","0070F8,78B8E8"][$Trainer.gender]
    loctext = _INTL("<ac><c2=43F022E8>{1}</c2></ac>", $game_map.name)
    temparray = @encarray.dup  # doing `if @encarray.pop==7` actually pops the last species off before the loop!
    if temparray.pop==7 || @encarray.length == 0 # i picked 7 cause funny
      loctext += sprintf("<al><c2=FFCADE00>This area has no encounters</c2></al>")
      loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
      #@viewport1.dispose
      #@viewport2.dispose
      @viewport3.dispose
      $no_enc = 1
    else
      i = 0
      @encarray.each do |specie|
     #   loctext += _INTL("<ar><c2=7FFF5EF7>{1}</c2></ar>",PBSpecies.getName(specie))
         iform = 0
         iform = iform
         encstringarray.push(GameData::Species.get(specie).name)#+", ")
         if iform != 0
           speciepic = "#{specie}_#{iform}"
         else
           speciepic = specie
         end
         @pkmnsprite[i]=PokemonSpeciesIconSprite.new(speciepic,@viewport2)
         if i > 6 && i < 14
           @pkmnsprite[i].y += 64
           @pkmnsprite[i].x = (64 * (i-7))
         elsif i > 13
           @pkmnsprite[i].y += 128
           @pkmnsprite[i].x = (64 * (i-14))
         else
           @pkmnsprite[i].x += 64 * i
         end
         i +=1
       end
      loctext += sprintf("<al><c2=FFCADE00>Total encounters for area: %s</c2></al>",@encarray.length)
      loctext += sprintf("<c2=63184210>-----------------------------------------</c2>")
      #loctext += sprintf("<al>%s</al>",encstringarray.join(", "))#.map{|a| a.to_s})
    end
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport1
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=20
    @sprites["locwindow"].width=512 #if @sprites["locwindow"].width<420
    @sprites["locwindow"].height=344
    @sprites["locwindow"].setSkin("Graphics/Windowskins/frlgtextskin")
    @sprites["locwindow"].opacity=200
    @sprites["locwindow"].visible=true
    @sprites["nav"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport3)
    @sprites["nav"].x = 5
    @sprites["nav"].y = 18
    @sprites["nav"].visible
    @sprites["nav"].play
    pbFadeInAndShow(@sprites)
    if $no_enc != 0
      pbWait(24)
      @viewport1.dispose
    end
    main
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def dispose
    pbFadeOutAndHide(@sprites) {pbUpdate}
    pbDisposeSpriteHash(@sprites)
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end

  def pbListOfEncounters(encounter)   # this method is from Nuri Yuri
    return [] unless encounter

    encable = encounter.compact # remove nils
    encable.map! { |enc_list| enc_list.map { |enc| enc[0] } }
    encable.flatten! # transform array of array into array
    encable.uniq! # prevent duplication

    return encable
  end

  def getEncData
    mapid = $game_map.map_id
    encounters = GameData::Encounter.get(mapid, $PokemonGlobal.encounter_version)
    return 0 if encounters == nil
    enc_type = encounters.types.keys[0]
    enc_type2 = encounters.types.keys[1]
    enc_type3 = encounters.types.keys[2]
    enc_type4 = encounters.types.keys[3]
    enc_type5 = encounters.types.keys[4]
    encounter_tables = Marshal.load(Marshal.dump(encounters.types))
    enc_list = encounter_tables[enc_type]
    enc_list2 = encounter_tables[enc_type2]
    enc_list3 = encounter_tables[enc_type3]
    enc_list4 = encounter_tables[enc_type4]
    enc_list5 = encounter_tables[enc_type5]
    encdata = []
    encdata_1 = []
    encdata_2 = []
    encdata_3 = []
    encdata_4 = []
    encdata_5 = []
    eLength = enc_list.length
    eLength2 = enc_list2.length if enc_list2 != nil
    eLength3 = enc_list3.length if enc_list3 != nil
    eLength4 = enc_list4.length if enc_list4 != nil
    eLength5 = enc_list5.length if enc_list5 != nil
    for i in 0...eLength
      encdata_1.push(enc_list[i][1])
    end
      if enc_list2 != nil
        for i in 0...eLength2
          encdata_2.push(enc_list2[i][1])
        end
      end
      if enc_list3 != nil
        for i in 0...eLength3
          encdata_3.push(enc_list3[i][1])
        end
      end
      if enc_list4 != nil
        for i in 0...eLength4
          encdata_4.push(enc_list4[i][1])
        end
      end
      if enc_list5 != nil
        for i in 0...eLength5
          encdata_5.push(enc_list5[i][1])
        end
      end
      pLoc = $game_map.terrain_tag($game_player.x,$game_player.y)
      if GameData::TerrainTag.get(pLoc).id == :Grass || GameData::TerrainTag.get(pLoc).id == :None || GameData::TerrainTag.get(pLoc).id == :StairLeft || GameData::TerrainTag.get(pLoc).id == :StairRight
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Land if $PokemonEncounters.has_land_encounters?
          $encTerr = :Cave if !$PokemonEncounters.has_land_encounters?
        end
      elsif GameData::TerrainTag.get(pLoc).id == :Rock
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Cave
        end
      elsif GameData::TerrainTag.get(pLoc).id == :HighBridge
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :HighBridge
        end
      elsif GameData::TerrainTag.get(pLoc).id == :Graveyard
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Graveyard
        end
      elsif GameData::TerrainTag.get(pLoc).id == :Snow
        if $MapFactory.getFacingTerrainTag== :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Snow if $PokemonEncounters.has_snow_encounters?
        end
      elsif GameData::TerrainTag.get(pLoc).id == :Sandy || GameData::TerrainTag.get(pLoc).id == :Sand
        if $MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater
          $encTerr = :OldRod
        else
          $encTerr = :Sandy if $PokemonEncounters.has_sandy_encounters?
          $encTerr = :Cave if $PokemonEncounters.has_cave_encounters? && !$PokemonEncounters.has_sandy_encounters?
          $encTerr = :Land if !$PokemonEncounters.has_cave_encounters? && !$PokemonEncounters.has_sandy_encounters?
        end
      elsif GameData::TerrainTag.get(pLoc).can_surf
        $encTerr = :OldRod
      elsif GameData::TerrainTag.get(pLoc).id == :Bridge
        $encTerr = :Water
      end
      terr = 0
      case $encTerr
      when enc_type
        terr = 0
      when enc_type2
        terr = 1
      when enc_type3
        terr = 2
      when enc_type4
        terr = 3
      when enc_type5
        terr = 4
      end
      if $encTerr == :OldRod
        terr += 4
      end
      case terr
      when 0
        encdata.push(encdata_1) 
      when 1
        encdata.push(encdata_2)
      when 2
        encdata.push(encdata_3)
      when 3
        encdata.push(encdata_4)
      when 4
        encdata.push(encdata_1)
        encdata.push(encdata_2)
        encdata.push(encdata_3)
      when 5
        encdata.push(encdata_1)
        encdata.push(encdata_2)
        encdata.push(encdata_3)
        encdata.push(encdata_4)
      when 6
        encdata.push(encdata_2)
        encdata.push(encdata_3)
        encdata.push(encdata_4)
        encdata.push(encdata_5)
      end
      encdata = encdata.flatten
      encdata = encdata.uniq
      encdata = encdata.compact

      if $encTerr == nil
        @encarray = [7]
      else
        @encarray = encdata
        @temp = 0
        for i in 0..@encarray.length-1
          j = @encarray.length-2
          while (j >= i)
            if GameData::Species.get(@encarray[j]).id > GameData::Species.get(@encarray[j+1]).id
              #Kernel.pbMessage(_INTL("{1}",PBSpecies::pbGetSpeciesConst(@encarray[j])))
              @temp = @encarray[j]
              @encarray[j] = @encarray[j+1]
              @encarray[j+1] = @temp
            end
            j -= 1
          end
        end
      end
  end

  def main
    navMon = 0
    @navChoice = 0
    lastMon = @encarray.length - 1
    return if lastMon == -1
    if @encarray[navMon] == nil
      @sprites["navMon"]=Window_AdvancedTextPokemon.new(_INTL("<c2=FFCADE00>-</c2>"))
    else
      @sprites["navMon"]=Window_AdvancedTextPokemon.new(_INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name))
    end
    @sprites["navMon"].viewport = @viewport1
    @sprites["navMon"].x=340
    @sprites["navMon"].y=52
    @sprites["navMon"].width=156
    @sprites["navMon"].windowskin = nil
    textColor = "7FE00000"
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::DOWN)
        next if lastMon < 7 && @navChoice < 7
        next if lastMon > 6 && lastMon <14 && @navChoice > 6 && @navChoice < 14
        next if (@navChoice + 7) > lastMon
        @navChoice +=7
        navMon += 7
        @sprites["nav"].y += 64
        @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
      elsif Input.trigger?(Input::UP) && @navChoice > 6
        @navChoice -=7
        navMon -=7
        @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
        @sprites["nav"].y -= 64
      elsif Input.trigger?(Input::LEFT)
        if (@navChoice != 0 && @navChoice != 7 && @navChoice != 14)
          @navChoice -=1
          navMon -=1
          @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
          @sprites["nav"].x -= 64
        else
          if lastMon < 6 && @navChoice == 0 || (lastMon < 13 && lastMon > 6 && @navChoice == 7) || (lastMon < 20 && lastMon > 13 && @navChoice == 14)
            @navChoice = lastMon
            navMon = lastMon
            if navMon > 0 && navMon < 6 || navMon > 7 && navMon < 13 || navMon > 14 && navMon < 20
              if navMon < 6
                @sprites["nav"].x = 5 + (64*navMon)
              elsif navMon > 7 && navMon < 13
                @sprites["nav"].x = 5 + (64*(navMon-7))
              else
                @sprites["nav"].x = 5 + (64*(navMon-14))
              end
            end
            @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
          else
            @navChoice +=6
            navMon +=6
            @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            @sprites["nav"].x = 384
          end
        end
      elsif Input.trigger?(Input::RIGHT)
        if @navChoice == 6 || @navChoice == 13 || @navChoice == 20 || @navChoice == lastMon
          if lastMon < 6 && @navChoice == lastMon || (lastMon < 13 && lastMon > 6 && @navChoice > 6) || (lastMon < 20 && lastMon > 13 && @navChoice > 13)
            if lastMon < 6 && @navChoice == lastMon
              @navChoice = 0
              navMon = 0
              @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            elsif (lastMon < 13 && lastMon > 6 && @navChoice > 6)
              @navChoice = 7
              navMon = 7
              @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            elsif (lastMon < 20 && lastMon > 13 && @navChoice > 13)
              @navChoice = 14
              navMon = 14
              @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            end
            @sprites["nav"].x = 5
          else
            @navChoice -= 6
            navMon -= 6
            @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
            @sprites["nav"].x -= 384
          end
        elsif (@navChoice !=6 && @navChoice !=13 && @navChoice !=20) || (@navChoice != lastMon)
          @navChoice +=1
          navMon +=1
          @sprites["navMon"].text = _INTL("<c2=FFCADE00>{1}</c2>",GameData::Species.get(@encarray[navMon]).name)
          @sprites["nav"].x += 64
        end
      elsif Input.trigger?(Input::C)
        if !$Trainer.pokedex.seen?(@encarray[navMon])
          pbMessage(_INTL("<c2={1}>You cannot search for this Pokémon yet!</c2>",textColor))
          pbMessage(_INTL("<c2={1}>Try looking for it first to register it to your Pokédex!</c2>",textColor))
          next
        elsif $currentDexSearch != nil
          pbMessage(_INTL("<c2={1}>You're already searching for one. Try having a look around!</c2>",textColor))
          @viewport2.dispose
          break
        else
          pbMessage(_INTL("<c2={1}>Searching\\ts[15]...\\wtnp[5]</c2>",textColor))
            if rand(2) == 0
               pbMessage(_INTL("<c2={1}>Oh! A Pokemon was found nearby!</c2>",textColor))
                species=@encarray[@navChoice]
               # We generate the pokemon they found (added to the encounters),
                # giving it some rare "egg moves"to incentivize using  this function
               $currentDexSearch=[species,DexNav.addRandomEggMove(species)]
               pbMessage(_INTL("<c2={1}>Try looking in wild Pokemon spots near you- it might appear!</c2>",textColor))
               pbFadeOutAndHide(@sprites)
               break
            else
               pbMessage(_INTL("<c2={1}>Nothing was found. Try looking somewhere else!</c2>",textColor))
            end
          end
      elsif Input.trigger?(Input::B)
        navMon = -1
        dispose
        break
      else
        next
      end
    end
    if navMon != -1
      @viewport2.dispose
      main2
    end
  end

  def main2
    if $currentDexSearch != nil
      searchmon = GameData::Species.get($currentDexSearch[0]).id
      maps = GameData::MapMetadata.try_get($game_map.map_id)   # Map IDs for Zharonian Forme
      form = 0
      form = form
      r = rand(2)
      $form_hunt = GameData::Species.get($currentDexSearch[0]).form
      navRand = rand(3)
      itemRand = rand(3)
      $game_variables[400] = navRand
      mon = GameData::Species.get_species_form(searchmon,form)
      randAbil = []

      if $game_variables[969] != 0
        for i in 0..2
          randAbil.push(getRandAbilities(searchmon,i))
        end
      end
      navAbil1 = $game_variables[969] == 0 ? GameData::Species.get_species_form(searchmon,form).abilities : [randAbil[0],randAbil[1]]
      hAbil = $game_variables[969] == 0 ? GameData::Species.get_species_form(searchmon,form).hidden_abilities : randAbil[2]
      navItemCommon = GameData::Species.get(searchmon).wild_item_common
      navItemUncommon = GameData::Species.get(searchmon).wild_item_uncommon
      navItemRare = GameData::Species.get(searchmon).wild_item_rare
      case itemRand
      when 0
        $game_variables[401] = navItemCommon
      when 1
        $game_variables[401] = navItemUncommon
      when 2
        $game_variables[401] = navItemRare
      end
      navItem = $game_variables[401]
      if $game_variables[969] == 0
        hAbil = hAbil.length == 0 ? nil : GameData::Species.get_species_form(searchmon,form).hidden_abilities
      else
        hAbil = hAbil == nil ? nil : randAbil[2]
        if hAbil == nil
          hAbil = randAbil[r]
        end
      end
      if $game_variables[969] == 0
        if hAbil == nil
          if navAbil1.length == 1
            navAbil = [navAbil1[0],navAbil1[0],navAbil1[0]]
          else
            navAbil = [navAbil1[0],navAbil1[1],navAbil1[r]]
          end
        else
          if navAbil1.length == 1
            navAbil = [navAbil1[0],navAbil1[0],hAbil[0]]
          else
            navAbil = [navAbil1[0],navAbil1[1],hAbil[0]]
          end
        end
      else
        if hAbil != nil
          if navAbil1.length == 1
            navAbil = [navAbil1[0],navAbil1[0],hAbil]
          else
            navAbil = [navAbil1[0],navAbil1[1],hAbil]
          end
        else
          if navAbil1.length == 1
            navAbil = [navAbil1[0],navAbil1[0],navAbil1[0]]
          else
            navAbil = [navAbil1[0],navAbil1[1],navAbil1[r]]
          end
        end
      end
      ab = GameData::Ability.get(navAbil[navRand]).name
      Graphics.update
      if $currentDexSearch[1] == nil
        dexMove = "-"
      else
        dexMove = GameData::Move.get($currentDexSearch[1]).name
      end
      searchmonName = GameData::Species.get($currentDexSearch[0]).name
      searchtext = [searchmonName,ab,dexMove]
      searchpic = "#{searchmon}_#{form}"
      @sprites["search"] = Window_AdvancedTextPokemon.newWithSize("",265,130,250,126,@viewport3)
      if navRand == 2 && navAbil[0] != navAbil[2]
        @sprites["search"].text = _INTL("{1}\n<c2=463F0000>{2}</c2>\n{3}",searchtext[0],searchtext[1],searchtext[2])
      else
        @sprites["search"].text = _INTL("{1}\n{2}\n{3}",searchtext[0],searchtext[1],searchtext[2])
      end
      @sprites["search"].setSkin("Graphics/Windowskins/frlgtextskin")
      @sprites["search"].opacity = 200
      if form != 0
        @sprites["searchIcon"] = PokemonSpeciesIconSprite.new(searchpic,@viewport3)
      else
        @sprites["searchIcon"] = PokemonSpeciesIconSprite.new(searchmon,@viewport3)
      end
      if (itemRand == 0 && navItemCommon != nil) || (itemRand == 1 && navItemUncommon != nil) || (itemRand == 2 && navItemRare != nil)
        @sprites["item"] = ItemIconSprite.new(440,65,navItem,@viewport3)
      end
      @sprites["searchIcon"].x = 450
      @sprites["searchIcon"].y = 65
      $viewport1 = @viewport3
      pbFadeInAndShow(@sprites) {pbUpdate}
      $game_switches[350] = true
    end
  end
end

Events.onStartBattle+=proc {|_sender,e|
  $repel_toggle = false
  if $game_switches[350] == true
    $viewport1.dispose
    $game_switches[350] = false
  end
}

Events.onMapChanging +=proc {|_sender,e|
  if $game_switches[350] == true
    if $currentDexSearch != nil
      $viewport1.dispose
    end
    $currentDexSearch = nil
    $game_switches[350] = false
  end
}

Events.onWildPokemonCreate+=proc {|sender,e|
    pokemon=e[0]
    # Checks current search value, if it exists, sets the Pokemon to it
    if $currentDexSearch != nil
      mapid = $game_map.map_id
      pLoc = $game_map.terrain_tag($game_player.x,$game_player.y)
      if GameData::TerrainTag.get(pLoc).id == $encTerr || (GameData::TerrainTag.get(pLoc).id == :Sand && $encTerr == :Sandy) || ((GameData::TerrainTag.get(pLoc).id == :Rock || GameData::TerrainTag.get(pLoc).id == :Sand || GameData::TerrainTag.get(pLoc).id == :None) && $encTerr == :Cave) ||((GameData::TerrainTag.get(pLoc).id == :Grass || GameData::TerrainTag.get(pLoc).id == :None || GameData::TerrainTag.get(pLoc).id == :Sand) && $encTerr == :Land) || (($MapFactory.getFacingTerrainTag == :Water || $MapFactory.getFacingTerrainTag == :StillWater || $MapFactory.getFacingTerrainTag == :DeepWater) && $encTerr == :OldRod && (($PokemonBag.pbQuantity(:OLDROD)>0 && GameData::EncounterType.get($PokemonTemp.encounterType).id == :OldRod) || ($PokemonBag.pbQuantity(:GOODROD)>0 && GameData::EncounterType.get($PokemonTemp.encounterType).id == :GoodRod) || ($PokemonBag.pbQuantity(:SUPERROD)>0 && GameData::EncounterType.get($PokemonTemp.encounterType).id == :SuperRod)))
        pokemon.species = $currentDexSearch[0]
        $chainNav = [$currentDexSearch[0],0] if $chain == nil
        $chain = 0 if $chain == nil
        if $chain == 0
          $chainNav[0]=$currentDexSearch[0]
          $chainNav[1]=1
        elsif $chain != nil && $currentDexSearch[0] == $chainNav[0]
          $chainNav[1]+=1
        elsif $chain != nil && $currentDexSearch[0] != $chainNav[0]
          $chainNav[0]=$currentDexSearch[0]
          $chainNav[1]=1
        end
        $chain = $chainNav[1]
        lvl = rand(100)
        if lvl > 90
          pokemon.level = pokemon.level + rand(100-lvl)
          if pokemon.level > $game_variables[106]
            $game_switches[89] = true
          end
        else
          pokemon.level = pokemon.level
        end
        pokemon.item = $game_variables[401]
        pokemon.name=GameData::Species.get(pokemon.species).name
        pokemon.form = $form_hunt
        pokemon.ability_index = $game_variables[400]
        maps = GameData::MapMetadata.try_get($game_map.map_id)
        if $chain >= 0
          ivRand1 = rand(6)
        elsif $chain >= 5
          ivRand1 = rand(6)
          ivRand2 = rand(6)
        elsif $chain >= 10
          ivRand2 = rand(6)
          ivRand1 = rand(6)
          ivRand3 = rand(6)
        end
        if ivRand1 != nil
          case ivRand1
          when 0 then pokemon.iv[:HP] = 31
          when 1 then pokemon.iv[:ATTACK] = 31
          when 2 then pokemon.iv[:DEFENSE] = 31
          when 3 then pokemon.iv[:SPECIAL_ATTACK] = 31
          when 4 then pokemon.iv[:SPECIAL_DEFENSE] = 31
          when 5 then pokemon.iv[:SPEED] = 31
          end
        end
        if ivRand2 != nil
          case ivRand2
          when 0 then pokemon.iv[:HP] = 31
          when 1 then pokemon.iv[:ATTACK] = 31
          when 2 then pokemon.iv[:DEFENSE] = 31
          when 3 then pokemon.iv[:SPECIAL_ATTACK] = 31
          when 4 then pokemon.iv[:SPECIAL_DEFENSE] = 31
          when 5 then pokemon.iv[:SPEED] = 31
          end
        end
        if ivRand3 != nil
          case ivRand3
          when 0 then pokemon.iv[:HP] = 31
          when 1 then pokemon.iv[:ATTACK] = 31
          when 2 then pokemon.iv[:DEFENSE] = 31
          when 3 then pokemon.iv[:SPECIAL_ATTACK] = 31
          when 4 then pokemon.iv[:SPECIAL_DEFENSE] = 31
          when 5 then pokemon.iv[:SPEED] = 31
          end
        end
        pokemon.calc_stats
        pokemon.reset_moves
        if pokemon.moves[1] == nil
          pokemon.moves[1]=Pokemon::Move.new($currentDexSearch[1]) if $currentDexSearch[1]
        elsif pokemon.moves[1] != nil && pokemon.moves[2] == nil
          pokemon.moves[2]=Pokemon::Move.new($currentDexSearch[1]) if $currentDexSearch[1]
        elsif pokemon.moves[1] != nil && pokemon.moves[2] != nil
          pokemon.moves[3]=Pokemon::Move.new($currentDexSearch[1]) if $currentDexSearch[1]
        end
        # There is a higher chance for shininess, so we give it another chance to force it to be shiny
        tempInt = $PokemonBag.pbQuantity(GameData::Item.get(:SHINYCHARM))>0 ? 256 : 768
        if rand(tempInt)<=1+($chain/5).floor && $chain<46
         pokemon.makeShiny
        end
      end
        $currentDexSearch = nil
    end
}

class DexNav
  def self.addRandomEggMove(species)
    baby = GameData::Species.get(species).get_baby_species
    maps = GameData::MapMetadata.try_get($game_map.map_id)
    form = GameData::Species.get(species).form
    egg = GameData::Species.get_species_form(baby,form).egg_moves
    moveChoice = rand(egg.length)
    moves = egg[moveChoice]
    return moves
  end
end
