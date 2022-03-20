module BattleScripts
  TURNER = {
    "afterLastOpp" => "My last Pokémon. Time to switch up my approach!",
    "turnStart0" => "Let's see just how prepared you are!"
  }

  HAZEL = {
    "afterLastOpp" => "Hmm, my last Pokémon...",
    "turnStart0" => "I'm very curious to see how you handle this battle style."
  }

  ASTRID = {
    "afterLastOpp" => "My heavens. Is this my last Pokémon?",
    "turnStart0" => "I hope you're ready to learn about the power of Cosmic-types."
  }

  GORDON = {
    "afterLastOpp" => proc do
      pname = $Trainer.name
      rname = $game_variables[12]
      @scene.pbTrainerSpeak("Get ready #{pname}! Here's my trump card")
    end,
    "turnStart0" => proc do
      pname = $Trainer.name
      rname = $game_variables[12]
      @scene.pbTrainerSpeak("I have heard good things about you from #{rname}! Let's see if he was right.")
    end
  }

  MILITIA1 = {
    "afterLastOpp" => "You are quite good. How frustrating.",
    "turnStart0" => "You don't know what you're dealing with, kid."
  }

  ARMY1 = {
    "afterLastOpp" => "How interesting...",
    "turnStart0" => "Stop while you can kid. You're way out of your depth."
  }
end
