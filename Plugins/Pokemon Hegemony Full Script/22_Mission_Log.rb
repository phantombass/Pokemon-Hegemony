module Mission
  Main = 504
end

def pbMissionUpdate(num)
  case num
  when 1
    $game_variables[Mission::Main] += 1
    $PokemonGlobal.quests.advanceQuestToStage(:Quest1,$game_variables[Mission::Main],"463F0000",false)
  when 5
    $PokemonGlobal.quests.advanceQuestToStage(:Quest5,2,"463F0000",false)
  when 7
    $PokemonGlobal.quests.advanceQuestToStage(:Quest7,2,"463F0000",false)
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
  when 4
    $PokemonGlobal.quests.activateQuest(:Quest4,"56946F5A",false)
  when 5
    $PokemonGlobal.quests.activateQuest(:Quest5,"56946F5A",false)
  when 6
    $PokemonGlobal.quests.activateQuest(:Quest6,"56946F5A",false)
  when 7
    $PokemonGlobal.quests.activateQuest(:Quest7,"56946F5A",false)
  end
end

def pbCompleteMission(num)
  case num
  when 1
    $PokemonGlobal.quests.completeQuest(:Quest1,"56946F5A",false)
  when 2
    $PokemonGlobal.quests.completeQuest(:Quest2,"56946F5A",false)
  when 3
    $PokemonGlobal.quests.completeQuest(:Quest3,"56946F5A",false)
  when 4
    $PokemonGlobal.quests.completeQuest(:Quest4,"56946F5A",false)
  when 5
    $PokemonGlobal.quests.completeQuest(:Quest5,"56946F5A",false)
  when 6
    $PokemonGlobal.quests.completeQuest(:Quest6,"56946F5A",false)
  when 7
    $PokemonGlobal.quests.completeQuest(:Quest7,"56946F5A",false)
  end
end
