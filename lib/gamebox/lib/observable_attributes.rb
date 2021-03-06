module ObservableAttributes

  # atomically update all attributes
  # it updates all of the values; then triggers the events
  # my_actor.update_attributes(x: 5, y: 7)
  # will emit both x_changed and y_changed after setting _both_ values
  def update_attributes(attributes)
    # TODO put this in kvo gem; there is too much internal knowlege of where
    # kvo stores stuff 
    #
    # self.kvo_set('x', new_val, silent: true)
    # self.changed('x', old_val, new_val)
    old_values = attributes.keys.inject({}) do |hash, attr_name|
      hash[attr_name] = self.send(attr_name)
      hash
    end

    attributes.each do |name, val|
      self.instance_variable_set("@kvo_#{name}", val)
    end

    attributes.each do |name, val|
      fire "#{name}_changed".to_sym, old_values[name], val
    end
  end

  # Adds attributes that are not currently set. 
  # Takes a list of symbols or a hash of symbols => default values
  #
  # examples:
  #
  # foo.has_attributes :x, :y
  # # adds x, x=, y, y= methods
  # #fires events x_changed, y_changed when the values change
  #
  # foo.has_attributes x: 5, y: 3
  # # this form provides default values if these are new attributes
  def has_attributes(*names)
    if names.first.is_a? Hash
      names.first.each do |name, default|
        has_attribute name, default
      end
    else
      names.each do |name|
        has_attribute name
      end
    end
  end

  # singular form of has_attributes
  # takes the symbol name and an optional default value
  def has_attribute(name, value=nil)
    @evented_attributes ||= []
    unless has_attribute? name
      @evented_attributes << name
      self.metaclass.send :kvo_attr_accessor, name
      self.define_singleton_method "#{name}?" do
        self.send name
      end
      self.send("#{name}=", value)
    end
  end

  # Returns true if the passed in symbol is an attr on this object
  def has_attribute?(name)
    @evented_attributes && @evented_attributes.include?(name)
  end

  # Returns a new hash containing the attr keys and values
  def attributes
    {}.tap do |atts|
      if @evented_attributes
        @evented_attributes.each do |name|
          atts[name] = self.send name
        end
      end
    end
  end

  def self.included(klass)
    klass.instance_eval do
      include Kvo
      def has_attribute(name)
        kvo_attr_accessor name
      end
    end

  end

end
