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