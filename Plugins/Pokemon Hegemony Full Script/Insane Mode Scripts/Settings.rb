#=================
# Level Cap Modifiers
#=================

INSANE_LEVEL_CAP = [9,13,20,23,28,31,40,43,45,48,55,59,65,68,71,72,76,79,80,83,85,88,90,93,95,98,100]

#=================
# Restrictions
#=================

module Restriction_Info
  Abilities = 961
  Moves = 962
  TutorMoves = 963
end

class Restrictions

  attr_accessor :abilities
  attr_accessor :moves

  def self.setup
    @abilities = $game_variables[Restriction_Info::Abilities]
    @moves = $game_variables[Restriction_Info::Moves]
  end

  def self.start
    self.restrict_abilities
    self.restrict_moves
  end

  def self.active?
    return $game_switches[LvlCap::Insane]
  end

  def self.abilities
    return @abilities
  end

  def self.moves
    return @moves
  end

  BANNED_MOVES = [:CALMMIND,:BULKUP,:SWORDSDANCE,:NASTYPLOT,:STATICSURGE,:TAILGLOW,:WORKUP,:HOWL,:AGILITY,:COSMICPOWER,:DEFENDORDER,
    :QUIVERDANCE,:VICTORYDANCE,:GEOMANCY,:CLANGOROUSSOUL,:STEALTHROCK,:SPIKES,:TOXICSPIKES,:STICKYWEB,:COMETSHARDS,:RAINDANCE,:SUNNYDAY,
    :SANDSTORM,:HAIL,:SNOWSCAPE,:STARSTORM,:TAUNT,:MAGICCOAT,:CURSE,:TAILWIND,:GRASSYTERRAIN,:PSYCHICTERRAIN,:MISTYTERRAIN,:ELECTRICTERRAIN,
    :COIL,:BELLYDRUM,:AMNESIA,:ACIDARMOR,:IRONDEFENSE,:NORETREAT,:OCTOLOCK,:SHIFTGEAR,:COTTONGUARD,:DRAGONDANCE,:STOCKPILE,:SPITUP,:SWALLOW,
    :PSYCHUP,:SNATCH,:PROTECT,:WIDEGUARD,:QUICKGUARD,:SUBSTITUTE,:PERISHSONG,:ROCKPOLISH,:AUTOTOMIZE,:GROWTH,:FIERYDANCE,:MEDITATE,:HONECLAWS,
    :FLAMECHARGE,:CHARGEBEAM,:SCALESHOT,:POWERUPPUNCH,:CHARM,:TOXIC,:LEECHSEED,:DEFOG,:STRENGTHSAP,:FELLSTINGER,:SKULLBASH,
    :METEORBEAM,:CHILLYRECEPTION,:TRAILBLAZE,:SPICYEXTRACT,:SHELLSMASH,:FILLETAWAY,:AQUASTEP,:TORCHSONG,:STONEAXE,:CEASELESSEDGE,:DEFENSECURL,:HOWL
  ]

  ABILITY_CHANGES = {
    :UNSHAKEN => [:MOXIE,:GRIMNEIGH,:CHILLINGNEIGH,:CONTRARY,:DEFIANT,:COMPETITIVE,:SPEEDBOOST,:ANGERSHELL,:WEAKARMOR,:GUARDDOG,:STEAMENGINE,:WATERCOMPACTION],
    :TELEPATHY => [:MISTYSURGE,:PSYCHICSURGE,:ELECTRICSURGE,:GRASSYSURGE,:TOXICSURGE,:SEEDSOWER,:DIMENSIONBLOCK],
    :SURGESURFER => [:HADRONENGINE],
    :MAGICGUARD => [:MAGICBOUNCE,:SPLINTER,:TOXICDEBRIS,:WEBWEAVER],
    :GRASSPELT => [:SAPSIPPER],
    :SLUSHRUSH => [:SNOWWARNING,:HAILSTORM,:SNOWCLOAK],
    :SANDRUSH => [:SANDSPIT,:SANDSTREAM,:SANDVEIL],
    :STARSPRINT => [:EQUINOX],
    :BACKDRAFT => [:GALEFORCE,:DELTASTREAM],
    :CHLOROPHYLL => [:DROUGHT,:ORICHALCUMPULSE,:DESOLATELAND],
    :SWIFTSWIM => [:DRIZZLE,:PRIMORDIALSEA],
    :TOXICRUSH => [:URBANCLOUD],
    :UNTAINTED => [:NIGHTFALL],
    :DRYSKIN => [:STORMDRAIN],
    :VOLTABSORB => [:LIGHTNINGROD,:MOTORDRIVE],
    :FLASHFIRE => [:WELLBAKEDBODY],
    :WATERVEIL => [:THERMALENGINE],
    :NATURALCURE => [:FAIRYBUBBLE],
    :VAMPIRIC => [:TRIAGE],
    :FOREWARN => [:TRACE,:DOWNLOAD],
    :SHELLARMOR => [:STAMINA],
    :LIMBER => [:IMPOSTER]
  }

  def self.restrict_abilities
      return if !self.active?
      PBAI.log("Restricting abilities...")
      pkmn = load_data("Data/species.dat")
      ability = load_data("Data/abilities.dat")
      abilities = []
      for i in 0...ability.keys.length
        abilities.push(ability.keys[i]) if i.odd?
      end
      return if !pkmn.is_a?(Hash)
      return if !ability.is_a?(Hash)
      $restricted_abilities = {
        :pokemon => [],
        :abilities => []
      }
      restrictions = Restrictions::ABILITY_CHANGES
      for key in pkmn.keys
        abil = []
        habil = []
        if !key.is_a?(Symbol)
          $restricted_abilities[:pokemon].push(pkmn[key].id)
          $restricted_abilities[:pokemon].uniq!
          for i in 0...pkmn[key].abilities.length
              for ab in restrictions.keys
                if restrictions[ab].include?(pkmn[key].abilities[i])
                  pkmn[key].abilities[i] = ab
                end
              end
            abil.push([pkmn[key].abilities[i]])
          end
          for i in 0...pkmn[key].hidden_abilities.length
              for ab in restrictions.keys
                if restrictions[ab].include?(pkmn[key].hidden_abilities[i])
                  pkmn[key].hidden_abilities[i] = ab
                end
              end
            habil.push([pkmn[key].hidden_abilities[i]])
          end
          $restricted_abilities[:abilities][key] = abil[0],(abil[1] == nil ? abil[0] : abil[1]),habil
          $restricted_abilities[:abilities][key].flatten!
          $restricted_abilities[:abilities].delete_at(key-1) if $restricted_abilities[:abilities][key-1] == nil
        end
      end
      @abilities = $restricted_abilities
      $game_variables[Restriction_Info::Abilities] = @abilities
      $game_variables[Randomizer_Info::Abilities] = @abilities if Randomizer.active?(:ABILITIES)
      return @abilities
    end

    def self.restrict_moves
      return if !self.active?
      PBAI.log("Restricting moves...")
      data = load_data("Data/species.dat")
      move_data = load_data("Data/moves.dat")
      restricted = Restrictions::BANNED_MOVES
      move_list = []
      $restricted_moves = {
        :pokemon => [],
        :moves => []
        }

      return if !data.is_a?(Hash) || !move_data.is_a?(Hash)
      for key in data.keys
        moveset = []
        species = data[key].id
        next if $restricted_moves[:pokemon].include?(species)
        for i in data[key].moves
          next if restricted.include?(i[1])
          moves = []
          moves.push(i[0])
          moves.push(i[1])
          moveset.push(moves)
        end
        $restricted_moves[:moves].push(moveset)
        $restricted_moves[:pokemon].push(data[key].id)
      end
      @moves = $restricted_moves
      $game_variables[Restriction_Info::Moves] = @moves
      $game_variables[Randomizer_Info::Movesets] = @moves if Randomizer.active?(:MOVES)
      return @moves
    end
  end

  def getRestrictedAbility(species,ability_index)
    array = Restrictions.abilities
    ability = array[:abilities]
    pokemon = array[:pokemon]
    idx = -1
    for i in pokemon
      idx += 1
      break if i == species
    end
    return ability[idx][ability_index]
  end

  def getRestrictedMoves(species)
    pkmn = GameData::Species.get(species).id
    array = Restrictions.moves
    moves = array[:moves]
    pokemon = array[:pokemon]
    idx = -1
    for i in pokemon
      idx += 1
      break if i == pkmn
    end
    return moves[idx]
  end