# BehaviorFactory is in charge of creating all behaviors and placing them in an Actor.
# Everything you want an Actor to _do_ is part of a Behavior. Actors are stupid buckets of data.
# Behaviors can be created by:
#   has_behavior in an Actor's class definition
#   or by dynamically creating one at runtime via another behavior.
class BehaviorFactory
  construct_with :this_object_context

  # Build a behavior. Takes a symbol or a Hash.
  #  add_behavior(:shootable) or add_behavior(:shootable => {:range=>3})
  #  this will create a new instance of Shootable and pass
  #  :range=>3 to it
  def add_behavior(actor, behavior, opts = {})
    raise "nil actor" if actor.nil?
    raise "nil behavior definition" if behavior.nil?

    this_object_context[behavior].tap do |behavior|
      deps = behavior.class.required_behaviors
      deps.each do |beh|
        add_behavior actor, beh unless @actor.is? beh
      end
      behavior.configure(actor, opts)
    end
  end


end
