class SafeDeleter
  Models=[Preview,Collection,Keyword,Location,City,Region,Country,Stamp,Month,Year]
  def initialize
    createArchive
  end
  def createArchive
    @archive=Hash.new
    Models.each do |classname|
      tempList=classname.all
      archiveList=Array.new
      tempList.each do |model|
        archiveList.push model.attributes
      end
      symToUse=classname.getSymbol
      @archive[symToUse]=archiveList
    end
    @keywordsPreviews=capturePrevJoin(Preview,:keywords)
    puts "New Database Archive Initialized"
  end
  def clearDatabase
    Models.each do |classname|
      classname.destroy_all
    end
  end
  def viewArchive
    return @archive
  end
  def restoreDatabase
    clearDatabase()
    Models.reverse.each do |classname|
      sym=classname.getSymbol
      models=@archive[sym]
      models.each do |mHash|
        # mHash.delete("created_at")
        # mHash.delete("updated_at")
        newmodel=classname.new(mHash)
        newmodel.save
      end
    end
    effectPrevJoin(@keywordsPreviews,Preview,:keywords)
    puts "Database Restored"
  end

  def self.allModels
    return Models
  end

  private

  def capturePrevJoin(model,joinedsym)
    joinHash=Hash.new
    model.includes(joinedsym).each do |prev|
      if joinedsym == :keywords
        ids=prev.keywords.pluck(:id)
      else 
        puts "Join symbol #{joinedsym} not recognized, and its join table with #{model} could not be saved"
      end
      joinHash[prev.id]=ids
    end
    return joinHash
  end

  def effectPrevJoin(joinHash,model,joinedsym)
    joinHash.each do |parent,idList|
      parentModel=model.find(parent)
      idList.each do |child|
        if joinedsym == :keywords
          childModel=Keyword.find(child)
          parentModel.keywords << childModel
        end
      end
    end
  end
end
