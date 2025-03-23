# Hash#to_parameter_string

# 20120610
# 1.0.2

# Changes since 0: 
# 1. I changed it from a class method to an instance method and hence removed references to any arguments and substituted self for those arguments.  
# 0/1
# 2. I forget about needing String#url_encode, which for now I'll paste in here.  
# 1/2
# 3. - String#url_encode.  
# 4. + require 'String/url_encode'.  

require 'String/url_encode'

class Hash
  
  def to_parameter_string
    parameters_string_parts = []
    self.each do |k,v|
      parameters_string_parts << (k.to_s + '=' + v.url_encode) unless v.nil?
    end
    parameters_string_parts.join('&')
  end
  
end
