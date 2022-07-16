def grass_starter_eggs
  egg_list = [:BULBASAUR,:CHIKORITA,:TREECKO,:TURTWIG,:SNIVY,:CHESPIN,:ROWLET,:GROOKEY]
  return egg_list
end

def fire_starter_eggs
  egg_list = [:CHARMANDER,:CYNDAQUIL,:TORCHIC,:CHIMCHAR,:TEPIG,:FENNEKIN,:LITTEN,:SCORBUNNY]
  return egg_list
end

def water_starter_eggs
  egg_list = [:SQUIRTLE,:TOTODILE,:MUDKIP,:PIPLUP,:OSHAWOTT,:FROAKIE,:POPPLIO,:SOBBLE]
  return egg_list
end

def hisui_eggs
  egg_list = [:CYNDAQUIL,:ROWLET,:OSHAWOTT,:QWILFISH,:SNEASEL,:GOOMY,:BERGMITE,:PETILIL,:ZORUA,:GROWLITHE,:VOLTORB,:RUFFLET,:BASCULIN]
  return egg_list
end

def random_eggs
  egg_list = [:SKITTY,:GULPIN,:FLABEBE,:AZURILL,:MAREANIE,:SNEASEL,:TEDDIURSA,:TOXEL,:CUBONE,:DARUMAKA,:MIMEJR,:MEOWTH,:EXEGGCUTE,:PONYTA,:CORSOLA,:FARFETCHD,:GEODUDE,:ROLYCOLY,:SKIDDO,:KLINK,:STANTLER,:PICHU,:MAGBY,:ELEKID,:SMOOCHUM,:HAPPINY,:MUNCHLAX,:POIPOLE,:COSMOG,:PHIONE,:KUBFU,:LARVESTA,:SIZZLIPEDE,:SANDACONDA,:MAGNEMITE,:CARBINK,:AUDINO,:RALTS,:ABRA,:GASTLY,:DROWZEE,:ELGYEM,:BRONZOR,:MUNNA,:IMPIDIMP,:INDEEDEE,:PINCURCHIN,:PYUKUMUKU,:WYNAUT,:SCRAGGY,:SEEL,:HORSEA,:JIGGLYPUFF,:MANKEY,:SEVIPER,
  :ZANGOOSE,:SNUBBULL,:MAREEP,:GIRAFARIG,:DUNSPARCE,:CHINGLING,:SNORUNT,:SPHEAL,:BUIZEL,:FINNEON,:ARROKUDA,:MORELULL,:FOMANTIS,:INKAY,:COTTONEE]
  return egg_list
end

def generate_hisui_egg
  rand = rand(hisui_eggs.length)
  egg = hisui_eggs[rand]
  if pbGenerateEgg(egg,_I("Random Hiker"))
    pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
    egg = $Trainer.last_party
    species = egg.species
    move = GameData::Species.get(species).egg_moves
    egg.ability_index = 2
    egg.form = 1
    egg.iv[:HP] = 31
    egg.iv[:DEFENSE] = 31
    egg.iv[:SPECIAL_DEFENSE] = 31
    egg.learn_move(move[rand(move.length)])
    egg.steps_to_hatch = 200
    egg.calc_stats
    vTSS(@event_id,"A")
  else
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
  end
end

def generate_random_egg
  rand = rand(random_eggs.length)
  regionals = [:CUBONE,:DARUMAKA,:MIMEJR,:MEOWTH,:EXEGGCUTE,:PONYTA,:CORSOLA,:FARFETCHD,:GEODUDE]
  reg_rand = rand(10)
  egg = random_eggs[rand]
  if pbGenerateEgg(egg,_I("Random Hiker"))
    pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
    egg = $Trainer.last_party
    species = egg.species
    move = GameData::Species.get(species).egg_moves
    egg.ability_index = 2
    egg.form = !regionals.include?(species) ?  0 : reg_rand > 4 ? 1 : 0
    egg.iv[:HP] = 31
    egg.iv[:DEFENSE] = 31
    egg.iv[:SPECIAL_DEFENSE] = 31
    egg.learn_move(move[rand(move.length)])
    egg.steps_to_hatch = 200
    egg.calc_stats
    vTSS(@event_id,"A")
  else
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
  end
end

def generate_starter_egg(type)
  case type
  when :GRASS
    rand = rand(grass_starter_eggs.length)
    hisui_rand = rand(10)
    egg = grass_starter_eggs[rand]
    if pbGenerateEgg(egg,_I("Random Hiker"))
      pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
      egg = $Trainer.last_party
      species = egg.species
      move = GameData::Species.get(species).egg_moves
      egg.ability_index = 2
      egg.form = species != :ROWLET ? 0 : hisui_rand > 4 ? 1 : 0
      egg.iv[:HP] = 31
      egg.iv[:DEFENSE] = 31
      egg.iv[:SPECIAL_DEFENSE] = 31
      egg.learn_move(move[rand(move.length)])
      egg.steps_to_hatch = 200
      egg.calc_stats
      vTSS(@event_id,"A")
    else
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
    end
  when :FIRE
    rand = rand(fire_starter_eggs.length)
    hisui_rand = rand(10)
    egg = fire_starter_eggs[rand]
    if pbGenerateEgg(egg,_I("Random Hiker"))
      pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
      egg = $Trainer.last_party
      species = egg.species
      move = GameData::Species.get(species).egg_moves
      egg.ability_index = 2
      egg.form = species != :CYNDAQUIL ? 0 : hisui_rand > 4 ? 1 : 0
      egg.iv[:HP] = 31
      egg.iv[:DEFENSE] = 31
      egg.iv[:SPECIAL_DEFENSE] = 31
      egg.learn_move(move[rand(move.length)])
      egg.steps_to_hatch = 200
      egg.calc_stats
      vTSS(@event_id,"A")
    else
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
    end
  when :WATER
    rand = rand(water_starter_eggs.length)
    hisui_rand = rand(10)
    egg = water_starter_eggs[rand]
    if pbGenerateEgg(egg,_I("Random Hiker"))
      pbMessage(_INTL("\\me[Egg get]\\PN received an Egg!"))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Take good care of it!"))
      egg = $Trainer.last_party
      species = egg.species
      move = GameData::Species.get(species).egg_moves
      egg.ability_index = 2
      egg.form = species != :OSHAWOTT ? 0 : hisui_rand > 4 ? 1 : 0
      egg.iv[:HP] = 31
      egg.iv[:DEFENSE] = 31
      egg.iv[:SPECIAL_DEFENSE] = 31
      egg.learn_move(move[rand(move.length)])
      egg.steps_to_hatch = 200
      egg.calc_stats
      vTSS(@event_id,"A")
    else
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Oh, you can't carry it with you."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("\\[7fe00000]Make some space in your party and come back."))
    end
  end
end
