#This file is a copy of the one found at interface/app/models/safe_deleter.rb
class SafeDeleter
  Models=[Preview,Collection,Location,City,Region,Country,Stamp,Month,Year]
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
    puts "New Database Archive Initialized"
  end
  def clearDatabase
    Models.each do |classname|
      classname.delete_all
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
    puts "Database Restored"
  end
end
