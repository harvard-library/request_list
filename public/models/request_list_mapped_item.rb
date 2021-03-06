class RequestListMappedItem

  attr_reader :uri, :type, :repository, :collection, :record,
              :container, :creator, :date, :extent

  attr_accessor :form_fields

  def initialize(uri, type)
    @uri = uri
    @type = type

    @repository = Attribute.new
    @collection = Attribute.new
    @record = Attribute.new
    @container = Attribute.new
    @creator = Attribute.new
    @date = Attribute.new
    @extent = Attribute.new
    @extensions = {}

    @form_fields = {}
  end


  def ext(key)
    @extensions[key] ||= Attribute.new
  end


  def scrub!(&block)
    @repository.scrub!(&block)
    @collection.scrub!(&block)
    @record.scrub!(&block)
    @container.scrub!(&block)
    @creator.scrub!(&block)
    @date.scrub!(&block)
    @extent.scrub!(&block)
    @extensions.map {|k,v| v.scrub!(&block)}
  end


  class Attribute

    attr_accessor :name, :id, :uri
    attr_reader :multi

    def initialize(opts = {})
      @name = opts[:name] || ''
      @id = opts[:id] || ''
      @uri = opts[:uri] || ''
      @multi = []
      @extensions = {}
    end

    def set(name, id, uri)
      @name = name || ''
      @id = id || ''
      @uri = uri || ''
      self
    end

    def add(opts = {})
      @multi.push(Attribute.new(opts)).last
    end

    def ext(name, value = false)
      @extensions[name] = value if value
      @extensions[name]
    end

    def has_multi?
      @multi.length > 0
    end

    def name_from_multi
      @name = @multi.map {|m| m.name}.join('; ')
    end

    def scrub!(&block)
      @name = block.call(@name)
      @id = block.call(@id)
      @uri = block.call(@uri)
      @multi.map {|m| m.scrub!(&block)}
      @extensions.map {|k,v| @extensions[k] = block.call(v) }
    end
  end

end
