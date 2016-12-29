class ApplicationAction

  def self.call(*_)
    new(*_).call
  end

  def t(key, *_)
    if key.start_with?('.')
      key = "actions.#{self.class.name.underscore}#{key}"
    end
    ::Bold::I18n.t key, *_
  end
end
