module Mission
  Main = 504
end

def pbMissionUpdate(num)
  case num
  when 1
    $game_variables[Mission::Main] += 1
    $PokemonGlobal.quests.advanceQuestToStage(:Quest1,$game_variables[Mission::Main],"463F0000",false)
  end
end

def pbNewMission(num)
  case num
  when 1
    $game_variables[Mission::Main] = 1
    $PokemonGlobal.quests.activateQuest(:Quest1,"56946F5A",false)
  when 2
    $PokemonGlobal.quests.activateQuest(:Quest2,"56946F5A",false)
  when 3
    $PokemonGlobal.quests.activateQuest(:Quest3,"56946F5A",false)
  end
end

def pbCompleteMission(num)
  case num
  when 1
    $game_variables[Mission::Main] = 1
    $PokemonGlobal.quests.completeQuest(:Quest1,"56946F5A",false)
  when 2
    $PokemonGlobal.quests.completeQuest(:Quest2,"56946F5A",false)
  when 3
    $PokemonGlobal.quests.completeQuest(:Quest3,"56946F5A",false)
  end
end
