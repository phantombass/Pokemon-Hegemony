class PBAI
  class SwitchHandler
    @@GeneralCode = []
    @@TypeCode = []

	  def self.add(&code)
	   	@@GeneralCode << code
	 	end

	  def self.add_type(*type,&code)
			@@TypeCode << code
	  end

		def self.trigger(list,score,ai,user,target)
			return score if list.nil?
			list = [list] if !list.is_a?(Array)
			list.each do |code|
		  	next if code.nil?
		  		newscore = code.call(score,ai,user,target)
		  		score = newscore if newscore.is_a?(Numeric)
		  	end
		  return score
		end

		def self.trigger_general(score,ai,user,target)
		  return self.trigger(@@GeneralCode,score,ai,user,target)
		end

		def self.trigger_type(type,score,ai,user,target)
			target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
			if target_moves != nil
	  		for i in target_moves
					$has_move_type = true if i.type == type && i.damagingMove? && user.calculate_move_matchup(i.id) > 1    
			  end
			end
			if $has_move_type
		  	return self.trigger(@@TypeCode,score,ai,user,target)
		  else
		  	score += 0
		  	return score
		  end
		end
  end
end

#=======================
#Type Immunity Modifiers
#=======================

PBAI::SwitchHandler.add_type(:FIRE) do |score,ai,user,target|
  if user.hasActiveAbility?([:FLASHFIRE,:STEAMENGINE,:WELLBAKEDBODY]) || user.hasActiveItem?(:FLASHFIREORB)
    score += 100
  end
  if user.hasActiveAbility?(:THERMALEXCHANGE)
    score += 60
  end
	next score
end

PBAI::SwitchHandler.add_type(:WATER) do |score,ai,user,target|
  if user.hasActiveAbility?([:WATERABSORB,:DRYSKIN,:STORMDRAIN,:STEAMENGINE,:WATERCOMPACTION]) || user.hasActiveItem?(:WATERABSORBORB)
    score += 100
  end
	next score
end

PBAI::SwitchHandler.add_type(:GRASS) do |score,ai,user,target|
	  if user.hasActiveAbility?(:SAPSIPPER) || user.hasActiveItem?(:SAPSIPPERORB)
	    score += 100
	  end
	next score
end

PBAI::SwitchHandler.add_type(:ELECTRIC) do |score,ai,user,target|
	  if user.hasActiveAbility?([:VOLTABSORB,:LIGHTNINGROD]) || user.hasActiveItem?(:LIGHTNINGRODORB)
	    score += 100
	  end
	next score
end

PBAI::SwitchHandler.add_type(:GROUND) do |score,ai,user,target|
	  if user.hasActiveAbility?(:EARTHEATER) || user.hasActiveItem?(:EARTHEATERORB) || user.airborne?
	    score += 100
	  end
	next score
end

PBAI::SwitchHandler.add_type(:DARK) do |score,ai,user,target|
	  if user.hasActiveAbility?(:UNTAINTED)
	    score += 100
	  end
	next score
end

PBAI::SwitchHandler.add_type(:COSMIC) do |score,ai,user,target|
	  if user.hasActiveAbility?(:DIMENSIONBLOCK) || user.hasActiveItem?(:DIMENSIONBLOCKORB)
	    score += 100
	  end
	next score
end

#=======================
#Other Modifiers
#=======================

#Defensive Role modifiers
PBAI::SwitchHandler.add do |score,ai,user,target|
  user.opposing_side.battlers.each do |target|
  	next if target.nil?
  	if target.is_physical_attacker? && user.role.id == :PHYSICALWALL
  		score += 100
  	end
  	if target.is_special_attacker? && user.role.id == :SPECIALWALL
  		score += 100
  	end
  end
	next score
end

#Future Sight
PBAI::SwitchHandler.add do |score,ai,user,target|
	party = ai.battle.pbParty(user.index)
	pos = ai.battle.positions[user.index]
	switch_to_dark_type = false
    # If Future Sight will hit at the end of the round
    if pos.effects[PBEffects::FutureSightCounter] == 1
      # And if we have a dark type in our party
      if party.any? { |pkmn| pkmn.types.include?(:DARK) }
        # We should switch to a dark type,
        # but not if we're already close to dying anyway.
        switch_to_dark_type = true
      end
    end
    if switch_to_dark_type
    	score += 300 if user.pokemon.types.include?(:DARK)
    end
	next score
end

#Matchup
PBAI::SwitchHandler.add do |score,ai,user,target|
	off_score = user.get_offense_score(target)
	def_score = target.get_offense_score(user)
	if def_score > off_score
		score += 0
	elsif off_score > def_score
		score += (off_score-def_score)*100
		if user.role.id == :OFFENSIVEPIVOT
			score += 50
		end
	else
		score += 0
	end
	if off_score < 2 && def_score < 1 && user.defensive?
		score += 50
	end
	next score
end

#Setup Prevention
PBAI::SwitchHandler.add do |score,ai,user,target|
	boosts = 0
	GameData::Stat.each_battle { |s| boosts += target.battler.stages[s] if target.battler.stages[s] != nil}
	score += (boosts * 10)
	user.flags[:should_haze] if boosts >= 2
	next score
end

#Identifying Setup Fodder
PBAI::SwitchHandler.add do |score,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	off = 0
	if target_moves != nil
		for i in target_moves
			dmg = user.get_move_damage(target, i)
			off += 1 if i.damagingMove? && dmg >= user.totalhp/2
	  end
	  if off == 0
	  	score += 400
	  	user.flags[:should_setup] = true
	  	user.flags[:should_taunt] = true
	  end
	end
end

#Health Related
PBAI::SwitchHandler.add do |score,ai,user,target|
	if user.hp <= user.totalhp/4
		score -= 100
	end
	if ai.battle.positions[user.index].effects[PBEffects::Wish] > 0 && user.hp <= user.totalhp/3
		score += 200
		score += 100 if user.setup?
	end
	next score
end

#Don't switch if you will die to hazards
PBAI::SwitchHandler.add do |score,ai,user,target|
	hazard_score = 0
  rocks = user.own_side.effects[PBEffects::StealthRock] ? 1 : 0
  webs = user.own_side.effects[PBEffects::StickyWeb] ? 1 : 0
  spikes = user.own_side.effects[PBEffects::Spikes] > 0 ? user.own_side.effects[PBEffects::Spikes] : 0
  tspikes = user.own_side.effects[PBEffects::ToxicSpikes] > 0 ? user.own_side.effects[PBEffects::ToxicSpikes] : 0
  comet = user.own_side.effects[PBEffects::CometShards] ? 1 : 0
  hazard_score = (rocks*12.5) + (spikes*12.5) + (comet*12.5) + (tspikes*6.25)
  if hazard_score >= ((user.hp/user.totalhp)*100).round
  	score -= 500
  end
  #Switch in to absorb hazards
  if tspikes > 0 && (user.pbHasType?(:POISON) && !user.airborne?) || user.hasActiveAbility?(:GALEFORCE)
  	score += 200
  end
  if comet > 0 && (user.pbHasType?(:COSMIC) && !user.airborne? && !user.hasActiveAbility?(:MAGICGUARD)) || user.hasActiveAbility?(:GALEFORCE)
  	score += 200
  end
end