require "active_attr/attributes"
require "active_attr/typecasting"
require "active_support/concern"

module ActiveAttr
  # TypecastedAttributes allows types to be declared for your attributes
  #
  # Types are declared by passing the :type option to the attribute class
  # method. After a type is declared, attribute readers will convert any
  # assigned attribute value to the declared type. If the assigned value
  # cannot be cast, nil will be returned instead. You can access the original
  # assigned value using the before_type_cast methods.
  #
  # See {Typecasting} for the currently supported types.
  #
  # @example Usage
  #   class Person
  #     include ActiveAttr::TypecastedAttributes
  #     attribute :age, :type => Integer
  #   end
  #
  #   person = Person.new
  #   person.age = "29"
  #   person.age #=> 29
  #   person.age_before_type_cast #=> "29"
  #
  # @since 0.5.0
  module TypecastedAttributes
    extend ActiveSupport::Concern
    include Attributes
    include Typecasting

    included do
      attribute_method_suffix "_before_type_cast"
    end

    # Read the raw attribute value
    #
    # @example Reading a raw age value
    #   person.age = "29"
    #   person.attribute_before_type_cast(:age) #=> "29"
    #
    # @param [String, Symbol, #to_s] name Attribute name
    #
    # @return [Object, nil] The attribute value before typecasting
    #
    # @since 0.5.0
    def attribute_before_type_cast(name)
      @attributes ||= {}
      @attributes[name.to_s]
    end

    private

    # Reads the attribute and typecasts the result
    #
    # @since 0.5.0
    def attribute(name)
      value = super
      value = nil if value == '' && _nil_if_blank(name) # RS HACK

      typecast_attribute(_attribute_typecaster(name), value)
    end

    # Calculates an attribute type
    #
    # @private
    # @since 0.5.0
    def _attribute_type(attribute_name)
      self.class._attribute_type(attribute_name)
    end

    # Checks if we should return nil on blank fields
    #
    # @private
    def _nil_if_blank(attribute_name)
      self.class._nil_if_blank(attribute_name)
    end

    # Resolve an attribute typecaster
    #
    # @private
    # @since 0.6.0
    def _attribute_typecaster(attribute_name)
      type = _attribute_type(attribute_name)

      # RS HACK. Some types support options
      options = self.class.attributes[attribute_name][:options]
      self.class.attributes[attribute_name][:typecaster] || typecaster_for(type, options) or raise UnknownTypecasterError, "Unable to cast to type #{type}"
    end

    module ClassMethods
      # Returns the class name plus its attribute names and types
      #
      # @example Inspect the model's definition.
      #   Person.inspect
      #
      # @return [String] Human-readable presentation of the attributes
      #
      # @since 0.5.0
      def inspect
        inspected_attributes = attribute_names.sort.map { |name| "#{name}: #{_attribute_type(name)}" }
        attributes_list = "(#{inspected_attributes.join(", ")})" unless inspected_attributes.empty?
        "#{name}#{attributes_list}"
      end

      # Calculates an attribute type
      #
      # @private
      # @since 0.5.0
      def _attribute_type(attribute_name)
        attributes[attribute_name][:type] || Object
      end

      # policy to determine if we convert blank fields to nil
      #
      # @note RS HACK!
      def _nil_if_blank(attribute_name)
        if !attributes[attribute_name][:nil_if_blank].nil?
          attributes[attribute_name][:nil_if_blank]
        else
          true
        end
      end

    end
  end
end
