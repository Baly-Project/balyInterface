class String
    def is_integer?
        self.to_i.to_s == self
    end
    def to_s
        return self
    end
    def lfullstrip
        temp=self
        if temp.length > 0
            while temp[0].codepoints[0]==32 or temp[0].codepoints[0]==160
                temp=temp[1..-1]
                if temp.length < 1
                    return temp  
                end
            end
        end
        return temp
    end
    def rfullstrip
        temp=self
        if temp.length > 0
            while temp[-1].codepoints[0]==32 or temp[-1].codepoints[0]==160
                temp=temp[...-1]
                if temp.length < 1
                    return temp  
                end
            end
        end
        return temp
    end
    def fullstrip
        temp=self
        temp=temp.lfullstrip
        temp=temp.rfullstrip
        return temp
    end
    Alphabet=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    def alphValue
        temp=self
        length=temp.length
        sum=0
        length.times {|i| 
            exp=length-(i+1)
            place=temp[i]
            val=Alphabet.index(place)+1
            sum=sum+val*(26**exp)
        }
        return sum
    end
    def is_alphanumeric?
        rtnval=true
        self.each_char do |char|
            unless Alphabet.include? char
                rtnval=false
            end
        end
        return rtnval
    end
end
