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
  Gym = 70                   #Switch for Gym Battles
  Rival = 69                 #Switch for Rival Battles
  LvlTrainer = 83
  Ace = 129                  #Switch for Ace Trainer Battles
end


Events.onTrainerPartyLoad+=proc {| sender, trainer |
   if trainer # Trainer data should exist to be loaded, but may not exist somehow
     party = trainer[0].party   # An array of the trainer's Pokémon
    if $game_switches && $game_switches[LvlCap::Switch] && $Trainer
       levelcap = $game_variables[LvlCap::LevelCap]
       badges = $Trainer.badge_count
       mlv = $Trainer.party.map { |e| e.level  }.max
      for i in 0...party.length
        level = 0
        level=1 if level<1
      if mlv<levelcap && mlv < party[i].level && $game_switches[LvlCap::Gym] == true
        level = levelcap
      elsif $game_switches[LvlCap::LvlTrainer] == true
        level = levelcap - 5
      elsif mlv<levelcap && mlv>party[i].level && $game_switches[LvlCap::Rival] == true
        level = mlv
      elsif mlv<levelcap && mlv<=party[i].level && $game_switches[LvlCap::Rival] == true
        level = party[i].level
      elsif mlv<levelcap && mlv <= party[i].level
        level = party[i].level
        level = levelcap if level > levelcap
      elsif mlv<levelcap && mlv > party[i].level
        level = (mlv - 2) + rand(5)
        level = levelcap if level > levelcap
      elsif mlv <= 1 && $game_switches[LvlCap::Rival] == true
        level = party[i].level
      else
        level = levelcap
      end
      party[i].level = level
      #now we evolve the pokémon, if applicable
      species = party[i].species
      if badges > 8
      newspecies = GameData::Species.get(species).get_baby_species # revert to the first evolution
      evoflag=0 #used to track multiple evos not done by lvl
      endevo=false
      loop do #beginning of loop to evolve species
      nl = level + 5
      nl = levelcap if nl > levelcap
      pkmn = Pokemon.new(newspecies, nl)
      cevo = GameData::Species.get(newspecies).evolutions
      evo = GameData::Species.get(newspecies).get_evolutions
      if evo
        evo = evo[rand(evo.length - 1)]
        # here we evolve things that don't evolve through level
        # that's what we check with evo[0]!=4
        #notice that such species have cevo==-1 and wouldn't pass the last check
        #to avoid it we set evoflag to 1 (with some randomness) so that
        #pokemon may have its second evolution (Raichu, for example)
        if evo && cevo < 1 && rand(50) <= level
          if evo[0] != 4 && rand(50) <= level
          newspecies = evo[2]
             if evoflag == 0 && rand(50) <= level
               evoflag=1
             else
               evoflag=0
             end
           end
        else
        endevo=true
        end
      end
      if evoflag==0 || endevo
      if  cevo == -1 || rand(50) > level
        # Breaks if there no more evolutions or randomnly
        # Randomness applies only if the level is under 50
        break
      else
        newspecies = evo[2]
      end
      end
      end #end of loop do
    #fixing some things such as Bellossom would turn into Vileplume
    #check if original species could evolve (Bellosom couldn't)
    couldevo=GameData::Species.get(species).get_evolutions
    #check if current species can evolve
    evo = GameData::Species.get(newspecies).get_evolutions
      if evo.length<1 && couldevo.length<1
      else
         species=newspecies
      end #end of evolving script
    end
      party[i].name=GameData::Species.get(species).name
      party[i].species=species
      party[i].calc_stats
      if $game_switches[LvlCap::Gym] == false && $game_switches[LvlCap::Ace] == false && $game_switches[LvlCap::LvlTrainer] == false
        party[i].reset_moves
      end
      end #end of for
     end
     end
}
