#===============================================================================
# ** Better AI
# ** By #Not Important
#===============================================================================
=begin
Changes:
  - There is now an AI class for over 200 skill, beast mode.
	- Mega Evolution will only be used if:
    ~ One of the AI's moves is super effective
    ~ The opponent is on low HP (1/3)
  - The switching out for AI is now *much* more sophisticated, here are a few
    things I did:
    ~ If the user has a priority move, stay in
    ~ If the user is faster than the opponent and has a super effective move,
      stay in
		~ If the opponent is in the middle of a two-turn move, and cannot attack,
      stay in.
    ~ If the user is in the last turn of perish song, switch
    ~ I did more stuff but cannot be bothered to document it all here
  - Moves are NOT chosen as a possibility if they are not:
		~ Priority
		~ Super effective
    ~ Powerful
  - If no moves fit the above conditions, choose a random one
=end
#-------------------------------------------------------------------------------
# AI skill levels:
#     0:     Wild Pokémon
#     1-31:  Basic trainer (young/inexperienced)
#     32-47: Some skill
#     48-99: High skill
#     100+:  Best trainers (Gym Leaders, Elite Four, Champion)
# NOTE: A trainer's skill value can range from 0-255, but by default only four
#       distinct skill levels exist. The skill value is typically the same as
#       the trainer's base money value.
module PBTrainerAI
	# Minimum skill level to be in each AI category.
	def self.minimumSkill; return 1;   end
	def self.mediumSkill;  return 32;  end
	def self.highSkill;    return 48;  end
	def self.bestSkill;    return 100; end
	def self.beastMode;    return 200; end
end
$nextMove   = nil
$nextTarget = nil
$nextQue    = 0
def isSuperEffective?(battler1,battler2)
	types = [battler2.type1,battler2.type2]
	mod = 0
	battler1.moves do |m|
		types do |t|
			if PurifyChamberSet.isSuperEffective(m,t)
				mod += 1
			else
				mod -= 1
			end
		end
	end
	if mod >= 1
		return true
	end
	return false
end

class PokeBattle_Move
	def pbDisplayUseMessage(user)
    @battle.pbDisplayBrief(_INTL("{1} used {2}!",user.pbThis,@name))
		if !user.opposes?
			case $target_idx
			when 0
				$ai_learned_team[:moves1].push(@realMove)
				$ai_learned_team[:moves1].uniq!
			when 1
				$ai_learned_team[:moves2].push(@realMove)
				$ai_learned_team[:moves2].uniq!
			when 2
				$ai_learned_team[:moves3].push(@realMove)
				$ai_learned_team[:moves3].uniq!
			when 3
				$ai_learned_team[:moves4].push(@realMove)
				$ai_learned_team[:moves4].uniq!
			when 4
				$ai_learned_team[:moves5].push(@realMove)
				$ai_learned_team[:moves5].uniq!
			when 5
				$ai_learned_team[:moves6].push(@realMove)
				$ai_learned_team[:moves6].uniq!
			end
		end
  end
end

class PokeBattle_AI
	def initialize(battle)
		@battle = battle
		$ai_learned_team = {
			:pokemon => [],
			:moves1 => [],
			:moves2 => [],
			:moves3 => [],
			:moves4 => [],
			:moves5 => [],
			:moves6 => []
		}
		$enem_prio = false
		$enem_should_switch = false
		$targ_moves = []
	end
	def pbEnemyShouldMegaEvolve?(idxBattler)
		battler = @battle.battlers[idxBattler]
    return true if battler.turnCount == 0
  end

#-------------------------------------------------------------------------------
# Switching pkmn
	#=============================================================================
	# Decide whether the opponent should switch Pokémon
	#=============================================================================
	def pbEnemyShouldWithdraw?(idxBattler)
		return pbEnemyShouldWithdrawEx?(idxBattler,false)
	end

	def shouldSwitchHandler(idxBattler,battler,opps)
    battler = @battle.battlers[idxBattler]
		skill = @battle.pbGetOwnerFromBattlerIndex(idxBattler).skill_level || 0
		moves = battler.moves
		hp = battler.hp
		higherhp = false
		hyper = false
		thp = battler.totalhp
#		opps = battler.eachOpposing
		move_pri = false
		move_super = false
		faster = false
		opp_move_pri = false
		battler.moves do |m|
			if m.priority>0
				move_pri = true
			end
			opps do |o|
				if PurifyChamberSet.isSuperEffective(m.type,o.type1)
					move_super = true
				end
				if o.type2
					if PurifyChamberSet.isSuperEffective(m.type,o.type2)
						move_super = true
					end
				end
				if battler.stats[:SPEED]>o.stats[:SPEED] && battler.status != :PARALYSIS
					faster = true
				end
				oppmoves = o.moves
				oppmoves do |om|
					if om.priority>0
						opp_move_pri = true
					end
				end
				if hp > o.hp
					higherhp = true
				else
					higherhp = false
				end
				if @battle.pbSideSize(battler.index+1)==1 &&
					!battler.pbDirectOpposing.fainted? && skill>=PBTrainerAI.highSkill
					opp = battler.pbDirectOpposing
					if opp.effects[PBEffects::HyperBeam]>0 ||
						(opp.hasActiveAbility?(:TRUANT) && opp.effects[PBEffects::Truant])
						hyper = true
					else
						hyper = false
					end
				end
			end
		end
		if move_pri && !opp_move_pri
			return false
		end
		if skill >= PBTrainerAI.mediumSkill
			if move_super && faster
				return false
			end
		end
		if skill >= PBTrainerAI.highSkill
			if (higherhp && faster) || (higherhp && move_pri) || (higherhp && faster && move_super)
				return false
			end
		end
		if skill >= PBTrainerAI.bestSkill
			if battler.effects[PBEffects::PerishSong]==1
				return true
			end
			if hyper
				return false
			end
		end
		if skill >= PBTrainerAI.beastMode
			if battler.effects[PBEffects::Encore]>0
				idxEncoredMove = battler.pbEncoredMoveIndex
				if idxEncoredMove>=0
					scoreSum   = 0
					scoreCount = 0
					battler.eachOpposing do |b|
						scoreSum += pbGetMoveScore(battler.moves[idxEncoredMove],battler,b,skill)
						scoreCount += 1
					end
					if scoreCount>0 && scoreSum/scoreCount<=20
						return false
					end
				end
			end
			if battler.status==:POISON && battler.statusCount>0
				toxicHP = battler.totalhp/16
				nextToxicHP = toxicHP*(battler.effects[PBEffects::Toxic]+1)
				if battler.hp<=nextToxicHP && battler.hp>toxicHP*2
					return true
				end
			end
		end
		return false
	end

	def pbEnemyShouldWithdrawEx?(idxBattler,forceSwitch)
    return false if @battle.wildBattle?
		return false if @battle.battlers.length == 1
		$shouldBoost = false
		$shouldBoostSpeed = false
		$shouldPri = false
		$shouldHeal = false
		$fakeOut = false
		$canSwitch = true
		$shouldAttack = false
		$shouldHaze = false
    shouldSwitch = forceSwitch
    batonPass = -1
		teleport = -1
    moveType = -1
    skill = @battle.pbGetOwnerFromBattlerIndex(idxBattler).skill_level || 0
    battler = @battle.battlers[idxBattler]
		target = battler.pbDirectOpposing(true)
		role = battler.role
		$role = role.id
		$opposing = []
		for i in @battle.battlers
			if i != battler
				if not(i.fainted?)
					if i.opposes?
						$opposing.push(i)
					end
				end
			end
		end
		moves = battler.moves
		battler.moves do |move|
			for o in $opposing
				baseDmg = pbMoveBaseDamage(move,battler,o,skill)
			end
		end
		aspeed = pbRoughStat(battler,:SPEED,skill)
		ospeed = pbRoughStat(target,:SPEED,skill)
		faster = aspeed > ospeed ? true : false
		$ai_learned_team[:pokemon].push(target.species)
		$ai_learned_team[:pokemon].uniq!
    # If Pokémon is within 6 levels of the foe, and foe's last move was
    # super-effective and powerful
    if !shouldSwitch && battler.turnCount>-1 && skill>=PBTrainerAI.highSkill
			target_id = $ai_learned_team[:pokemon]
			targ = target.species
			$target_idx = -1
			for i in target_id
				$target_idx += 1
				break if i == targ
			end
			$targ_id = $ai_learned_team[:pokemon][$target_idx]
			move_id1 = $ai_learned_team[:move1]
			move_id2 = $ai_learned_team[:move2]
			move_id3 = $ai_learned_team[:move3]
			move_id4 = $ai_learned_team[:move4]
			move_id5 = $ai_learned_team[:move5]
			move_id6 = $ai_learned_team[:move6]
			case $target_idx
			when 0
				if move_id1 != nil
					for i in 0..move_id1.length
						$targ_move = move_id1[i]
						$enem_prio = true if $targ_move.priority > 0
						$targbaseDmg = pbMoveBaseDamage($ai_learned_team[:move1][i],target,battler,skill)
					end
				end
			when 1
				if move_id2 != nil
					for i in 0..move_id2.length
						$targ_move = move_id2[i]
						$enem_prio = true if $targ_move.priority > 0
						$targbaseDmg = pbMoveBaseDamage($ai_learned_team[:move2][i],target,battler,skill)
					end
				end
			when 2
				if move_id3 != nil
					for i in 0..move_id3.length
						$targ_move = move_id3[i]
						$enem_prio = true if $targ_move.priority > 0
						$targbaseDmg = pbMoveBaseDamage($ai_learned_team[:move3][i],target,battler,skill)
					end
				end
			when 3
				if move_id4 != nil
					for i in 0..move_id4.length
						$targ_move = move_id4[i]
						$enem_prio = true if $targ_move.priority > 0
						$targbaseDmg = pbMoveBaseDamage($ai_learned_team[:move4][i],target,battler,skill)
					end
				end
			when 4
				if move_id5 != nil
					for i in 0..move_id5.length
						$targ_move = move_id5[i]
						$enem_prio = true if $targ_move.priority > 0
						$targbaseDmg = pbMoveBaseDamage($ai_learned_team[:move5][i],target,battler,skill)
					end
				end
			when 5
				if move_id6 != nil
					for i in 0..move_id6.length
						$targ_move = move_id6[i]
						$enem_prio = true if $targ_move.priority > 0
						$targbaseDmg = pbMoveBaseDamage($ai_learned_team[:move6][i],target,battler,skill)
					end
				end
			end
			#Effectiveness of Target against Battler
					type1Battler = GameData::Type.get(target.type1).effectiveness(battler.type1) * GameData::Type.get(target.type2).effectiveness(battler.type1)
				if battler.type1 != battler.type2
					type2Battler = GameData::Type.get(target.type1).effectiveness(battler.type2) * GameData::Type.get(target.type2).effectiveness(battler.type2)
				end
			#Effectiveness of Battler against Target
				type1Target = GameData::Type.get(battler.type1).effectiveness(target.type1) * GameData::Type.get(battler.type2).effectiveness(target.type1)
				if target.type1 != target.type2
					type2Target = GameData::Type.get(battler.type1).effectiveness(target.type2) * GameData::Type.get(battler.type2).effectiveness(target.type2)
				end
				battler_SE = 8
				battler_2SE = 16
				# 1 = NVE
				# 2 = Neutral
				# 4 = SE
				# 0 = Immune
				if skill>=PBTrainerAI.beastMode
					switchChance = 0
					for move in battler.moves
						$has_prio = true if move.priority > 0 && !move.statusMove?
						$fakeOut = true if move.function == "012"
						$has_haze = true if move.function == "051"
						$has_healing = true if move.healingMove?
					end
					if (target.stages[:ATTACK] >= 2 || target.stages[:SPECIAL_ATTACK] >= 2) && !battler.hasActiveAbility?(:UNAWARE) && $has_haze == false
						$shouldAttack = true
					end
					if $has_haze == true
						stages = 0
						@battle.eachBattler do |b|
		          totalStages = 0
		          GameData::Stat.each_battle { |s| totalStages += b.stages[s.id] }
		          if b.opposes?(battler)
		            stages += totalStages
		          else
		            stages -= totalStages
		          end
		        end
						haze_score = stages*10
						haze_score += 50 if stages > 0
						haze_score += 20 if [:PHYSICALWALL,:SPECIALWALL,:PIVOT,:STALLBREAKER].include?($role) && stages > 0
						$shouldHaze = (pbAIRandom(100)<haze_score)
					end
				if type1Target == (battler_SE || battler_2SE) || type2Target == (battler_SE || battler_2SE)
					if !faster && $shouldPri == false
						if $targ_move != nil
							for i in $targ_move
								if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) >= battler.hp
									shouldSwitch = true
								else
									for move in battler.moves
										baseDmg = pbMoveBaseDamage(move,battler,target,skill)
										switchChance += 20 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
										switchChance -= 20 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp
									end
									shouldSwitch = (pbAIRandom(100)<switchChance)
								end
							end
							$shouldBoostSpeed = shouldSwitch ? false : true
							$shouldHeal = true if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.totalhp/2 && $has_healing && battler.hp < battler.totalhp*(0.75)
						else
							switchChance = 85
							shouldSwitch = (pbAIRandom(100)<switchChance)
						end
					elsif !faster && $shouldPri
						if $targ_move != nil
							for i in $targ_move
								if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) >= battler.hp
									switchChance += 50
								else
									for move in battler.moves
										baseDmg = pbMoveBaseDamage(move,battler,target,skill)
										switchChance += 20 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
										switchChance -= 40 if move.priority > 0
										switchChance -= 60 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp && move.priority > 0
										switchChance -= 20 if $fakeOut == true
									end
								end
							end
							shouldSwitch = (pbAIRandom(100)<switchChance)
						else
							for move in battler.moves
								baseDmg = pbMoveBaseDamage(move,battler,target,skill)
								switchChance += 40 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
								switchChance -= 40 if move.priority > 0
								switchChance -= 60 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp && move.priority > 0
								switchChance -= 20 if $fakeOut == true
							end
							shouldSwitch = (pbAIRandom(100)<switchChance)
						end
						$enem_should_switch = true if shouldSwitch == false
					elsif faster
						$enem_should_switch = true
						if $targ_move != nil
							for i in $targ_move
								if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) >= battler.hp
									switchChance += 40
									for move in battler.moves
										baseDmg = pbMoveBaseDamage(move,battler,target,skill)
										switchChance += 20 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
										switchChance -= 80 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp
									end
									shouldSwitch = (pbAIRandom(100)<switchChance)
									$shouldBoost = shouldSwitch ? false : true
								else
									shouldSwitch = false
									$shouldBoost = shouldSwitch ? false : true
								end
							end
						else
							shouldSwitch = false
						end
					end
				end
				if (type1Battler == (battler_SE || battler_2SE) || type2Battler == (battler_SE || battler_2SE)) && (type1Target != (battler_SE || battler_2SE) && type2Target != (battler_SE || battler_2SE))
					if !faster && $shouldPri == false
						if $targ_move != nil
							for i in $targ_move
								if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) >= battler.hp
									shouldSwitch = true
								else
									for move in battler.moves
										baseDmg = pbMoveBaseDamage(move,battler,target,skill)
										switchChance += 20 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
										switchChance -= 20 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp
									end
									shouldSwitch = false
								end
							end
							$shouldBoostSpeed = true if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.hp/2
							$shouldHeal = true if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.totalhp/2 && $has_healing && battler.hp < battler.totalhp*(0.75)
						else
							shouldSwitch = true
						end
					elsif !faster && $shouldPri
						if $targ_move != nil
							for i in $targ_move
								if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) >= battler.hp
									switchChance += 50
								else
									for move in battler.moves
										baseDmg = pbMoveBaseDamage(move,battler,target,skill)
										switchChance += 20 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
										switchChance -= 20 if move.priority > 0
										switchChance -= 60 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp && move.priority > 0
										switchChance -= 20 if $fakeOut == true
									end
									shouldSwitch = (pbAIRandom(100)<switchChance)
								end
							end
						else
							for move in battler.moves
								baseDmg = pbMoveBaseDamage(move,battler,target,skill)
								switchChance += 20 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
								switchChance -= 40 if move.priority > 0
								switchChance -= 60 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp && move.priority > 0
								switchChance -= 20 if $fakeOut == true
							end
							shouldSwitch = (pbAIRandom(100)<switchChance)
						end
					elsif faster
						if $targ_move != nil
							for i in $targ_move
								if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) >= battler.hp
									switchChance += 40
									for move in battler.moves
										baseDmg = pbMoveBaseDamage(move,battler,target,skill)
										switchChance += 20 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
										switchChance -= 20 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp
									end
									shouldSwitch = (pbAIRandom(100)<switchChance)
									$shouldBoost = shouldSwitch ? false : true
								else
									shouldSwitch = false
									$shouldBoost = shouldSwitch ? false : true
									$shouldHeal = true if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.totalhp/2 && $has_healing && battler.hp <= battler.totalhp/2
								end
							end
						else
							shouldSwitch = false
						end
						$enem_should_switch = true if shouldSwitch == false
					end
				end
				if type1Target != (battler_SE || battler_2SE) && type2Target != (battler_SE || battler_2SE)
					if faster
						if $targ_move != nil
							for i in $targ_move
								if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) >= battler.hp
									switchChance += 50
								else
									$shouldHeal = true if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.totalhp/2 && $has_healing && battler.hp <= battler.totalhp/2
								end
							end
						end
						for move in battler.moves
							baseDmg = pbMoveBaseDamage(move,battler,target,skill)
							switchChance += 20 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
							switchChance -= 40 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp
						end
						shouldSwitch = (pbAIRandom(100)<switchChance)
						$enem_should_switch = true if shouldSwitch == false
						$shouldBoost = shouldSwitch ? false : true
					elsif !faster && $shouldPri == false
						if type1Battler == (battler_SE || battler_2SE) || type2Battler == (battler_SE || battler_2SE)
							if $targ_move != nil
								for i in $targ_move
									switchChance = pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.hp/2 ? 25 : 75
									$shouldBoostSpeed = true if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.hp/2
									$shouldHeal = true if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.totalhp/2 && $has_healing && battler.hp < battler.totalhp*(0.75)
								end
							end
							shouldSwitch = (pbAIRandom(100)<switchChance)
						else
							switchChance = 50
							shouldSwitch = (pbAIRandom(100)<switchChance)
						end
					elsif !faster && $shouldPri
						if type1Battler == (battler_SE || battler_2SE) || type2Battler == (battler_SE || battler_2SE)
							if $targ_move != nil
								for i in $targ_move
									switchChance = pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.hp/2 ? false : 50
									$shouldBoostSpeed = true if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.hp/2
									$shouldHeal = true if pbRoughDamage(i,$targ_id,battler,skill,$targbaseDmg) < battler.totalhp/2 && $has_healing && battler.hp < battler.totalhp*(0.75)
								end
							end
							shouldSwitch = (pbAIRandom(100)<switchChance)
						else
							switchChance = 35
							shouldSwitch = (pbAIRandom(100)<switchChance)
						end
					else
						switchChance = 10
						shouldSwitch = (pbAIRandom(100)<switchChance)
					end
				end
			end
      if !target.fainted? && target.lastMoveUsed != nil &&
				if battler.lastMoveUsed == nil
					return false
				end
        moveData = GameData::Move.get(target.lastMoveUsed)
				moveData2 = GameData::Move.get(battler.lastMoveUsed)
        moveType = moveData.type
				moveType2 = moveData2.type
        typeMod = pbCalcTypeMod(moveType,target,battler)
				typeMod2 = pbCalcTypeMod(moveType2,target,battler)
        if typeMod == (battler_SE || battler_2SE) && moveData.base_damage>50
					if skill>=PBTrainerAI.beastMode
          	switchChance = 90
          	shouldSwitch = (pbAIRandom(100)<switchChance)
					else
						switchChance = 50
          	shouldSwitch = (pbAIRandom(100)<switchChance)
					end
        end
				if typeMod2 != battler_SE && target.hp > target.totalhp/3
					if !faster
						if skill>=PBTrainerAI.beastMode
	          	switchChance = 85
	          	shouldSwitch = (pbAIRandom(100)<switchChance)
						else
							switchChance = 30
	          	shouldSwitch = (pbAIRandom(100)<switchChance)
						end
					end
				end
      end
    end
    # Pokémon can't do anything (must have been in battle for at least 5 rounds)
    if !@battle.pbCanChooseAnyMove?(idxBattler) && battler.turnCount && battler.turnCount>=0
      shouldSwitch = true
    end
		if battler.effects[PBEffects::Substitute] > 0
			shouldSwitch = false
		end
		if [:WINCON,:SETUPSWEEPER,:NONE].include?($role) && $enem_prio == false
			switchChance = 0
			if $targ_move != nil
				for i in $targ_move
					switchChance += 25 if pbRoughDamage(i,target,battler,skill,$baseDmg) >= battler.hp
					switchChance -= 25 if pbRoughDamage(i,target,battler,skill,$baseDmg) < battler.hp/2
				end
			end
			shouldSwitch = (pbAIRandom(100)<switchChance)
			if $has_healing && shouldSwitch == false
				healChance = (battler.hp/battler.totalhp)*100
				if healChance < 67
					$shouldHeal = healChance <= 50 ? true : pbAIRandom(100)<healChance
				else
					$shouldHeal = pbAIRandom(100)>healChance
				end
			end
			if battler.stages[:ATTACK] <= 0 || battler.stages[:SPECIAL_ATTACK] <= 0
				$shouldBoost = true if shouldSwitch == false && $shouldHeal == false
			end
			if battler.stages[:SPEED] <= 0 && !faster
				$shouldBoostSpeed = true if shouldSwitch == false && $shouldHeal == false
			end
		end
		@battle.pbParty(idxBattler).each_with_index do |pkmn,i|
			if !@battle.pbCanSwitch?(idxBattler,i)
				$canSwitch = false
				$shouldPri = true if ((battler.hp < battler.totalhp/3) && $has_prio)
				next if $targ_move == nil
				for i in $targ_move
					if pbRoughDamage(i,target,battler,skill,$baseDmg) >= battler.hp && (battler.stages[:ATTACK] > 0 || battler.stages[:SPECIAL_ATTACK] > 0) && $has_prio
						$shouldPri = true
					elsif pbRoughDamage(i,target,battler,skill,$baseDmg) >= battler.hp && i.priority > 0
						$shouldPri = true
					elsif pbRoughDamage(i,target,battler,skill,$baseDmg) < battler.hp/2
						$shouldBoost = true if battler.hp>=battler.totalhp/2
						if $has_healing
							healChance = (battler.hp/battler.totalhp)*100
							if healChance < 67
								$shouldHeal = healChance <= 50 ? true : pbAIRandom(100)<healChance
							else
								$shouldHeal = pbAIRandom(100)>healChance
							end
						end
						$shouldBoost = false if $shouldHeal
					end
				end
			end
		end
		if battler.stages[:ATTACK] > 0 || battler.stages[:SPECIAL_ATTACK] > 0
			$shouldPri = true if $has_prio && (!faster || battler.hp<battler.totalhp/4)
			switchChance = 0 if [:SETUPSWEEPER,:SPECIALBREAKER,:PHYSICALBREAKER,:NONE].include?($role)
			if $role == :WINCON && $canSwitch
				if $targ_move != nil
					for i in $targ_move
						if pbRoughDamage(i,target,battler,skill,$baseDmg) < battler.hp/2
							if !faster && battler.hp > battler.hp/2
								$shouldBoostSpeed = true
							else
								for move in battler.moves
									baseDmg = pbMoveBaseDamage(move,battler,target,skill)
									$shouldBoost if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp && !$has_healing
									if $has_healing
										healChance = (battler.hp/battler.totalhp)*100
										if healChance < 67
											$shouldHeal = healChance <= 50 ? true : pbAIRandom(100)<healChance
										else
											$shouldHeal = pbAIRandom(100)>healChance
										end
									end
								end
							end
							switchChance = 0
						end
						if pbRoughDamage(i,target,battler,skill,$baseDmg) >= battler.hp && !faster
							for move in battler.moves
								baseDmg = pbMoveBaseDamage(move,battler,target,skill)
								ch += 2 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
								ch -= 2 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp
							end
							switchChance = i.priority > 0 ? 100 : (92 + ch)
						end
					end
				end
			shouldSwitch = pbAIRandom(100)<switchChance
		end
	end
		if battler.stages[:SPEED] > 0
			$shouldBoostSpeed = false if faster
			switchChance = 0 if [:SETUPSWEEPER,:SPECIALBREAKER,:PHYSICALBREAKER,:NONE].include?($role)
			if $role == :WINCON && $canSwitch
				if $targ_move == nil
					for i in $targ_move
						if pbRoughDamage(i,target,battler,skill,$baseDmg) > battler.hp && (!faster)
							for move in battler.moves
								baseDmg = pbMoveBaseDamage(move,battler,target,skill)
								ch += 5 if pbRoughDamage(move,battler,target,skill,baseDmg) < target.hp
								ch -= 5 if pbRoughDamage(move,battler,target,skill,baseDmg) >= target.hp
							end
							switchChance = i.priority > 0 ? 100 : (80 + ch)
						end
					end
				end
			end
			shouldSwitch = pbAIRandom(100)<switchChance
		end
    # Pokémon is Perish Songed and has Baton Pass
    if skill>=PBTrainerAI.highSkill && battler.effects[PBEffects::PerishSong]==1
      battler.eachMoveWithIndex do |m,i|
        next if m.function!="0ED"   # Baton Pass
        next if !@battle.pbCanChooseMove?(idxBattler,i,false)
        batonPass = i
        break
      end
    end

		if skill>=PBTrainerAI.highSkill
      battler.eachMoveWithIndex do |m,i|
        next if m.function!="0EA"   # Teleport
        next if !@battle.pbCanChooseMove?(idxBattler,i,false)
        teleport = i
        break
      end
    end
    # Pokémon will faint because of bad poisoning at the end of this round, but
    # would survive at least one more round if it were regular poisoning instead
    if battler.status==GameData::Status.get(:POISON).id && battler.statusCount>0 &&
       skill>=PBTrainerAI.highSkill
      toxicHP = battler.totalhp/16
      nextToxicHP = toxicHP*(battler.effects[PBEffects::Toxic]+1)
      if battler.hp<=nextToxicHP && battler.hp>toxicHP*2
        shouldSwitch = true if pbAIRandom(100)<80
      end
    end
    # Pokémon is Encored into an unfavourable move
    if battler.effects[PBEffects::Encore]>0 && skill>=PBTrainerAI.mediumSkill
      idxEncoredMove = battler.pbEncoredMoveIndex
      if idxEncoredMove>=0
        scoreSum   = 0
        scoreCount = 0
        battler.eachOpposing do |b|
          scoreSum += pbGetMoveScore(battler.moves[idxEncoredMove],battler,b,skill)
          scoreCount += 1
        end
        if scoreCount>0 && scoreSum/scoreCount<=20
          shouldSwitch = true if pbAIRandom(100)<80
        end
      end
    end
    # If there is a single foe and it is resting after Hyper Beam or is
    # Truanting (i.e. free turn)
    if @battle.pbSideSize(battler.index+1)==1 &&
       !battler.pbDirectOpposing.fainted? && skill>=PBTrainerAI.highSkill
      opp = battler.pbDirectOpposing
      if opp.effects[PBEffects::HyperBeam]>0 ||
         (opp.hasActiveAbility?(:TRUANT) && opp.effects[PBEffects::Truant])
        shouldSwitch = false
      end
    end
    # Sudden Death rule - I'm not sure what this means
    if @battle.rules["suddendeath"] && battler.turnCount>0
      if battler.hp<=battler.totalhp/4 && pbAIRandom(100)<30
        shouldSwitch = true
      elsif battler.hp<=battler.totalhp/2 && pbAIRandom(100)<80
        shouldSwitch = true
      end
    end
    # Pokémon is about to faint because of Perish Song
    if battler.effects[PBEffects::PerishSong]==1
      shouldSwitch = true
    end
    if shouldSwitch
      list = []
      @battle.pbParty(idxBattler).each_with_index do |pkmn,i|
        next if !@battle.pbCanSwitch?(idxBattler,i)
        # If perish count is 1, it may be worth it to switch
        # even with Spikes, since Perish Song's effect will end
        if battler.effects[PBEffects::PerishSong]!=1
          # Will contain effects that recommend against switching
          spikes = battler.pbOwnSide.effects[PBEffects::Spikes]
          # Don't switch to this if too little HP
          if spikes>0
            spikesDmg = [8,6,4][spikes-1]
            if pkmn.hp<=pkmn.totalhp/spikesDmg
              next if !battler.airborne? && !battler.hasActiveAbility?(:MAGICGUARD)
            end
          end
        end
        # moveType is the type of the target's last used move
        if moveType>=0 && Effectiveness.ineffective?(pbCalcTypeMod(moveType,battler,battler))
          weight = 80
          typeMod = pbCalcTypeModPokemon(pkmn,battler.pbDirectOpposing(true))
          if GameData::Type.isSuperEffective?(typeMod.to_f/Effectiveness::NORMAL_EFFECTIVE)
            # Greater weight if new Pokemon's type is effective against target
            weight = 100
          end
          list.unshift(i) if pbAIRandom(100)<weight   # Put this Pokemon first
				elsif moveType>=0 && Effectiveness.super_effective?(pbCalcTypeMod(moveType,battler,battler))
					list.push(i)
				elsif $role == :WINCON && @battle.pbCanChooseMove?(idxBattler,i,false)
					list.push(i)
				elsif moveData != nil && moveData.category == 0 && $role == :PHYSICALWALL
					weight = 70
					if $targ_move != nil
						for j in $targ_move.length
							if $targ_move[j].category == 0
								weight += 10
							end
						end
					end
					list.unshift(i)  if pbAIRandom(100)<weight
				elsif moveData != nil && moveData.category == 1 && $role == :SPECIALWALL
					weight = 70
					if $targ_move != nil
						for j in $targ_move.length
							if $targ_move[j].category == 1
								weight += 10
							end
						end
					end
					list.unshift(i)  if pbAIRandom(100)<weight
				elsif moveData != nil && moveData.category == 2 && $role == :STALLBREAKER
					weight = 80
					if $targ_move != nil
						for j in $targ_move.length
							if $targ_move[j].category == 2
								weight += 10
							end
						end
					end
					list.unshift(i)  if pbAIRandom(100)<weight
				elsif $role == :PIVOT
					weight = 80
					list.unshift(i)  if pbAIRandom(100)<weight
        elsif moveType>=0 && Effectiveness.resistant?(pbCalcTypeMod(moveType,battler,battler))
          weight = 40
          typeMod = pbCalcTypeModPokemon(pkmn,battler.pbDirectOpposing(true))
          if GameData::Type.isSuperEffective?(typeMod.to_f/Effectiveness::NORMAL_EFFECTIVE)
            # Greater weight if new Pokemon's type is effective against target
            weight = 60
          end
          list.unshift(i) if pbAIRandom(100)<weight   # Put this Pokemon first
        else
          list.push(i)   # put this Pokemon last
        end
      end
      if list.length>0
        if batonPass>=0 && @battle.pbRegisterMove(idxBattler,batonPass,false)
          PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use Baton Pass to avoid Perish Song")
          return true
        end
				if teleport>=0 && @battle.pbRegisterMove(idxBattler,teleport,false)
          PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will use Teleport.")
          return true
        end
        if @battle.pbRegisterSwitch(idxBattler,list[0])
          PBDebug.log("[AI] #{battler.pbThis} (#{idxBattler}) will switch with " +
                      "#{@battle.pbParty(idxBattler)[list[0]].name}")
          return true
        end
      end
    end
    return false
end
	#=============================================================================
	# Choose a replacement Pokémon
	#=============================================================================
	def pbDefaultChooseNewEnemy(idxBattler,party)
		enemies = []
		party.each_with_index do |p,i|
			enemies.push(i) if @battle.pbCanSwitchLax?(idxBattler,i)
		end
		return -1 if enemies.length==0
		return pbChooseBestNewEnemy(idxBattler,party,enemies)
	end
end
#===============================================================================
# * Attacks
class PokeBattle_AI
	#=============================================================================
	# Main move-choosing method
	#=============================================================================
	def pbChooseMoves(idxBattler)
		user        = @battle.battlers[idxBattler]
		wildBattler = @battle.wildBattle?
		skill       = 0
		if !wildBattler
			skill     = @battle.pbGetOwnerFromBattlerIndex(user.index).skill_level || 0
		end
		# Get scores and targets for each move
		# NOTE: A move is only added to the choices array if it has a non-zero
		#       score.
		choices     = []
		user.eachMoveWithIndex do |m,i|
			next if !@battle.pbCanChooseMove?(idxBattler,i,false)
			if wildBattler
				pbRegisterMoveWild(user,i,choices)
			else
				pbRegisterMoveTrainer(user,i,choices,skill)
			end
		end
		# Figure out useful information about the choices
		totalScore = 0
		maxScore   = 0
		choices.each do |c|
			totalScore += c[1]
			maxScore = c[1] if maxScore<c[1]
		end
		# Log the available choices
		if $INTERNAL
			logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): "
			choices.each_with_index do |c,i|
				logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
				logMsg += " (target #{c[2]})" if c[2]>=0
				logMsg += ", " if i<choices.length-1
			end
			PBDebug.log(logMsg)
		end
		# Find any preferred moves and just choose from them
		if skill == PBTrainerAI.minimumSkill
			battler = @battle.battlers[idxBattler]
			battler.eachMoveWithIndex do |_m,i|
        #next if !@battle.pbCanChooseMove?(idxBattler,i,false)
        choices.push(i)   # Move index, score, target
      end
			memento = choices[0][0]
			@battle.pbRegisterMove(idxBattler,memento,false)
		end
		if !wildBattler && skill>=PBTrainerAI.highSkill && maxScore>100
			stDev = pbStdDev(choices)
			if stDev>=40
				preferredMoves = []
				choices.each do |c|
					next if c[1]<200 && c[1]<maxScore*0.8
					if $mPri != 0 && $mPri != nil && $mPri != -1 && $mPri != -2 && $mPri != -3
						preferredMoves.push(c)
						preferredMoves.push(c) if user.hp <= (user.totalhp/3).floor
					end
					user.eachOpposing do |o|
						typeMatch = o.damageState.typeMod
						superEffective = Effectiveness.super_effective?(typeMatch)
						if superEffective
							if !o.immune_by_ability?(user.moves[c[0]].type,o.ability)
								preferredMoves.push(c)
							end
						end
					end
					# preferredMoves.push(c) No. Bad moves should not be added to possible moves
					preferredMoves.push(c) if c[1]==maxScore   # Doubly prefer the best move
				end
				if preferredMoves.length == 0
					choices.each do |move|
						preferredMoves.push(move) #choose rand move bc all bad
					end
				end
				if preferredMoves.length>0
					m = preferredMoves[pbAIRandom(preferredMoves.length)]
					PBDebug.log("[AI] #{user.pbThis} (#{user.index}) prefers #{user.moves[m[0]].name}")
					@battle.pbRegisterMove(idxBattler,m[0],false)
					@battle.pbRegisterTarget(idxBattler,m[2]) if m[2]>=0
					return
				end
			end
		end
		# Decide whether all choices are bad, and if so, try switching instead
		if !wildBattler && skill>=PBTrainerAI.highSkill
			badMoves = false
			if (maxScore<=100 && user.turnCount>0)
				badMoves = true
			end
			if !badMoves && totalScore<100 && user.turnCount>0
				badMoves = true
				choices.each do |c|
					next if !user.moves[c[0]].damagingMove?
					badMoves = false
					break
				end
				badMoves = false if badMoves
			end
			if badMoves && pbEnemyShouldWithdrawEx?(idxBattler,true)
				if $INTERNAL
					PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves.")
				end
				return
			end
		end
		battler = @battle.battlers[idxBattler]
    $opposing = []
    for i in @battle.battlers
      if i != battler
        if not(i.fainted?)
          if i.opposes?
            $opposing.push(i)
          end
        end
      end
    end
		moves = battler.moves
		battler.moves do |move|
			for o in $opposing
				baseDmg = pbMoveBaseDamage(move,battler,o,skill)
				if pbRoughDamage(move,battler,o,skill,baseDmg) >= o.hp
					$nextTarget = o
					$nextMove = move
					$nextQue = 1
				end
			end
		end
		# Randomly choose a move to use
		if choices.length==0
			# If there are no calculated choices, use Struggle (or an Encored move)
			@battle.pbAutoChooseMove(idxBattler)
		else
			# Randomly choose a move from the choices and register it
			if !($nextQue == 1)
				randNum = pbAIRandom(totalScore)
				choices.each do |c|
					randNum -= c[1]
					next if randNum>=0
					@battle.pbRegisterMove(idxBattler,c[0],false)
					@battle.pbRegisterTarget(idxBattler,c[2]) if c[2]>=0
					break
				end
			else
				@battle.pbRegisterMove(idxBattler,$nextMove,false)
				@battle.pbRegisterTarget(idxBattler,$nextTarget) if $nextTarget>=0
				$nextQue = 0
			end
		end
		# Log the result
		if @battle.choices[idxBattler][2]
			PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[user.index][2].name} boom boom you die")
		end
	end

	#=============================================================================
	# Get scores for the given move against each possible target
	#=============================================================================
	# Wild Pokémon choose their moves randomly.
	# If you dont want this and want wild battles to be hard tell me
	def pbRegisterMoveWild(user,idxMove,choices)
		choices.push([idxMove,100,-1])   # Move index, score, target
	end

	# Trainer Pokémon calculate how much they want to use each of their moves.
	def pbRegisterMoveTrainer(user,idxMove,choices,skill)
		move = user.moves[idxMove]
		targetType = move.pbTarget(user)
		if targetType.num_targets > 1
			# If move affects multiple battlers and you don't choose a particular one
			totalScore = 0
			@battle.eachBattler do |b|
				next if !@battle.pbMoveCanTarget?(user.index,b.index,targetType)
				score = pbGetMoveScore(move,user,b,skill)
				totalScore += ((user.opposes?(b)) ? score : -score)
			end
			choices.push([idxMove,totalScore,-1]) if totalScore>0
		elsif targetType.num_targets == 0
			# If move has no targets, affects the user, a side or the whole field
			score = pbGetMoveScore(move,user,user,skill)
			choices.push([idxMove,score,-1]) if score>0
		else
			# If move affects one battler and you have to choose which one
			scoresAndTargets = []
			@battle.eachBattler do |b|
				next if !@battle.pbMoveCanTarget?(user.index,b.index,targetType)
				next if targetType.can_target_one_foe? && !user.opposes?(b)
				score = pbGetMoveScore(move,user,b,skill)
				scoresAndTargets.push([score,b.index]) if score>0
			end
			if scoresAndTargets.length>0
				# Get the one best target for the move
				scoresAndTargets.sort! { |a,b| b[0]<=>a[0] }
				choices.push([idxMove,scoresAndTargets[0][0],scoresAndTargets[0][1]])
			end
		end
	end

	#=============================================================================
	# Get a score for the given move being used against the given target
	#=============================================================================
	def pbGetMoveScore(move,user,target,skill=100)
		skill = PBTrainerAI.minimumSkill if skill<PBTrainerAI.minimumSkill
		score = 100
		score = pbGetMoveScoreFunctionCode(score,move,user,target,skill)
		# A score of 0 here means it absolutely should not be used
		return 0 if score<=0
		if skill>=PBTrainerAI.mediumSkill
			# Prefer damaging moves if AI has no more Pokémon or AI is less clever
			if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
				if !(skill>=PBTrainerAI.highSkill && @battle.pbAbleNonActiveCount(target.idxOwnSide)>0)
					if move.statusMove?
						score /= 1.5
					elsif target.hp<=target.totalhp/3
						score *= 1.5
					end
				end
			end
			# Don't prefer attacking the target if they'd be semi-invulnerable
			if skill>=PBTrainerAI.highSkill && move.accuracy>0 &&
				(target.semiInvulnerable? || target.effects[PBEffects::SkyDrop]>=0)
				miss = true
				miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
				if miss && pbRoughStat(user,GameData::Stat.get(:SPEED).id,skill)>pbRoughStat(target,GameData::Stat.get(:SPEED),skill)
					# Knows what can get past semi-invulnerability
					if target.effects[PBEffects::SkyDrop]>=0
						miss = false if move.hitsFlyingTargets?
					else
						if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
							miss = false if move.hitsFlyingTargets?
						elsif target.inTwoTurnAttack?("0CA")          # Dig
							miss = false if move.hitsDiggingTargets?
						elsif target.inTwoTurnAttack?("0CB")          # Dive
							miss = false if move.hitsDivingTargets?
						end
					end
				end
				score -= 80 if miss
			end
			# Pick a good move for the Choice items
			if user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
				if user.effects[PBEffects::ChoiceBand] != -1 && move.id == user.effects[PBEffects::ChoiceBand]
					score += 100
					shouldSwitch = false if @battle.pbSideSize(user.index)==1
			  elsif move.baseDamage>=60;     score += 60
				elsif move.damagingMove?;   score += 30
				elsif move.function=="0F2"; score += 70   # Trick
				else;                       score -= 60
				end
			end
			# If user is asleep, prefer moves that are usable while asleep
			if user.status==GameData::Status.get(:SLEEP).id && !move.usableWhenAsleep?
				hasSleepMove = false
				user.eachMove do |m|
					next unless m.usableWhenAsleep?
					score -= 60
					break
				end
			end
			# If user is frozen, prefer a move that can thaw the user
			if user.status==GameData::Status.get(:FROZEN).id
				if move.thawsUser?
					score += 40
				end
			end
			# If target is frozen, don't prefer moves that could thaw them
			if target.status==GameData::Status.get(:FROZEN).id
				user.eachMove do |m|
					next if m.thawsUser?
					score -= 60
					break
				end
			end
		end
		if target.effects[PBEffects::Substitute]>0
			user.eachMove do |m|
				if move.soundMove?
					score += 40
				end
			end
		end

		user.eachMove do |m|
			if Effectiveness.super_effective?(pbCalcTypeMod(m.type,user,target))
				score += 20 if [:PHYSICALBREAKER,:SPECIALBREAKER,:REVENGEKILLER,:NONE].include?($role)
				score += 30 if [:WINCON,:PHYSICALBREAKER,:SPECIALBREAKER,:SETUPSWEEPER,:NONE].include?($role) && (user.stages[:ATTACK]>0||user.stages[:SPECIAL_ATTACK]>0||user.stages[:SPEED]>0)
			end
		end
		# Adjust score based on how much damage it can deal
		if move.damagingMove?
			score = pbGetMoveScoreDamage(score,move,user,target,skill)
		else   # Status moves
			# Don't prefer attacks which don't deal damage
			score -= 10
			# Account for accuracy of move
			accuracy = pbRoughAccuracy(move,user,target,skill)
			score *= accuracy/100.0
			score = 0 if score<=10 && skill>=PBTrainerAI.highSkill
		end
		score = score.to_i
		score = 0 if score<0
		return score
	end

	#=============================================================================
	# Add to a move's score based on how much damage it will deal (as a percentage
	# of the target's current HP)
	#=============================================================================
	def pbGetMoveScoreDamage(score,move,user,target,skill)
		# Don't prefer moves that are ineffective because of abilities or effects
		return 0 if score<=0 || pbCheckMoveImmunity(score,move,user,target,skill)
		# Calculate how much damage the move will do (roughly)
		baseDmg = pbMoveBaseDamage(move,user,target,skill)
		realDamage = pbRoughDamage(move,user,target,skill,baseDmg)
		# Account for accuracy of move
		accuracy = pbRoughAccuracy(move,user,target,skill)
		realDamage *= accuracy/100.0
		# Two-turn attacks waste 2 turns to deal one lot of damage
		if move.chargingTurnMove? || move.function=="0C2"   # Hyper Beam
			realDamage *= 2/3   # Not halved because semi-invulnerable during use or hits first turn
		end
		# Prefer flinching external effects (note that move effects which cause
		# flinching are dealt with in the function code part of score calculation)
		# Convert damage to percentage of target's remaining HP
		damagePercentage = realDamage*100.0/target.hp
		# Don't prefer weak attacks
		#    damagePercentage /= 2 if damagePercentage<20
		# Prefer damaging attack if level difference is significantly high
		damagePercentage *= 1.2 if user.level-10>target.level
		# Adjust score
		damagePercentage = 120 if damagePercentage>120   # Treat all lethal moves the same
		damagePercentage += 40 if damagePercentage>100   # Prefer moves likely to be lethal
		score += damagePercentage.to_i
		return score
	end
end
