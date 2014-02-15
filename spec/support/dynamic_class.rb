def dynamic_class(parent, name = 'Klass')
  random_string = SecureRandom.base64(4).tr('+/=lIO0', 'pqrsxyz')

  Class.new(parent).tap { |k| Object.const_set("#{name}#{random_string}", k) }
end
