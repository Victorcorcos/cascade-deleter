# Deactivate default_scopes for the given classes for a given code block
# --------------------------- Usage ---------------------------
# Deactivator.new(['ClassA', 'ClassB']).without_default_scopes do
#   My
#   Code
#   Block
#   Without ClassA and ClassB default_scopes
# end
class Deactivator
  def initialize(classes)
    @classes = classes
    @default_scopes = capture_default_scopes
  end

  def without_default_scopes
    remove_default_scopes
    yield
  ensure
    restore_default_scopes
  end

  private

  def capture_default_scopes
    @classes.to_h do |klass|
      [klass, klass.constantize.default_scopes]
    end
  end

  def remove_default_scopes
    @classes.each do |klass|
      klass.constantize.class_eval { self.default_scopes = [] }
    end
  end

  def restore_default_scopes
    deactivator = self

    @classes.each do |klass|
      klass.constantize.class_eval do
        self.default_scopes = deactivator.instance_variable_get(:@default_scopes)[klass]
      end
    end
  end
end
