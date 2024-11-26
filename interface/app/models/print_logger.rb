class PrintLogger
  # The logger object stores strings passed to it while also printing them to output.
  # This allows for us to have the running update info the same for automatic updates,
  # where the console output is stored in an updatelogs file and communicated by email,
  # and also for manual updates and debugging, where someone is actively watching the terminal.
  def initialize
    @mainstring = ""
  end

  def puts(output)
    Kernel.puts output
    add output
    @mainstring += "\n"
  end

  def print(output)
    Kernel.print output
    add output
  end

  def access
    return @mainstring
  end
  
  def write(filename)
    logfile=File.new(filename,"w")
    logfile.print @mainstring
    logfile.close
    puts "log closed and written to #{filename}"
  end

  private
  def add(content)
    if content.class != String
      @mainstring+=JSON.pretty_generate(content)
    else
      @mainstring+=content
    end
  end
end
