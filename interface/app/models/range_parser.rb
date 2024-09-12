class RangeParser
  Alphabet=("A".."Z").to_a
  def parseSlideRange(string)
    #this will be our array that we return at the end
    slidesMentioned=Array.new
  
    collectionsMentioned=Array.new
    collectionsToIndex=Hash.new
  
    #we begin by splitting the ranges. 
    #Ranges are separated by commas, and common info is not repeated
    #an especially complicated example of this is 
    #"B27.012-15, B45.905-06, B47.654-63, 716-18"
    if string.include? ". "
        n=string.index ". "
        string=string[...n]
    end
  
    ranges=string.split(",",-1)
    
    for i in 0...ranges.length
      ranges[i] = ranges[i].lfullstrip
    end
    #next we store each B-collection in case the next one reuses it
    lastcollection="ERROR"
  
    #we now loop through the ranges and process them
    ranges.each do |range|
      range=range.fullstrip
      #the following will be a sample range to indicate which parts the code is handling
      
      #B22.222-22  
      #   ^
      if range.include? "."
        rightside=range.split(".")[1]
      else
        #in case it is only 222-22 
        decimalpoint=0
        rightside=range
      end
      
      #B22.222-22
      #^^^
      if Alphabet.include? range[0]
        lastcollection=range.split('.')[0]
        unless collectionsMentioned.include? lastcollection
          collectionsMentioned.push lastcollection
        end 
      end
      
      #B22.222-22
      #       ^
      if rightside.include? "-"
        dashplace=rightside.index "-"
      
        if dashplace < 3
          rightside="0" + rightside
          if dashplace < 2
            rightside="0"+rightside
          end
        end
        dashplace=4
        hundreds=rightside[0]
        start=rightside[1..2].to_i
        last=rightside[dashplace..].to_i
        if last.to_s.length > 2
            last=(last-hundreds.to_i*100)
        end
        #puts [rightside,hundreds,start,last] 
        for i in start..last
            if i < 100
                slidestem=lastcollection + "." + hundreds
            else
                slidestem=lastcollection+"."+(i/100+hundreds.to_i).to_s
                i=i%100
            end
          if i.to_s.length < 2
            ending="0"+i.to_s
          else 
            ending=i.to_s
          end
          slide=(slidestem+ending)
          slidesMentioned.push slide
        end
      else 
        #print "#{rightside}, #{rightside.length} "
        while rightside.length <3
          rightside="0"+rightside
        end
        slide=lastcollection+"."+rightside
        slidesMentioned.push slide.split(" ")[0]
      end
    end
  
    slidesMentioned=slidesMentioned.sort
    if slidesMentioned[0].class != NilClass
      if slidesMentioned[0][4..] == 1000
        slidesMentioned=slidesMentioned.rotate(1) 
      end
    end
    minslide=slidesMentioned[0]
    maxslide=slidesMentioned[-1]
    return [slidesMentioned,minslide,maxslide]
    #we begin by splitting our description up by subcollection. 
  end
end
