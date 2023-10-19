################################################################################
# Advanced Pokemon Level Balancing
# By Joltik
#Inspired by Umbreon's code
#Tweaked by Phantombass for use in Pokémon Promenade
################################################################################
################################################################################


module LvlCap
  Switch = 111               #Switch that turns on Trainer Difficulty Control
  LevelCap = 106             #Variable for the Level Cap
  Gym = 86                   #Switch for Gym Battles
  Rival = 87                 #Switch for Rival Battles
  LvlTrainer = 88
  Trainers = 72              #Switch for Trainers
  Boss = 908                  #Switch for Ace Trainer Battles
  Hard = 900
  Expert = 903
  Insane = 902
  Ironmon = 905
  Kaizo = 906
  Randomizer = 907

  def self.start_battle(type)
    case type
    when :Gym
      $game_switches[LvlCap::Gym] = true
    when :Boss
      $game_switches[LvlCap::Boss] = true
    when :Rival
      $game_switches[LvlCap::Rival] = true
    when :LvlTrainer
      $game_switches[LvlCap::LvlTrainer] = true
    end
  end

  def self.end_battle
    type = [:Gym,:Boss,:Rival,:LvlTrainer]
    for i in type
      $game_switches[i] = false
    end
  end

  def self.player_max_level
    return $Trainer.party.map { |e| e.level  }.max
  end
end


Events.onTrainerPartyLoad+=proc {| sender, trainer |
   if trainer # Trainer data should exist to be loaded, but may not exist somehow
     party = trainer[0].party   # An array of the trainer's Pokémon
#     if $game_switches && $Trainer && ($game_switches[LvlCap::Kaizo] || $game_switches[LvlCap::Randomizer])
#       if $game_switches[LvlCap::Gym] == false && $game_switches[LvlCap::Rival] == false && $game_switches[LvlCap::Boss] == false
#         for i in 0..party.length
#           Console.echo _INTL("\n#{party[i]}\n")
#           species = GameData::Species.get(party[i].species)
#           Console.echo _INTL("\n#{species}\n")
#           level = species.level
#           pkmn = Pokemon.new(species,level)
#           pkmn.reset_moves
#         end
#       end
#     end
    if $game_switches && $game_switches[LvlCap::Switch] && $Trainer && $game_switches[Settings::LEVEL_CAP_SWITCH]
       levelcap = $game_switches[LvlCap::Insane] ? INSANE_LEVEL_CAP[$game_system.level_cap] : LEVEL_CAP[$game_system.level_cap]
       badges = $Trainer.badge_count
       mlv = LvlCap.player_max_level
      for i in 0...party.length
        level = 0
        level=1 if level<1
        if $game_switches[LvlCap::Gym] == true
          if $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == false
            level = levelcap + rand(2)
          elsif $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == true
            level = levelcap + rand(2) + 1
          else
            level = levelcap
          end
        elsif $game_switches[LvlCap::Boss] == true && $game_switches[LvlCap::Gym] == false
          if $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == false
            level = levelcap + rand(1)
          elsif $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == true
            level = levelcap + rand(1) + 1
          else
            level = levelcap - rand(1)
          end
        elsif $game_switches[LvlCap::LvlTrainer] == true
          level = levelcap - 5
        elsif $game_switches[LvlCap::Gym] == false && $game_switches[LvlCap::Rival] == false
          level = (mlv-1) - rand(1)
          if $game_switches[LvlCap::Hard]
            level += 1
          elsif $game_switches[LvlCap::Expert]
            level += 2
          end
        elsif $game_switches[LvlCap::Rival] == true && $game_switches[LvlCap::Hard] == false
          level = party[i].level - rand(2)
        elsif $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == false && $game_switches[LvlCap::Rival] == true
          level = party[i].level
        elsif $game_switches[LvlCap::Hard] == true && $game_switches[LvlCap::Expert] == true && $game_switches[LvlCap::Rival] == true
          level = party[i].level + 2
        else
          level = $game_switches[LvlCap::Insane] ? levelcap - 2 : levelcap - 4
        end
        if $game_switches[Settings::DISABLE_EVS] && $game_switches[LvlCap::Hard]
          minus = $game_switches[LvlCap::Expert] ? 1 : 2
          #minus = 0 if $game_switches[LvlCap::Insane]
          level -= minus
        end
        party[i].level = level
        #now we evolve the pokémon, if applicable
        #unused
        species = party[i].species
        party[i].calc_stats
        if ($game_switches[LvlCap::Kaizo] || $game_switches[907]) && ($game_switches[LvlCap::Gym] == false && $game_switches[LvlCap::Rival] == false && $game_switches[LvlCap::Trainers] == false && $game_switches[LvlCap::Boss] == false)
          party[i].species=species
          party[i].reset_moves
        end
      end #end of for
     end
   end
}
