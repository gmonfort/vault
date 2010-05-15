module Vault
  module Associations
    def has_many(name, klass_name=name.to_s.classify, foreign_key="#{self.to_s.underscore.singularize}_key")
      define_method name do
        model = klass_name.is_a?(Class) ? klass_name : self.class.const_get(klass_name)
        HasManyProxy.new(self, model, foreign_key, foreign_key => key)
      end
    end

    def belongs_to(name, klass_name=name.to_s.classify)
      foreign_key = "#{name}_key"

      property(foreign_key)

      define_method name do
        model = klass_name.is_a?(Class) ? klass_name : self.class.const_get(klass_name)
        model[send(foreign_key)]
      end

      define_method "#{name}=" do |object|
        send("#{foreign_key}=", object.key)
      end
    end

    class HasManyProxy < Scoping::Scope
      def initialize(owner, model, foreign_key, conditions={})
        super(model, conditions)
        @owner = owner
        @foreign_key = foreign_key
      end

      def <<(object)
        object.send("#{@foreign_key}=", @owner.key)
        object.save
        self
      end
    end
  end
end