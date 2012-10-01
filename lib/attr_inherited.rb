require "attr_inherited/version"
require 'active_record'

module AttrInherited
  def self.included(base) #:nodoc:
    base.extend(AttrInheritedMacro)
  end

  module AttrInheritedMacro

    def attr_inherited(*attrs)
      if attrs.last.is_a? Hash
        options = attrs.pop
      end

      _parent = options[:from] || 'parent'
      _predicate = options[:when] && options[:when].to_s || 'nil?'

      raise ArgumentError.new("Can't specify :as for multiple attributes in a single line") if attrs.size > 1 && options[:as].present?

      attrs.each do |attr|
        _alias = options[:as] || attr

        class_eval <<-END, __FILE__, __LINE__

        def #{_alias}_before_type_cast
          _super = super
          !_super.#{_predicate} && super || #{_parent} && #{_parent}.#{attr}_before_type_cast
        end

        def #{_alias}
          _super = super
          !_super.#{_predicate} && _super || #{_parent} && #{_parent}.#{attr} && !#{_parent}.#{attr}.#{_predicate} && #{_parent}.#{attr} || _super
        end

        def #{_alias}=(value)
          super(value) if #{_parent}.nil? || #{_parent}.#{attr}.#{_predicate} || (#{_parent} && #{_parent}.#{attr} && #{_parent}.#{attr} != value)
        end

        def #{_alias}_inherited?
          #{_parent}.#{attr} == self.#{attr}
        end

        END
      end
    end
  end

end

ActiveRecord::Base.send(:include, AttrInherited) 
