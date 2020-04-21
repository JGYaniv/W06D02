class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |method_name|

      name = "#{method_name}".to_sym
      inst_name = "@#{method_name}".to_sym
      define_method(name) do
        instance_variable_get(inst_name)
      end

      define_method("#{method_name}=".to_sym) do |value|
        instance_variable_set(inst_name, value)
      end
    end
  end
end
