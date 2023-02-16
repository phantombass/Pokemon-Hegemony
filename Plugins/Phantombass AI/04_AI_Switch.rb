=begin
class PBAI
    class SwitchHandler
      @@GeneralCode = []
      @@TypeCode = []
  	def add(&code)
   	 @@GeneralCode << code
 	end

  	def add_type(*type,&code)
		@@TypeCode << code
  	end

	def self.trigger(list,score,ai,proj,user,target,type)
		return score if list.nil?
		list = [list] if !list.is_a?(Array)
		list.each do |code|
	  	next if code.nil?
	  		newscore = code.call(score,ai,proj,target,type)
	  		score = newscore if newscore.is-a?(Numeric)
	  	end
	  return score
	end

	def self.trigger_general(score,ai,proj,user,target,type)
	  return self.trigger(@@GeneralCode,score,ai,proj,target,type)
	end

	def trigger_type(score,ai,proj,user,target,type)
	  return self.trigger(@@TypeCode,score,ai,proj,target,type)
	end
  end
end

PBAI::SwitchHandler.add_type(:FIRE) do |score,ai,proj,user,target,type|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	if target_moves != nil
	  for i in target_moves
		has_move_type? = true if i.type == type && i.damagingMove? && user.calc_move_matchup(i.id) > 1    
	  end
	end
	if has_move_type?
	  if proj.hasActiveAbility?([:FLASHFIRE,:STEAMENGINE,:WELLBAKEDBODY])
	    score += 100
	    PBAI.log("+ 100 for being immune to #{type.name}-type moves")
	  end
	  if proj.hasActiveAbility?(:THERMALEXCHANGE)
	    score += 60
	    PBAI.log("+ 60 for getting a boost from Fire moves")
	  end
	end
	return score
end

PBAI::SwitchHandler.add_type(:WATER) do |score,ai,proj,user,target,type|
	target_moves = $game_switches[LvlCap::Expert] ? target.moves : target.used_moves
	if target_moves != nil
	  for i in target_moves
		has_move_type? = true if i.type == type && i.damagingMove? && user.calc_move_matchup(i.id) > 1    
	  end
	end
	if has_move_type?
	  if proj.hasActiveAbility?([:WATERABSORB,:DRYSKIN,:STORMDRAIN,:STEAMENGINE,:WATERCOMPACTION])
	    score += 100
	    PBAI.log("+ 100 for being immune to #{type.name}-type moves")
	  end
	end
	return score
end
=end