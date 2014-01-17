
##
# DSL class to define browser
class BrowserDescriptor
  def initialize
    @column = {}
    @normalizers = {}
  end

  def default_db_paths(paths=nil)
    if paths
      @paths = paths
    else
      @paths
    end
  end

  def table(*args)
    if args.length == 0
      @table
    else
      @table = args[0]
    end
  end

  def column(*args)
    if args.length == 1
      @column[args[0]]
    elsif args.length == 2
      @column[args[0]] = args[1]
    else
      raise ArgumentError, 'Invalid number of arguments (expected 1-2)'
    end
  end

  def normalize(attr, &block)
    normalizers[attr] = block
  end

  def normalizers
    @normalizers
  end
end
