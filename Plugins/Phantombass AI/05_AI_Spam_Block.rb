class PBAI
  class SpamHandler
    @@GeneralCode = []

	  def self.add(&code)
	   	@@GeneralCode << code
	 	end

	 	def self.trigger(list,flag,ai,battler,target)
	 		return flag if list.nil?
	 		list = [list] if !list.is_a?(Array)
			list.each do |code|
	  	next if code.nil?
	  		add_flag = code.call(flag,ai,battler,target)
	  		flag = add_flag
	  	end
		  return flag
		end
  end
end

#Triple Switch
PBAI::SpamHandler.add do |flag,ai,battler,target|
	triple_switch = $spam_block_flags[:triple_switch]
	next flag if triple_switch.length < 3
	check = 0
	for i in triple_switch
		check += 1 if !i.nil?
		check = 0 if i.nil?
		$spam_block_flags[:triple_switch].clear if check == 0
	end
	if check == 3
		flag = true
		PBAI.log("Spam Block triggered")
		$spam_block_flags[:triple_switch].clear
	end
	next flag
end

#Same Move
PBAI::SpamHandler.add do |flag,ai,battler,target|
	same_move = $spam_block_flags[:same_move]
	next flag if same_move.length < 3
	check = 0
	for i in 1..same_move.length
		check += 1 if same_move[i] == same_move[i-1]
		check = 0 if same_move[i] != same_move[i-1]
		$spam_block_flags[:same_move].clear if check == 0
	end
	if check == 2
		flag = true
		PBAI.log("Spam Block triggered")
		$spam_block_flags[:same_move].clear
	end
	next flag
end

#Double Stat Drop
PBAI::SpamHandler.add do |flag,ai,battler,target|
	double_stat = $spam_block_flags[:double_intimidate]
	next flag if double_stat.length < 2
	check = 0
	for i in double_stat
		check += 1 if [:INTIMIDATE,:MEDUSOID,:MINDGAMES].include?(i)
		check = 0 if ![:INTIMIDATE,:MEDUSOID,:MINDGAMES].include?(i)
		$spam_block_flags[:double_intimidate].clear if check == 0
	end
	if check == 2
		flag = true
		PBAI.log("Spam Block triggered")
		$spam_block_flags[:double_intimidate].clear
	end
	next flag
end