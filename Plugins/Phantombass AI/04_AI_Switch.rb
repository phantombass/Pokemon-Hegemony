class PBAI
  class SwitchHandler
    @@GeneralCode = []
    @@TypeCode = []
    @@SwitchOutCode = []

	  def self.add(&code)
	   	@@GeneralCode << code
	 	end

	  def self.add_type(*type,&code)
			@@TypeCode << code
	  end

	  def self.add_out(&code)
	  	@@SwitchOutCode << code
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

		def self.out_trigger(list,switch,ai,user,target)
			return switch if list.nil?
			list = [list] if !list.is_a?(Array)
			list.each do |code|
	  	next if code.nil?
	  		newswitch = code.call(switch,ai,user,target)
	  		switch = newswitch if ![true,false].include?(switch)
	  	end
		  return switch
		end

		def self.trigger_general(score,ai,user,target)
		  return self.trigger(@@GeneralCode,score,ai,user,target)
		end

		def self.trigger_out(switch,ai,user,target)
		  return self.out_trigger(@@SwitchOutCode,switch,ai,user,target)
		end

		def self.trigger_type(type,score,ai,user,target)
		  return self.trigger(@@TypeCode,score,ai,user,target)
		end
  end
end

#=======================
#Type Immunity Modifiers
#=======================

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :FIRE && i.damagingMove? && user.calculate_move_matchup(i.id) > 1
	end
	if $game_switches[LvlCap::Expert]
		if has_move
			switch = true
		end
	else
		if has_move && target.pbHasType?(:FIRE)
			switch = true
		end
	end
	$switch_flags[:fire] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :WATER && i.damagingMove? && user.calculate_move_matchup(i.id) > 1
	end
	if $game_switches[LvlCap::Expert]
		if has_move
			switch = true
		end
	else
		if has_move && target.pbHasType?(:WATER)
			switch = true
		end
	end
	$switch_flags[:water] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :GRASS && i.damagingMove? && user.calculate_move_matchup(i.id) > 1
	end
	if $game_switches[LvlCap::Expert]
		if has_move
			switch = true
		end
	else
		if has_move && target.pbHasType?(:GRASS)
			switch = true
		end
	end
	$switch_flags[:grass] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :ELECTRIC && i.damagingMove? && user.calculate_move_matchup(i.id) > 1
	end
	if $game_switches[LvlCap::Expert]
		if has_move
			switch = true
		end
	else
		if has_move && target.pbHasType?(:ELECTRIC)
			switch = true
		end
	end
	$switch_flags[:electric] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :GROUND && i.damagingMove? && user.calculate_move_matchup(i.id) > 1
	end
	if $game_switches[LvlCap::Expert]
		if has_move
			switch = true
		end
	else
		if has_move && target.pbHasType?(:GROUND)
			switch = true
		end
	end
	if target.inTwoTurnAttack?("0CA")
		switch = true
		$switch_flags[:digging] = true
	end
	$switch_flags[:ground] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :ROCK && i.damagingMove? && user.calculate_move_matchup(i.id) > 1
	end
	if $game_switches[LvlCap::Expert]
		if has_move
			switch = true
		end
	else
		if has_move && target.pbHasType?(:ROCK)
			switch = true
		end
	end
	$switch_flags[:rock] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :COSMIC && i.damagingMove? && user.calculate_move_matchup(i.id) > 1
	end
	if $game_switches[LvlCap::Expert]
		if has_move
			switch = true
		end
	else
		if has_move && target.pbHasType?(:COSMIC)
			switch = true
		end
	end
	$switch_flags[:cosmic] = true if switch
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	for i in target_moves
		next if target_moves == nil
		has_move = true if i.type == :DARK && i.damagingMove? && user.calculate_move_matchup(i.id) > 1
	end
	if $game_switches[LvlCap::Expert]
		if has_move
			switch = true
		end
	else
		if has_move && target.pbHasType?(:DARK)
			switch = true
		end
	end
	$switch_flags[:dark] = true if switch
	next switch
end

PBAI::SwitchHandler.add_type(:FIRE) do |score,ai,user,target|
	if $switch_flags[:fire] == true
	  if user.hasActiveAbility?([:FLASHFIRE,:STEAMENGINE,:WELLBAKEDBODY]) || user.hasActiveItem?(:FLASHFIREORB)
	    score += 200
	  end
	  if user.hasActiveAbility?(:THERMALEXCHANGE) 
	    score += 120
	  end
	end
	next score
end

PBAI::SwitchHandler.add_type(:WATER) do |score,ai,user,target|
	if $switch_flags[:water] == true
	  if user.hasActiveAbility?([:WATERABSORB,:DRYSKIN,:STORMDRAIN,:STEAMENGINE,:WATERCOMPACTION]) || user.hasActiveItem?(:WATERABSORBORB)
	    score += 200
	  end
	end
	next score
end

PBAI::SwitchHandler.add_type(:GRASS) do |score,ai,user,target|
	if $switch_flags[:grass] == true
	  if user.hasActiveAbility?(:SAPSIPPER) || user.hasActiveItem?(:SAPSIPPERORB)
	    score += 200
	  end
	end
	next score
end

PBAI::SwitchHandler.add_type(:ELECTRIC) do |score,ai,user,target|
	if $switch_flags[:electric] == true
	  if user.hasActiveAbility?([:VOLTABSORB,:LIGHTNINGROD,:MOTORDRIVE]) || user.hasActiveItem?(:LIGHTNINGRODORB)
	    score += 200
	  end
	end
	next score
end

PBAI::SwitchHandler.add_type(:GROUND) do |score,ai,user,target|
	if $switch_flags[:ground] == true
	  if user.hasActiveAbility?(:EARTHEATER) || user.hasActiveItem?(:EARTHEATERORB) || user.airborne?
	    score += 200
	  end
	  for i in target.moves
	  	if user.calculate_move_matchup(i.id) < 1 && i.function == "0CA"
	  		dig = true
	  	end
	  end
	  if dig == true && $switch_flags[:digging] == true
	  	score += 150
	  end
	end
	next score
end

PBAI::SwitchHandler.add_type(:DARK) do |score,ai,user,target|
	pos = ai.battle.positions[user.index]
	party = ai.battle.pbParty(user.index)
	if $switch_flags[:dark] == true
	  if user.hasActiveAbility?(:UNTAINTED)
	    score += 200
	  elsif user.hasActiveAbility?(:JUSTIFIED)
	  	score += 150
	  end
	  if pos.effects[PBEffects::FutureSightCounter] == 1 && user.pbHasType?(:DARK)
	  	score += 300
	  end
	end
	next score
end

PBAI::SwitchHandler.add_type(:COSMIC) do |score,ai,user,target|
	if $switch_flags[:cosmic] == true
	  if user.hasActiveAbility?(:DIMENSIONBLOCK) || user.hasActiveItem?(:DIMENSIONBLOCKORB)
	    score += 200
	  end
	  if user.own_side.effects[PBEffects::CometShards] && user.pbHasType?(:COSMIC)
	  	score += 200
	  end
	end
	next score
end

PBAI::SwitchHandler.add do |score,ai,user,target|
	if $switch_flags[:poison] == true && user.pbHasType?(:POISON)
	  if user.own_side.effects[PBEffects::ToxicSpikes]
	  	score += 200
	  end
	end
	next score
end

PBAI::SwitchHandler.add_type(:ROCK) do |score,ai,user,target|
	if $switch_flags[:rock] == true
	  if user.hasActiveAbility?(:SCALER) || user.hasActiveItem?(:SCALERORB)
	    score += 200
	  end
	end
	next score
end

#=======================
# Switch Out Modifiers
#=======================

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	if !ai.battle.pbCanChooseAnyMove?(user.index)
    switch = true
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	if user.effects[PBEffects::PerishSong] == 1
    switch = true
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	if user.choice_locked?
    choiced_move_name = GameData::Move.get(user.effects[PBEffects::ChoiceBand])
    factor = 0
    user.opposing_side.battlers.each do |pkmn|
      factor += pkmn.calculate_move_matchup(choiced_move_name)
    end
    if (factor < 1 && ai.battle.pbSideSize(0) == 1) || (factor < 2 && ai.battle.pbSideSize(0) == 2)
      switch = true
    end
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	for i in user.set_up_score
    sum = 0
    sum += i
    if i < 0
      switch = true
    else
      if sum >= 2
        switch = false
      end
    end
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	if user.effects[PBEffects::Toxic] > 1
    switch = true
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	party = ai.battle.pbParty(user.index)
	if user.status != :NONE
		if party.any? {|pkmn| pkmn.role.id == :CLERIC && user.role.id != :CLERIC}
    	switch = true
    	$switch_flags[:need_cleric] = true
    end
    if user.hasActiveAbility?(:NATURALCURE)
    	switch = true
    end
    if user.hasActiveAbility?(:GUTS)
    	switch = false
    end
  end
	next switch
end

#Matchup
PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	calc = 0
	damage = 0
	if target.bad_against?(user) && target_moves != nil
		user.opposing_side.battlers.each do |target|
		  next if ai.battle.wildBattle?
			for i in target_moves
				next if target_moves == nil
			  dmg = target.get_move_damage(user, i)
			  calc += 1 if (dmg >= user.hp/2 || dmg >= user.totalhp/2)
			end
		end
		user.opposing_side.battlers.each do |target|
		  next if ai.battle.wildBattle?
		  for i in user.moves
		    dmg = user.get_move_damage(target, i)
		    damage += 1 if (dmg >= target.hp/2 || dmg >= target.totalhp/2)
		  end
		end
		if user.faster_than?(target) && damage >= 0 && calc == 0
			switch = false
		end
		if user.faster_than?(target) && damage == 0 && calc > 0
			switch = true
		end
		if target.faster_than?(user) && damage >= 0 && calc == 0
			switch = false
		end
		if target.faster_than?(user) && calc > 0
			switch = true
		end
	elsif target.bad_against?(user) && target_moves == nil
		switch = false
	end
	if user.bad_against?(target)
		switch = true
	end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	calc = 0
	damage = 0
	flag1 = false
	flag2 = false
	user.opposing_side.battlers.each do |target|
	  next if ai.battle.wildBattle?
	  next if target_moves == nil
		for i in target_moves
		  calc += 1 if i.damagingMove?
		end
		if calc <= 0
			flag1 = true
		end
		for i in user.moves
	    dmg = user.get_move_damage(target, i)
	    damage += 1 if dmg >= target.totalhp/2
	  end
	  if damage == 0
	  	flag2 = true
	  end
	  if flag1 == true && flag2 == true
	  	$switch_flags[:setup_fodder].push(target)
	  	switch = user.setup? ? false : true
	  end
	end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	pos = ai.battle.positions[user.index]
	party = ai.battle.pbParty(user.index)
	tspikes = user.own_side.effects[PBEffects::ToxicSpikes] == nil ? 0 : user.own_side.effects[PBEffects::ToxicSpikes]
	comet = user.own_side.effects[PBEffects::CometShards] == false ? 0 : 1
	if tspikes > 0
	  if party.any? { |pkmn| pkmn.types.include?(:POISON) }
	    switch = true
	    $switch_flags[:poison] = true
	  end
	end
	if comet > 0
	  if party.any? { |pkmn| pkmn.types.include?(:COSMIC) }
	    switch = true
	    $switch_flags[:cosmic] = true
	  end
	end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	if user.effects[PBEffects::Encore] > 0
    encored_move_index = user.pbEncoredMoveIndex
    if encored_move_index >= 0
      encored_move = user.moves[encored_move_index]
      if encored_move.statusMove?
        switch = true
      else
        dmgs = self.damage_dealt.select { |e| e[1] == encored_move.id }
        if dmgs.size > 0
          last_dmg = dmgs[-1]
          # Bad move if it did less than 25% damage
          if last_dmg[3] < 0.25
            switch = true
          end
        else
          # No record of dealing damage with this move,
          # which probably means the target is immune somehow,
          # or the user happened to miss. Don't risk being stuck in
          # a bad move in any case, and switch.
          switch = true
        end
      end
    end
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	pos = ai.battle.positions[user.index]
	party = ai.battle.pbParty(user.index)
  # If Future Sight will hit at the end of the round
  if pos.effects[PBEffects::FutureSightCounter] == 1
    # And if we have a dark type in our party
    if party.any? { |pkmn| pkmn.types.include?(:DARK) }
      # We should switch to a dark type,
      # but not if we're already close to dying anyway.
      if !self.may_die_next_round?
        switch = true
        $switch_flags[:dark] = true
      end
    end
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	if user.trapped?
    switch = false
  end
	next switch
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	calc = 0
	user.opposing_side.battlers.each do |target|
	  next if ai.battle.wildBattle?
	  for i in user.moves
	    dmg = user.get_move_damage(target, i)
	    calc += 1 if dmg >= target.totalhp/3
	  end
	end
	if calc == 0
	  switch = true
	end
	next switch
end
#=======================
#Other Modifiers
#=======================

#Defensive Role modifiers
PBAI::SwitchHandler.add do |score,ai,user,target|
  user.opposing_side.battlers.each do |target|
  	next if target.nil?
  	if target.is_physical_attacker? && user.role.id == :PHYSICALWALL
  		score += 200
  	end
  	if target.is_special_attacker? && user.role.id == :SPECIALWALL
  		score += 200
  	end
  	if target.defensive? && ![:PHYSICALWALL,:SPECIALWALL].include?(user.role.id)
  		if [:DEFENSIVEPIVOT,:CLERIC,:TOXICSTALLER,:HAZARDLEAD].include?(user.role.id)
  			score += 150
  		else
  			score += 100
  		end
  	end
  end
	next score
end

#Setup Prevention
PBAI::SwitchHandler.add do |score,ai,user,target|
	boosts = 0
	GameData::Stat.each_battle { |s| boosts += target.battler.stages[s] if target.battler.stages[s] != nil}
	score += (boosts * 10)
	$learned_flags[:has_setup].push(target) if boosts >= 1
	next score
end

#Identifying Setup Fodder
PBAI::SwitchHandler.add do |score,ai,user,target|
	if $switch_flags[:setup_fodder]
		target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
		off = 0
		if target_moves != nil
			for i in target_moves
				next if target_moves == nil
				dmg = user.get_move_damage(target, i)
				off += 1 if i.damagingMove? && dmg >= user.totalhp/2
		  end
		  if off == 0
		  	score += 400
		  	$learned_flags[:setup_fodder].push(target)
		  	$learned_flags[:should_taunt].push(target)
		  end
		end
	end
end

#Health Related
PBAI::SwitchHandler.add do |score,ai,user,target|
	if user.hp <= user.totalhp/4
		score -= 100
	end
	if ai.battle.positions[user.index].effects[PBEffects::Wish] > 0 && user.hp <= user.totalhp/3
		score += 400
		score += 200 if user.setup?
	end
	if $switch_flags[:need_cleric] && user.role.id == :CLERIC
		score += 400
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
  	score += 400
  end
  if comet > 0 && (user.pbHasType?(:COSMIC) && !user.airborne? && !user.hasActiveAbility?(:MAGICGUARD)) || user.hasActiveAbility?(:GALEFORCE)
  	score += 400
  end
  next score
end

PBAI::SwitchHandler.add do |score,ai,user,target|
	if $switch_flags[:move] != nil
	   lastMove = $switch_flags[:move]
	   next if lastMove == nil
	   immune = 0
	   immune = user.calculate_move_matchup(lastMove.id) == 0 ? 600 : (300/user.calculate_move_matchup(lastMove.id))
	   immune = 0 if immune < 300
	   score += immune
 	end
  next score
end

PBAI::SwitchHandler.add_out do |switch,ai,user,target|
	prevDmg = user.get_damage_by_user(target)
  if prevDmg.size > 0 && prevDmg != 0
    lastDmg = prevDmg[-1]
    lastMove = PokeBattle_Move.from_pokemon_move(ai.battle,Pokemon::Move.new(lastDmg[1]))
    switch = true if user.calculate_move_matchup(lastMove.id) > 1
    $switch_flags[:move] = lastMove if switch == true
  end
  next switch
end

#Matchup
PBAI::SwitchHandler.add do |score,ai,user,target|
	off_score = user.get_offense_score(target)
	def_score = target.get_offense_score(user)
	score *= off_score
	score *= (1/def_score)
	next score
end