class RequestListMapper

  attr_reader :opts

  def initialize(profile, opts)
    @profile = profile
    @opts = opts
  end


  def form_fields
    # implement in subclass
    {}
  end


  def sort_fields
    {
      'record'     => proc {|mapped| mapped.record.name},
      'collection' => proc {|mapped| mapped.collection.name},
    }
  end
end
