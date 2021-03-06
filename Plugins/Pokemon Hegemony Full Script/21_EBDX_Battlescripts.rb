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

  GAIL = {
    "afterLastOpp" => "I see you've picked up rather fast. Think you can handle this one, though?",
    "turnStart0" => "You'll be so confused in this battle. It's ok, you'll learn."
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

  WINSLOW = {
    "afterLastOpp" => "Am I being played here? This is my last ditch Pokémon!",
    "turnStart0" => "Things are about to get real twisted in here!"
  }

  VINCENT = {
    "afterLastOpp" => "Looks like it's closing time. Last call!",
    "turnStart0" => "Let's march."
  }

  JACKSON = {
    "afterLastOpp" => "Don't think we've given up!",
    "turnStart0" => "I don't plan on losing to some punk."
  }

  MILITIA1 = {
    "afterLastOpp" => "You are quite good. How frustrating.",
    "turnStart0" => "You don't know what you're dealing with, kid."
  }

  MILITIA2 = {
    "afterLastOpp" => "...",
    "turnStart0" => "..."
  }

  ARMY1 = {
    "afterLastOpp" => "How interesting...",
    "turnStart0" => "Stop while you can kid. You're way out of your depth."
  }

  ARMY2 = {
    "afterLastOpp" => "How infuriating...",
    "turnStart0" => "Don't think you can beat my team again like you did last time."
  }

  OFFCORP1 = {
    "afterLastOpp" => "I can't say I was expecting this.",
    "turnStart0" => "Prepare to be overrun."
  }

  NAVY1 = {
    "afterLastOpp" => "Ah, I see yer point. Well said, yungin.",
    "turnStart0" => "Ye may as well be a criminal showing up at a time like this."
  }

  NAVY2 = {
    "afterLastOpp" => "...",
    "turnStart0" => "..."
  }

  AIRFORCE1 = {
    "afterLastOpp" => "I do believe we are getting to the best part of this match!",
    "turnStart0" => "It's not that I don't trust you kiddo. I've just got to do my due diligence."
  }

  CHANCELLOR1 = {
    "afterLastOpp" => "I will not accept this. I WILL MAINTAIN CONTROL!",
    "turnStart0" => "You can't seem to comprehend. I control EVERYTHING."
  }
end
