#===============================================================================
#  Randomizer Functionality for EBS DX
#-------------------------------------------------------------------------------
#  Randomizes compiled data instead of generating random battlers on the fly
#===============================================================================
module EliteBattle
  @randomizer = false
  #-----------------------------------------------------------------------------
  #  check if randomizer is on
  #-----------------------------------------------------------------------------
  def self.randomizer?
    return $PokemonGlobal && $PokemonGlobal.isRandomizer
  end
  def self.randomizerOn?
    return self.randomizer? && self.get(:randomizer)
  end
  #-----------------------------------------------------------------------------
  #  toggle randomizer state
  #-----------------------------------------------------------------------------
  def self.toggle_randomizer(force = nil)
    @randomizer = force.nil? ? !@randomizer : force
    # refresh encounter tables
    $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  end

  def self.ironmonKaizo
    # list of all possible rules
    modifiers = [:TRAINERS, :ENCOUNTERS, :STATIC, :GIFTS, :ITEMS, :ABILITIES, :STATS, :MOVES]
    # list of rule descriptions
    # default
    added = []
    for i in 0..modifiers.length
      added.push(modifiers[i])
    end
    # adds randomizer rules
    $PokemonGlobal.randomizerRules = added
    EliteBattle.add_data(:RANDOMIZER, :RULES, added)
    Input.update
    return (added.length > 0)
  end
  #-----------------------------------------------------------------------------
  #  randomizes compiled trainer data
  #-----------------------------------------------------------------------------
  def self.randomizeTrainers
    # loads compiled data and creates new array
    data = load_data("Data/trainers.dat")
    trainer_exclusions = $game_switches[906] ? nil : [:RIVAL2,:LEADER_Brock,:LEADER_Misty,:LEADER_Surge,:LEADER_Erika,:LEADER_Sabrina,:LEADER_Blaine,:LEADER_Winslow,:LEADER_Jackson,:OFFCORP,:DEFCORP,:PSYCORP,:ROCKETBOSS,:CHAMPION,:ARMYBOSS,:NAVYBOSS,:AIRFORCEBOSS,:GUARDBOSS,:CHANCELLOR,:DOJO_Luna,:DOJO_Apollo,:DOJO_Jasper,:DOJO_Maloki,:DOJO_Juliet,:DOJO_Adam,:DOJO_Wendy,:LEAGUE_Astrid,:LEAGUE_Winslow,:LEAGUE_Eugene,:LEAGUE_Armand,:LEAGUE_Winston,:LEAGUE_Vincent]
    species_exclusions = $game_switches[906] ? nil : [:SPINDA,:SUNKERN,:SUNFLORA]
    $new_trainers = {
      :trainer => [],
      :pokemon => {
        :species => [],
        :level => []
      }
    }
    return if !data.is_a?(Hash) # failsafe
    # iterate through each trainer
    for key in data.keys
      # skip numeric trainers
      next if !trainer_exclusions.nil? && trainer_exclusions.include?(data[key].id[0])
      next if !$new_trainers[:trainer] != nil && key.is_a?(Array)
      $new_trainers[:trainer].push(data[key].id)
      # iterate through party
      pkmn = []
      lvl = []
      for i in 0...data[key].pokemon.length
        next if !species_exclusions.nil? && species_exclusions.include?(data[key].pokemon[i][:species])
        data[key].pokemon[i][:species] = EliteBattle.all_species.sample
        pkmn.push(data[key].pokemon[i][:species])
        lvl.push(data[key].pokemon[i][:level])
        $new_trainers[:pokemon][:species][key] = pkmn
        $new_trainers[:pokemon][:level][key] = lvl
        #data[key].pokemon[i].delete(:moves) if data[key].pokemon[i].key?(:moves)
        #data[key].pokemon[i].delete(:ability) if data[key].pokemon[i].key?(:ability)
        #data[key].pokemon[i].delete(:role) if data[key].pokemon[i].key?(:role)
        #data[key].pokemon[i].delete(:ability_index) if data[key].pokemon[i].key?(:ability_index)
        #data[key].pokemon[i].delete(:ev) if data[key].pokemon[i].key?(:ev)
        #data[key].pokemon[i].delete(:iv) if data[key].pokemon[i].key?(:iv)
        #data[key].pokemon[i].delete(:nature) if data[key].pokemon[i].key?(:nature)
      end
    end
    $game_variables[971] = $new_trainers
    return $new_trainers
  end
  #-----------------------------------------------------------------------------
  #  randomizes abilities per pokemon
  #-----------------------------------------------------------------------------
  def self.randomizeAbilities
    pkmn = load_data("Data/species.dat")
    ability = load_data("Data/abilities.dat")
    trainer = load_data("Data/trainers.dat")
    abilities = []
    for i in 0...ability.keys.length
      abilities.push(ability.keys[i]) if i.odd?
    end
    ability_blacklist = [
      :BATTLEBOND,
      :DISGUISE,
      :FLOWERGIFT,                                        # This can be stopped
      :FORECAST,
      :MULTITYPE,
      :POWERCONSTRUCT,
      :WONDERGUARD,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :ZENMODE,
      :DUAT,
      :ACCLIMATE,
      :WORMHOLE,
      :PINDROP,
      :BOREALIS,
      :BAROMETRIC,
      :DESERTSTORM,
      :ASHCOVER,
      :ASHRUSH,
      :MUGGYAIR,
      :FIGHTERSWRATH,
      :ELECTROSTATIC,
      :BAILOUT,
      :IMPATIENT,
      :TIMEWARP,
      :HYPERSPACE,
      :APPLIANCE,
      :MENTALBLOCK,
      :CORRUPTION,
      :CLOUDCOVER,
      :MULTITOOL,
      :SHROUD,
      :ZEROTOHERO,
      # Abilities intended to be inherent properties of a certain species
      :COMATOSE,
      :RKSSYSTEM
    ]
    return if !pkmn.is_a?(Hash)
    return if !ability.is_a?(Hash)
    return if !trainer.is_a?(Hash)
    for key in trainer.keys
      # skip numeric trainers
      # iterate through party
      for i in 0...trainer[key].pokemon.length
        trainer[key].pokemon[i].delete(:ability) if trainer[key].pokemon[i].key?(:ability)
      end
    end
    $new_ability = {
      :pokemon => [],
      :abilities => []
    }
    for key in pkmn.keys
      abil = []
      habil = []
      if !key.is_a?(Symbol)
        $new_ability[:pokemon].push(pkmn[key].id)
        $new_ability[:pokemon].uniq!
        for i in 0...pkmn[key].abilities.length
          loop do
            pkmn[key].abilities[i] = abilities.sample
            break if !ability_blacklist.include?(pkmn[key].abilities[i])
          end
          abil.push([pkmn[key].abilities[i]])
        end
        for i in 0...pkmn[key].hidden_abilities.length
          loop do
            pkmn[key].hidden_abilities[i] = abilities.sample
            break if !ability_blacklist.include?(pkmn[key].hidden_abilities[i])
          end
          habil.push([pkmn[key].hidden_abilities[i]])
        end
        $new_ability[:abilities][key] = abil[0],(abil[1] == nil ? abil[0] : abil[1]),habil
        $new_ability[:abilities][key].flatten!
        $new_ability[:abilities].delete_at(key-1) if $new_ability[:abilities][key-1] == nil
      end
    end
    $game_variables[969] = $new_ability
    return $new_ability
  end
  #-----------------------------------------------------------------------------
  #  randomizes compiled pokemon base stats
  #-----------------------------------------------------------------------------
  def self.randomizeStats
    data = load_data("Data/species.dat")
    $new_stats = {
      :pokemon => [],
      :stats => {
        :HP => [],
        :ATTACK => [],
        :DEFENSE => [],
        :SPECIAL_ATTACK => [],
        :SPECIAL_DEFENSE => [],
        :SPEED => []
      }
    }
    randStat = 0
    return if !data.is_a?(Hash)
    for key in data.keys
      bst = 0
      rem_stat = 0
      species = data[key].id
      next if $new_stats[:pokemon].include?(species)
      for i in data[key].base_stats.keys
        bst += data[key].base_stats[i]
      end
      for stat in data[key].base_stats.keys
        if data[key].base_stats[stat] == 1
          data[key].base_stats[stat] = 1
          bst -= 1
          rem_stat += 1
          next
        end
        if [:MIMIKYU,:ROTOM].include?(data[key].id) && stat == :HP
          data[key].base_stats[stat] = data[key].base_stats[stat]
          bst -= data[key].base_stats[stat]
          rem_stat += data[key].base_stats[stat]
        end
        loop do
          randStat = rand(bst-rem_stat)
          if bst-rem_stat <= 5
            randStat = 5
          end
          break if (randStat>4 && randStat<201)
        end
        data[key].base_stats[stat] = randStat
        if stat == :SPEED
          data[key].base_stats[stat] = bst-rem_stat < 5 ? 5 : bst-rem_stat
          if data[key].base_stats[stat] > 200
            diff = data[key].base_stats[stat] - 200
            data[key].base_stats[stat] = 200
            rand2 = rand(5)
            stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
            data[key].base_stats[stats[rand]] += diff
          end
        end
        rem_stat += data[key].base_stats[stat]
        $new_stats[:stats][stat].push(data[key].base_stats[stat])
      end
      $new_stats[:pokemon].push(data[key].id)
    end
    $game_variables[970] = $new_stats
    return data
  end

    #-----------------------------------------------------------------------------
  #  randomizes compiled pokemon level up moves
  #-----------------------------------------------------------------------------

  def self.randomizeMoves
    data = load_data("Data/species.dat")
    move_data = load_data("Data/moves.dat")
    move_list = []
    $new_moves = {
      :pokemon => [],
      :moves => []
      }
    randStat = 0
    return if !data.is_a?(Hash) || !move_data.is_a?(Hash)
    for move in move_data.keys
      move_list.push(move) if !move.is_a?(Integer)
    end
    for key in data.keys
      moveset = []
      species = data[key].id
      next if $new_moves[:pokemon].include?(species)
      ind = -1
      for i in data[key].moves
        moves = []
        ind += 1
        i[1] = move_list[rand(move_list.length)]
        moves.push(i[0])
        moves.push(i[1])
        moveset.push(moves)
      end
      $new_moves[:moves].push(moveset)
      $new_moves[:pokemon].push(data[key].id)
    end
    $game_variables[973] = $new_moves
    return data
  end
  #-----------------------------------------------------------------------------
  #  randomizes map encounters
  #-----------------------------------------------------------------------------
  def self.randomizeEncounters
    # loads map encounters
    data = load_data("Data/encounters.dat")
    species_exclusions = $game_switches[906] ? nil : [:SPINDA,:SUNKERN,:SUNFLORA]
    return if !data.is_a?(Hash) # failsafe
    # iterates through each map point
    $timerand = 0 if $timerand.nil?
    for key in data.keys
      timerand += 1
      # go through each encounter type
      for type in data[key].types.keys
        # cycle each definition
        for i in 0...data[key].types[type].length
          # set randomized species
          next if !species_exclusions.nil? && species_exclusions.include?(data[key].types[type][i][1])
          data[key].types[type][i][1] = EliteBattle.all_species.sample
        end
      end
    end
    $game_variables[972] = data
    $game_variables[975] = data if $timerand == 1
    return data
  end
  #-----------------------------------------------------------------------------
  #  randomizes static battles called through events
  #-----------------------------------------------------------------------------
  def self.randomizeStatic
    new = {}
    array = EliteBattle.all_species
    # shuffles up species indexes to load a different one
    for org in EliteBattle.all_species
      i = rand(array.length)
      new[org] = array[i]
      array.delete_at(i)
    end
    $game_variables[974] = new
    return new
  end
  #-----------------------------------------------------------------------------
  #  randomizes items received through events
  #-----------------------------------------------------------------------------
  def self.randomizeItems
    new = {}
    item = :POTION
    # shuffles up item indexes to load a different one
    for org in GameData::Item.values
      loop do
        item = GameData::Item.values.sample
        break if !GameData::Item.get(item).is_key_item?
      end
      new[org] = item

    end
    return new
  end
  #-----------------------------------------------------------------------------
  #  begins the process of randomizing all data
  #-----------------------------------------------------------------------------
  def self.randomizeData
    data = {}
    # compiles hashtable with randomized values
    randomized = {
      :TRAINERS => proc{ next EliteBattle.randomizeTrainers },
      :ENCOUNTERS => proc{ next EliteBattle.randomizeEncounters },
      :STATIC => proc{ next EliteBattle.randomizeStatic },
      :GIFTS => proc{ next EliteBattle.randomizeStatic },
      :ITEMS => proc{ next EliteBattle.randomizeItems },
      :ABILITIES => proc{ next EliteBattle.randomizeAbilities },
      :STATS => proc { next EliteBattle.randomizeStats },
      :MOVES => proc { next EliteBattle.randomizeMoves }
    }
    # applies randomized data for specified rule sets
    for key in EliteBattle.get_data(:RANDOMIZER, :Metrics, :RULES)
      data[key] = randomized[key].call if randomized.has_key?(key)
    end
    # return randomized data
    return data
  end
  #-----------------------------------------------------------------------------
  #  returns randomized data for specific entry
  #-----------------------------------------------------------------------------
  def self.getRandomizedData(data, symbol, index = nil)
    return data if !self.randomizerOn?
    if $PokemonGlobal && $PokemonGlobal.randomizedData && $PokemonGlobal.randomizedData.has_key?(symbol)
      return $PokemonGlobal.randomizedData[symbol][index] if !index.nil?
      return $PokemonGlobal.randomizedData[symbol]
    end
    return data
  end
  #-----------------------------------------------------------------------------
  # randomizes all data and toggles on randomizer
  #-----------------------------------------------------------------------------
  def self.startRandomizer(skip = false)
    ret = $PokemonGlobal && $PokemonGlobal.isRandomizer
    ret, cmd = self.ironmonKaizo if skip
    ret, cmd = self.randomizerSelection unless skip
    @randomizer = true
    # randomize data and cache it
    $PokemonGlobal.randomizedData = self.randomizeData if $PokemonGlobal.randomizedData.nil?
    $PokemonGlobal.isRandomizer = ret
    # refresh encounter tables
    $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
    # display confirmation message
    return if skip
    added = EliteBattle.get_data(:RANDOMIZER, :Metrics, :RULES)
    msg = _INTL("Your selected Randomizer rules have been applied.")
    msg = _INTL("No Randomizer rules have been applied.") if added.length < 1
    msg = _INTL("Your selection has been cancelled.") if cmd < 0
    pbMessage(msg)
  end
  #-----------------------------------------------------------------------------
  #  creates an UI to select the randomizer options
  #-----------------------------------------------------------------------------
  def self.randomizerSelection
    # list of all possible rules
    modifiers = [:TRAINERS, :ENCOUNTERS, :STATIC, :GIFTS, :ITEMS, :ABILITIES, :STATS, :MOVES]
    # list of rule descriptions
    desc = [
      _INTL("Randomize Trainer parties"),
      _INTL("Randomize Wild encounters"),
      _INTL("Randomize Static encounters"),
      _INTL("Randomize Gifted Pokémon"),
      _INTL("Randomize Items"),
      _INTL("Randomize Abilities"),
      _INTL("Randomize Base Stats"),
      _INTL("Randomize Level-Up Moves")
    ]
    # default
    added = []; cmd = 0
    # creates help text message window
    msgwindow = pbCreateMessageWindow(nil, "choice 1")
    msgwindow.text = _INTL("Select the Randomizer Modes you wish to apply.")
    # main loop
    loop do
      # generates all commands
      commands = []
      for i in 0...modifiers.length
        commands.push(_INTL("{1} {2}", (added.include?(modifiers[i])) ? "[X]" : "[  ]", desc[i]))
      end
      commands.push(_INTL("Done"))
      # goes to command window
      cmd = self.commandWindow(commands, cmd, msgwindow)
      # processes return
      if cmd < 0
        clear = pbConfirmMessage("Do you wish to cancel the Randomizer selection?")
        added.clear if clear
        next unless clear
      end
      break if cmd < 0 || cmd >= (commands.length - 1)
      if cmd >= 0 && cmd < (commands.length - 1)
        if added.include?(modifiers[cmd])
          added.delete(modifiers[cmd])
        else
          added.push(modifiers[cmd])
        end
      end
    end
    # disposes of message window
    pbDisposeMessageWindow(msgwindow)
    # adds randomizer rules
    $PokemonGlobal.randomizerRules = added
    EliteBattle.add_data(:RANDOMIZER, :RULES, added)
    Input.update
    return (added.length > 0), cmd
  end
  #-----------------------------------------------------------------------------
  #  clear the randomizer content
  #-----------------------------------------------------------------------------
  def self.resetRandomizer
    EliteBattle.reset(:randomizer)
    if $PokemonGlobal
      $PokemonGlobal.randomizedData = nil
      $PokemonGlobal.isRandomizer = nil
      $PokemonGlobal.randomizerRules = nil
    end
    $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  helper functions to return randomized battlers and items
#===============================================================================
def randomizeSpecies(species, static = false, gift = false)
  return species if !EliteBattle.get(:randomizer)
  return species if $game_switches[RandBoss::Var]
  pokemon = nil
  if species.is_a?(Pokemon)
    pokemon = species.clone
    species = pokemon.species
  end
  # if defined as an exclusion rule, species will not be randomized
    excl = $game_switches[906] ? nil : [:SPINDA,:SUNKERN,:SUNFLORA]
  if !excl.nil? && excl.is_a?(Array)
    for ent in excl
      return (pokemon.nil? ? species : pokemon) if species == ent
    end
  end
  # randomizes static encounters
  if static == true || gift == true
    randStatic = pbGet(974)
    if randStatic != 0
      for mon in randStatic.keys
        next if mon != species
        species = randStatic[mon]
      end
    end
  end
 # species = EliteBattle.getRandomizedData(species, :STATIC, species) if static
 # species = EliteBattle.getRandomizedData(species, :GIFTS, species) if gift
  if !pokemon.nil?
    pokemon.species = species
    pokemon.calc_stats
    pokemon.reset_moves
  end
  return pokemon.nil? ? species : pokemon
end

def randomizeItem(item)
  return item if !EliteBattle.get(:randomizer)
  return item if GameData::Item.get(item).is_key_item?
  # if defined as an exclusion rule, species will not be randomized
  excl = EliteBattle.get_data(:RANDOMIZER, :Metrics, :EXCLUSIONS_ITEMS)
  if !excl.nil? && excl.is_a?(Array)
    for ent in excl
      return item if item == ent
    end
  end
  item = EliteBattle.getRandomizedData(item, :ITEMS, item)
  return item
end


