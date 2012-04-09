# Actor represent a game object.
# Actors can have behaviors added and removed from them. Such as :physical or :animated.
# They are created and hooked up to their optional View class in Stage#create_actor.
class Actor
  extend Publisher
  include EventedAttributes
end
class Actor
  include Gamebox::Extensions::Object::Yoda
  can_fire_anything
  construct_with :this_object_context
  public :this_object_context

  # TODO show/hide methods? go in a behavior? base behavior ActorBehavior?
  has_attribute :alive
  attr_accessor :actor_type

  def initialize
    @behaviors = []
  end

  def configure(opts={}) # :nodoc:
    @opts = opts
    @actor_type = @opts[:actor_type]
    self.alive = true
  end

  def add_behavior(name, behavior)
    # TODO do we need a name here?
    @behaviors << behavior
  end

  def react_to(message, *opts)
    @behaviors.each do |behavior|
      behavior.react_to(message)
    end
  end

  # Tells the actor's Director that he wants to be removed; and unsubscribes
  # the actor from all input events.
  def remove
    self.alive = false
    fire :remove_me
  end

  def to_s
    "#{self.class.name}:#{self.object_id} with behaviors\n#{@behaviors.map(&:class).inspect}"
  end

  # TODO should this live somewhere else?
  # TODO should we support "inheritance" of components?
  class << self

    def define(actor_type)
      @definitions ||= {}
      definition = ActorDefinition.new
      yield definition if block_given?
      @definitions[actor_type] = definition
    end

    def definitions
      @definitions ||= {}
    end

  end

  class ActorDefinition
    attr_accessor :behaviors
    def initialize
      @behaviors = []
    end

    def has_behaviors(*behaviors)
      behaviors.each do |beh|
        @behaviors << beh
      end
    end
    alias has_behavior has_behaviors
  end

end
