module Action

  def self.included(base)
    base.class_eval do
      def self.call(*_)
        new(*_).call
      end
    end
  end

end
