module Bold
  module Activity
    module CommentsHelper
      def posting_html(text)
        Bold::Kramdown::to_html(text).html_safe
      end
    end
  end
end
